from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.database.session import get_session
from app.services.action_service import ActionService
from app.schemas.action import ActionCreate

router = APIRouter()

# --- SPIEGAZIONE TEACHER ---
# Se iniettassimo direttamente la Session qui nel router:
# 1. Dovremmo scrivere query SQL (o SQLModel) qui nel router.
# 2. Se volessimo riutilizzare la creazione di un'azione in un'altra parte (es. un bot telegram), 
#    dovremmo copiare e incollare il codice del database.
# 3. Violazione della separazione: "Il router deve solo occuparsi di HTTP (200 OK, 400 Bad Request)".

@router.post("/actions/clean")
async def create_action(
    action_in: ActionCreate,
    # Iniettiamo il SERVICE, non la sessione!
    # Nota: il Service a sua volta riceverà la sessione dal suo costruttore
    service: ActionService = Depends()
):
    """
    Esempio di Router 'Saggio': 
    Non sa COME viene salvato il dato, sa solo a CHI chiedere di farlo.
    """
    try:
        return await service.create_action(action_in)
    except ValueError as e:
        # Il router trasforma un errore di logica in un errore HTTP
        raise HTTPException(status_code=400, detail=str(e))
