from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from app.database.session import async_engine
from app.models.user import User

@tool
async def get_user_rank_db(config: RunnableConfig) -> str:
    """Use this tool when the user wants to know his rank"""
    user_id = config.get("configurable", {}).get("user_id")
    print(f"DEBUG TOOL: Accesso al DB per l'utente {user_id}...")
    
    if not user_id:
        return "Errore: ID utente mancante."

    async with AsyncSession(async_engine) as session:
        statement = select(User).where(User.id == user_id)
        result = await session.execute(statement)
        user = result.scalar_one_or_none()
        if not user:
            print(f"DEBUG TOOL: Utente {user_id} non trovato.")
            return f"Utente {user_id} non trovato."
        
        print(f"DEBUG TOOL: Recuperato rank {user.rank_score} per {user.username}")
        return f"L'utente {user.username} ha un Rank: {user.rank_score}"