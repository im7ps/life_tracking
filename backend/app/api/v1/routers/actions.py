from typing import List
from fastapi import APIRouter, Depends, status
from app.schemas.action import ActionRead, ActionCreate, ActionUpdate
from app.models.user import User
from app.api.v1.deps import get_current_active_user, get_action_service
from app.services.action_service import ActionService

router = APIRouter()

@router.post("/", response_model=ActionRead, status_code=status.HTTP_201_CREATED)
async def create_action(
    action_in: ActionCreate,
    current_user: User = Depends(get_current_active_user),
    service: ActionService = Depends(get_action_service),
):
    """
    Create a new action (activity log) for a specific dimension.
    """
    return await service.create_action(current_user.id, action_in)

@router.get("/", response_model=List[ActionRead])
async def read_actions(
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_active_user),
    service: ActionService = Depends(get_action_service),
):
    """
    Retrieve user actions.
    """
    return await service.get_user_actions(current_user.id, skip=skip, limit=limit)

@router.get("/portfolio", response_model=List[ActionRead])
async def read_portfolio(
    current_user: User = Depends(get_current_active_user),
    service: ActionService = Depends(get_action_service),
):
    """
    Retrieve user portfolio (unique actions).
    """
    return await service.get_user_portfolio(current_user.id)

@router.patch("/{action_id}", response_model=ActionRead)
async def update_action(
    action_id: str,
    action_in: ActionUpdate,
    current_user: User = Depends(get_current_active_user),
    service: ActionService = Depends(get_action_service),
):
    """
    Update a specific action.
    """
    import uuid
    try:
        uid = uuid.UUID(action_id)
    except ValueError:
        from fastapi import HTTPException
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    action = await service.update_action(current_user.id, uid, action_in)
    if not action:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Action not found or not owned by user")
    return action

@router.delete("/{action_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_action(
    action_id: str,
    current_user: User = Depends(get_current_active_user),
    service: ActionService = Depends(get_action_service),
):
    """
    Delete a specific action.
    """
    import uuid
    try:
        uid = uuid.UUID(action_id)
    except ValueError:
        from fastapi import HTTPException
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    success = await service.delete_action(current_user.id, uid)
    if not success:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Action not found or not owned by user")
    return None
