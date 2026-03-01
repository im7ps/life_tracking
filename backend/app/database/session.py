import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel
from app.core.config import settings

DATABASE_URL = os.getenv("DATABASE_URL")

# Il driver psycopg (v3) usa un dialetto diverso.
# Sostituiamo lo schema per assicurarci che SQLAlchemy usi il driver corretto.
ASYNC_DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg://")

# L'engine asincrono è il punto d'ingresso per le connessioni al database in un'app asincrona.
async_engine = create_async_engine(
    ASYNC_DATABASE_URL, 
    echo=False, 
    future=True,
    pool_size=settings.POSTGRES_POOL_SIZE,
    max_overflow=settings.POSTGRES_MAX_OVERFLOW,
    pool_recycle=3600,
    pool_pre_ping=True,
    pool_use_lifo=True
)

# La session factory crea nuove sessioni asincrone.
AsyncSessionFactory = sessionmaker(
    bind=async_engine, class_=AsyncSession, expire_on_commit=False
)

async def init_db():
    """
    Questa funzione asincrona crea le tabelle nel database se non esistono.
    """
    async with async_engine.begin() as conn:
        # await conn.run_sync(SQLModel.metadata.drop_all) # Opzionale: per ripartire da zero
        await conn.run_sync(SQLModel.metadata.create_all)

async def get_session() -> AsyncSession:
    """
    Questo generatore asincrono fornisce una sessione per interagire con i dati.
    Assicura che la sessione venga chiusa correttamente dopo l'uso.
    """
    async with AsyncSessionFactory() as session:
        yield session
