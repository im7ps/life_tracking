import uuid
from typing import AsyncGenerator
from langchain_core.messages import HumanMessage, BaseMessage
from app.services.user_service import UserService
from app.schemas.ai_onboarding import UserOnboardingData
from app.services.action_service import ActionService
from app.services.consultant_service import ConsultantService

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
        
        # 1. RECUPERO UTENTE
        user = await self.user_service.get_user_by_id(user_id)
        if not user:
            yield "Errore: Utente non trovato."
            return

        # 2. PREPARAZIONE DATI ONBOARDING
        try:
            # Carichiamo la bio esistente se presente
            onboarding_data = UserOnboardingData.model_validate(user.bio) if user.bio else UserOnboardingData()
        except Exception:
            onboarding_data = UserOnboardingData()
        
        # 3. CONFIGURAZIONE E MESSAGGI
        # La thread_id permette a LangGraph di mantenere la memoria persistente nel DB
        config = {"configurable": {"thread_id": f"{user_id}_{session_id}", "user_id": str(user_id)}}
        human_msg = HumanMessage(content=message)
        
        # 4. INIZIALIZZAZIONE STATO
        initial_state = {
            "messages": [human_msg],
            "user_id": str(user_id),
            "onboarding_data": onboarding_data
        }
        
        # 5. ESECUZIONE GRAFO (Streaming)
        if not self.app_graph:
            yield "Il sistema di intelligenza artificiale non è pronto. Contatta l'assistenza."
            return

        try:
            # 'astream' con stream_mode="messages" invia i token mentre vengono generati
            async for chunk, metadata in self.app_graph.astream(
                initial_state, 
                config, 
                stream_mode="messages"
            ):
                # Filtriamo: vogliamo solo il testo generato dal nodo assistente (tipo 'ai')
                if isinstance(chunk, BaseMessage) and chunk.type == "AIMessageChunk":
                    if chunk.content:
                        # print(f"\n\n\nChunk ricevuto: {chunk}\n\n\n")
                        yield str(chunk.content)
        except Exception as e:
            yield f"Ouch! Ho avuto un piccolo problema tecnico: {str(e)}"

    async def resume_chat(self, user_id: uuid.UUID, confirmed: bool, session_id: str):
        pass
