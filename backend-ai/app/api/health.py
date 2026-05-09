"""Router health check pour monitoring."""

from datetime import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

from app.models.schemas import HealthResponse
from app.core.database import get_db, engine
from app.services.queue import redis_client

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health_check(db: AsyncSession = Depends(get_db)):
    """
    Health check complet avec status des dépendances.
    """
    checks = {
        "database": {"status": "unknown"},
        "redis": {"status": "unknown"},
        "ml_models": {"status": "unknown"}
    }
    
    # Test PostgreSQL
    try:
        await db.execute(text("SELECT 1"))
        checks["database"] = {"status": "ok", "latency_ms": 0}
    except Exception as e:
        checks["database"] = {"status": "error", "error": str(e)}
    
    # Test Redis
    try:
        await redis_client.ping()
        checks["redis"] = {"status": "ok"}
    except Exception as e:
        checks["redis"] = {"status": "error", "error": str(e)}
    
    # Test modèles ML (mock)
    checks["ml_models"] = {
        "status": "ok",
        "loaded": ["flood_xgboost", "cyclone_ridge", "fire_cnn", "bert_nlp"]
    }
    
    # Déterminer status global
    all_ok = all(c["status"] == "ok" for c in checks.values())
    
    return HealthResponse(
        status="healthy" if all_ok else "degraded",
        service="mitandrina-ai",
        version="1.0.0",
        timestamp=datetime.utcnow(),
        checks=checks
    )


@router.get("/ready")
async def readiness_check():
    """Kubernetes readiness probe."""
    return {"ready": True}


@router.get("/live")
async def liveness_check():
    """Kubernetes liveness probe."""
    return {"alive": True}
