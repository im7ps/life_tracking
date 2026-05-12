from typing import Annotated, List, TypedDict, Union
from langchain_core.messages import BaseMessage, ToolMessage, AIMessage, HumanMessage, SystemMessage
from langchain_core.runnables import RunnableConfig
from langgraph.graph import StateGraph, START, END, add_messages
import json

# 1. Definizione dello Stato
class GraphState(TypedDict):
    messages: Annotated[List[BaseMessage], add_messages]
    user_id: str
    last_action_status: str # "success" | "error" | "pending"

# --- SFIDA ---
def apply_action_node(state: GraphState, config: RunnableConfig):
    """
    SFIDA PRO:
    L'utente ha chiesto di salvare un'azione. L'LLM ha chiamato 'save_action_to_db'.
    Il ToolNode ha eseguito il tool e ha aggiunto uno o più ToolMessages allo stato.
    
    COMPITI:
    1. Analizza i messaggi partendo dall'ultimo fino a trovare il/i ToolMessage.
    2. Se il tool 'save_action_to_db' ha restituito un errore (es: status: "error"):
       - Imposta last_action_status = "error"
       - Aggiungi un messaggio (magari un HumanMessage o System) che spieghi all'AI 
         cosa è successo, così può scusarsi con l'utente.
    3. Se ha avuto successo:
       - Imposta last_action_status = "success"
    """
    
    messages = state.get("messages", [])
    if not messages:
        return {}

    # --- INIZIO ESERCIZIO ---
    
    # [Tuo Codice Qui]
    # Suggerimento: itera all'indietro su messages per trovare i ToolMessage
    # Suggerimento 2: controlla il campo 'content' del messaggio.
    
    new_status = "pending"
    feedback_messages: List[BaseMessage] = []
    
    for msg in messages[::-1]:
        if isinstance(msg, ToolMessage) and msg.name == "save_action_to_db":
            # Analizza il contenuto del messaggio per determinare se è un successo o un errore
            try:
                content = json.loads(msg.content)
                if content.get("status") == "error":
                    new_status = "error"
                    feedback_messages.append(SystemMessage(content="Mi dispiace, c'è stato un problema nel salvare l'azione."))
                else:
                    new_status = "success"
            except json.JSONDecodeError:
                new_status = "error"
                feedback_messages.append(SystemMessage(content="Mi dispiace, non sono riuscito a capire la risposta del tool."))
            break

    # ... logic ...

    return {
        "last_action_status": new_status,
        "messages": feedback_messages
    }
