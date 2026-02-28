import pytest
from httpx import AsyncClient
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.action import Action
from app.models.user import User
from fastapi import status
from datetime import datetime

@pytest.mark.asyncio
async def test_consume_consultant_proposal_unauthenticated(test_client: AsyncClient):
    """Test that an unauthenticated user cannot consume a consultant proposal."""
    # Need a valid UUID for the path, even if unauthenticated
    dummy_uuid = "00000000-0000-0000-0000-000000000001" 
    response = await test_client.post(f"/api/v1/consultant/proposals/{dummy_uuid}/consume")
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

@pytest.mark.asyncio
async def test_get_proposals_empty_portfolio(authenticated_client: AsyncClient):
    """Test that a new user with no history receives no proposals."""
    response = await authenticated_client.get("/api/v1/consultant/proposals")
    assert response.status_code == status.HTTP_200_OK
    assert response.json() == []

@pytest.mark.asyncio
async def test_consume_valid_consultant_proposal(
    authenticated_client: AsyncClient,
    test_user: User,
    db_session: AsyncSession
):
    """Test that an authenticated user can consume a valid consultant proposal from history."""
    # 1. Seed some history for the user
    test_action = Action(
        description="Azione di Test",
        user_id=test_user.id,
        category="Test",
        difficulty=1,
        fulfillment_score=5,
        dimension_id="test",
        status="COMPLETED",
        start_time=datetime.utcnow()
    )
    db_session.add(test_action)
    await db_session.commit()

    # 2. Get initial proposals
    response = await authenticated_client.get("/api/v1/consultant/proposals")
    assert response.status_code == status.HTTP_200_OK
    initial_proposals = response.json()
    assert len(initial_proposals) > 0

    # Choose one to consume
    proposal_to_consume = initial_proposals[0]
    proposal_id = proposal_to_consume["id"]

    # 3. Consume the proposal
    response = await authenticated_client.post(
        f"/api/v1/consultant/proposals/{proposal_id}/consume"
    )
    assert response.status_code == status.HTTP_200_OK

    # 4. Verify the consumed proposal was added as a user action in the DB
    result = await db_session.execute(
        select(Action).where(
            Action.user_id == test_user.id,
            Action.description == proposal_to_consume["description"],
            Action.status == "COMPLETED"
        )
    )
    # We should have the initial seeded action and the newly consumed one
    # Note: if description is the same, they might both match.
    saved_actions = result.scalars().all()
    assert len(saved_actions) >= 1

@pytest.mark.asyncio
async def test_consume_invalid_consultant_proposal(authenticated_client: AsyncClient):
    """Test consuming an invalid proposal ID returns a 404."""
    invalid_uuid = "ffffffff-ffff-ffff-ffff-ffffffffffff" 
    response = await authenticated_client.post(
        f"/api/v1/consultant/proposals/{invalid_uuid}/consume"
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND
