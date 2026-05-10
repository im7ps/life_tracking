import asyncio
import operator
from typing import Annotated, TypedDict

from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, START, StateGraph


class GraphState(TypedDict):
    messages: Annotated[list, operator.add]
    needs_reset: bool

# --- LOGICA DEI NODI ---

async def agent_node(state: GraphState):
    print("\n[NODE] Agente: Sto analizzando la richiesta...")
    last = state["messages"][-1] if state["messages"] else ""
    if "ricominciare da zero" in last.lower():
        return {
            "needs_reset": True, 
            "messages": ["L'utente ha chiesto il reset del rank. Richiedo conferma."]
        }
    return {
        "needs_reset": False, 
        "messages": ["Nessuna richiesta di reset rilevata. Continuo normalmente."]
    }

async def reset_node(state: GraphState):
    print("\n[NODE] Reset: Esecuzione del reset nel database...")
    return {
        "messages": ["Rank resettato con successo nel database!"], 
        "needs_reset": False
    }

# --- COSTRUZIONE DEL GRAFO ---

def router(state: GraphState):
    if state.get("needs_reset"):
        # --- ESERCIZIO A ---
        # Deve restituire la chiave che mappa al 'reset_node'
        return "reset" 
    return END

workflow = StateGraph(GraphState)
workflow.add_node("agent", agent_node)
workflow.add_node("reset_node", reset_node)

workflow.add_edge(START, "agent")
workflow.add_conditional_edges("agent", router, {"reset": "reset_node", END: END})
workflow.add_edge("reset_node", END)

# --- CONFIGURAZIONE E COMPILAZIONE ---

# --- ESERCIZIO B ---
# Crea l'istanza corretta per gestire la memoria volatile
memory = MemorySaver() 

# --- ESERCIZIO C ---
# Compila il grafo abilitando l'interruzione nel punto giusto
app = workflow.compile(
    checkpointer=memory,
    interrupt_before=["reset_node"],
)

async def run_exercise():
    response: str
    # Una volta completato B e C, de-commenta queste righe per testare
    config = {"configurable": {"thread_id": "pro-user-1"}}
    initial_input = {"messages": ["Voglio ricominciare da zero."], "needs_reset": False}
    
    print("--- PRIMA ESECUZIONE ---")
    await app.ainvoke(initial_input, config=config)
    
    snapshot = await app.aget_state(config)
    print(f"\nStato attuale: {snapshot.next}")
    
    if snapshot.next:
        print("\n[HITL] Il sistema è in attesa di approvazione.")
        conferma = input("Vuoi procedere con il reset? (s/n): ")
        if conferma.lower() == 's':
            # --- ESERCIZIO D ---
            # Come riprendi l'esecuzione passandogli 'None' per continuare dal checkpoint?
            response = await app.ainvoke(None, config=config)
        elif conferma.lower() == 'n':
            print("Reset annullato. Il sistema tornerà allo stato iniziale.")
            # --- ESERCIZIO E ---
            # Come resetti lo stato del grafo per tornare all'inizio?
            response = await app.ainvoke({"messages": [], "needs_reset": False}, config=config)
    
    if snapshot.next:
        print("\n[HITL] Il sistema è in attesa di approvazione di nuovo.")
        conferma = input("Vuoi procedere con il reset? (s/n): ")
        if conferma.lower() == 's':
            # --- ESERCIZIO D ---
            # Come riprendi l'esecuzione passandogli 'None' per continuare dal checkpoint?
            response = await app.ainvoke(None, config=config)
        elif conferma.lower() == 'n':
            print("Reset annullato. Il sistema tornerà allo stato iniziale.")
            # --- ESERCIZIO E ---
            # Come resetti lo stato del grafo per tornare all'inizio?
            response = await app.ainvoke({"messages": [], "needs_reset": False}, config=config)


    print(f"\nRisposta finale: {response}")
    # print("\nEsercizio caricato. Completa i placeholder nel file!")

if __name__ == "__main__":
    # Nota: su Windows serve l'event loop policy corretta (già vista nei tuoi file)
    asyncio.run(run_exercise())
