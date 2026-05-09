"""Service client OpenWeather API."""

import httpx
from typing import Optional, Dict, Any

from app.core.config import settings

BASE_URL = "https://api.openweathermap.org/data/2.5"


async def fetch_current(lat: float, lng: float, alerts_only: bool = False) -> Dict[str, Any]:
    """
    Récupère la météo actuelle.
    """
    if not settings.OPENWEATHER_API_KEY:
        # Retourne des données mock pour développement
        return _mock_weather(lat, lng)
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BASE_URL}/weather",
            params={
                "lat": lat,
                "lon": lng,
                "appid": settings.OPENWEATHER_API_KEY,
                "units": "metric",
                "lang": "fr"
            },
            timeout=10.0
        )
        response.raise_for_status()
        return response.json()


async def fetch_forecast(lat: float, lng: float, days: int = 5) -> Dict[str, Any]:
    """
    Récupère les prévisions sur plusieurs jours.
    """
    if not settings.OPENWEATHER_API_KEY:
        return {"cnt": 0, "list": []}
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BASE_URL}/forecast",
            params={
                "lat": lat,
                "lon": lng,
                "appid": settings.OPENWEATHER_API_KEY,
                "units": "metric",
                "lang": "fr",
                "cnt": days * 8  # 3h intervalles
            },
            timeout=10.0
        )
        response.raise_for_status()
        return response.json()


def _mock_weather(lat: float, lng: float) -> Dict[str, Any]:
    """Données mock pour développement sans clé API."""
    return {
        "coord": {"lat": lat, "lon": lng},
        "weather": [{"id": 800, "main": "Clear", "description": "ciel dégagé"}],
        "main": {
            "temp": 25.5,
            "feels_like": 26.0,
            "humidity": 65,
            "pressure": 1013
        },
        "wind": {"speed": 5.5, "deg": 180},
        "clouds": {"all": 10},
        "dt": 1700000000,
        "sys": {"country": "MG", "sunrise": 1700000000, "sunset": 1700040000},
        "timezone": 10800,
        "name": "Antananarivo"
    }
