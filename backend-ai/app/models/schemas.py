"""Schémas Pydantic pour l'API."""

from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from enum import Enum

from pydantic import BaseModel, Field, validator


# Enums
class DisasterType(str, Enum):
    inondation = "inondation"
    incendie = "incendie"
    cyclone = "cyclone"
    seisme = "seisme"
    glissement_terrain = "glissement_terrain"
    tsunami = "tsunami"


class AlertLevel(str, Enum):
    info = "info"
    vigilance = "vigilance"
    alerte = "alerte"
    urgence = "urgence"


class ModelType(str, Enum):
    xgboost = "xgboost"
    lstm = "lstm"
    cnn = "cnn"
    ridge_regression = "ridge_regression"
    bert = "bert"


# ============== PRÉDICTIONS ==============

class PredictionRequest(BaseModel):
    lat: float = Field(..., ge=-90, le=90, description="Latitude")
    lng: float = Field(..., ge=-180, le=180, description="Longitude")
    type: Optional[DisasterType] = None
    horizon_hours: int = Field(default=24, ge=1, le=168)
    
    class Config:
        json_schema_extra = {
            "example": {
                "lat": -18.9078,
                "lng": 47.5208,
                "type": "inondation",
                "horizon_hours": 24
            }
        }


class PredictionResponse(BaseModel):
    id: str
    type: DisasterType
    confidence_score: float = Field(..., ge=0, le=100)
    severity: AlertLevel
    predicted_zone: Dict[str, Any]  # GeoJSON
    center_lat: float
    center_lng: float
    horizon: datetime
    model_used: ModelType
    features: Dict[str, Any]
    created_at: datetime


class RiskAssessmentRequest(BaseModel):
    locations: List[Dict[str, float]] = Field(..., min_items=1, max_items=100)
    
    @validator('locations')
    def validate_locations(cls, v):
        for loc in v:
            if 'lat' not in loc or 'lng' not in loc:
                raise ValueError('Chaque location doit avoir lat et lng')
        return v


# ============== INCENDIES (CNN) ==============

class FireDetectionRequest(BaseModel):
    image_base64: Optional[str] = None
    image_url: Optional[str] = None
    lat: float
    lng: float
    source: str = "satellite"  # satellite, drone, camera


class FireDetectionResponse(BaseModel):
    fire_detected: bool
    confidence: float
    bounding_boxes: List[Dict[str, Any]]  # Coordonnées des zones de feu
    heat_score: float  # 0-100
    coordinates: Dict[str, float]
    processed_at: datetime


class SatelliteFireData(BaseModel):
    source: str = "NASA FIRMS"
    detections: List[Dict[str, Any]]
    last_updated: datetime


# ============== NLP / SIGNAUX SOCIAUX ==============

class SocialSignalRequest(BaseModel):
    text: str = Field(..., min_length=10, max_length=2000)
    platform: str = Field(default="twitter")  # twitter, facebook, etc.
    language: str = Field(default="fr")
    author_location: Optional[str] = None


class NLPAnalysisResponse(BaseModel):
    disaster_type: Optional[DisasterType]
    confidence: float
    urgency: str  # faible, moyenne, elevee, critique
    sentiment: float  # -1 à 1
    keywords: List[str]
    entities: List[Dict[str, Any]]
    location_mentioned: Optional[Dict[str, float]]
    processed_at: datetime


class BatchNLPRequest(BaseModel):
    texts: List[str] = Field(..., min_items=1, max_items=50)


# ============== ROUTING A* ==============

class RouteRequest(BaseModel):
    origin_lat: float
    origin_lng: float
    destination_lat: float
    destination_lng: float
    avoid_zones: Optional[List[str]] = []  # IDs des zones à éviter
    mode: str = Field(default="car", pattern="^(car|foot|bike)$")
    max_distance_km: int = Field(default=200, le=500)


class RouteResponse(BaseModel):
    route_id: str
    path: Dict[str, Any]  # GeoJSON LineString
    distance_km: float
    estimated_time_minutes: int
    danger_score: float
    waypoints: List[Dict[str, Any]]
    alternatives: Optional[List[Dict[str, Any]]] = None
    calculated_at: datetime


class ShelterRouteRequest(BaseModel):
    user_lat: float
    user_lng: float
    disaster_zone_id: Optional[str] = None
    max_distance_km: int = Field(default=50, le=200)
    prefer_medical: bool = False


class ShelterRouteResponse(BaseModel):
    shelter_id: str
    shelter_name: str
    shelter_type: str
    shelter_location: Dict[str, float]
    route: RouteResponse
    shelter_capacity: Dict[str, int]  # total, occupied, remaining


# ============== MÉTÉO ==============

class WeatherCurrent(BaseModel):
    location: Dict[str, float]
    temperature: float
    precipitation_24h: float
    humidity: float
    wind_speed: float
    wind_direction: int
    pressure: float
    condition: str
    recorded_at: datetime


class WeatherForecast(BaseModel):
    location: Dict[str, float]
    hourly: List[Dict[str, Any]]
    daily: List[Dict[str, Any]]
    alerts: List[Dict[str, Any]]
    fetched_at: datetime


# ============== SIMULATION ==============

class SimulationRequest(BaseModel):
    name: str
    scenario_type: DisasterType
    center_lat: float
    center_lng: float
    radius_km: float = Field(..., ge=1, le=100)
    intensity: int = Field(..., ge=1, le=10)
    parameters: Optional[Dict[str, Any]] = {}


class SimulationResponse(BaseModel):
    simulation_id: str
    name: str
    status: str  # pending, running, completed, failed
    scenario_type: DisasterType
    impact_zone: Dict[str, Any]  # GeoJSON
    affected_population_estimate: int
    evacuation_routes: List[RouteResponse]
    execution_time_seconds: float
    created_at: datetime


# ============== HEALTH ==============

class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    timestamp: datetime
    checks: Dict[str, Any]
