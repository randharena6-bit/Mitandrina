"""Configuration base de données async SQLAlchemy + PostGIS."""

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import create_engine

from app.core.config import settings

# Engine async pour FastAPI
engine = create_async_engine(
    str(settings.DATABASE_URL),
    echo=settings.DEBUG,
    pool_size=20,
    max_overflow=30,
    pool_recycle=3600,
)

# Engine sync pour les tâches background
engine_sync = create_engine(
    settings.DATABASE_URL_SYNC,
    pool_size=10,
    max_overflow=20
)

# Sessions
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine_sync)

# Base déclarative
Base = declarative_base()


async def get_db():
    """Dependency pour obtenir une session DB."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def init_db():
    """Initialise les tables (à utiliser avec Alembic en prod)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
