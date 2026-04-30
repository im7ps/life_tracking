import os
import sys
import asyncio
from dotenv import load_dotenv

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# --- CONFIGURAZIONE AMBIENTE (Indispensabile per far girare il file) ---
current_dir = os.path.dirname(os.path.abspath(__file__))
# Risaliamo: langchain -> training -> backend
backend_root = os.path.dirname(os.path.dirname(current_dir))

dotenv_path = os.path.join(backend_root, ".env")
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path, override=True)
    print(f"DEBUG ENV: .env caricato da {backend_root}")

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

from app.core.llm.components.graph import Graph
from app.core.llm.components.invoke_model import invoke_model

from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.memory import MemorySaver

from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig

async def compile_workflow():
    checkpointer = MemorySaver()
    workflow = StateGraph(Graph)

    workflow.add_node("agent", invoke_model)
    workflow.add_edge(START, "agent")
    workflow.add_edge("agent", END)
    
    return workflow.compile(checkpointer=checkpointer)

async def main():
    app = await compile_workflow()
    
    config: RunnableConfig = {
        "configurable": {
            "thread_id": "thread_1"
        }
    }
    
    input: Graph = {
        "messages": [HumanMessage(content="Ciao, mi chiamo Mario")]
    }
    await app.ainvoke(input=input, config=config)
    
    input: Graph = {
        "messages": [HumanMessage(content="Qual è il mio nome?")]
    }
    result = await app.ainvoke(input=input, config=config)
    
    for msg in result["messages"]:
        print(f"{type(msg).__name__}: {msg.content}")
    
if __name__ == "__main__":
    asyncio.run(main())

