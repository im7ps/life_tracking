import logging
import json
from dataclasses import dataclass
from typing import AsyncGenerator, Optional

from langchain_core.messages import HumanMessage
from langgraph.types import Command

from app.services.user_service import UserService
from app.services.action_service import ActionService
from app.services.consultant_service import ConsultantService

logger = logging.getLogger(__name__)
HUMAN_MSG_MAX_LENGHT = 5000

class ChatService:
    def __init__(
        self,
        user_service: UserService,
        action_service: ActionService,
        consultant_service: ConsultantService,
        app_graph,
    ):
        self.user_service = user_service
        self.action_service = action_service
        self.consultant_service = consultant_service
        self.app_graph = app_graph

    @dataclass
    class _UserContext:
        rank: int
        portfolio: list[str]
        proposals: list[str]
    
    async def _fetch_context(self, user_id) -> _UserContext:
        user = await self.user_service.get_user_by_id(user_id)
        rank = user.rank_score
        
        portfolio_actions = await self.action_service.get_user_portfolio(user_id)
        # portfolio_actions is now a list of dicts from ActionRepo.get_unique_completed_actions
        portfolio_desc = [f"{a['description']} ({a['category']})" for a in portfolio_actions]
        
        proposals = await self.consultant_service.get_proposals(user_id)
        proposals_desc = [f"{p.description}: {p.category}" for p in proposals]
        
        return self._UserContext(rank=rank, portfolio=portfolio_desc, proposals=proposals_desc)
    
    def _return_context_configurable(self, user_id, session_id: str, context: _UserContext):
        thread_id = f"{user_id}_{session_id}"
        return {
            "configurable": {
                "thread_id": thread_id,
                "user_id": user_id,
                "action_service": self.action_service,
                "rank": context.rank,
                "portfolio": context.portfolio,
                "proposals": context.proposals,
            }}

    async def stream_chat(self, user_id, user_message: str, session_id: str = "default") -> AsyncGenerator[str, None]:
        if len(user_message) > HUMAN_MSG_MAX_LENGHT:
            yield "Il messaggio è troppo lungo."
            return

        input_data = {"messages": [HumanMessage(content=user_message)]}
        try:
            context = await self._fetch_context(user_id)
            config = self._return_context_configurable(user_id, session_id, context)

            logger.info(f"START stream_chat for user {user_id} on thread {config['configurable']['thread_id']}")

            async for event in self.app_graph.astream_events(input_data, config=config, version="v2"):
                # Yield only tokens from the model stream
                if event["event"] == "on_chat_model_stream":
                    chunk = event["data"]["chunk"]
                    content = getattr(chunk, "content", None)
                    
                    if content:
                        # Ensure content is a string and not empty to prevent UI glitches
                        if isinstance(content, str) and content.strip():
                            yield content
                        elif isinstance(content, list):
                            # Handle list of content blocks if necessary
                            for part in content:
                                if isinstance(part, dict) and part.get("type") == "text":
                                    text = part.get("text", "")
                                    if text.strip():
                                        yield text
                                elif isinstance(part, str) and part.strip():
                                    yield part
            
            state = await self.app_graph.aget_state(config)
            logger.info(f"END stream_chat. State next: {state.next}")

            if state.next:
                for task in state.tasks:
                    for interrupt_obj in task.interrupts:
                        tool_calls = (
                            interrupt_obj.value.get("tool_calls", [])
                            if isinstance(interrupt_obj.value, dict)
                            else []
                        )
                        if tool_calls:
                            tool_call = tool_calls[0]
                            args_str = json.dumps(tool_call.get('args', {}))
                            logger.info(f"Yielding INTERRUPT for tool: {tool_call['name']} with args: {args_str}")
                            yield f"||INTERRUPT||{tool_call['name']}||{args_str}"
                            return
        except Exception as e:
            import traceback
            logger.error(f"Error in stream_chat: {e}")
            logger.error(traceback.format_exc())
            yield f"Si è verificato un errore durante la chat: {str(e)}"
        finally:
            logger.debug("Cleaning up chat stream resources...")

    async def resume_chat(self, user_id, confirmed: bool, session_id: str = "default") -> AsyncGenerator[str, None]:
        try:
            context = await self._fetch_context(user_id)
            config = self._return_context_configurable(user_id, session_id, context)
            
            logger.info(f"START resume_chat (confirmed={confirmed}) for user {user_id} on thread {config['configurable']['thread_id']}")

            if not confirmed:
                yield "Ricevuto. Annullamento operazione e generazione risposta alternativa...\n\n"

            async for event in self.app_graph.astream_events(
                Command(resume=confirmed),
                config=config,
                version="v2"
            ):
                if event["event"] == "on_chat_model_stream":
                    chunk = event["data"]["chunk"]
                    content = getattr(chunk, "content", None)
                    if content:
                        if isinstance(content, str) and content.strip():
                            yield content
                        elif isinstance(content, list):
                            for part in content:
                                if isinstance(part, dict) and part.get("type") == "text":
                                    text = part.get("text", "")
                                    if text.strip():
                                        yield text
                                elif isinstance(part, str) and part.strip():
                                    yield part
            
            state = await self.app_graph.aget_state(config)
            logger.info(f"END resume_chat. State next: {state.next}")

            if state.next:
                for task in state.tasks:
                    for interrupt_obj in task.interrupts:
                        tool_calls = (
                            interrupt_obj.value.get("tool_calls", [])
                            if isinstance(interrupt_obj.value, dict)
                            else []
                        )
                        if tool_calls:
                            tool_call = tool_calls[0]
                            args_str = json.dumps(tool_call.get('args', {}))
                            logger.info(f"Yielding INTERRUPT in resume for tool: {tool_call['name']} with args: {args_str}")
                            yield f"||INTERRUPT||{tool_call['name']}||{args_str}"
                            return
        except Exception as e:
            import traceback
            logger.error(f"Error in resume_chat: {e}")
            logger.error(traceback.format_exc())
            yield f"Si è verificato un errore durante la ripresa della chat: {str(e)}"
