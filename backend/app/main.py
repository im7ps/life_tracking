from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import structlog
import os

from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware

from app.api.v1.routers import auth, users, dimensions, actions, daily_logs, consultant, chat
from app.core.exceptions import (
    ResourceNotFound,
    EntityAlreadyExists,
    InvalidCredentials,
    DomainValidationError,
)
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.logging import configure_logging
from app.core.config import settings
from app.core.rate_limit import limiter
from app.services.chat_graph import compile_graph


# Inizializza il logging strutturato prima della creazione dell'app
configure_logging()
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

    logger.info("Application shutting down")


app = FastAPI(
    title="What I've Done API",
    description="Backend for the What I've Done productivity tracker.",
    version="0.1.0",
    lifespan=lifespan
)

# Configurazione Proxy Headers
app.add_middleware(ProxyHeadersMiddleware, trusted_hosts=["*"])

# Configurazione Rate Limiting
app.state.limiter = limiter
app.state.app_graph = None
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Configurazione CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(ResourceNotFound)
async def resource_not_found_handler(request: Request, exc: ResourceNotFound):
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={"detail": exc.message},
    )

@app.exception_handler(EntityAlreadyExists)
async def entity_already_exists_handler(request: Request, exc: EntityAlreadyExists):
    return JSONResponse(
        status_code=status.HTTP_409_CONFLICT,
        content={"detail": exc.message},
    )

@app.exception_handler(InvalidCredentials)
async def invalid_credentials_handler(request: Request, exc: InvalidCredentials):
    return JSONResponse(
        status_code=status.HTTP_401_UNAUTHORIZED,
        content={"detail": exc.message},
    )

@app.exception_handler(DomainValidationError)
async def domain_validation_error_handler(request: Request, exc: DomainValidationError):
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={"detail": exc.message},
    )

app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/v1/users", tags=["users"])
app.include_router(dimensions.router, prefix="/api/v1/dimensions", tags=["dimensions"])
app.include_router(actions.router, prefix="/api/v1/actions", tags=["actions"])
app.include_router(daily_logs.router, prefix="/api/v1/daily-logs", tags=["daily-logs"])
app.include_router(consultant.router, prefix="/api/v1/consultant", tags=["consultant"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["chat"])


@app.get("/")
def read_root():
    return {"message": "Welcome to the What I've Done API"}
