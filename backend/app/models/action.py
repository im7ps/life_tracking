import uuid
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, TYPE_CHECKING
from datetime import datetime
from sqlalchemy.dialects import postgresql
from app.models.utils import get_utc_now

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.dimension import Dimension

# --- ACTIONS (ex ActivityLog) ---
class Action(SQLModel, table=True):
    __tablename__ = "action" 
    
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)

    start_time: datetime = Field(default_factory=get_utc_now, index=True)
    end_time: Optional[datetime] = Field(default=None)
    description: Optional[str] = None
    
    # Day 0 specific fields
    category: str = Field(default="Dovere", index=True) 
    difficulty: int = Field(default=3, ge=1, le=5)
    status: str = Field(default="COMPLETED", index=True) # COMPLETED, FAILED, POSTPONED, IN_PROGRESS
    
    # Fulfillment Score (1-5) - acts as satisfaction
    fulfillment_score: int = Field(default=3, ge=1, le=5)
    
    # Duration and Timer
    duration_minutes: Optional[int] = Field(default=None)
    is_running: bool = Field(default=False)
    last_started_at: Optional[datetime] = Field(default=None)
    total_seconds: int = Field(default=0) # Total accumulated time in seconds
    
    # Future planning
    scheduled_date: Optional[datetime] = Field(default_factory=get_utc_now, index=True)
    is_recurring: bool = Field(default=False)
    
    # NEW: Sub-tasks (Checklist)
    sub_tasks: Optional[list[dict]] = Field(default_factory=list, sa_type=postgresql.JSONB)

    user_id: uuid.UUID = Field(foreign_key="user.id", index=True)
    user: Optional["User"] = Relationship(back_populates="actions")

    # Dimension FK is now a String (Slug)
    dimension_id: str = Field(foreign_key="dimension.id", index=True)
    dimension: Optional["Dimension"] = Relationship(back_populates="actions")
