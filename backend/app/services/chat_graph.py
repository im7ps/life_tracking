
import uuid
from typing import Annotated, Literal, TypedDict, cast

from langchain_core.messages import BaseMessage, SystemMessage
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

class Graph(TypedDict, total=False):
    messages: Annotated[list[BaseMessage], add_messages]
    user_id: uuid.UUID
    onboarding_data: UserOnboardingData
    error: str | None


async def error_handling_node(state: Graph):
    error_type = state.get("error")
    if error_type == "DATABASE_ERROR":
        system_msg="Si è verificato un errore di database. Chiedi scusa all'utente e informalo che attualmente non possiamo salvare i dati."
    elif error_type == "MODEL_ERROR":
        system_msg="Si è verificato un errore nel modello. Chiedi scusa all'utente e informalo che il modello di ai non è al momento disponibile."
    elif error_type:
        system_msg="Si è verificato un errore sconosciuto. Chiedi scusa all'utente."
    elif error_type == "DATA_ERROR":
        system_msg="I dati raccolti non sono validi. Chiedi scusa all'utente e chiedigli di fornire nuovamente le informazioni necessarie."

    llm = fetch_llm()
    response = await llm.ainvoke([SystemMessage(content=system_msg)])
    return {"messages": [response], "error": None}


async def data_extractor_node(state: Graph) -> Graph:
    llm = fetch_llm().with_structured_output(UserOnboardingData)
    
    # if onboarding_data is missing we create a brand new one
    current_data: UserOnboardingData = state.get("onboarding_data") or UserOnboardingData()
    messages = state.get("messages", [])
    if current_data:
        prompt = [
            SystemMessage(content=
                        f"Dati correnti: {current_data.model_dump()}. Aggiornali se trovi nuove info.")
        ] + messages
    else:
        return {"error": "DATA_ERROR"}

    try:
        response = await llm.ainvoke(prompt)
        new_data = cast(UserOnboardingData, response)
    except Exception as e:
        return {"error": "MODEL_ERROR"}
    return {"onboarding_data": new_data}

async def save_to_db_node(state: Graph) -> Graph:
    user_id = state.get("user_id", None)
    data = state.get("onboarding_data", None)
    
    if user_id is None or data is None:
        return {"error": "DATA_ERROR"}
    else:
        try:
            async with AsyncSession(async_engine) as session:
                repo = UserRepo(session)
                db_user = await repo.get(user_id)
                if db_user:
                    update_dto = UserUpdateDB(
                        bio=data.model_dump(),
                        onboarding_completed=data.is_complete
                    )
                    await repo.update(db_user, update_dto)
                    await session.commit()
        except Exception as e:
            # logger.error("db_failure", error=str(e))
            return {"error": "DATABASE_ERROR"}
    return {}


async def invoke_model_with_data(state: Graph) -> Graph:
    llm = fetch_llm()
    data = state.get("onboarding_data", None)

    system_prompt = ""
    if data:
        if not data.is_complete:
            system_prompt = "Ci servono i dati iniziali dell'utente, guarda onboarding_data e vedi cosa manca, se manca qualcosa fai una domanda all'utente."
        else:
            system_prompt = "L'onboarding_data è pieno, dai all'utente un resoconto e chiedi se puoi aiutarlo a creare questa prima task"
    else:
        return {"error": "DATA_ERROR"}

    try:
        response = await llm.ainvoke(
                [SystemMessage(content=system_prompt)] +
                state.get("messages", [])
            )
    except Exception as e:
        return {"error": "MODEL_ERROR"}
    return {"messages": [response]}


def error_router(state: Graph) -> Literal["error_node", "continue"]:
    error = state.get("error", None)
    if error:
        return "error_node"
    return "continue"


def build_workflow() -> StateGraph:
    workflow = StateGraph(Graph)
    
    workflow.add_node("agent", invoke_model_with_data)
    workflow.add_node("saver", save_to_db_node)
    workflow.add_node("data_extractor", data_extractor_node)
    workflow.add_node("error_node", error_handling_node)

    workflow.add_edge(START, "data_extractor")
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
    """Compila il workflow in un grafo eseguibile con memoria."""
    return build_workflow().compile(checkpointer=checkpointer)
