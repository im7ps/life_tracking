# 🚀 Master LangGraph: Production-Ready Roadmap

> [!IMPORTANT]
> **Regola di Ingaggio**: Aspetta sempre che sia l'utente a confermare esplicitamente il passaggio al punto successivo della roadmap prima di fornire la teoria o le sfide del nuovo punto.

## 🎓 Learning Mode: Q&A Protocol

Quando agisci in **Learning Mode**, devi seguire rigorosamente questo sistema di valutazione e tracciamento:

1.  **Storico Domande**: Mantieni e aggiorna costantemente il file `langchain_questions.txt`. Ogni risposta dell'utente deve essere categorizzata (Well Answered, Partially Correct, New).
2.  **Algoritmo di Selezione**: Ogni volta che proponi nuove domande teoriche, rispetta questa proporzione:
    - **60% Nuove Domande**: Per avanzare nel programma.
    - **30% Ripasso Critico**: Domande vecchie a cui l'utente ha risposto in modo incompleto o errato.
    - **10% Consolidamento**: Domande a cui l'utente ha risposto bene, per verificare la ritenzione a lungo termine.
3.  **Feedback Proattivo**: Se una risposta è parziale, non limitarti a correggerla, ma inseriscila nel "Ripasso Critico" per riproporla con una sfumatura diversa.

---

## 🛡️ Production-Ready Standards

Per ogni implementazione, seguiamo rigorosamente questi criteri di robustezza:

1.  **Multi-Tool Awareness**: Mai assumere che ci sia una sola `tool_call`. I router e i gestori devono iterare su tutte le chiamate o validare esplicitamente l'aspettativa.
2.  **ID Mapping**: I `ToolMessage` devono sempre essere mappati correttamente ai loro `tool_call_id` originali. L'omissione o il mapping errato rompe la catena di ragionamento dell'LLM.
3.  **State Atomicità**: Le modifiche allo stato (es. `score`) devono avvenire nello stesso nodo che conferma l'azione, per garantire consistenza tra log e dati.
4.  **No Magic Numbers**: Evitare l'accesso diretto via indice (es. `[0]`) senza controlli preventivi sulla lunghezza delle liste.

---

## 🛤️ Percorso di Studio

### 1. Core Concepts & State Management [x]
- **State Definition**: Utilizzo di `TypedDict` e `Pydantic`.
- **Reducers**: `Annotated` e `add_messages`.
- **Nodes & Edges**: Nodi atomici e routing condizionale.
- **Cycle Control**: Gestione dei loop.

### 2. Tool Calling & DB Integration [x]
- **ReAct Pattern**: Ciclo "Reasoning + Acting".
- **Structured Output**: Generazione schema validati.
- **Custom Tools**: Integrazione con SQLModel.

### 3. Memory & Persistence (PostgreSQL) [x]
- **Checkpointers**: Uso di `PostgresSaver`.
- **Thread-level Memory**: Sessioni multiple.

### 4. Control Flow Avanzato & HITL [ ]
- **Human-in-the-Loop**: Breakpoints e approvazioni.
- **Time Travel**: Modifica stati precedenti.

### 5. Production & Observability [ ]
- **FastAPI Integration**: Streaming asincrono.
- **LangSmith Tracing**: Debugging e latenza.

---
*Status: Punto 4 - Control Flow Avanzato & HITL.*
