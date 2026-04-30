import uuid
import structlog
from typing import AsyncGenerator
from langchain_core.messages import HumanMessage, BaseMessage
from app.services.user_service import UserService
from app.schemas.ai_onboarding import UserOnboardingData
from app.services.action_service import ActionService
from app.services.consultant_service import ConsultantService

logger = structlog.get_logger()

class ChatService:
    def __init__(
        self,
        user_service: UserService,
        action_service: ActionService, 
        consultant_service: ConsultantService, 
        app_graph = None
    ):
        self.user_service = user_service
        self.action_service = action_service
        self.consultant_service = consultant_service
        self.app_graph = app_graph

    async def stream_chat(
        self, 
        user_id: uuid.UUID, 
        message: str, 
        session_id: str = "default"
    ) -> AsyncGenerator[str, None]:
        """
        Gestisce il flusso della chat di onboarding utilizzando LangGraph.
        """
        logger.info("chat_stream_request", user_id=user_id, session_id=session_id)
        
        # 1. RECUPERO UTENTE
        user = await self.user_service.get_user_by_id(user_id)
        if not user:
            logger.error("chat_user_not_found", user_id=user_id)
            yield "Errore: Utente non trovato."
            return

        # 2. PREPARAZIONE DATI ONBOARDING
        try:
            onboarding_data = UserOnboardingData.model_validate(user.bio) if user.bio else UserOnboardingData()
        except Exception as e:
            logger.warning("onboarding_data_validation_failed", error=str(e), user_id=user_id)
            onboarding_data = UserOnboardingData()
        
        # 3. CONFIGURAZIONE E MESSAGGI
        config = {"configurable": {"thread_id": f"{user_id}_{session_id}", "user_id": str(user_id)}}
        
        # Innesco reale per Gemini
        display_message = message if message and message.strip() else "Inizia sessione"
        messages = [HumanMessage(content=display_message)]
        
        # 4. INIZIALIZZAZIONE STATO
        initial_state = {
            "messages": messages,
            "user_id": str(user_id),
            "onboarding_data": onboarding_data
        }
        
        # 5. ESECUZIONE GRAFO (Streaming)
        if not self.app_graph:
            logger.error("chat_graph_not_initialized")
            yield "Il sistema di intelligenza artificiale non è pronto. Contatta l'assistenza."
            return

        try:
            async for chunk, metadata in self.app_graph.astream(
                initial_state, 
                config, 
                stream_mode="messages"
            ):
                if isinstance(chunk, BaseMessage) and chunk.type == "AIMessageChunk" and metadata['langgraph_node'] == "agent":
                    if chunk.content:
                        yield str(chunk.content)
        except Exception as e:
            logger.exception("chat_graph_stream_failed", error=str(e), user_id=user_id)
            yield f"Ouch! Ho avuto un piccolo problema tecnico: {str(e)}"

    async def resume_chat(self, user_id: uuid.UUID, confirmed: bool, session_id: str):
        pass
