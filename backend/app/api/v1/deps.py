from typing import Annotated, Any
import uuid
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.core.exceptions import InvalidCredentials, AccessTokenExpired, InvalidToken
from app.database.session import get_session
from app.models.user import User
from app.repositories.user_repo import UserRepo
from app.services.user_service import UserService
from app.services.auth_service import AuthService

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def get_user_repo(session: Annotated[AsyncSession, Depends(get_session)]) -> UserRepo:
    return UserRepo(session)

def get_user_service(
    session: Annotated[AsyncSession, Depends(get_session)],
    repo: Annotated[UserRepo, Depends(get_user_repo)]
) -> UserService:
    return UserService(session=session, user_repo=repo)

def get_auth_service(user_service: Annotated[UserService, Depends(get_user_service)]) -> AuthService:
    return AuthService(user_service)


# --- Type Aliases for Dependencies ---

TokenDep = Annotated[str, Depends(oauth2_scheme)]
UserServiceDep = Annotated[UserService, Depends(get_user_service)]
AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]

# --- Dependency for Getting Current User ---

async def get_current_user(
    token: TokenDep,
    user_service: UserServiceDep
) -> User:
    try:
        payload = decode_access_token(token)
        user_id_str: str | None = payload.get("sub")
        if user_id_str is None:
            raise InvalidToken("Subject not found in token")
            
    except AccessTokenExpired:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except (InvalidToken, InvalidCredentials):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_id = uuid.UUID(user_id_str)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user ID format in token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user = await user_service.get_user_by_id(user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

CurrentUser = Annotated[User, Depends(get_current_user)]

async def get_current_active_user(current_user: CurrentUser) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# --- Repositories ---
from app.repositories.dimension_repo import DimensionRepo
from app.repositories.action_repo import ActionRepo
from app.repositories.daily_log_repo import DailyLogRepo

def get_dimension_repo(session: Annotated[AsyncSession, Depends(get_session)]) -> DimensionRepo:
    return DimensionRepo(session)

def get_action_repo(session: Annotated[AsyncSession, Depends(get_session)]) -> ActionRepo:
    return ActionRepo(session)

def get_daily_log_repo(session: Annotated[AsyncSession, Depends(get_session)]) -> DailyLogRepo:
    return DailyLogRepo(session)

# --- Services (Lazy Import per evitare TypeError e Circolarità) ---

def get_dimension_service(repo: Annotated[ActionRepo, Depends(get_dimension_repo)]) -> Any:
    from app.services.dimension_service import DimensionService
    return DimensionService(repo)

def get_action_service(
    repo: Annotated[ActionRepo, Depends(get_action_repo)],
    dim_repo: Annotated[DimensionRepo, Depends(get_dimension_repo)]
) -> Any:
    from app.services.action_service import ActionService
    from app.services.dimension_service import DimensionService
    dim_service = DimensionService(dim_repo)
    return ActionService(repo, dim_service)

def get_daily_log_service(
    session: Annotated[AsyncSession, Depends(get_session)],
    repo: Annotated[DailyLogRepo, Depends(get_daily_log_repo)]
) -> Any:
    from app.services.daily_log_service import DailyLogService
    return DailyLogService(session, repo)

def get_consultant_engine(
    repo: Annotated[ActionRepo, Depends(get_action_repo)]
) -> Any:
    from app.services.consultant_engine import ConsultantEngine
    # Log di debug esplicito (visibile nei log docker)
    print(f"DEBUG: Initializing ConsultantEngine with repo {repo}")
    return ConsultantEngine(action_repo=repo)

def get_consultant_service(
    action_service: Annotated[Any, Depends(get_action_service)],
    engine: Annotated[Any, Depends(get_consultant_engine)]
) -> Any:
    from app.services.consultant_service import ConsultantService
    return ConsultantService(
        action_service,
        engine
    )

def get_chat_service(
    request: Request,
    user_service: Annotated[UserService, Depends(get_user_service)],
    action_service: Annotated[Any, Depends(get_action_service)],
    consultant_service: Annotated[Any, Depends(get_consultant_service)]
) -> Any:
    from app.services.chat_service import ChatService
    return ChatService(
        user_service,
        action_service,
        consultant_service,
        app_graph=getattr(request.app.state, "app_graph", None),
    )
