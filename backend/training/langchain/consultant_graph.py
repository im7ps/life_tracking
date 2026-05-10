import asyncio
import operator
from typing import Annotated, TypedDict

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, START, StateGraph

class GraphState(TypedDict):
    messages: Annotated[list, operator.add]
    user_choice: str

# --- LOGICA DEI NODI ---

def propose_node(state: GraphState):
    print("\n[NODE] Proposta: Sto proponendo all'utente di resettare il rank...")
    return {
        "messages": ["Vuoi ricominciare da zero? (sì/no)"], 
    }
    
def HITL_node(state: GraphState):
    print("\n[NODE] Ricevuto feedback dall'utente.")
    return {}


def execute_node(state: GraphState):
    print("\n[NODE] Esecuzione del reset nel database...")
    return {
        "messages": ["Rank resettato con successo nel database!"], 
    }

# --- ROUTER ---

def router(state: GraphState):
    if state.get("user_choice", "").lower() == "sì":
        return "execute"
    return END

# --- COSTRUZIONE DEL GRAFO ---

workflow = StateGraph(GraphState)
workflow.add_node("propose", propose_node)
workflow.add_node("HITL", HITL_node)
workflow.add_node("execute", execute_node)

workflow.add_edge(START, "propose")
workflow.add_edge("propose", "HITL")
workflow.add_conditional_edges("HITL", router, {"execute": "execute", END: END})
workflow.add_edge("execute", END)

app = workflow.compile(
    checkpointer=MemorySaver(),
    interrupt_after=["HITL"],
)

async def main():
    config = {
        "configurable":
            {
                "thread_id": "1",
            }
    }
    
    await app.ainvoke({"messages": ["Aiuto"], "user_choice": ""}, config)
    snapshot = await app.aget_state(config)
    print(f"\nGrafo in attesa su: {snapshot.next}")

    choice = input("\nVuoi procedere? (s/n): ")
    choice_val = "sì" if choice.lower() == "s" else "no"

    await app.aupdate_state(config, {"user_choice": choice_val})
    
    print("\n---RIPRESA---")
    await app.ainvoke(None, config)

if __name__ == "__main__":
    asyncio.run(main())