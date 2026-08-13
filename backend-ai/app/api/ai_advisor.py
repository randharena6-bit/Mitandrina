"""Router pour l'analyse cyclonique instantanée."""

from datetime import datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.services.gemini_service import analyzer as gemini_analyzer
from app.services.openrouter_service import openrouter_analyzer

router = APIRouter()


class CyclonePoint(BaseModel):
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)
    title: Optional[str] = None
    level: Optional[str] = "vigilance"
    wind_speed: Optional[float] = None
    pressure: Optional[float] = None


class IncidentPoint(BaseModel):
    lat: float
    lng: float
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = "signalé"


class ShelterPoint(BaseModel):
    lat: float
    lng: float
    name: Optional[str] = None
    capacity: Optional[int] = 0


class WeatherData(BaseModel):
    temperature: Optional[float] = None
    humidity: Optional[float] = None
    wind_speed: Optional[float] = None
    pressure: Optional[float] = None


class AnalyzeCyclonesRequest(BaseModel):
    cyclones: List[CyclonePoint] = []
    incidents: List[IncidentPoint] = []
    shelters: List[ShelterPoint] = []
    weather: Optional[WeatherData] = None
    user_lat: Optional[float] = None
    user_lng: Optional[float] = None


class ZoneAdviceRequest(BaseModel):
    cyclone: CyclonePoint
    user_lat: float
    user_lng: float
    nearby_shelters: List[ShelterPoint] = []


@router.post("/analyze-cyclones", summary="Analyse cyclonique instantanée")
async def analyze_cyclones(request: AnalyzeCyclonesRequest):
    """
    Analyse instantanée des données cycloniques.
    Retourne analyse risque, recommandations, alertes et conseils d'évacuation.
    Temps de réponse < 50ms (pas d'appel API externe).
    """
    try:
        result = await gemini_analyzer.analyze(
            cyclones=[c.model_dump() for c in request.cyclones],
            incidents=[i.model_dump() for i in request.incidents],
            shelters=[s.model_dump() for s in request.shelters],
            weather=request.weather.model_dump() if request.weather else None,
            user_location={"lat": request.user_lat, "lng": request.user_lng}
            if request.user_lat is not None and request.user_lng is not None
            else None,
        )
        return {"success": True, "data": result, "timestamp": datetime.now(timezone.utc).isoformat()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur analyse: {str(e)}")


@router.post("/analyze-cyclones/deep", summary="Analyse cyclonique approfondie (Gemini)")
async def analyze_cyclones_deep(request: AnalyzeCyclonesRequest):
    """
    Analyse approfondie avec enrichment Gemini.
    Temps de réponse jusqu'à 15s (appel API Gemini).
    """
    try:
        result = await gemini_analyzer.analyze_deep(
            cyclones=[c.model_dump() for c in request.cyclones],
            incidents=[i.model_dump() for i in request.incidents],
            shelters=[s.model_dump() for s in request.shelters],
            weather=request.weather.model_dump() if request.weather else None,
            user_location={"lat": request.user_lat, "lng": request.user_lng}
            if request.user_lat is not None and request.user_lng is not None
            else None,
        )
        return {"success": True, "data": result, "timestamp": datetime.now(timezone.utc).isoformat()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur analyse approfondie: {str(e)}")


@router.post("/analyze-cyclones/openrouter", summary="Analyse cyclonique via OpenRouter")
async def analyze_cyclones_openrouter(request: AnalyzeCyclonesRequest):
    """
    Analyse cyclonique via OpenRouter (DeepSeek/autre LLM configuré).
    Fallback intelligent: utilise l'analyse locale si l'API OpenRouter est indisponible.
    """
    try:
        result = await openrouter_analyzer.analyze(
            cyclones=[c.model_dump() for c in request.cyclones],
            incidents=[i.model_dump() for i in request.incidents],
            shelters=[s.model_dump() for s in request.shelters],
            weather=request.weather.model_dump() if request.weather else None,
            user_location={"lat": request.user_lat, "lng": request.user_lng}
            if request.user_lat is not None and request.user_lng is not None
            else None,
        )
        return {"success": True, "data": result, "timestamp": datetime.now(timezone.utc).isoformat()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur analyse OpenRouter: {str(e)}")


@router.post("/analyze-zone", summary="Conseil spécifique à une zone touchée par un cyclone")
async def analyze_zone(request: ZoneAdviceRequest):
    """
    Analyse OpenRouter pour une zone spécifique.
    Retourne un conseil personnalisé, l'abri recommandé et l'action immédiate à prendre.
    Utile quand l'utilisateur clique sur un cyclone sur la carte.
    """
    try:
        result = await openrouter_analyzer.analyze_zone(
            cyclone=request.cyclone.model_dump(),
            user_lat=request.user_lat,
            user_lng=request.user_lng,
            nearby_shelters=[s.model_dump() for s in request.nearby_shelters],
        )
        return {"success": True, "data": result, "timestamp": datetime.now(timezone.utc).isoformat()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur analyse zone: {str(e)}")
