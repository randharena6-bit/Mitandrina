"""Router pour la détection d'incendies par CNN."""

import base64
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, HTTPException, UploadFile, File, Form

from app.models.schemas import (
    FireDetectionRequest, 
    FireDetectionResponse,
    SatelliteFireData
)
from app.services.ml_models import fire_cnn_model
from app.services.nasa_firms import fetch_nasa_detections

router = APIRouter()


@router.post("/detect", response_model=FireDetectionResponse)
async def detect_fire_image(
    image: Optional[UploadFile] = File(None),
    lat: float = Form(...),
    lng: float = Form(...),
    source: str = Form("upload")
):
    """
    Détecte les incendies sur une image via CNN ResNet-50.
    Accepte upload direct ou URL.
    """
    try:
        if image:
            contents = await image.read()
            result = await fire_cnn_model.predict_from_bytes(contents)
        else:
            raise HTTPException(status_code=400, detail="Image requise")
        
        return FireDetectionResponse(
            fire_detected=result["fire_detected"],
            confidence=result["confidence"],
            bounding_boxes=result["boxes"],
            heat_score=result["heat_score"],
            coordinates={"lat": lat, "lng": lng},
            processed_at=datetime.utcnow()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur détection: {str(e)}")


@router.post("/detect-url", response_model=FireDetectionResponse)
async def detect_fire_from_url(request: FireDetectionRequest):
    """Détecte incendie depuis une URL d'image."""
    if not request.image_url:
        raise HTTPException(status_code=400, detail="image_url requis")
    
    try:
        result = await fire_cnn_model.predict_from_url(request.image_url)
        
        return FireDetectionResponse(
            fire_detected=result["fire_detected"],
            confidence=result["confidence"],
            bounding_boxes=result["boxes"],
            heat_score=result["heat_score"],
            coordinates={"lat": request.lat, "lng": request.lng},
            processed_at=datetime.utcnow()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur détection: {str(e)}")


@router.get("/satellite/nasa-firms", response_model=SatelliteFireData)
async def get_nasa_firms_data(
    min_lat: float,
    max_lat: float,
    min_lng: float,
    max_lng: float,
    hours: int = 24
):
    """
    Récupère les données satellites NASA FIRMS pour une zone.
    
    Bounding box exemple (Madagascar):
    - min_lat=-25.6, max_lat=-11.9
    - min_lng=43.1, max_lng=50.5
    """
    try:
        detections = await fetch_nasa_detections(
            min_lat, max_lat, min_lng, max_lng, hours
        )
        
        return SatelliteFireData(
            source="NASA FIRMS",
            detections=detections,
            last_updated=datetime.utcnow()
        )
        
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"NASA FIRMS indisponible: {str(e)}")


@router.get("/active-fires")
async def get_active_fires_in_zone(
    lat: float,
    lng: float,
    radius_km: float = 100
):
    """
    Retourne tous les feux actifs détectés dans un rayon.
    Combine NASA FIRMS + prédiction CNN.
    """
    # Calcul bounding box approximatif
    km_per_deg_lat = 111
    km_per_deg_lng = 111 * abs(cos(radians(lat)))
    
    delta_lat = radius_km / km_per_deg_lat
    delta_lng = radius_km / km_per_deg_lng
    
    try:
        nasa_data = await fetch_nasa_detections(
            lat - delta_lat, lat + delta_lat,
            lng - delta_lng, lng + delta_lng,
            hours=24
        )
        
        # Filtrer par distance exacte
        from math import radians, cos, sin, asin, sqrt
        
        def haversine(lat1, lon1, lat2, lon2):
            R = 6371
            lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
            dlat = lat2 - lat1
            dlon = lon2 - lon1
            a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
            return 2 * R * asin(sqrt(a))
        
        nearby_fires = [
            f for f in nasa_data
            if haversine(lat, lng, f["latitude"], f["longitude"]) <= radius_km
        ]
        
        return {
            "fires": nearby_fires,
            "count": len(nearby_fires),
            "search_radius_km": radius_km,
            "center": {"lat": lat, "lng": lng}
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
