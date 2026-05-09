"""
Services ML - Implémentations mock pour développement.
En production, charger les vrais modèles entraînés.
"""

import uuid
import random
from datetime import datetime, timedelta
from typing import Dict, Any, List


class FloodPredictionModel:
    """Modèle XGBoost pour prédiction d'inondation."""
    
    async def predict(self, lat: float, lng: float, 
                      weather_features: Dict, horizon_hours: int) -> Dict[str, Any]:
        """
        Prédit le risque d'inondation.
        Features: précipitations, niveau rivière, topographie
        """
        # Mock: calcul basé sur précipitations
        precip = weather_features.get("precipitation_24h", 0)
        
        # Score plus élevé si beaucoup de pluie
        base_score = min(precip * 3, 80)  # 30mm -> 90%, plafonné à 80
        noise = random.uniform(-10, 10)
        confidence = max(0, min(100, base_score + noise))
        
        # Générer une zone d'impact
        zone = self._create_impact_zone(lat, lng, confidence)
        
        return {
            "id": str(uuid.uuid4()),
            "confidence": round(confidence, 2),
            "zone": zone,
            "features_used": weather_features
        }
    
    async def get_weather_features(self, lat: float, lng: float) -> Dict[str, Any]:
        """Récupère les features météo pour la prédiction."""
        # En prod: appeler service weather ou DB
        return {
            "precipitation_24h": random.uniform(0, 50),
            "precipitation_7d": random.uniform(10, 200),
            "river_level": random.uniform(1.0, 5.0),
            "soil_moisture": random.uniform(20, 80),
            "elevation": random.uniform(0, 1500)
        }
    
    async def quick_risk(self, lat: float, lng: float) -> Dict[str, Any]:
        """Évaluation rapide pour carte de chaleur."""
        score = random.uniform(5, 65)
        return {
            "type": "inondation",
            "score": round(score, 1)
        }
    
    def _create_impact_zone(self, lat: float, lng: float, confidence: float) -> Dict[str, Any]:
        """Crée un GeoJSON polygon pour la zone d'impact."""
        # Rayon en fonction du score
        radius_km = max(5, confidence / 10)
        
        # Approximation: 1° ≈ 111km
        delta_lat = radius_km / 111
        delta_lng = radius_km / (111 * abs(__import__('math').cos(__import__('math').radians(lat))))
        
        return {
            "type": "Polygon",
            "coordinates": [[
                [lng - delta_lng, lat - delta_lat],
                [lng + delta_lng, lat - delta_lat],
                [lng + delta_lng, lat + delta_lat],
                [lng - delta_lng, lat + delta_lat],
                [lng - delta_lng, lat - delta_lat]
            ]]
        }


class CyclonePredictionModel:
    """Modèle Ridge Regression pour risque cyclonique."""
    
    async def predict(self, lat: float, lng: float, horizon_hours: int) -> Dict[str, Any]:
        """Prédit le risque cyclonique basé sur pression, vents, SST."""
        # Mock: zones côtières ont plus de risque
        # Madagascar: côte Est plus exposée
        is_east_coast = lng > 48.0 and -25 < lat < -15
        
        base_score = 40 if is_east_coast else 15
        seasonal_factor = 20 if datetime.now().month in [1, 2, 3] else 5  # Saison cyclone Jan-Mar
        
        confidence = min(95, base_score + seasonal_factor + random.uniform(-10, 10))
        
        return {
            "id": str(uuid.uuid4()),
            "confidence": round(confidence, 2),
            "zone": self._create_cyclone_zone(lat, lng, confidence),
            "features": {
                "pressure": random.uniform(980, 1020),
                "wind_speed": random.uniform(10, 80),
                "sea_surface_temp": random.uniform(26, 30),
                "season": "cyclone" if datetime.now().month in [1, 2, 3] else "normal"
            }
        }
    
    async def quick_risk(self, lat: float, lng: float) -> Dict[str, Any]:
        is_east_coast = lng > 48.0 and -25 < lat < -15
        score = random.uniform(30, 70) if is_east_coast else random.uniform(5, 25)
        return {
            "type": "cyclone",
            "score": round(score, 1)
        }
    
    def _create_cyclone_zone(self, lat: float, lng: float, confidence: float) -> Dict[str, Any]:
        """Zone d'impact circulaire pour cyclone."""
        radius_km = confidence * 2  # Plus gros
        delta_lat = radius_km / 111
        delta_lng = radius_km / (111 * abs(__import__('math').cos(__import__('math').radians(lat))))
        
        return {
            "type": "Polygon",
            "coordinates": [[
                [lng - delta_lng, lat - delta_lat],
                [lng + delta_lng, lat - delta_lat],
                [lng + delta_lng, lat + delta_lat],
                [lng - delta_lng, lat + delta_lat],
                [lng - delta_lng, lat - delta_lat]
            ]]
        }


