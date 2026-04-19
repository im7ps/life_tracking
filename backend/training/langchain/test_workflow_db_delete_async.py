import os
import sys
import asyncio
from dotenv import load_dotenv

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# --- CONFIGURAZIONE AMBIENTE (Indispensabile per far girare il file) ---
current_dir = os.path.dirname(os.path.abspath(__file__))
backend_root = os.path.dirname(current_dir)
project_root = os.path.dirname(backend_root)

for path in [backend_root, project_root]:
    dotenv_path = os.path.join(path, ".env")
    if os.path.exists(dotenv_path):
        load_dotenv(dotenv_path, override=True)
        print(f"DEBUG ENV: .env caricato da {path}")
        break

if not os.getenv("DATABASE_URL"):
    user = os.getenv("POSTGRES_USER")
    pw = os.getenv("POSTGRES_PASSWORD")
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    db = os.getenv("POSTGRES_DB")
    if all([user, pw, db]):
        os.environ["DATABASE_URL"] = f"postgresql://{user}:{pw}@{host}:{port}/{db}"

if backend_root not in sys.path:
    sys.path.insert(0, backend_root)
# -----------------------------------------------------------------------

from graph_components.graph import Graph

from app.models.user import User

import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from app.database.session import async_engine

from typing import Hashable

from langchain_core.messages import HumanMessage, AIMessage
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool

from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode, tools_condition

# def build_tools() -> list:
#     return [check_user_existence]

# def build_tool_node() -> ToolNode:
#     tools = build_tools()
#     return ToolNode(tools, handle_tool_errors=True)

async def router(state: Graph, config: RunnableConfig) -> str:
    messages = state.get("messages", [])
    if messages:
        last_msg = messages[-1]
        if "ADDIO" in last_msg.content:
            print("DEBUG ROUTER: 'ADDIO' rilevato nel messaggio. Routing verso 'delete_account'.")
            return "delete_account"
    return "__end__"
        

async def handle_delete_account(state: Graph, config: RunnableConfig) -> dict:
    user_id = config.get("configurable", {}).get("user_id")
    if user_id:
        async with AsyncSession(async_engine) as session:
            query = select(User).where(User.id == user_id)
            result = await session.execute(query)
            user = result.scalar_one_or_none()
            if user:
                await session.delete(user)
                await session.commit()
                print(f"DEBUG NODO: Account con ID {user_id} cancellato.")
                return {"messages": [AIMessage(content=f"Account con ID {user_id} cancellato con successo.")]}
    
    print(f"DEBUG NODO: Impossibile cancellare l'account. ID {user_id} non trovato.")
    return {"messages": [AIMessage(content=f"Impossibile cancellare l'account. ID {user_id} non trovato.")]}
    

def build_workflow(router):
    my_map: dict[Hashable, str] = {
        "delete_account": "delete_account_node",
        "__end__": END
    }
    workflow = StateGraph(Graph)
    workflow.add_node("delete_account_node", handle_delete_account)
    workflow.add_conditional_edges(START, router, my_map)
    workflow.add_edge("delete_account_node", END)
    return workflow

async def test():
    USER_ID_TEST = "97cc7ddd-c075-494e-bea4-a3c25415f3e3"
    print("DEBUG TEST: Avvio del test asincrono...")
    workflow = build_workflow(router=router)
    print("DEBUG TEST: Workflow costruito. Compilazione in corso...")
    app = workflow.compile()
    print("DEBUG TEST: Workflow compilato. Invocazione in corso...")
    config: RunnableConfig = {
        "configurable": {
            "user_id": USER_ID_TEST,
        }
    }
    inputs: Graph = {
        "messages": [HumanMessage(content="ADDIO, voglio cancellare il mio account!")],
        }
    result = await app.ainvoke(inputs, config=config)
    print("DEBUG TEST: Invocazione completata. Risultato ottenuto.")
    print(result)

if __name__ == "__main__":
    asyncio.run(test())