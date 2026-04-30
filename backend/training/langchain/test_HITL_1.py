import os
import sys
import asyncio
from typing import Hashable
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
        # print(f"DEBUG ENV: .env caricato da {path}")
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

from app.core.llm.components.graph import Graph
from app.core.llm.components.persistent_memory import get_db_memory
from app.core.llm.components.invoke_model import invoke_model_with_tools, invoke_model
from app.core.llm.components.tools_builder import build_tool_node

from langchain_core.messages import AIMessage, HumanMessage, ToolMessage
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool

@tool
def delete_score_tool() -> str:
    """Usa questo tool SOLO quando l'utente vuole azzerare il suo score."""
    return ""

@tool
def wrong_tool() -> str:
    """Questo tool non deve essere usato in questo contesto."""
    return ""


def handle_delete_score(state: Graph) -> Graph:
    messages = state.get("messages", [])
    if messages:
        last_message = messages[-1]
        if isinstance(last_message, AIMessage) and last_message.tool_calls:
            tool_calls = last_message.tool_calls
            tool_call_id = None
            for tc in tool_calls:
                if tc['name'] == 'delete_score_tool':
                    tool_call_id = tc['id']
                    break
            if not tool_call_id:
                raise ValueError("Nodo delete_score raggiunto ma nessuna tool_call di delete_score_tool trovata.")
    return {
            "messages": [
                ToolMessage(
                    content="Lo score è stato azzerato con successo.",
                    tool_call_id=tool_call_id
                    )
                ],
            "score": 0
        }

def handle_wrong_tool(state: Graph) -> Graph:
    return {
            "messages": [AIMessage(content="Miao")],
        }


async def agent_node(state: Graph):
    return await invoke_model_with_tools(state, [delete_score_tool])

def router(state: Graph) -> str:
    msg =  state.get("messages", [])
    if msg and isinstance(msg[-1], AIMessage):
        tool_calls_list = msg[-1].tool_calls
        if tool_calls_list:
            if any(tc['name'] == 'delete_score_tool' for tc in tool_calls_list):
                return "delete_score"
            elif any(tc['name'] == 'wrong_tool' for tc in tool_calls_list):
                return "wrong_tool"
    return "alredy_deleted"

def build_workflow():
    from langgraph.graph import StateGraph, START, END
    
    my_map: dict[Hashable, str] = {
        "delete_score": "delete_score_node",
        "wrong_tool": "wrong_tool_node",
        "alredy_deleted": "__end__"
    }
    
    # delete_score_node = build_tool_node(tool_list=[delete_score_tool])

    workflow = StateGraph(Graph)
    
    workflow.add_node("agent", agent_node)
    workflow.add_node("delete_score_node", handle_delete_score)
    workflow.add_node("wrong_tool_node", handle_wrong_tool)
    workflow.add_edge(START, "agent")
    workflow.add_conditional_edges("agent", router, my_map)
    workflow.add_edge("delete_score_node", "agent")
    
    return workflow


async def main():
    checkpointer, pool = await get_db_memory()
    workflow = build_workflow()
    app = workflow.compile(checkpointer=checkpointer, interrupt_before=["delete_score_node"])

    app_input: Graph = {
        "messages": [HumanMessage(content="Azzera lo score dell'utente")],
        "score": 10
    }
    
    config: RunnableConfig = {
        "configurable": {
            "thread_id": "5"
        }
    }
    
    await app.ainvoke(input=app_input, config=config)

    snapshot = await app.aget_state(config)
    # print("\n--- STATO DEL GRAFO ---")
    # print(f"Score attuale: {snapshot.values.get('score')}")
    # print(f"Nodi successivi in coda: {snapshot.next}")
    # print(f"Messaggi attuali: {len(snapshot.values['messages'])}")
    
    if snapshot.next:
        choice = input("L'agente vuole azzerare lo score. Confermi? (s/n): ")
        if choice.lower() == "s":
            await app.ainvoke(None, config)
            # final_snapshot = await app.aget_state(config)
            # print(f"Score finale nel Grafo: {final_snapshot.values.get('score')}")
        else:
            # final_snapshot = await app.aget_state(config)
            # print(f"Score finale nel Grafo: {final_snapshot.values.get('score')}")
            print("Operazione annullata dall'utente.")
    
    snapshot = await app.aget_state(config)

    print("\n--- CRONOLOGIA MESSAGGI ---")
    for msg in snapshot.values.get("messages", []):
        print(f"[{msg.type.upper()}]: {msg}")

    await pool.close()


if __name__ == "__main__":
    asyncio.run(main())