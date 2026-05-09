"""Service de queue Redis pour tâches async."""

import json
import redis.asyncio as redis
from app.core.config import settings

# Client Redis global
redis_client = redis.from_url(
    str(settings.REDIS_URL),
    decode_responses=True
)


async def enqueue_alert_check(prediction: dict, alert_type: str):
    """Ajoute une vérification d'alerte à la queue."""
    message = {
        "type": "alert_check",
        "prediction": prediction,
        "alert_type": alert_type,
        "priority": "high" if prediction.get("confidence_score", 0) > 85 else "normal"
    }
    
    await redis_client.lpush("mitandrina:queue:alerts", json.dumps(message))


async def enqueue_social_signal(text: str, platform: str, analysis: dict):
    """Sauvegarde un signal social détecté."""
    message = {
        "type": "social_signal",
        "text": text,
        "platform": platform,
        "analysis": analysis,
        "timestamp": json.dumps(datetime.utcnow(), default=str)
    }
    
    await redis_client.lpush("mitandrina:queue:social", json.dumps(message))


async def publish_websocket_event(channel: str, data: dict):
    """Publie un événement temps réel."""
    await redis_client.publish(f"mitandrina:ws:{channel}", json.dumps(data))


from datetime import datetime
