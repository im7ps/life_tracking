import structlog
from typing import Annotated, Literal, TypedDict, cast

from langgraph.graph.message import add_messages
from langgraph.graph import StateGraph, START, END

from langchain_core.messages import BaseMessage, SystemMessage, HumanMessage
from langchain_core.runnables import RunnableConfig

from app.schemas.ai_onboarding import UserOnboardingData
from app.core.llm.components.llm import fetch_llm

logger = structlog.get_logger()

class Graph(TypedDict, total=False):
    messages: Annotated[list[BaseMessage], add_messages]
    onboarding_data: UserOnboardingData
    error_state: str | None
    is_updated: bool


async def error_handling_node(state: Graph):
    error_type = state.get("error")
    logger.error("graph_error_triggered", error_type=error_type)

    if error_type == "DATABASE_ERROR":
        system_msg="Si è verificato un errore di database. Chiedi scusa all'utente e informalo che attualmente non possiamo salvare i dati."
    elif error_type == "MODEL_ERROR":
        system_msg="Si è verificato un errore nel modello. Chiedi scusa all'utente e informalo che il modello di ai non è al momento disponibile."
    elif error_type == "DATA_ERROR":
        system_msg="I dati raccolti non sono validi. Chiedi scusa all'utente e chiedigli di fornire nuovamente le informazioni necessarie."
    else:
        system_msg="Si è verificato un errore sconosciuto. Chiedi scusa all'utente."

    llm = fetch_llm()
    # Gemini fix: needs at least one HumanMessage. We add a support message.
    response = await llm.ainvoke([
        SystemMessage(content=system_msg),
        # HumanMessage(content="C'è stato un errore tecnico, per favore scusati.")
    ])
    return {"messages": [response], "error_state": error_type}


async def data_extractor_node(state: Graph, config: RunnableConfig) -> Graph:
    """Cerca di popolare i dati mancanti di onboarding_data"""
    llm = config["configurable"].get("llm", fetch_llm())
    structured_llm = llm.with_structured_output(UserOnboardingData)

    current_data: UserOnboardingData = state.get("onboarding_data") or UserOnboardingData()
    messages = state.get("messages", [])

    if not messages:
        logger.warning("data_extractor_called_with_no_messages")
        return {"onboarding_data": current_data, "is_updated": False}

    prompt = [
        SystemMessage(
            content=(
                f"Dati correnti: {current_data.model_dump()}\n."
                "Estrai nuove info se presenti nei messaggi. Non inventare dati.\n"
            )
        )
    ] + messages

    try:
        response = await structured_llm.ainvoke(prompt)
        new_extracted_data = cast(UserOnboardingData, response)
        
        # Merge logico: i nuovi dati non devono sovrascrivere i vecchi con None
        updated_dict = current_data.model_dump()
        new_data_dict = new_extracted_data.model_dump(exclude_none=True)
        
        has_changes = False
        for key, value in new_data_dict.items():
            if getattr(current_data, key) != value:
                has_changes = True
                break
        
        updated_dict.update(new_data_dict)
        final_data = UserOnboardingData(**updated_dict)
        
        logger.debug("data_extracted_and_merged", 
                    new_info=new_data_dict, 
                    final_state=final_data.model_dump(exclude_none=True))
        
        return {"onboarding_data": final_data, "is_updated": has_changes, "error_state": None}
    except Exception as e:
        # Invece di andare in errore fatale, logghiamo e restituiamo i dati correnti.
        logger.warning("data_extraction_failed", error=str(e), user_input=messages[-1].content)
        return {"onboarding_data": current_data, "is_updated": False, "error_state": "DATA_ERROR"}