class FireDetectionModel:
    """CNN ResNet-50 pour détection d'incendies sur images."""
    
    async def predict_from_bytes(self, image_bytes: bytes) -> Dict[str, Any]:
        """Analyse une image uploadée."""
        # Mock: score aléatoire avec tendance à détecter
        confidence = random.uniform(0.3, 0.95)
        fire_detected = confidence > 0.6
        
        return {
            "fire_detected": fire_detected,
            "confidence": round(confidence, 3),
            "boxes": self._generate_boxes() if fire_detected else [],
            "heat_score": round(confidence * 100, 1)
        }
    
    async def predict_from_url(self, image_url: str) -> Dict[str, Any]:
        """Analyse une image depuis URL."""
        return await self.predict_from_bytes(b"")  # Même mock
    
    def _generate_boxes(self) -> List[Dict[str, Any]]:
        """Génère bounding boxes mock."""
        n_boxes = random.randint(1, 3)
        boxes = []
        for i in range(n_boxes):
            x1 = random.uniform(0, 0.7)
            y1 = random.uniform(0, 0.7)
            x2 = x1 + random.uniform(0.1, 0.3)
            y2 = y1 + random.uniform(0.1, 0.3)
            boxes.append({
                "x1": round(x1, 3),
                "y1": round(y1, 3),
                "x2": round(x2, 3),
                "y2": round(y2, 3),
                "confidence": round(random.uniform(0.6, 0.95), 3)
            })
        return boxes


class NLPModel:
    """BERT pour analyse de texte et détection d'urgence."""
    
    DISASTER_KEYWORDS = {
        "inondation": ["inondation", "débordement", "crue", "submergé", "eau", "pluie"],
        "incendie": ["feu", "incendie", "flammes", "brûlé", "fumée", "pompiers"],
        "cyclone": ["cyclone", "tempête", "ouragan", "vent", "typhon", "grande vague"],
        "seisme": ["tremblement", "séisme", "secousse", "terre", "effondré"],
        "glissement_terrain": ["glissement", "éboulement", "terrain", "boue"]
    }
    
    URGENCY_KEYWORDS = [
        "urgent", "urgence", "aide", "secours", "mort", "blessé",
        "danger", "fuite", "evacuer", "appelez", "911", "18"
    ]
    
    async def analyze(self, text: str, language: str = "fr", 
                      author_location_hint: str = None) -> Dict[str, Any]:
        """Analyse complète d'un texte."""
        text_lower = text.lower()
        
        # Détection type
        detected_type = None
        max_score = 0
        for dtype, keywords in self.DISASTER_KEYWORDS.items():
            score = sum(1 for k in keywords if k in text_lower)
            if score > max_score:
                max_score = score
                detected_type = dtype
        
        # Niveau d'urgence
        urgency_score = sum(1 for u in self.URGENCY_KEYWORDS if u in text_lower)
        if urgency_score >= 3:
            urgency = "critique"
        elif urgency_score >= 1:
            urgency = "elevee"
        elif max_score > 0:
            urgency = "moyenne"
        else:
            urgency = "faible"
        
        # Sentiment (-1 à 1, négatif pour catastrophe)
        sentiment = -0.5 if urgency in ["elevee", "critique"] else 0.0
        
        return {
            "disaster_type": detected_type,
            "confidence": min(0.95, max(0.1, max_score * 0.2 + random.uniform(0, 0.3))),
            "urgency": urgency,
            "sentiment": round(sentiment, 2),
            "keywords": [k for k in text.split() if len(k) > 4][:10],
            "entities": self._extract_entities(text),
            "location": self._extract_location(text, author_location_hint)
        }
    
    async def analyze_batch(self, texts: List[str], batch_size: int = 16) -> List[Dict[str, Any]]:
        """Analyse batch de textes."""
        results = []
        for text in texts:
            result = await self.analyze(text)
            results.append(result)
        return results
    
    async def quick_analyze(self, text: str) -> Dict[str, Any]:
        """Version rapide sans NLP complexe."""
        return await self.analyze(text)
    
    def _extract_entities(self, text: str) -> List[Dict[str, str]]:
        """Extraction basique d'entités."""
        # Mock: recherche de villes connues de Madagascar
        cities = ["antananarivo", "toamasina", "mahajanga", "antsirabe", "toliara", "antsiranana"]
        found = []
        for city in cities:
            if city in text.lower():
                found.append({"type": "LOCATION", "value": city.capitalize()})
        return found
    
    def _extract_location(self, text: str, hint: str = None) -> Dict[str, float]:
        """Extrait localisation approximative."""
        # Mock: retourne coordonnées d'Antananarivo si mentionné
        if "antananarivo" in text.lower():
            return {"lat": -18.9078, "lng": 47.5208}
        if "toamasina" in text.lower():
            return {"lat": -18.1442, "lng": 49.3956}
        return None


# Instances globales
flood_model = FloodPredictionModel()
cyclone_model = CyclonePredictionModel()
fire_cnn_model = FireDetectionModel()
nlp_model = NLPModel()
