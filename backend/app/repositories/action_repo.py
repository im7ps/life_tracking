from typing import List
import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlmodel import select, desc
from app.models.action import Action
from app.schemas.action import ActionCreate, ActionUpdate
from app.repositories.user_owned_repo import UserOwnedRepo

class ActionRepo(UserOwnedRepo[Action, ActionCreate, ActionUpdate]):
    def __init__(self, session: AsyncSession):
        super().__init__(model=Action, session=session)

    async def get_recent_by_user(
        self, 
        user_id: uuid.UUID, 
        limit: int = 50, 
        skip: int = 0
    ) -> List[Action]:
        statement = (
            select(self.model)
            .options(selectinload(self.model.dimension))
            .where(self.model.user_id == user_id)
            .order_by(desc(self.model.start_time))
            .offset(skip)
            .limit(limit)
        )
        # result = await self.session.exec(statement) # SQLModel .exec is for Sync, for AsyncSession use .execute
        result = await self.session.execute(statement)
        return result.scalars().all()

    async def get_unique_completed_actions(self, user_id: uuid.UUID) -> List[dict]:
        """
        Returns a list of unique actions with stats (count, avg satisfaction).
        """
        print(f"DEBUG: ActionRepo.get_unique_completed_actions - Fetching for user {user_id}")
        from sqlalchemy import func, or_
        
        # Subquery to get the latest action for each unique description to get current attributes
        latest_subquery = (
            select(
                self.model.description,
                func.max(self.model.start_time).label("max_time")
            )
            .where(self.model.user_id == user_id)
            .group_by(self.model.description)
            .subquery()
        )
        
        # Query to get the stats
        stats_query = (
            select(
                self.model.description,
                func.count(self.model.id).label("count"),
                func.avg(self.model.fulfillment_score).label("avg_satisfaction"),
                func.avg(self.model.difficulty).label("avg_difficulty")
            )
            .where(self.model.user_id == user_id)
            .where(self.model.status == "COMPLETED")
            .group_by(self.model.description)
            .subquery()
        )

        statement = (
            select(
                self.model,
                func.coalesce(stats_query.c.count, 0).label("completion_count"),
                func.coalesce(stats_query.c.avg_satisfaction, self.model.fulfillment_score).label("avg_fulfillment"),
                func.coalesce(stats_query.c.avg_difficulty, self.model.difficulty).label("avg_difficulty_stat")
            )
            .join(
                latest_subquery,
                (self.model.description == latest_subquery.c.description) & 
                (self.model.start_time == latest_subquery.c.max_time)
            )
            .outerjoin(
                stats_query,
                self.model.description == stats_query.c.description
            )
            .where(self.model.user_id == user_id)
            .options(selectinload(self.model.dimension))
        )
        
        result = await self.session.execute(statement)
        rows = result.all()
        
        portfolio = []
        for row in rows:
            action = row.Action
            # We build a clean dictionary, ensuring all required fields for ActionRead are present
            # and explicitly setting 'dimension' to None to avoid Pydantic trying to access the lazy relationship
            action_data = {
                "id": action.id,
                "user_id": action.user_id,
                "description": action.description,
                "category": action.category,
                "difficulty": int(row.avg_difficulty_stat),
                "fulfillment_score": int(row.avg_fulfillment),
                "status": action.status,
                "start_time": action.start_time,
                "dimension_id": action.dimension_id,
                "completion_count": row.completion_count,
                "duration_minutes": action.duration_minutes,
                "is_running": action.is_running,
                "total_seconds": action.total_seconds,
                "is_recurring": action.is_recurring,
                "sub_tasks": action.sub_tasks,
                "dimension": None # Prevent lazy-loading attempt by Pydantic
            }
            portfolio.append(action_data)
            
        print(f"DEBUG: ActionRepo.get_unique_completed_actions - FOUND {len(portfolio)} unique actions with stats")
        return portfolio
