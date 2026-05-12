from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from sqlmodel import select
from app.database.session import async_engine
from app.models.user import User
from app.database.session import AsyncSessionFactory

@tool
async def get_user_rank_db(config: RunnableConfig) -> str:
    """Use this tool when the user wants to know his rank"""
    user_id = config.get("configurable", {}).get("user_id")
    print(f"DEBUG TOOL: Accesso al DB per l'utente {user_id}...")
    
    if not user_id:
        return "Errore: ID utente mancante."

    session = AsyncSessionFactory()
    try:
        statement = select(User).where(User.id == user_id)
        result = await session.execute(statement)
        user = result.scalar_one_or_none()
        if not user:
            print(f"DEBUG TOOL: Utente {user_id} non trovato.")
            return f"Utente {user_id} non trovato."
        
        print(f"DEBUG TOOL: Recuperato rank {user.rank_score} per {user.username}")
        return f"L'utente {user.username} ha un Rank: {user.rank_score}"
    except Exception as e:
        print(f"DEBUG TOOL: Errore durante l'accesso al DB: {e}")
        await session.rollback()
        raise
    finally:
        await session.close()


# @tool
# async def delete_graph_score():
#     """"Use this tool to delete the user's score"""