"""Router pour l'agrégation des données météo."""

from datetime import datetime, timedelta
from typing import List, Optional

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from fastapi import Depends

from app.models.schemas import WeatherCurrent, WeatherForecast
from app.core.database import get_db
from app.services.openweather import fetch_current, fetch_forecast

router = APIRouter()


@router.get("/current")
async def get_current_weather(
    lat: float,
    lng: float,
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère la météo actuelle pour une position.
    Vérifie d'abord le cache Redis, sinon appelle OpenWeather.
    """
    try:
        # Vérifier si données récentes en DB (< 15 min)
        query = text("""
            SELECT * FROM weather_data
            WHERE location_lat BETWEEN :lat_min AND :lat_max
              AND location_lng BETWEEN :lng_min AND :lng_max
              AND recorded_at > NOW() - INTERVAL '15 minutes'
            ORDER BY ABS(location_lat - :lat) + ABS(location_lng - :lng)
            LIMIT 1
        """)
        
        result = await db.execute(
            query,
            {
                "lat": lat,
                "lng": lng,
                "lat_min": lat - 0.1,
                "lat_max": lat + 0.1,
                "lng_min": lng - 0.1,
                "lng_max": lng + 0.1
            }
        )
        cached = result.mappings().first()
        
        if cached:
            return {
                "source": "cache",
                "data": dict(cached),
                "cached_at": cached["recorded_at"]
            }
        
        # Sinon, fetch depuis OpenWeather
        weather = await fetch_current(lat, lng)
        
        # Sauvegarder en DB
        insert_query = text("""
            INSERT INTO weather_data (
                location, location_lat, location_lng,
                temperature, precipitation_24h, humidity,
                wind_speed, wind_direction, pressure,
                weather_condition, weather_code, recorded_at
            ) VALUES (
                ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                :lat, :lng, :temp, :rain, :humidity,
                :wind_speed, :wind_dir, :pressure,
                :condition, :code, NOW()
            )
            ON CONFLICT DO NOTHING
        """)
        
        await db.execute(
            insert_query,
            {
                "lat": lat,
                "lng": lng,
                "temp": weather["main"]["temp"],
                "rain": weather.get("rain", {}).get("1h", 0) * 24,  # Approx 24h
                "humidity": weather["main"]["humidity"],
                "wind_speed": weather["wind"]["speed"],
                "wind_dir": weather["wind"].get("deg", 0),
                "pressure": weather["main"]["pressure"],
                "condition": weather["weather"][0]["description"],
                "code": weather["weather"][0]["id"]
            }
        )
        await db.commit()
        
        return {
            "source": "openweather",
            "data": weather,
            "fetched_at": datetime.utcnow()
        }
        
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service météo indisponible: {str(e)}")


@router.get("/forecast")
async def get_weather_forecast(
    lat: float,
    lng: float,
    days: int = Query(default=5, le=16)
):
    """
    Prévisions météo sur plusieurs jours.
    """
    try:
        forecast = await fetch_forecast(lat, lng, days)
        return {
            "location": {"lat": lat, "lng": lng},
            "forecast": forecast,
            "days": days,
            "fetched_at": datetime.utcnow()
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Forecast indisponible: {str(e)}")


@router.get("/history")
async def get_weather_history(
    lat: float,
    lng: float,
    days: int = Query(default=7, le=30),
    db: AsyncSession = Depends(get_db)
):
    """
    Historique météo pour une position.
    """
    query = text("""
        SELECT 
            recorded_at,
            temperature,
            precipitation_24h,
            humidity,
            wind_speed,
            pressure,
            weather_condition
        FROM weather_data
        WHERE location_lat BETWEEN :lat_min AND :lat_max
          AND location_lng BETWEEN :lng_min AND :lng_max
          AND recorded_at >= NOW() - INTERVAL ':days days'
        ORDER BY recorded_at DESC
    """)
    
    result = await db.execute(
        query,
        {
            "lat_min": lat - 0.5,
            "lat_max": lat + 0.5,
            "lng_min": lng - 0.5,
            "lng_max": lng + 0.5,
            "days": days
        }
    )
    
    records = result.mappings().all()
    
    return {
        "location": {"lat": lat, "lng": lng},
        "records": [dict(r) for r in records],
        "count": len(records),
        "period_days": days
    }


@router.get("/alerts")
async def get_weather_alerts(
    min_lat: float,
    max_lat: float,
    min_lng: float,
    max_lng: float
):
    """
    Alerte météo active pour une région (tempête, cyclone, etc.)
    """
    try:
        alerts = await fetch_current(
            (min_lat + max_lat) / 2,
            (min_lng + max_lng) / 2,
            alerts_only=True
        )
        
        return {
            "bbox": {
                "min_lat": min_lat,
                "max_lat": max_lat,
                "min_lng": min_lng,
                "max_lng": max_lng
            },
            "alerts": alerts.get("alerts", []),
            "count": len(alerts.get("alerts", []))
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))
