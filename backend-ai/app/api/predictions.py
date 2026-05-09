"""Router pour les prédictions IA (Flood, Cyclone)."""

from datetime import datetime, timedelta
from typing import List, Dict, Any

from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.schemas import (
    PredictionRequest, 
    PredictionResponse, 
    RiskAssessmentRequest,
    DisasterType,
    AlertLevel,
    ModelType
)
from app.core.database import get_db
from app.services.ml_models import flood_model, cyclone_model
from app.services.queue import enqueue_alert_check

router = APIRouter()


@router.post("/flood", response_model=PredictionResponse)
async def predict_flood(
    request: PredictionRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db)
):
    """
    Prédit le risque d'inondation avec XGBoost.
    
    Features utilisées:
    - Précipitations 24h/7j
    - Niveau des rivières
    - Humidité du sol
    - Topographie
    """
    try:
        # Récupérer données météo
        weather_data = await flood_model.get_weather_features(
            request.lat, request.lng
        )
        
        # Prédiction
        result = await flood_model.predict(
            lat=request.lat,
            lng=request.lng,
            weather_features=weather_data,
            horizon_hours=request.horizon_hours
        )
        
        prediction = PredictionResponse(
            id=result["id"],
            type=DisasterType.inondation,
            confidence_score=result["confidence"],
            severity=_score_to_level(result["confidence"]),
            predicted_zone=result["zone"],
            center_lat=request.lat,
            center_lng=request.lng,
            horizon=datetime.utcnow() + timedelta(hours=request.horizon_hours),
            model_used=ModelType.xgboost,
            features=weather_data,
            created_at=datetime.utcnow()
        )
        
        # Si risque élevé, déclencher vérification d'alerte
        if result["confidence"] > 75:
            background_tasks.add_task(
                enqueue_alert_check,
                prediction.dict(),
                "flood"
            )
        
        return prediction
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur prédiction: {str(e)}")


@router.post("/cyclone", response_model=PredictionResponse)
async def predict_cyclone(
    request: PredictionRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db)
):
    """
    Prédit le risque cyclonique avec modèle Ridge + données météo océanique.
    """
    try:
        result = await cyclone_model.predict(
            lat=request.lat,
            lng=request.lng,
            horizon_hours=request.horizon_hours
        )
        
        return PredictionResponse(
            id=result["id"],
            type=DisasterType.cyclone,
            confidence_score=result["confidence"],
            severity=_score_to_level(result["confidence"]),
            predicted_zone=result["zone"],
            center_lat=request.lat,
            center_lng=request.lng,
            horizon=datetime.utcnow() + timedelta(hours=request.horizon_hours),
            model_used=ModelType.ridge_regression,
            features=result["features"],
            created_at=datetime.utcnow()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur prédiction: {str(e)}")


@router.post("/risk-assessment")
async def assess_risk_batch(
    request: RiskAssessmentRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Évalue le risque pour plusieurs points en parallèle.
    Utile pour les cartes de chaleur.
    """
    results = []
    
    for loc in request.locations:
        # Prédiction parallèle flood + cyclone
        flood_risk = await flood_model.quick_risk(loc["lat"], loc["lng"])
        cyclone_risk = await cyclone_model.quick_risk(loc["lat"], loc["lng"])
        
        max_risk = max(flood_risk, cyclone_risk, key=lambda x: x["score"])
        
        results.append({
            "lat": loc["lat"],
            "lng": loc["lng"],
            "risk_score": max_risk["score"],
            "risk_type": max_risk["type"],
            "level": _score_to_level(max_risk["score"]).value
        })
    
    return {
        "assessments": results,
        "highest_risk": max(results, key=lambda x: x["risk_score"]) if results else None,
        "timestamp": datetime.utcnow()
    }


@router.get("/history")
async def get_prediction_history(
    lat: float,
    lng: float,
    radius_km: float = 50,
    days: int = 7,
    db: AsyncSession = Depends(get_db)
):
    """Récupère l'historique des prédictions pour une zone."""
    from sqlalchemy import text
    
    query = text("""
        SELECT * FROM ai_predictions
        WHERE ST_DWithin(
            ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
            center_location,
            :radius
        )
        AND created_at >= NOW() - INTERVAL ':days days'
        ORDER BY created_at DESC
    """)
    
    result = await db.execute(
        query, 
        {"lat": lat, "lng": lng, "radius": radius_km * 1000, "days": days}
    )
    predictions = result.mappings().all()
    
    return {
        "predictions": [dict(p) for p in predictions],
        "count": len(predictions)
    }


def _score_to_level(score: float) -> AlertLevel:
    """Convertit un score 0-100 en niveau d'alerte."""
    if score >= 76:
        return AlertLevel.urgence
    elif score >= 56:
        return AlertLevel.alerte
    elif score >= 31:
        return AlertLevel.vigilance
    return AlertLevel.info
