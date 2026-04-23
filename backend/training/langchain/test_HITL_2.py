import os
import select
import sys
import asyncio
from typing import Hashable
from dotenv import load_dotenv

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

os.environ["GRPC_VERBOSITY"] = "ERROR"

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

from app.models.user import User
from components.graph import Graph
from langgraph.graph import StateGraph, START, END
from langchain_core.tools import tool
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage
from langchain_core.runnables import RunnableConfig

import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from app.database.session import async_engine

from components.persistent_memory import get_db_memory
from components.invoke_model import invoke_model_with_tools

@tool(extras={"type": "get"})
async def get_user_stats(config: RunnableConfig) -> dict:
    "Recupera statistiche utente db"
    configurable = config.get("configurable", {})
    user_id = configurable.get("user_id")
    
    if user_id:
        async with AsyncSession(async_engine) as session:
            query = select(User).where(User.id == user_id)
            result = await session.execute(query)
            user = result.scalar_one_or_none()
            if user:
                return {
                    "username": user.username,
                    "rank": user.rank_score,
                }
            else:
                return {"error": "Utente non trovato"}
    return {"error": "Utente non trovato o user_id mancante"}


@tool(extras={"type": "update"})
async def reset_user_rank(config: RunnableConfig) -> dict:
    "Azzera rank utente db"
    configurable = config.get("configurable", {})
    user_id = configurable.get("user_id")
    
    if user_id:
        async with AsyncSession(async_engine) as session:
            query = select(User).where(User.id == user_id)
            result = await session.execute(query)
            user = result.scalar_one_or_none()
            
            if user:
                username = user.username
                user.rank_score = 0
                rank_score = user.rank_score
                session.add(user)
                await session.commit()
                return {
                    "username": username,
                    "rank": rank_score,
                }
            else:
                return {"error": "Utente non trovato"}
    return {"error": "Errore durante il reset del rank"} 


@tool(extras={"type": "update"})
async def update_user_rank(config: RunnableConfig, new_rank: int) -> dict:
    "Aggiorna il rank utente db"
    configurable = config.get("configurable", {})
    user_id = configurable.get("user_id")
    
    if user_id:
        async with AsyncSession(async_engine) as session:
            query = select(User).where(User.id == user_id)
            result = await session.execute(query)
            user = result.scalar_one_or_none()
            
            if user:
                username = user.username
                user.rank_score = new_rank
                session.add(user)
                await session.commit()
                return {
                    "username": username,
                    "rank": new_rank,
                }
            else:
                return {"error": "Utente non trovato"}
    return {"error": "Errore durante l'aggiornamento del rank"}


tool_registry = {
    "get_user_stats": get_user_stats,
    "reset_user_rank": reset_user_rank,
    "update_user_rank": update_user_rank,
}


def router(state: Graph) -> list[str]:
    tool_map = []
    messages = state.get("messages", [])
    if messages:
        last_msg = messages[-1]
        if last_msg and isinstance(last_msg, AIMessage) and last_msg.tool_calls:
            tool_list = last_msg.tool_calls
            for tool in tool_list:
                tool_name = tool['name']
                real_tool = tool_registry.get(tool_name)
                if real_tool and getattr(real_tool, "extras", {}).get("type") == "update":
                    return ["ex_" + tool_list[0]['name']]
                tool_map.append("ex_" + tool['name'])
            return list(set(tool_map))
    return [END]

    
    


async def ex_get_user_stats(state: Graph, config: RunnableConfig) -> Graph:
    messages = state.get("messages", [])
    if messages:
        last_msg = messages[-1]
        if last_msg and isinstance(last_msg, AIMessage) and last_msg.tool_calls:
            tool = next((tc for tc in last_msg.tool_calls if tc['name'] == 'get_user_stats'), None)
            if tool:
                user_stats = await get_user_stats.ainvoke(input=tool["args"], config=config)
                user_rank = user_stats.get("rank", "N/A")
                user_name = user_stats.get("username", "N/A")
                return {
                    "messages": 
                        [
                            ToolMessage(
                                content=f"Nome utente: {user_name}, Rank attuale: {user_rank}",
                                tool_call_id=tool["id"]
                            )
                        ],
                    "score": user_rank
                }
            else:
                return {
                    "messages": [AIMessage(content="Errore: get_user_stats tool call non trovato nei messaggi.")]
                }
        return {
            "messages": [AIMessage(content="Errore: Ultimo messaggio non contiene tool calls o non è un AIMessage.")]
        }
    return {
        "messages": [AIMessage(content="Errore: Nessun messaggio trovato nello stato.")]
    }


