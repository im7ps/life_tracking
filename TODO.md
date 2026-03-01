# TODO - What I've Done (Emotional Compass)

## 🎨 Aesthetic (Prossimi Step)
# Curare la light mode (Verificare contrasti e colori)

## 🚀 Nuove Funzionalità (Utilità & UX)
# Inserire varie personalità dell'LLM (selezionabili dall'utente)
# Focus Mode con "Deep Work" (Timer dedicato con suoni ambientali)
# Sfide Context-Aware (Notifiche basate su posizione/GPS)
# Riflessione Post-Task (Feedback qualitativo dopo il completamento)
# Modalità "Burnout Prevention" (L'agente suggerisce riposo se il Dovere è troppo alto)
# Inserire differenza nelle subtask fra "core" e "occasionali" per le subtask che accompagnano sempre la task principale e quelle che a volte ci sono a volte possono cambiare o non esserci (es: nel fare la spesa una subtask che c'è quasi sempre è prendere la busta della spesa, mentre comprare il tonno è una subtask occasionale). Nel portfolio (e quindi nel DB) va salvata la task con solo le subtask core.
# Riuscire a comunicare con il backend anche se non ci si trova sulla stessa rete WIFI

## 🌌 Visione Avanzata (Oltre il Prototipo)
# L'Arena del Presente (Visualizzazione globale degli utenti attivi per categoria)
# Soundscapes Adattivi (Audio differenziato in base alla dimensione attiva)
# Identity Archetypes (Analisi mensile dell'identità prevalente: es. Guerriero, Saggio, Artista)
# Focus Mode "Zen" (Interfaccia minimale con solo la task attiva e lo sfondo)
# Widget & Wearables (Monitoraggio timer da Home screen e Smartwatch)
# Insight Predictivity (L'AI suggerisce l'orario migliore per ogni task basandosi sulla storia)
# Hands-Free Voice (Comandi vocali completi per avviare/terminare task senza mani)

## 🤖 Agents (In fondo alla lista)
# Creare agent specifici per ogni zona (Energia - Anima - ecc)
# Creare agent router che sa quale agent specifico chiamare

## 🧪 TEST MANUALE DA ESEGUIRE
# Con la task ancora presente nella Dashboard, prova a ri-aggiungerla dal Portfolio. Verifica (dai log o dal comportamento) che non venga creato un doppione.

---
## ✅ Completati
# Fix Agent Deletion: La ricerca per descrizione ora è robusta e include portfolio/dashboard.
# Fix Sub-tasks Persistence: Le subtask ora vengono correttamente trasferite dal Portfolio alla Dashboard.
# Fix Portfolio detail: Aggiunta visualizzazione e rimozione subtask anche nella modale Portfolio.
# Fix Dashboard Layout: ActiveTaskBar integrata nello scroll sotto la IdentityGrid (non più floating).
# Fix Modal UX: Risolti overflow e problemi di tastiera con SingleChildScrollView.
# UI Polish: Sfondo DynamicBackground con blur (glassmorphism) e contenitori solidi.
# Logic: Impedito l'inserimento di task duplicate (stesso titolo) dal Portfolio.
# Quando clicco le icone non si spengono per diventare inattive (fatto)
# Non funziona se non sulla stessa rete wifi del server (fatto - aggiunta impostazione IP)
# Il portfolio visualizzato sull'app non coincide con quello presente nel BE (fatto)
# La chat non scorre per visualizzare l'ultimo messaggio (fatto)
# Quando annullo la conferma di una task (fatto)
# Quando elimino una task dal portfolio tramite agent (fatto)
# Cambiare la scritta "identità in azione" con "riepilogo task" (fatto)
# Integrare la logica dei checkpoint (fatto)
# Integrare il termine della giornata corrente (fatto)
# Integrare giornate successive al day0 (fatto)
# Aggiungere durata temporale delle task con pulsante Play/Pause (fatto)
# Aggiungere bottone per eliminare una task da quelle correnti (fatto)
# dimension_id campo confusionario (fatto - refactoring BE/FE)
# Niente doppia conferma inutile dell'agente (fatto)
# L'Albero dell'Identità e visualizzazioni grafiche per categoria (fatto)
# Migliorare il login (fatto)
# Cambiare lo sfondo delle schermate in dark mode e light mode (fatto - aggiunti blob animati in Dashboard)
# Inserire la possibilità di creare liste/sub-task nelle task (fatto - checklist interna in dettaglio task)
# Inserire task ricorrenti (fatto - gestione reset in checkpoint)
# Inserire icona "?" in alto a destra per triggerare il tutorial di utilizzo (fatto)
# Mettere notifiche/indicatori persistenti per task con timer attivo (fatto - barra dinamica in Dashboard)
