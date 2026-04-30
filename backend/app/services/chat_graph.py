
import uuid
import structlog
from typing import Annotated, Literal, TypedDict, cast

from langchain_core.messages import BaseMessage, SystemMessage, HumanMessage
from langgraph.graph.message import add_messages
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode

from app.repositories.user_repo import UserRepo
from app.schemas.ai_onboarding import UserOnboardingData
from app.core.llm.components.llm import fetch_llm_with_tools, fetch_llm
from app.core.llm.components.invoke_model import invoke_model, invoke_model_with_tools

from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import async_engine
from app.schemas.user import UserUpdateDB

logger = structlog.get_logger()

class Graph(TypedDict, total=False):
    messages: Annotated[list[BaseMessage], add_messages]
    user_id: uuid.UUID
    onboarding_data: UserOnboardingData
    error: str | None


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
        HumanMessage(content="C'è stato un errore tecnico, per favore scusati.")
    ])
    return {"messages": [response], "error": None}


async def data_extractor_node(state: Graph) -> Graph:
    llm = fetch_llm().with_structured_output(UserOnboardingData)

    current_data: UserOnboardingData = state.get("onboarding_data") or UserOnboardingData()
    messages = state.get("messages", [])

    if not messages:
        logger.warning("data_extractor_called_with_no_messages")
        return {"onboarding_data": current_data}

    prompt = [
        SystemMessage(content=f"Dati correnti: {current_data.model_dump()}. Estrai nuove info se presenti.")
    ] + messages

    try:
        response = await llm.ainvoke(prompt)
        new_data = cast(UserOnboardingData, response)
        logger.debug("data_extracted", data=new_data.model_dump())
        return {"onboarding_data": new_data}
    except Exception as e:
        # Invece di andare in errore fatale, logghiamo e restituiamo i dati correnti.
        # Questo evita il crash di Gemini se l'input non è informativo.
        logger.warning("data_extraction_failed", error=str(e), user_input=messages[-1].content)
        return {"onboarding_data": current_data}


async def save_to_db_node(state: Graph) -> Graph:
    user_id = state.get("user_id", None)
    data = state.get("onboarding_data", None)

    if user_id is None or data is None:
        logger.error("save_to_db_missing_data", user_id=user_id, data_exists=data is not None)
        return {"error": "DATA_ERROR"}

    try:
        async with AsyncSession(async_engine) as session:
            repo = UserRepo(session)
            db_user = await repo.get(user_id)
            if db_user:
                new_timezone = data.timezone or getattr(db_user, 'timezone', 'UTC')
                update_dto = UserUpdateDB(
                    bio=data.model_dump(),
                    onboarding_completed=data.is_complete,
                    timezone=new_timezone,
                )
                await repo.update(db_user, update_dto)
                await session.commit()
                logger.info("user_onboarding_saved", user_id=user_id, complete=data.is_complete)
    except Exception as e:
        logger.error("database_save_failed", error=str(e))
        return {"error": "DATABASE_ERROR"}
    return {}


async def invoke_model_with_data(state: Graph) -> Graph:
    llm = fetch_llm()
    data = state.get("onboarding_data", None)
    messages = state.get("messages", [])

    personality = (
        "Sei il Consulente Day 0. Accompagna l'utente nella costruzione della sua identità.\n"
        "Sii curioso, empatico e accogliente. Fai una sola domanda alla volta.\n"
        "Obiettivo: Capire chi è l'utente oggi. Usa un linguaggio naturale, non robotico.\n"
    )

    if not data:
        logger.error("invoke_model_missing_onboarding_data")
        return {"error": "DATA_ERROR"}

    if not data.is_complete:
        system_prompt = f"{personality}\nDati raccolti: {data.model_dump(exclude_none=True)}. Chiedi con garbo cosa manca."
    else:
        system_prompt = f"{personality}\nOnboarding completo! Presenta un riepilogo e proponi di creare la prima task."

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
        return {"error": "MODEL_ERROR"}


def error_router(state: Graph) -> Literal["error_node", "continue"]:
    error = state.get("error", None)
    if error:
        return "error_node"
    return "continue"


def onboarding_router(state: Graph) -> Literal["data_extractor", "agent"]:
    onboarding_data = state.get("onboarding_data", None)
    messages = state.get("messages", [])

    # Se non ci sono messaggi, vai dritto all'agente.
    if not messages:
        return "agent"

    # Analizziamo l'ultimo messaggio per decidere se tentare l'estrazione.
    last_msg = messages[-1].content.strip().lower()

    # Lista di parole chiave di innesco o saluti che non contengono dati utili da estrarre.
    # Se il messaggio è un saluto o è troppo corto, saltiamo l'estrattore per evitare errori di Gemini.
    skip_extraction_triggers = ["inizia sessione", "ciao", "ehi", "hey", "buongiorno", "buonasera"]

    if last_msg in skip_extraction_triggers or len(last_msg) < 3:
        logger.debug("onboarding_router_skipping_extraction", reason="greeting_or_short_msg")
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
    workflow.add_conditional_edges("data_extractor", error_router, 
            {"error_node": "error_node", "continue": "saver"}
        )
    workflow.add_conditional_edges("saver", error_router, 
            {"error_node": "error_node", "continue": "agent"}
        )
    workflow.add_edge("error_node", END)
    workflow.add_edge("agent", END)

    return workflow

def compile_graph(checkpointer=None):
    return build_workflow().compile(checkpointer=checkpointer)

