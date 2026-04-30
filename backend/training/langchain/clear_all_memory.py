# training/langchain/clear_all_memory.py
import asyncio
import os
import sys

# --- FIX COMPATIBILITÀ WINDOWS ---
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# --- CONFIGURAZIONE AMBIENTE ---
current_dir = os.path.dirname(os.path.abspath(__file__))
# La struttura è backend/training/langchain/, quindi saliamo di due livelli per arrivare a backend/
backend_root = os.path.abspath(os.path.join(current_dir, "..", ".."))

if backend_root not in sys.path:
    sys.path.insert(0, backend_root)

# Caricamento delle variabili d'ambiente (DATABASE_URL)
from dotenv import load_dotenv
load_dotenv(os.path.join(backend_root, ".env"), override=True)

# Fallback se DATABASE_URL non è presente (costruisce la stringa dalle singole variabili)
if not os.getenv("DATABASE_URL"):
    user = os.getenv("POSTGRES_USER")
    pw = os.getenv("POSTGRES_PASSWORD")
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    db = os.getenv("POSTGRES_DB")
    if all([user, pw, db]):
        os.environ["DATABASE_URL"] = f"postgresql://{user}:{pw}@{host}:{port}/{db}"
        print(f"DEBUG: DATABASE_URL generata da variabili POSTGRES_*")

from app.core.llm.components.persistent_memory import get_db_memory

async def clear_all_memory():
    """Cancella tutti i dati di checkpoint dal database Postgres."""
    print("--- RESET TOTALE MEMORIA LANGGRAPH ---")
    
    try:
        checkpointer, pool = await get_db_memory()
        
        async with pool.connection() as conn:
            # Tabelle standard utilizzate da LangGraph PostgresSaver
            tables = ["checkpoints", "checkpoint_writes", "checkpoint_blobs"]
            
            for table in tables:
                try:
                    # TRUNCATE è più efficiente di DELETE per svuotare intere tabelle
                    await conn.execute(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE")
                    print(f"✅ Tabella '{table}' svuotata con successo.")
                except Exception as e:
                    # Se checkpoint_blobs non esiste o ci sono errori minori, continuiamo
                    print(f"⚠️  Info: Salto tabella '{table}' ({str(e).splitlines()[0]})")
            
            print("\n🚀 Memoria azzerata. Ora puoi ripartire da capo con qualsiasi thread_id.")
            
        await pool.close()
    except Exception as e:
        print(f"❌ Errore critico durante la connessione al DB: {e}")

if __name__ == "__main__":
    asyncio.run(clear_all_memory())
