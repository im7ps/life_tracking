# TODO - What I've Done (Emotional Compass)

## Bug
# Quando clicco le icone non si spengono per diventare inattive
# Non funziona se non sulla stessa rete wifi del server (il pc)
# Il portfolio visualizzato sull'app non coincide con quello presente nel BE
# La chat non scorre per visualizzare l'ultimo messaggio
# Quando annullo la conferma di una task perchè voglio modificare qualcosa il messaggio dell'agent è vuoto al posto di essere qualcosa del tipo "cosa vuoi modificare?"
# Quando elimino una task dal portfolio tramite agent dovrebbe eliminarla anche dalle attività correnti

## Features
# Cambiare la scritta "identità in azione" con "riepilogo task"
# Integrare la logica dei checkpoint
# Integrare il termine della giornata corrente
# Integrare giornate successive al day0 per programmare azioni anche nel domani, dopodomani ecc
# Aggiungere durata temporale delle task calcolabile tramite pulsante che consente di mettere in pausa/riprendere le task
# Aggiungere bottone per eliminare una task da quelle correnti

## Agents
# Creare agent specifici per ogni zona (Energia - Anima - ecc)
# Creare agent che sa quale agent deve chiamare 

## Noises
# dimension_id è un campo che genera confusione, da rivedere
# non c'è bisogno che l'agent mi chieda la conferma dopo che gli ho dato le info perchè poi mi fa vedere la card che posso scegliere di modificare

## Aesthetic
# Migliorare il login, fa schifo
# Curare la light mode
# Cambiare lo sfondo delle schermate in dark mode e light mode

## idee nuove
# mettere le notifiche che mostrano il progresso di una task a tempo per poterla estendere o terminare
# inserire la possibilità di creare liste nelle task "es prendere medicine: un text dove scrivi tutte le medicine che devi prendere con casella per spuntare quelle prese
# inserire task ricorrenti es: prendere medicine se le devi prendere ogni giorno senza dover avviare la task ogni volta
# inserire varie personalità dell llm per tarare in base ai gusti dell'utente
# inserire icona in alto a destra con punto interrogativo per triggerare il tutorial di come usare l'app (bisogna anche creare il tutorial perchè ancora non esiste)


💡 Idee per nuove integrazioni (Oltre il TODO)
1. L'Albero dell'Identità (Visualizzazione): Una visualizzazione grafica (tipo albero
    o costellazione) che cresce in base alle categorie completate. Se fai molto
    "Dovere", un ramo diventa robusto; se fai "Passione", nascono fiori. Serve a dare
    un feedback visivo immediato a lungo termine.
2. Focus Mode con "Deep Work": Un timer integrato nell'app che, quando attivo,
    registra il tempo effettivo di esecuzione. Potrebbe includere suoni binaurali o
    rumore bianco per aiutare la concentrazione.
3. Sfide Context-Aware: Se il GPS rileva che sei in palestra o al parco, l'Agente ti
    invia una notifica: "Vedo che sei nel posto giusto, vuoi iniziare [Task Palestra]
    ora?".
4. Riflessione Post-Task: Invece di completare e basta, l'app potrebbe chiedere: "Ti
    senti più [Energico/Soddisfatto] dopo questa attività?". Questo dato serve al
    Consulente per affinare i consigli futuri (AI personalizzata).
5. Modalità "Burnout Prevention": Se l'app rileva troppe task di "Dovere" completate e
    nessuna di "Energia/Passione", l'Agente interviene forzando una proposta di riposo
    o svago.