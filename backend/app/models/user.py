import uuid
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List, TYPE_CHECKING
from datetime import datetime
from sqlalchemy import JSON, Column, func
from app.models.utils import get_utc_now

if TYPE_CHECKING:
    from app.models.action import Action
    from app.models.daily_log import DailyLog
    from app.models.dimension import Dimension

# --- UTENTE ---
class User(SQLModel, table=True):
    # --- INFRASTRUCTURE ---
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True, index=True)
    username: str = Field(unique=True, index=True)
    email: str = Field(unique=True)
    hashed_password: str
    is_active: bool = Field(default=True)

    # --- BUSINESS LOGIC ---
    rank_score: int = Field(default=0, sa_column_kwargs={"server_default": "0"})
    onboarding_completed: bool = Field(default=False)
    timezone: str = Field(default="UTC")
    
    # --- DYNAMIC IDENTITY (for AI purposes) ---
    bio: dict = Field(
                    default_factory=dict,
                    sa_column=Column(JSON)
                )

    created_at: datetime = Field(default_factory=get_utc_now)
    updated_at: Optional[datetime] = Field(
        default=None, 
        sa_column_kwargs={"onupdate": func.now()}
    )

    actions: List["Action"] = Relationship(back_populates="user")
    daily_logs: List["DailyLog"] = Relationship(back_populates="user")
