# training/components/memory.py
from multiprocessing import pool
import os
from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
from psycopg_pool import AsyncConnectionPool

# Usiamo la stessa URL del tuo DB principale
DB_URI = os.getenv("DATABASE_URL")

async def get_db_memory():
    # 1. Pool di connessioni asincrone
    pool = AsyncConnectionPool(conninfo=DB_URI, max_size=20, open=False)
    await pool.open()

    # 2. Inizializziamo il saver
    checkpointer = AsyncPostgresSaver(pool)

    return checkpointer, pool