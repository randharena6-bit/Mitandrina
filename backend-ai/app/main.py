"""
🌪️ MITANDRINA - FastAPI AI Services
Services: Prédictions IA, Détection Incendies, NLP, Calcul A*
"""

import asyncio
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

from app.api import (
    predictions,
    fire_detection,
    nlp_analysis,
    routing,
    weather,
    health
)
from app.core.config import settings
from app.core.database import engine, Base
from app.services.queue import redis_client


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gestion du cycle de vie de l'application."""
    # Startup
    print("🚀 Initialisation MITANDRINA AI Services...")
    
    # Test Redis
    try:
        await redis_client.ping()
        print("✅ Redis connecté")
    except Exception as e:
        print(f"⚠️ Redis non disponible: {e}")
    
    yield
    
    # Shutdown
    print("🛑 Arrêt des services...")
    await redis_client.close()


# Application FastAPI
app = FastAPI(
    title="🌪️ MITANDRINA AI Services",
    description="API IA pour prédiction, détection et calcul d'itinéraires",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# Middlewares
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)


# Exception handler global
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "Erreur interne du service IA", "error": str(exc)}
    )


# Inclusion des routers
app.include_router(health.router, tags=["Health"])
app.include_router(predictions.router, prefix="/api/v1/predictions", tags=["Prédictions IA"])
app.include_router(fire_detection.router, prefix="/api/v1/fire", tags=["Détection Incendies"])
app.include_router(nlp_analysis.router, prefix="/api/v1/nlp", tags=["Analyse NLP"])
app.include_router(routing.router, prefix="/api/v1/routing", tags=["Calcul Routes A*"])
app.include_router(weather.router, prefix="/api/v1/weather", tags=["Données Météo"])


@app.get("/")
async def root():
    return {
        "name": "🌪️ MITANDRINA AI Services",
        "version": "1.0.0",
        "services": [
            "predictions",
            "fire_detection", 
            "nlp_analysis",
            "routing_astar",
            "weather_aggregation"
        ],
        "docs": "/docs"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        workers=1 if settings.DEBUG else 4
    )
