"""Configuration de l'application."""

from typing import List
from pydantic_settings import BaseSettings
from pydantic import PostgresDsn, RedisDsn


class Settings(BaseSettings):
    """Configuration globale."""
    
    # App
    APP_NAME: str = "mitandrina-ai"
    DEBUG: bool = False
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "https://mitandrina.vercel.app"
    ]
    
    # Database
    DATABASE_URL: PostgresDsn = "postgresql+asyncpg://postgres:postgres@localhost:5432/mitandrina"
    DATABASE_URL_SYNC: str = "postgresql://postgres:postgres@localhost:5432/mitandrina"
    
    # Redis
    REDIS_URL: RedisDsn = "redis://localhost:6379/0"
    REDIS_QUEUE_URL: str = "redis://localhost:6379/1"
    
    # External APIs
    OPENWEATHER_API_KEY: str = ""
    NASA_FIRMS_API_KEY: str = ""
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_PHONE_NUMBER: str = ""
    FIREBASE_PROJECT_ID: str = ""
    
    # ML Models
    MODEL_PATH: str = "./models"
    FLOOD_MODEL_FILE: str = "flood_xgboost.pkl"
    FIRE_MODEL_FILE: str = "fire_cnn.h5"
    NLP_MODEL_FILE: str = "bert_disaster"
    
    # Routing
    OSM_CACHE_DIR: str = "./cache/osm"
    MAX_ROUTE_DISTANCE_KM: int = 200
    
    # JWT (pour validation tokens depuis NodeJS)
    JWT_SECRET: str = "your-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
