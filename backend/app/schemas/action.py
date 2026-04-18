from sqlmodel import SQLModel
import uuid
from typing import Optional, Literal
from datetime import datetime
from pydantic import field_validator


from .base import TunableBaseModel
from .dimension import DimensionRead
from .validators import validate_xss_basic

# --- Schemi Action ---

class ActionBase(TunableBaseModel):
    description: Optional[str] = None
    category: Optional[str] = None
    difficulty: Optional[int] = None
    status: Optional[str] = None
    icon: Optional[str] = None # Icon slug
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    duration_minutes: Optional[int] = None
    dimension_id: Optional[str] = None 
    fulfillment_score: Optional[int] = None
    
    # Timer fields
    is_running: Optional[bool] = None
    last_started_at: Optional[datetime] = None
    total_seconds: Optional[int] = None
    
    # Future planning
    scheduled_date: Optional[datetime] = None
    is_recurring: Optional[bool] = None
    
    # Sub-tasks
    sub_tasks: Optional[list[dict]] = None

    @field_validator("description")
    def validate_desc(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        return validate_xss_basic(v)
        
    @field_validator("fulfillment_score")
    def validate_score(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and not (1 <= v <= 5):
            raise ValueError("Fulfillment score must be between 1 and 5")
        return v

class ActionCreate(ActionBase):
    dimension_id: Literal["dovere", "passione", "energia", "relazioni", "anima"]  # Required (Slug)
    fulfillment_score: int = 3
    category: str = "Dovere"
    difficulty: int = 3
    status: str = "COMPLETED"
    icon: str = "briefcase"

class ActionUpdate(ActionBase):
    pass

class ActionRead(ActionBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: Optional[datetime] = None
    dimension: Optional[DimensionRead] = None
    completion_count: Optional[int] = 0
