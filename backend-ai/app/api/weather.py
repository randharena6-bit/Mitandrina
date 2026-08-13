"""Router pour l'agrégation des données météo."""

from datetime import datetime

from fastapi import APIRouter, Query

from app.services.openweather import fetch_current, fetch_forecast

router = APIRouter()


def _fire_risk(weather: dict) -> int:
    temp = weather.get("main", {}).get("temp", 25)
    humidity = weather.get("main", {}).get("humidity", 50)
    wind = weather.get("wind", {}).get("speed", 5)
    risk = (temp * 1.5) + (wind * 5) - (humidity * 0.5)
    return max(0, min(100, int(risk)))


def _transform_current(weather: dict) -> dict:
    w = weather["weather"][0] if weather.get("weather") else {}
    return {
        "temp": round(weather["main"]["temp"]),
        "description": w.get("description", ""),
        "location": weather.get("name", "Antananarivo"),
        "condition": w.get("main", "Clear"),
        "humidity": weather["main"]["humidity"],
        "windSpeed": round(weather["wind"]["speed"] * 3.6, 1),
        "pressure": weather["main"]["pressure"],
        "visibility": round(weather.get("visibility", 10000) / 1000, 1),
        "uvIndex": 5,
        "fireRisk": _fire_risk(weather),
        "warnings": weather.get("alerts", []),
    }


def _transform_forecast(forecast: dict) -> list:
    days_map = {}
    for entry in forecast.get("list", []):
        date = datetime.fromtimestamp(entry["dt"]).strftime("%Y-%m-%d")
        if date not in days_map:
            days_map[date] = {
                "date": date,
                "condition": entry["weather"][0]["main"],
                "tempMin": entry["main"]["temp_min"],
                "tempMax": entry["main"]["temp_max"],
            }
        else:
            days_map[date]["tempMin"] = min(days_map[date]["tempMin"], entry["main"]["temp_min"])
            days_map[date]["tempMax"] = max(days_map[date]["tempMax"], entry["main"]["temp_max"])
    return list(days_map.values())


@router.get("/current")
async def get_current_weather(
    lat: float,
    lng: float
):
    """
    Récupère la météo actuelle pour une position.
    """
    weather = await fetch_current(lat, lng)
    return _transform_current(weather)


@router.get("/forecast")
async def get_weather_forecast(
    lat: float,
    lng: float,
    days: int = Query(default=5, le=16)
):
    """
    Prévisions météo sur plusieurs jours.
    """
    forecast = await fetch_forecast(lat, lng, days)
    return {
        "location": {"lat": lat, "lng": lng},
        "forecast": _transform_forecast(forecast),
        "days": days,
        "fetched_at": datetime.utcnow().isoformat()
    }
