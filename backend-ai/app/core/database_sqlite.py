"""
SQLite database for development (no PostgreSQL/PostGIS required)
"""

import sqlite3
from contextlib import asynccontextmanager
from pathlib import Path

DB_PATH = Path(__file__).parent.parent.parent / "mitandrina.db"


def get_db_connection():
    """Get SQLite connection."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    """Initialize database with schema."""
    conn = get_db_connection()
    
    # Read and execute schema
    schema_path = Path(__file__).parent.parent.parent.parent / "database" / "schema-sqlite.sql"
    if schema_path.exists():
        with open(schema_path) as f:
            conn.executescript(f.read())
    
    conn.close()
    print(f"✅ Database initialized: {DB_PATH}")


# FastAPI dependency
async def get_db():
    """Async generator for database sessions."""
    conn = get_db_connection()
    try:
        yield conn
    finally:
        conn.close()
