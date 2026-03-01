# backend/app/services/chat_graph.py

from typing import Annotated, TypedDict, Literal
import logging

from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode
from langgraph.types import interrupt

from langchain_core.messages import HumanMessage, BaseMessage, SystemMessage, AIMessage
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.tools import tool
from langchain_core.runnables import RunnableConfig

from app.core.config import settings

# Inizializza il logger
logger = logging.getLogger(__name__)

# 1. DEFINIZIONE DELLO STATO (La "lavagna" condivisa tra i nodi)
class GraphState(TypedDict):
    # Annotated + add_messages permette di accumulare i messaggi nella cronologia
    messages: Annotated[list[BaseMessage], add_messages]


SYSTEM_PROMPT_TEMPLATE = """
Sei il Consulente del "Day 0" di WhatI'veDone. Il tuo obiettivo è trasformare i desideri dell'utente in azioni immediate e gestibili.

LOGICA DI SCOMPOSIZIONE (ATOMI-CHECK):
1. **Analizza**: Se l'attività proposta è complessa o multi-step (es. "Cucinare un piatto specifico", "Preparare un esame", "Organizzare un viaggio"), NON crearla subito.
2. **Proponi**: Suggerisci una scomposizione in piccoli passi logici (sub-task checklist).
3. **Calibra**: Chiedi all'utente: "Ti sembra il giusto livello di dettaglio per procedere o vuoi che spezzettiamo ancora di più?".
4. **Crea**: Solo dopo l'ok dell'utente sull'atomicità, chiama `start_new_action` includendo OBBLIGATORIAMENTE la lista `sub_tasks` negli argomenti del tool. Ogni sub-task deve essere: {{"title": "string", "done": false}}.


LOGICA SMART DURATION & DIMENSION:
- **Inferenza Dimensione**: Identifica autonomamente la dimensione corretta tra 'dovere', 'passione', 'energia', 'relazioni', 'anima'. Non chiederla mai prima all'utente, la vedrà nella card finale.
- **Durata Selettiva**: Chiedi la durata stimata (minuti) SOLO per attività basate sulla durata della pratica (es. Allenamento, Meditazione, Studio, Sessione di lavoro). 
- **Goal-Based**: NON chiedere la durata per attività basate su un risultato finale concreto (es. Cucinare, Fare la spesa, Riparare un oggetto, Chiamare qualcuno).

CONTESTO UTENTE:
- Rank Attuale: {rank}
- Portfolio: {portfolio}

REGOLE DI COMPORTAMENTO:
1. Sii estremamente sintetico. Ogni parola deve spingere all'azione.
2. Se l'utente vuole resettare la giornata o cancellare tutte le task, usa `delete_all_active_actions`.
3. Se l'utente rifiuta una card grafica, chiedi "Cosa preferiresti modificare?" senza scuse.
4. Parla sempre in italiano, tono asciutto e diretto.
"""


@tool
async def get_user_portfolio(config: RunnableConfig):
    """Restituisce la lista delle azioni nel portfolio dell'utente.
    Usa questo tool per sapere cosa l'utente ha fatto o vuole fare in futuro."""
    
    user_id = config["configurable"].get("user_id")
    action_service = config["configurable"].get("action_service")
    
    if not action_service or not user_id:
        raise ValueError("action_service o user_id non disponibili nel config")
    
    actions = await action_service.get_user_portfolio(user_id)
    if not actions:
        return "L'utente non ha azioni nel suo portfolio"
    # actions is a list of dicts
    return [f"{a['description']} (Categoria: {a['category']})" for a in actions]