async def save_to_db_node(state: Graph, config: RunnableConfig) -> Graph:
    user_id = config.get("configurable", {}).get("user_id", None)
    user_service = config.get("configurable", {}).get("user_service", None)
    onboarding_data = state.get("onboarding_data", None)

    if not all([user_id, user_service, onboarding_data]):
        logger.error(
            "save_to_db_missing_dependencies",
            user_id=bool(user_id),
            service=bool(user_service),
            data=bool(onboarding_data)
            )
        return {"error_state": "DATA_ERROR"}

    try:
        updated_user = await user_service.update_onboarding(user_id, onboarding_data)
        if updated_user:
            logger.info("user_onboarding_saved_success", user_id=user_id)
            return {"is_updated": False, "error_state": None}
    except Exception as e:
        logger.error("database_save_failed", error=str(e))
        return {"error_state": "DATABASE_ERROR"}
    return {}


async def invoke_model_with_data(state: Graph) -> Graph:
    llm = fetch_llm()
    data = state.get("onboarding_data", None)
    messages = state.get("messages", [])
    system_prompt = ""

    personality = (
        "Sei il Consulente Day 0. Accompagna l'utente nella costruzione della sua identità.\n"
        "Sii curioso, empatico e accogliente. Fai una sola domanda alla volta.\n"
        "Obiettivo: Capire chi è l'utente oggi. Usa un linguaggio naturale, molto sintetico.\n"
        "Se sai il nome dell'utente, usalo per creare confidenza. Se hai abbastanza dati, proponi di creare la prima task insieme."
    )

    if not data:
        logger.error("invoke_model_missing_onboarding_data")
        return {"error_state": "DATA_ERROR"}

    system_prompt = (
                        f"{personality}\n"
                        f"Dati raccolti: {data.model_dump(exclude_none=True)}."
                )
    if not data.is_complete:
        system_prompt += (
            f"Campi ancora necessari: {', '.join(data.missing_fields)}\n"
            f"Scegli un campo mancante e chiedi info all'utente."
        )
    else:
        system_prompt += f"Onboarding completo! Presenta un riepilogo e proponi di creare la prima task."

    # Gemini fix: assicuriamoci che ci sia sempre un HumanMessage
    prompt = [SystemMessage(content=system_prompt)]
    if not messages:
        # Questo caso è gestito dal router, ma aggiungiamo un fallback di sicurezza
        prompt.append(HumanMessage(content="Inizia sessione"))
    else:
        prompt.extend(messages)

    try:
        response = await llm.ainvoke(prompt)
        return {"messages": [response]}
    except Exception as e:
        logger.error("invoke_model_failed", error=str(e))
        return {"error_state": "MODEL_ERROR"}


def error_router(state: Graph) -> Literal["error_node", "continue"]:
    error = state.get("error_state", None)
    if error:
        return "error_node"
    return "continue"


def post_extraction_router(state: Graph) -> Literal["error_node", "saver", "agent"]:
    if state.get("error_state", None):
        return "error_node"
    if state.get("is_updated", False):
        return "saver"
    return "agent"


def onboarding_router(state: Graph) -> Literal["data_extractor", "agent"]:
    onboarding_data = state.get("onboarding_data", None)
    messages = state.get("messages", [])

    if not messages or len(messages) <= 1:
        return "agent"

    if onboarding_data and not onboarding_data.is_complete:
        return "data_extractor"
    return "agent"


def build_workflow() -> StateGraph:

    workflow = StateGraph(Graph)

    workflow.add_node("agent", invoke_model_with_data)
    workflow.add_node("saver", save_to_db_node)
    workflow.add_node("data_extractor", data_extractor_node)
    workflow.add_node("error_node", error_handling_node)

    workflow.add_conditional_edges(START, onboarding_router,
            {"data_extractor": "data_extractor", "agent": "agent"}
        )
    workflow.add_conditional_edges("data_extractor", post_extraction_router, 
            {"error_node": "error_node", "saver": "saver", "agent": "agent"}
        )
    workflow.add_conditional_edges("saver", error_router, 
            {"error_node": "error_node", "continue": "agent"}
        )
    workflow.add_edge("error_node", END)
    workflow.add_edge("agent", END)

    return workflow


def compile_graph(checkpointer=None):
    return build_workflow().compile(checkpointer=checkpointer)

