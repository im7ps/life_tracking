import os
import structlog
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel
from app.core.config import settings

logger = structlog.get_logger(__name__)

# Il driver psycopg (v3) usa un dialetto diverso.
# Sostituiamo lo schema per assicurarci che SQLAlchemy usi il driver corretto.
ASYNC_DATABASE_URL = settings.DATABASE_URL.replace(
    "postgresql://", "postgresql+psycopg://")

# L'engine asincrono è il punto d'ingresso per le connessioni al database in un'app asincrona.
async_engine = create_async_engine(
    ASYNC_DATABASE_URL, 
    echo=False,
    pool_pre_ping=True,
    pool_size=settings.POSTGRES_POOL_SIZE,
    max_overflow=settings.POSTGRES_MAX_OVERFLOW,
    pool_recycle=3600,
    pool_use_lifo=True,
    pool_reset_on_return="rollback"
    )

# La session factory crea nuove sessioni asincrone.
AsyncSessionFactory = async_sessionmaker(
    bind=async_engine, 
    autoflush=False,
    expire_on_commit=False,
    class_=AsyncSession
)

async def init_db():
    """
    Questa funzione asincrona crea le tabelle nel database se non esistono.
    """
    async with async_engine.begin() as conn:
        # await conn.run_sync(SQLModel.metadata.drop_all) # Opzionale: per ripartire da zero
        await conn.run_sync(SQLModel.metadata.create_all)

async def close_db():
    """
    Chiude l'engine e libera le risorse del pool.
    Da chiamare nello shutdown dell'app.
    """
    await async_engine.dispose()
    logger.info("Database engine disposed")

async def get_session() -> AsyncSession:
    """
    Questo generatore asincrono fornisce una sessione per interagire con i dati.
    Usa try/finally per garantire il rientro nel pool anche su disconnessione o eccezione.
    """
    session = AsyncSessionFactory()
    logger.debug("session_opened", session_id=id(session))
    try:
        yield session
    except Exception as e:
        logger.error("session_error", session_id=id(session), error=str(e))
        await session.rollback()
        raise
    finally:
        logger.debug("session_closing", session_id=id(session))
        await session.close()
        logger.debug("session_closed", session_id=id(session))