@tool
async def start_new_action(
    description: str, 
    dimension_id: str, 
    fulfillment_score: int = 3,
    duration_minutes: int | None = None,
    sub_tasks: list[dict] | None = None,
    config: RunnableConfig = None
):
    """Inizia una nuova task per l'utente. 
    DIMENSION_ID validi: 'dovere', 'passione', 'energia', 'relazioni', 'anima'.
    Usa questo tool SOLO quando l'utente accetta esplicitamente una task o conferma una scomposizione.
    
    Args:
        description: Breve descrizione dell'attività.
        dimension_id: Lo slug della dimensione (es. 'passione').
        fulfillment_score: Valore da 1 a 5 dell'appagamento previsto (default 3).
        duration_minutes: Durata prevista in minuti (opzionale).
        sub_tasks: Lista di sotto-task opzionali. Ogni elemento deve essere un dizionario {"title": "nome task", "done": false}.
    """
    user_id = config["configurable"].get("user_id")
    action_service = config["configurable"].get("action_service")
    
    # Normalizzazione e Mapping delle Dimensioni
    mapping = {
        "energy": "energia",
        "soul": "anima",
        "relationships": "relazioni",
        "clarity": "chiarezza",
        "duties": "dovere",
        "passions": "passione",
        "work": "dovere",
        "health": "energia"
    }
    
    normalized_id = dimension_id.lower().strip()
    if normalized_id in mapping:
        normalized_id = mapping[normalized_id]
    
    if not action_service or not user_id:
        return "ERRORE: Servizio non disponibile."
        
    print(f"DEBUG: start_new_action - Received sub_tasks: {sub_tasks}")
    from app.schemas.action import ActionCreate
    
    action_in = ActionCreate(
        description=description,
        dimension_id=normalized_id,
        category=normalized_id.capitalize(),
        fulfillment_score=fulfillment_score,
        duration_minutes=duration_minutes,
        sub_tasks=sub_tasks,
        status="IN_PROGRESS"
    )
    
    try:
        await action_service.create_action(user_id, action_in)
        return f"SUCCESSO: L'attività '{description}' è stata avviata correttamente."
    except Exception as e:
        return f"ERRORE: Impossibile avviare la task. Dettaglio: {str(e)}"

@tool
async def delete_action(description_query: str, config: RunnableConfig):
    """Cancella una task dell'utente basandosi sulla descrizione.
    Usa questo tool quando l'utente vuole annullare, rimuovere o cancellare un'attività specifica.
    
    Args:
        description_query: Parola chiave o descrizione della task da cancellare.
    """
    user_id = config["configurable"].get("user_id")
    action_service = config["configurable"].get("action_service")
    
    if not action_service or not user_id:
        return "ERRORE: Servizio non disponibile."
    
    try:
        # 1. Recuperiamo le azioni dal portfolio (lista di dict)
        portfolio = await action_service.get_user_portfolio(user_id)
        
        # 2. Recuperiamo le azioni recenti (lista di oggetti Action)
        recent = await action_service.get_user_actions(user_id, limit=50)
        
        # Cerchiamo un match (case insensitive)
        target_id = None
        target_desc = None
        
        # Cerca nel portfolio (dict)
        for a in portfolio:
            desc = a.get('description', '')
            if description_query.lower() in desc.lower():
                target_id = a.get('id')
                target_desc = desc
                break
        
        # Se non trovato, cerca nelle recenti (oggetti)
        if not target_id:
            for a in recent:
                desc = a.description or ""
                if description_query.lower() in desc.lower():
                    target_id = a.id
                    target_desc = desc
                    break
        
        if not target_id:
            return f"ERRORE: Non ho trovato nessuna attività che corrisponde a '{description_query}'."
            
        success = await action_service.delete_action(user_id, target_id)
        if success:
            return f"SUCCESSO: L'attività '{target_desc}' è stata rimossa."
        else:
            return "ERRORE: Impossibile cancellare l'attività."
            
    except Exception as e:
        return f"ERRORE: {str(e)}"

