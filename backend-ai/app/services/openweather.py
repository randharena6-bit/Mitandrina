"""Service client OpenWeather API avec fallback robuste."""

import httpx
import time
from typing import Optional, Dict, Any

from app.core.config import settings

BASE_URL = "https://api.openweathermap.org/data/2.5"


async def fetch_current(lat: float, lng: float, alerts_only: bool = False) -> Dict[str, Any]:
    """
    Récupère la météo actuelle. Graceful fallback en cas d'erreur de clé API ou réseau.
    """
    if not settings.OPENWEATHER_API_KEY or "your_openweather" in settings.OPENWEATHER_API_KEY:
        return _mock_weather(lat, lng)
    
    try:
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
                timeout=5.0
            )
            response.raise_for_status()
            return response.json()
    except Exception as e:
        print(f"⚠️ OpenWeather fetch_current error ({e}). Fallback aux données de simulation.")
        return _mock_weather(lat, lng)


async def fetch_forecast(lat: float, lng: float, days: int = 5) -> Dict[str, Any]:
    """
    Récupère les prévisions sur plusieurs jours. Graceful fallback.
    """
    if not settings.OPENWEATHER_API_KEY or "your_openweather" in settings.OPENWEATHER_API_KEY:
        return _mock_forecast(lat, lng, days)
    
    try:
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
                timeout=5.0
            )
            response.raise_for_status()
            return response.json()
    except Exception as e:
        print(f"⚠️ OpenWeather fetch_forecast error ({e}). Fallback aux prévisions de simulation.")
        return _mock_forecast(lat, lng, days)


def _mock_weather(lat: float, lng: float) -> Dict[str, Any]:
    """Données mock pour développement sans clé API."""
    return {
        "coord": {"lat": lat, "lon": lng},
        "weather": [{"id": 800, "main": "Clear", "description": "ciel dégagé"}],
        "main": {
            "temp": 24.5,
            "feels_like": 25.0,
            "humidity": 60,
            "pressure": 1013
        },
        "wind": {"speed": 4.5, "deg": 180},
        "clouds": {"all": 10},
        "dt": int(time.time()),
        "sys": {"country": "MG", "sunrise": int(time.time()) - 10000, "sunset": int(time.time()) + 10000},
        "timezone": 10800,
        "name": "Antananarivo"
    }


def _mock_forecast(lat: float, lng: float, days: int = 5) -> Dict[str, Any]:
    """Prévisions mock pour développement sans clé API."""
    forecast_list = []
    current_time = int(time.time())
    for i in range(days * 8):
        temp = 22.0 + (i % 3)
        forecast_list.append({
            "dt": current_time + (i * 3 * 3600),
            "main": {
                "temp": temp,
                "temp_min": temp - 2,
                "temp_max": temp + 3,
                "feels_like": 22.5,
                "humidity": 65,
                "pressure": 1013
            },
            "weather": [{"id": 800, "main": "Clear", "description": "ciel dégagé"}],
            "wind": {"speed": 5.0, "deg": 180},
            "dt_txt": ""
        })
    return {
        "location": {"lat": lat, "lng": lng},
        "list": forecast_list,
        "days": days,
        "fetched_at": ""
    }
