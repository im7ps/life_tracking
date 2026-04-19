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

from langchain_core.messages import HumanMessage
from langchain_core.runnables import RunnableConfig
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import tools_condition


from backend.training.langchain.components.graph import Graph
from backend.training.langchain.components.tools_builder import build_tool_node
from backend.training.langchain.components.invoke_model import invoke_model
from backend.training.langchain.components.tools import get_user_rank_db

def build_workflow() -> StateGraph:
    tool_list = [get_user_rank_db]
    tool_node = build_tool_node(tool_list=tool_list)
    
    workflow = StateGraph(Graph)
    workflow.add_node("agent", invoke_model)
    workflow.add_node("tools", tool_node)
    workflow.add_edge(START, "agent")

    workflow.add_conditional_edges("agent", tools_condition)
    workflow.add_edge("tools", "agent")
    
    return workflow


async def test():
    workflow = build_workflow()
    app = workflow.compile()
    USER_ID_REALE = "97cc7ddd-c075-494e-bea4-a3c25415f3e3" 

    inputs: Graph = {
        "messages": [HumanMessage(content="Qual è il mio rank score?")],
        "category": "initial_category",
    }
    config: RunnableConfig = {
        "configurable": {"user_id": USER_ID_REALE}
        }
    result = await app.ainvoke(inputs, config=config)
    print("RESULT:", result)

if __name__ == "__main__":
    asyncio.run(test())
