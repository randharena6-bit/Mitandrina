"""Service client NASA FIRMS (Fire Information for Resource Management System)."""

import httpx
from datetime import datetime, timedelta
from typing import List, Dict, Any

from app.core.config import settings

BASE_URL = "https://firms.modaps.eosdis.nasa.gov/api/area"
MAP_KEY = settings.NASA_FIRMS_API_KEY or "YOUR_MAP_KEY"  # Clé gratuite sur firms.modaps.eosdis.nasa.gov


async def fetch_nasa_detections(
    min_lat: float,
    max_lat: float,
    min_lng: float,
    max_lng: float,
    hours: int = 24
) -> List[Dict[str, Any]]:
    """
    Récupère les détections de feux depuis NASA FIRMS.
    
    Sources disponibles:
    - VIIRS_SNPP_NRT (Visible Infrared Imaging Radiometer Suite)
    - MODIS_NRT (Moderate Resolution Imaging Spectroradiometer)
    """
    if not settings.NASA_FIRMS_API_KEY:
        # Mock data pour développement
        return _mock_fire_detections(min_lat, max_lat, min_lng, max_lng)
    
    # Format: csv, formaté selon doc NASA
    area = f"{min_lat},{min_lng},{max_lat},{max_lng}"
    date_str = (datetime.utcnow() - timedelta(hours=hours)).strftime("%Y-%m-%d")
    
    url = f"{BASE_URL}/csv/VIIRS_SNPP_NRT/{MAP_KEY}/{area}/1/{date_str}"
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url, timeout=30.0)
        
        if response.status_code == 200:
            return _parse_firms_csv(response.text)
        else:
            return []


def _parse_firms_csv(csv_text: str) -> List[Dict[str, Any]]:
    """Parse le CSV retourné par NASA FIRMS."""
    lines = csv_text.strip().split('\n')
    if len(lines) < 2:
        return []
    
    # Header
    headers = lines[0].split(',')
    
    detections = []
    for line in lines[1:]:
        values = line.split(',')
        if len(values) >= 10:
            detection = {
                "latitude": float(values[0]),
                "longitude": float(values[1]),
                "brightness": float(values[2]),  # Température en Kelvin
                "scan": float(values[3]),
                "track": float(values[4]),
                "acq_date": values[5],
                "acq_time": values[6],
                "satellite": values[7],
                "confidence": values[8],  # high, nominal, low
                "frp": float(values[9]) if values[9] else 0,  # Fire Radiative Power (MW)
            }
            detections.append(detection)
    
    return detections


def _mock_fire_detections(min_lat, max_lat, min_lng, max_lng) -> List[Dict[str, Any]]:
    """Génère des données de test pour le développement."""
    import random
    
    detections = []
    # Générer 0-3 faux feux aléatoires dans la zone
    for _ in range(random.randint(0, 3)):
        lat = random.uniform(min_lat, max_lat)
        lng = random.uniform(min_lng, max_lng)
        
        detections.append({
            "latitude": lat,
            "longitude": lng,
            "brightness": random.uniform(350, 450),  # K
            "scan": 0.5,
            "track": 0.5,
            "acq_date": datetime.utcnow().strftime("%Y-%m-%d"),
            "acq_time": datetime.utcnow().strftime("%H%M"),
            "satellite": "VNP",
            "confidence": random.choice(["high", "nominal", "low"]),
            "frp": random.uniform(10, 150),  # MW
        })
    
    return detections
