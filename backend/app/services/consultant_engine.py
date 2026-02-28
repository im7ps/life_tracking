import uuid
import random
from typing import List, Set
from datetime import datetime
from app.models.action import Action
from app.repositories.action_repo import ActionRepo

class ConsultantEngine:
    """
    Dedicated engine for calculating task proposals (The 'Consultant').
    This is separated from the Service to allow for complex ranking/selection algorithms.
    """

    def __init__(self, action_repo: ActionRepo):
        self.action_repo = action_repo

    async def _build_pool(self, user_id: uuid.UUID) -> List[dict]:
        """
        Builds the full list of candidate task dicts for a user (history only,
        excluding tasks already completed today). Does NOT apply random selection.
        """
        history = await self.action_repo.get_all_by_user(user_id)

        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
        completed_today = {
            a.description.lower() for a in history
            if a.status == "COMPLETED" and a.start_time >= today_start
        }

        portfolio = self._extract_unique_tasks(history)
        available_portfolio = [
            t for t in portfolio
            if t['description'].lower() not in completed_today
        ]
        return available_portfolio

    async def generate_proposals(self, user_id: uuid.UUID, count: int = 5) -> List[Action]:
        """
        Orchestrates the selection of tasks based on history.
        """
        pool = await self._build_pool(user_id)
        selected_tasks = self._select_balanced_subset(pool, count)
        return self._map_to_actions(selected_tasks, user_id)

    async def find_proposal_by_id(self, user_id: uuid.UUID, proposal_id: uuid.UUID) -> Action | None:
        """
        Searches the full pool (not just the random top-N) for a proposal by ID.
        Required by consume_proposal so that any valid proposal can be found,
        regardless of which random subset was shown to the user.
        """
        pool = await self._build_pool(user_id)
        all_proposals = self._map_to_actions(pool, user_id)
        return next((p for p in all_proposals if p.id == proposal_id), None)

    def _extract_unique_tasks(self, history: List[Action]) -> List[dict]:
        """
        Converts history of actions into a list of unique task templates.
        """
        unique_tasks = {}
        for action in history:
            key = action.description.lower()
            if key not in unique_tasks:
                unique_tasks[key] = {
                    "description": action.description,
                    "category": action.category,
                    "difficulty": action.difficulty,
                    "fulfillment": action.fulfillment_score,
                    "dimension_id": action.dimension_id
                }
        return list(unique_tasks.values())

    def _select_balanced_subset(self, pool: List[dict], count: int) -> List[dict]:
        """
        Selection logic: currently uses weighted randomness or simple shuffle.
        Can be improved with AI or specific category balancing.
        """
        if not pool:
            return []
        
        # Simple shuffle for now, ensuring variety
        random.shuffle(pool)
        return pool[:count]

    def _map_to_actions(self, task_dicts: List[dict], user_id: uuid.UUID) -> List[Action]:
        """
        Converts task dictionaries into Action objects for the API.
        """
        actions = []
        for p in task_dicts:
            # Deterministic UUID per user + task description to keep ID stable for the same day
            proposal_id = uuid.uuid5(uuid.NAMESPACE_DNS, f"{user_id}-{p['description']}")
            actions.append(
                Action(
                    id=proposal_id,
                    description=p["description"],
                    user_id=user_id,
                    category=p["category"],
                    difficulty=p["difficulty"],
                    fulfillment_score=p["fulfillment"],
                    start_time=datetime.utcnow(),
                    dimension_id=p["dimension_id"],
                    status="PENDING"
                )
            )
        return actions
