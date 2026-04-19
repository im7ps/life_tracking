import os
import sys
import asyncio
from dotenv import load_dotenv
from langgraph.graph import StateGraph


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

from langchain_core.messages import HumanMessage
from components.invoke_model import invoke_model
from components.graph import Graph
from langchain_core.runnables import RunnableConfig
from components.persistent_memory import get_db_memory


def build_workflow():
    from langgraph.graph import StateGraph, START, END
    workflow = StateGraph(Graph)
    workflow.add_node("agent", invoke_model)
    workflow.add_edge(START, "agent")
    workflow.add_edge("agent", END)

    return workflow

async def main():
    checkpointer, pool = await get_db_memory()
    app = build_workflow().compile(checkpointer=checkpointer)
    
    input: Graph = {
        "messages": [HumanMessage(content="Qual è il codice della cassaforte")],
    }
    
    config: RunnableConfig = {
        "configurable": {
            "user_id": "1",
            "thread_id": "1",
        }
    }
    
    result = await app.ainvoke(input=input, config=config)
    pool.close()
    
    for msg in result["messages"]:
        print(f"{msg.type}: {msg.content}")

if __name__ == "__main__":
    asyncio.run(main())