async def ex_reset_user_rank(state: Graph, config: RunnableConfig) -> Graph:
    messages = state.get("messages", [])
    if messages:
        last_msg = messages[-1]
        if last_msg and isinstance(last_msg, AIMessage) and last_msg.tool_calls:
            tool = next((tc for tc in last_msg.tool_calls if tc['name'] == 'reset_user_rank'), None)
            if tool:
                result = await reset_user_rank.ainvoke(input=tool["args"], config=config)
                if "error" in result:
                    return {
                        "messages": [AIMessage(content=f"Errore durante il reset del rank: {result['error']}")]
                    }
                user_rank = result.get("rank", "N/A")
                user_name = result.get("username", "N/A")
                return {
                    "messages":
                        [
                            ToolMessage(
                                content=f"Rank dell'utente {user_name} azzerato, rank attuale: {user_rank}",
                                tool_call_id=tool["id"]
                            )
                        ],
                    "score": user_rank
                }
            else:
                return {
                    "messages": [AIMessage(content="Errore: reset_user_rank tool call non trovato nei messaggi.")]
                }
        else:
            return {
                "messages": [AIMessage(content="Errore: Ultimo messaggio non contiene tool calls o non è un AIMessage.")]
            }
    else:
        return {
            "messages": [AIMessage(content="Errore: Nessun messaggio trovato nello stato.")]
        }


async def ex_update_user_rank(state: Graph, config: RunnableConfig) -> Graph:
    messages = state.get("messages", [])
    if messages:
        last = messages[-1]
        if last and isinstance(last, AIMessage) and last.tool_calls:
            tool = next((tc for tc in last.tool_calls if tc['name'] == 'update_user_rank'), None)
            if tool:
                result = await update_user_rank.ainvoke(input=tool["args"], config=config)
                if "error" in result:
                    return {
                        "messages": [AIMessage(content=f"Errore durante l'aggiornamento del rank: {result['error']}")]
                    }
                user_name = result.get("username", "N/A")
                user_rank = result.get("rank", "N/A")
                user_new_rank = result.get("new_rank", "N/A")
                return {
                    "messages":
                        [
                            ToolMessage(
                                content=f"Rank dell'utente {user_name} aggiornato, rank attuale: {user_rank}",
                                tool_call_id=tool["id"]
                            )
                        ],
                    "score": user_new_rank,
                }
            else:
                return {
                    "messages": [AIMessage(content="Errore: update_user_rank tool call non trovato nei messaggi.")]
                }
        else:
            return {
                "messages": [AIMessage(content="Errore: Ultimo messaggio non contiene tool calls o non è un AIMessage.")]
            }
    else:
        return {
            "messages": [AIMessage(content="Errore: Nessun messaggio trovato nello stato.")]
        }


async def agent_node(state: Graph):
    return await invoke_model_with_tools(state, [update_user_rank, reset_user_rank, get_user_stats])


def build_workflow():
    my_map: dict[Hashable, str] = {
        "ex_get_user_stats": "node_get_user_stats",
        "ex_reset_user_rank": "node_reset_user_rank",
        "ex_update_user_rank": "node_update_user_rank",
        END: END
    }
    
    workflow = StateGraph(Graph)
    
    workflow.add_node("agent", agent_node)
    workflow.add_node("node_get_user_stats", ex_get_user_stats)
    workflow.add_node("node_reset_user_rank", ex_reset_user_rank)
    workflow.add_node("node_update_user_rank", ex_update_user_rank)
    
    workflow.add_edge(START, "agent")
    workflow.add_conditional_edges("agent", router, my_map)
    workflow.add_edge("node_get_user_stats", "agent")
    workflow.add_edge("node_reset_user_rank", "agent")
    workflow.add_edge("node_update_user_rank", "agent")
    # workflow.add_edge("agent", END)
    return workflow


async def main():
    checkpointer, pool = await get_db_memory()
    workflow = build_workflow()
    app = workflow.compile(checkpointer=checkpointer, interrupt_before=["node_reset_user_rank"])
    
    app_input: Graph = {
        "messages": [
            HumanMessage(content="dammi una panoramica delle statistiche e poi porta il mio rank a 15 poi azzera il mio rank e ridammi le statistiche. Poi dimmi quanto fa 5+5"),
            ]
        }
    
    config: RunnableConfig = {
        "configurable": {
            "user_id": "b773ddaf-a1cc-4bd8-b848-9a2bbefb56af",
            "thread_id": "1",
        }
    }
    
    result = await app.ainvoke(app_input, config=config)
    
    snapshot = await app.aget_state(config)
    if snapshot.next:
        choice = input("L'agente vuole azzerare il tuo rank, confermi? (s/n): ")
        if choice.lower() == 's':
            result = await app.ainvoke(None, config=config)
        else:
            app.update_state(config, 
                {
                    "messages":
                        [AIMessage(content="Azione annullata dall'utente.")],
                },
                as_node="agent"
            )
            print("Azione annullata dall'utente.")


    # app_input["messages"] = [
    #         HumanMessage(content="Aumenta il mio rank a 5 e poi dimmi il mio rank attuale"),
    #     ]
    
    # result = await app.ainvoke(app_input, config=config)
    # print(f"Rank attuale: {result.get('rank')}")
    for msg in result.get("messages", []):
        user = ""
        if isinstance(msg, ToolMessage):
            user = "TOOL"
        elif isinstance(msg, AIMessage):
            user = "AI"
        elif isinstance(msg, HumanMessage):
            user = "HUMAN"
        if isinstance(msg, AIMessage) and msg.tool_calls:
            continue
        print(f"MESSAGGIO: {user}: {msg.content}\n")

    print("FINITO")
    await pool.close()

if __name__ == "__main__":
    asyncio.run(main())