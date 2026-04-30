from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from app.api.v1.deps import get_chat_service, CurrentUser
from app.services.chat_service import ChatService
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = "default"

@router.post("/stream")
async def stream_chat(
    request: ChatRequest,
    current_user: CurrentUser,
    chat_service: ChatService = Depends(get_chat_service),
):
    """
    Endpoint per lo streaming della chat con il Consulente Day 0.
    """
    print(f"DEBUG: Router POST /stream - user: {current_user.id}, msg: {request.message}")
    return StreamingResponse(
        chat_service.stream_chat(current_user.id, request.message, request.session_id),
        media_type="text/event-stream"
    )

class ConfirmRequest(BaseModel):
    confirmed: bool
    session_id: Optional[str] = "default"
    
@router.post("/confirm")
async def confirm_tool(
    request: ConfirmRequest,
    current_user: CurrentUser,
    chat_service: ChatService = Depends(get_chat_service),
):
    """
    Endpoint per ricevere la conferma dell'utente riguardo all'esecuzione di un tool suggerito.
    """
    return StreamingResponse(
        chat_service.resume_chat(current_user.id, request.confirmed, request.session_id),
        media_type="text/event-stream"
    )