@tool
async def delete_all_active_actions(config: RunnableConfig):
    """Elimina TUTTE le attività attualmente in corso per la giornata di oggi.
    Usa questo tool quando l'utente vuole resettare la dashboard o dice di voler 'cancellare tutto'.
    """
    user_id = config["configurable"].get("user_id")
    action_service = config["configurable"].get("action_service")
    
    if not action_service or not user_id:
        return "ERRORE: Servizio non disponibile."
    
    try:
        # Recuperiamo le azioni recenti (che includono quelle IN_PROGRESS)
        actions = await action_service.get_user_actions(user_id, limit=50)
        active_ids = [a.id for a in actions if a.status == "IN_PROGRESS"]
        
        if not active_ids:
            return "Non ci sono attività attive da eliminare."
            
        count = 0
        for aid in active_ids:
            if await action_service.delete_action(user_id, aid):
                count += 1
        
        return f"SUCCESSO: Sono state rimosse {count} attività."
    except Exception as e:
        return f"ERRORE: {str(e)}"

def build_tools() -> list:
    return [get_user_portfolio, start_new_action, delete_action, delete_all_active_actions]


def build_tool_node() -> ToolNode:
    tools = build_tools()
    return ToolNode(tools, handle_tool_errors=True)


def fetch_llm() -> ChatGoogleGenerativeAI:
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.5-flash",
        google_api_key=settings.GOOGLE_API_KEY,
        temperature=0.1,
    )
    return llm


def fetch_llm_with_tools() -> ChatGoogleGenerativeAI:
    llm = fetch_llm()
    tools = build_tools()
    return llm.bind_tools(tools)


def trim_to_last_n_turns(messages: list[BaseMessage], n: int = 10) -> list[BaseMessage]:
    turns = []
    current_turn = []
    for msg in messages:
        if isinstance(msg, HumanMessage) and current_turn:
            turns.append(current_turn)
            current_turn = [msg]
        else:
            current_turn.append(msg)
    if current_turn:
        turns.append(current_turn)
    return [msg for turn in turns[-n:] for msg in turn]


def route_tools(state: GraphState) -> Literal["tools", "__end__"]:
    msg = state["messages"][-1]
    tool_calls = getattr(msg, "tool_calls", [])
    if tool_calls:
        return "tools"
    return "__end__"


def build_workflow(graphState: GraphState, chatbot_func) -> StateGraph:
    tool_node = build_tool_node()
    workflow = StateGraph(graphState)
    workflow.add_node("agent", chatbot_func)
    workflow.add_node("tools", tool_node)
    workflow.add_edge(START, "agent")
    workflow.add_conditional_edges("agent", route_tools)
    workflow.add_edge("tools", "agent")
    return workflow

def compile_graph(checkpointer):
    llm = fetch_llm()
    llm_with_tools = fetch_llm_with_tools()

    async def chatbot(state: GraphState, config: RunnableConfig):
        rank = config["configurable"].get("rank", 0)
        portfolio = config["configurable"].get("portfolio", [])

        system_message = SystemMessage(content=SYSTEM_PROMPT_TEMPLATE.format(
            rank=rank,
            portfolio=portfolio,
        ))

        trimmed = trim_to_last_n_turns(state["messages"], 10)
        full_context = [system_message] + trimmed
        
        final_message = None
        async for chunk in llm_with_tools.astream(full_context, config=config):
            if final_message is None:
                final_message = chunk
            else:
                final_message += chunk
        
        if final_message.tool_calls:
            modifying_tools = ["start_new_action", "delete_action"]
            needs_confirmation = any(tc["name"] in modifying_tools for tc in final_message.tool_calls)
            
            if needs_confirmation:
                confirmed = interrupt({"tool_calls": final_message.tool_calls})
                
                if not confirmed:
                    rejection_context = HumanMessage(content="Ho rifiutato questa proposta perché vorrei cambiare qualcosa. Cosa preferiresti modificare?")
                    rejection_flow_context = full_context + [final_message, rejection_context]
                    
                    rejection_message = None
                    async for chunk in llm.astream(rejection_flow_context, config=config):
                        if rejection_message is None:
                            rejection_message = chunk
                        else:
                            rejection_message += chunk
                    return {"messages": [final_message, rejection_context, rejection_message]}
        
        return {"messages": [final_message]}

    workflow = build_workflow(GraphState, chatbot)
    app_graph = workflow.compile(checkpointer=checkpointer)
    return app_graph
