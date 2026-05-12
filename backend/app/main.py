import structlog

from app.core.logging import configure_logging
from app.core.factory_fastapi_app import app

# Inizializza il logging strutturato prima della creazione dell'app
configure_logging()
logger = structlog.get_logger()

logger.info("Starting FastAPI application")
