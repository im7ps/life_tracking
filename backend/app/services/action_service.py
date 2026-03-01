import uuid
from typing import List
from fastapi import HTTPException, status
from app.models.action import Action
from app.schemas.action import ActionCreate, ActionUpdate
from app.repositories.action_repo import ActionRepo
from app.services.dimension_service import DimensionService

class ActionService:
    def __init__(self, repo: ActionRepo, dimension_service: DimensionService):
        self.repo = repo
        self.dimension_service = dimension_service

    async def create_action(self, user_id: uuid.UUID, action_in: ActionCreate) -> Action:
        print(f"DEBUG: ActionService.create_action - User: {user_id}, Dimension: '{action_in.dimension_id}', Desc: '{action_in.description}'")
        # Verify dimension exists
        try:
            dim = await self.dimension_service.get_dimension(action_in.dimension_id)
        except HTTPException as e:
            print(f"DEBUG: ActionService.create_action - Dimension validation FAILED: {str(e.detail)}")
            raise e
             
        print(f"DEBUG: ActionService.create_action - Dimension validated. Creating record...")
        action = await self.repo.create_for_user(user_id, action_in)
        # --- FIX: AGGIUNTO COMMIT PER PERSISTENZA ---
        await self.repo.session.commit()
        
        # Manually populate the relationship to avoid MissingGreenlet error on serialization
        action.dimension = dim 
        print(f"DEBUG: ActionService.create_action - SUCCESS: Created action {action.id}")
        return action

    async def get_user_actions(self, user_id: uuid.UUID, skip: int = 0, limit: int = 50) -> List[Action]:
        return await self.repo.get_recent_by_user(user_id, limit=limit, skip=skip)

    async def get_user_portfolio(self, user_id: uuid.UUID) -> List[dict]:
        """
        Retrieves unique actions that the user has successfully completed.
        """
        return await self.repo.get_unique_completed_actions(user_id)
        
    async def update_action(self, user_id: uuid.UUID, action_id: uuid.UUID, action_in: ActionUpdate) -> Action | None:
        action = await self.repo.update_for_user(user_id, action_id, action_in)
        if action:
            await self.repo.session.commit()
            # Manually populate dimension if id changed
            if action_in.dimension_id:
                action.dimension = await self.dimension_service.get_dimension(action.dimension_id)
        return action

    async def delete_action(self, user_id: uuid.UUID, action_id: uuid.UUID) -> bool:
        success = await self.repo.delete_for_user(user_id, action_id)
        if success:
            await self.repo.session.commit()
        return success
