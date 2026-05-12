import os
import structlog
from fastapi import FastAPI
from contextlib import asynccontextmanager

from app.services.chat_graph import compile_graph
from app.database.session import async_engine, close_db
from app.core.config import settings

logger = structlog.get_logger()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Questo codice viene eseguito all'avvio dell'applicazione
    logger.info("Application starting", env=settings.ENVIRONMENT)
    
    # Configurazione LangChain / LangSmith Tracing
    if settings.LANGCHAIN_API_KEY:
        os.environ["LANGCHAIN_TRACING_V2"] = settings.LANGCHAIN_TRACING_V2
        os.environ["LANGCHAIN_API_KEY"] = settings.LANGCHAIN_API_KEY
        os.environ["LANGCHAIN_PROJECT"] = settings.LANGCHAIN_PROJECT
        logger.info("LangChain tracing enabled", project=settings.LANGCHAIN_PROJECT)
    
    from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
    from psycopg_pool import AsyncConnectionPool
    
    conn_string = settings.DATABASE_URL
    if not conn_string:
        logger.error("DATABASE_URL not set, chat graph will not work")
        yield
        return
    
    # Psycopg (usato qui da AsyncConnectionPool) vuole una URL standard (senza +psycopg).
    # Rimuoviamo eventuali driver SQLAlchemy se presenti.
    clean_conn_string = conn_string.replace("+psycopg", "").replace("+asyncpg", "")

    # Usiamo un pool di connessioni per gestire la concorrenza e la stabilità
    try:
        async with AsyncConnectionPool(clean_conn_string, max_size=20, kwargs={"autocommit": True}) as pool:
            checkpointer = AsyncPostgresSaver(pool)
            # Setup crea le tabelle se non esistono
            await checkpointer.setup()
            logger.info("LangGraph checkpointer (Pool) initialized and tables verified")
            app.state.app_graph = compile_graph(checkpointer)
            yield
    except Exception as e:
        logger.error("Failed to initialize LangGraph checkpointer pool", error=str(e))
        yield
    finally:
        logger.info("LangGraph checkpointer pool context closing")
        # Chiudiamo esplicitamente l'engine principale di SQLAlchemy
        await close_db()
    logger.info("Application shutting down")