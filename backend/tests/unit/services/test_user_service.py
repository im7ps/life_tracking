import pytest
from app.core.exceptions import EntityAlreadyExists
import uuid
from datetime import datetime

from app.services.user_service import UserService
from app.schemas.user import UserCreate
from app.models.user import User

from unittest.mock import AsyncMock
from tests.unit.fakes import FakeUserRepo

# --- UserService Unit Tests ---

@pytest.fixture
def user_service() -> UserService:
    """Provides a UserService instance with a fresh FakeUserRepo and a mock session."""
    return UserService(session=AsyncMock(), user_repo=FakeUserRepo())

@pytest.mark.asyncio
async def test_create_user_success(user_service: UserService):
    """
    Tests the happy path for creating a user.
    """
    user_data = UserCreate(
        username="testuser",
        email="test@example.com",
        password="ValidPassword123!"
    )
    
    # Action
    created_user = await user_service.create_user(user_data)
    
    # Assertions
    assert created_user is not None
    assert created_user.username == user_data.username
    assert created_user.email == user_data.email
    assert created_user.rank_score == 0
    assert created_user.id is not None
    assert created_user.created_at is not None
    
    # Check that the password was hashed
    assert created_user.hashed_password != user_data.password
    
    # Check that the session's commit method was called once
    await user_service.session.commit.assert_awaited_once()
    
    # Check that the user was "saved" in the fake repo
    saved_user = await user_service.user_repo.get_by_username("testuser")
    assert saved_user is not None
    assert saved_user.email == user_data.email


@pytest.mark.asyncio
async def test_create_user_fails_if_username_exists(user_service: UserService):
    """
    Tests that creating a user fails with EntityAlreadyExists if the username
    is already taken.
    """
    # Arrange: pre-populate the fake repo with an existing user
    existing_user_data = UserCreate(
        username="existinguser",
        email="existing@example.com",
        password="ValidPassword123!"
    )
    await user_service.create_user(existing_user_data)

    # New user data with the same username
    new_user_data = UserCreate(
        username="existinguser",
        email="new@example.com",
        password="AnotherPassword123!"
    )
    
    # Action & Assert
    with pytest.raises(EntityAlreadyExists) as exc_info:
        await user_service.create_user(new_user_data)
        
    assert "Username already registered" in exc_info.value.message


@pytest.mark.asyncio
async def test_create_user_fails_if_email_exists(user_service: UserService):
    """
    Tests that creating a user fails with EntityAlreadyExists if the email
    is already registered.
    """
    # Arrange: pre-populate the fake repo with an existing user
    existing_user_data = UserCreate(
        username="existinguser",
        email="existing@example.com",
        password="ValidPassword123!"
    )
    await user_service.create_user(existing_user_data)

    # New user data with the same email
    new_user_data = UserCreate(
        username="newuser",
        email="existing@example.com",
        password="AnotherPassword123!"
    )
    
    # Action & Assert
    with pytest.raises(EntityAlreadyExists) as exc_info:
        await user_service.create_user(new_user_data)
        
    assert "Email already registered" in exc_info.value.message


@pytest.mark.asyncio
async def test_get_user_by_username(user_service: UserService):
    """
    Tests retrieving a user by username.
    """
    # Arrange
    user_data = UserCreate(
        username="findme",
        email="findme@example.com",
        password="ValidPassword123!"
    )
    await user_service.create_user(user_data)
    
    # Action
    found_user = await user_service.get_user_by_username("findme")
    not_found_user = await user_service.get_user_by_username("nosuchuser")
    
    # Assert
    assert found_user is not None
    assert found_user.username == "findme"
    assert not_found_user is None
