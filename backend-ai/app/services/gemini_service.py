"""Analyse cyclonique locale instantanée + Gemini en arrière-plan."""

import asyncio
import json
import hashlib
import httpx
import math
from typing import List, Dict, Any, Optional
from datetime import datetime, timezone


from app.core.config import settings

GEMINI_API_KEY = settings.GEMINI_API_KEY
GEMINI_MODEL = "gemini-2.0-flash-lite"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}" if GEMINI_API_KEY else None

GEMINI_TIMEOUT = 15
GEMINI_TIMEOUT_SHORT = 5

_cache: Dict[str, Dict[str, Any]] = {}
_cache_max_size = 10


class CycloneAnalyzer:
    """Analyse cyclonique locale (instantanée) + Gemini en cache."""

    async def analyze(
        self,
        cyclones: List[Dict[str, Any]],
        incidents: List[Dict[str, Any]],
        shelters: List[Dict[str, Any]],
        weather: Optional[Dict[str, Any]] = None,
        user_location: Optional[Dict[str, float]] = None,
    ) -> Dict[str, Any]:
        cache_key = self._cache_key(cyclones, incidents)
        if cached := _cache.get(cache_key):
            return cached

        if len(_cache) >= _cache_max_size:
            _cache.pop(next(iter(_cache)))
        result = self._local_analysis(cyclones, incidents, shelters, weather, user_location)
        _cache[cache_key] = result
        return result

    async def analyze_deep(
        self,
        cyclones: List[Dict[str, Any]],
        incidents: List[Dict[str, Any]],
        shelters: List[Dict[str, Any]],
        weather: Optional[Dict[str, Any]] = None,
        user_location: Optional[Dict[str, float]] = None,
    ) -> Dict[str, Any]:
        """Analyse locale instantanée + enrichment Gemini (timeout 15s)."""
        cache_key = "deep_" + self._cache_key(cyclones, incidents)
        if cached := _cache.get(cache_key):
            return cached

        if len(_cache) >= _cache_max_size:
            _cache.pop(next(iter(_cache)))
        local = self._local_analysis(cyclones, incidents, shelters, weather, user_location)
        gemini = await self._call_gemini(cyclones, incidents, shelters, weather, user_location)
        if gemini:
            local.update({
                "resume": gemini.get("resume", local["resume"]),
                "risque_global": gemini.get("risque_global", local["risque_global"]),
                "recommandations_public": gemini.get("recommandations_public", local["recommandations_public"]),
                "conseils_evacuation": gemini.get("conseils_evacuation", local["conseils_evacuation"]),
                "source": "gemini"
            })
        _cache[cache_key] = local
        return local

    def _cache_key(self, cyclones: list, incidents: list) -> str:
        raw = json.dumps([cyclones[:5], incidents[:5]], sort_keys=True, default=str)
        return hashlib.md5(raw.encode()).hexdigest()

    def _local_analysis(
        self,
        cyclones: List[Dict[str, Any]],
        incidents: List[Dict[str, Any]],
        shelters: List[Dict[str, Any]],
        weather: Optional[Dict[str, Any]],
        user_location: Optional[Dict[str, float]],
    ) -> Dict[str, Any]:
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
        month = datetime.now(timezone.utc).month
        is_cyclone_season = month in [1, 2, 3]  # Jan-Mar

        if not cyclones:
            return self._safe_analysis(now, "faible", "Aucun système cyclonique actif détecté.")

        max_wind = max((c.get("wind_speed") or 0) for c in cyclones)
        pressures = [c["pressure"] for c in cyclones if c.get("pressure") is not None]
        min_pressure = min(pressures) if pressures else None
        n_high = sum(1 for c in cyclones if (c.get("level") or "") in ["alerte", "urgence"])

        risk_score = 0
        if max_wind >= 100: risk_score += 40
        elif max_wind >= 60: risk_score += 30
        elif max_wind >= 30: risk_score += 15
        if min_pressure and min_pressure < 980: risk_score += 20
        elif min_pressure and min_pressure < 1000: risk_score += 10
        risk_score += n_high * 10
        if is_cyclone_season: risk_score += 10
        if incidents: risk_score += min(len(incidents) * 5, 15)

        if risk_score >= 70:
            risk = "critique"
            recs = [
                "Évacuez immédiatement si vous êtes en zone côtière ou inondable",
                "Mettez-vous à l'abri dans un bâtiment solide",
                "Suivez ABSOLUMENT les instructions des autorités",
                "N'empruntez pas les routes inondées",
            ]
            evac = "ÉVACUATION OBLIGATOIRE dans les zones côtières et à risque. Rendez-vous immédiatement à l'abri le plus proche."
            alertes = [{"titre": "ALERTE ROUGE - Cyclone majeur", "message": f"Vents de {max_wind:.0f} km/h attendus. Évacuation obligatoire.", "niveau": "urgence", "zone_concernee": "Zones côtières et à risque"}]
        elif risk_score >= 45:
            risk = "élevé"
            recs = [
                "Préparez-vous à évacuer si l'ordre est donné",
                "Sécurisez votre maison (volets, objets extérieurs)",
                "Faites des réserves d'eau et de nourriture pour 72h",
                "Restez informé en continu",
            ]
            evac = "Préparez votre évacuation. Faites le plein d'essence, préparez vos documents importants et un sac d'urgence."
            alertes = [{"titre": "Alerte orange - Cyclone puissant", "message": f"Vents de {max_wind:.0f} km/h. Préparez-vous à évacuer.", "niveau": "alerte", "zone_concernee": "Zones menacées"}]
        elif risk_score >= 25:
            risk = "modéré"
            recs = [
                "Restez informé de l'évolution de la situation",
                "Vérifiez votre kit d'urgence",
                "Repérez l'abri le plus proche",
                "Évitez les déplacements non essentiels",
            ]
            evac = "Surveillez la situation. Identifiez votre abri le plus proche et préparez un sac d'urgence."
            alertes = [{"titre": "Vigilance cyclonique", "message": f"Vents de {max_wind:.0f} km/h. Restez informé.", "niveau": "vigilance", "zone_concernee": "À déterminer"}]
        else:
            risk = "faible"
            recs = [
                "Aucune action immédiate nécessaire",
                "Restez informé des prévisions météo",
                "Profitez-en pour vérifier votre kit d'urgence",
            ]
            evac = "Aucune évacuation nécessaire pour le moment. Restez vigilant."
            alertes = []

        # Analyse par cyclone
        cyc_analysis = []
        for i, c in enumerate(cyclones[:5]):
            w = c.get("wind_speed") or 0
            lvl = c.get("level", "vigilance")
            c_lat = c.get("lat") or 0
            c_lng = c.get("lng") or 0
            cyc_risk = "critique" if w >= 100 or lvl == "urgence" else "élevé" if w >= 60 or lvl == "alerte" else "modéré" if w >= 30 else "faible"

            # Analyse géographique en fonction des coordonnées
            if c_lng > 48:
                dir_str = "Se déplace vers l'Ouest en direction des terres"
                zones = ["Côte Est", "Toamasina", "Brickaville"]
            elif c_lng > 44:
                dir_str = "Trajectoire vers l'intérieur des terres"
                zones = ["Antananarivo", "Régions des Hautes Terres"]
            elif c_lat < -20:
                dir_str = "Trajectoire Sud-Ouest"
                zones = ["Toliara", "Côte Sud"]
            elif c_lat < -15:
                dir_str = "Trajectoire Ouest"
                zones = ["Morondava", "Côte Ouest"]
            elif c_lat < -12:
                dir_str = "Trajectoire Nord-Ouest"
                zones = ["Mahajanga", "Côte Nord-Ouest"]
            else:
                dir_str = "Trajectoire estimée vers l'Ouest"
                zones = ["Régions côtières"]

            cyc_analysis.append({
                "nom": f"Cyclone {c.get('title', 'Système')[:20]}",
                "risque": cyc_risk,
                "vitesse_vent_estimee_kmh": round(w, 1),
                "direction": dir_str,
                "zones_menacees": zones,
                "recommandation": recs[0] if recs else "Restez vigilant"
            })

        # Construire le résumé avec détails géographiques
        resume_parts = [f"Situation cyclonique {risk} à Madagascar."]
        resume_parts.append(f"{len(cyclones)} système(s) actif(s), vent max {max_wind:.0f} km/h.")

        # Ajouter des détails de position
        for c in cyclones[:3]:
            c_lng = c.get("lng") or 0
            c_lat = c.get("lat") or 0
            pos = "Côte Est" if c_lng > 48 else "Régions intérieures" if c_lng > 44 else "Côte Ouest" if c_lng < 44 else "Centre"
            resume_parts.append(f"Position estimée: {pos} ({abs(c_lat):.1f}°S, {c_lng:.1f}°E).")

        if is_cyclone_season:
            resume_parts.append("Saison cyclonique active - vigilance renforcée.")

        resume = " ".join(resume_parts)

        return {
            "resume": resume,
            "risque_global": risk,
            "analyse_cyclones": cyc_analysis,
            "recommandations_public": recs,
            "recommandations_autorites": [
                "Activez les cellules de crise communales" if risk in ["élevé", "critique"] else "Maintenez la veille",
                "Préparez l'ouverture des abris" if risk in ["modéré", "élevé", "critique"] else "Vérifiez les stocks",
            ],
            "alertes_generees": alertes,
            "abris_recommandes": [{"nom": s.get("name", "Abri")[:30], "raison": "Abris disponible à proximité"} for s in (shelters or [])[:3]],
            "conseils_evacuation": evac,
            "timestamp_analyse": now,
            "source": "analyse_locale"
        }

    def _safe_analysis(self, now: str, risk: str, resume: str) -> Dict[str, Any]:
        return {
            "resume": resume,
            "risque_global": risk,
            "analyse_cyclones": [],
            "recommandations_public": [
                "Aucune action immédiate nécessaire",
                "Restez informé des prévisions météo via les canaux officiels",
                "Profitez-en pour vérifier votre kit d'urgence (eau, nourriture, médicaments)",
                "Identifiez l'abri le plus proche de votre position par précaution"
            ],
            "recommandations_autorites": ["Maintenez la veille", "Vérifiez les stocks d'urgence"],
            "alertes_generees": [],
            "abris_recommandes": [],
            "conseils_evacuation": "Rien à signaler. Aucune évacuation nécessaire pour le moment. Restez vigilant.",
            "timestamp_analyse": now,
            "source": "analyse_locale"
        }

    async def _call_gemini(self, cyclones, incidents, shelters, weather, user_location) -> Optional[Dict]:
        """Appel Gemini en arrière-plan (optionnel)."""
        if not GEMINI_URL:
            return None
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
        c_data = json.dumps([{"lat":c.get("lat"),"lng":c.get("lng"),"titre":(c.get("title")or"")[:40],"vent":c.get("wind_speed"),"niveau":c.get("level")} for c in (cyclones or [])[:5]], ensure_ascii=False)
        i_data = json.dumps([{"lat":i.get("lat"),"lng":i.get("lng"),"titre":(i.get("title")or"")[:40]} for i in (incidents or [])[:5]], ensure_ascii=False)
        s_data = json.dumps([{"nom":(s.get("name")or"")[:30]} for s in (shelters or [])[:5]], ensure_ascii=False)
        prompt = f"Analyse cyclones Madagascar. {now}. Cyclones:{c_data}. Incidents:{i_data}. Abris:{s_data}. JSON: {{\"resume\":\"\",\"risque_global\":\"faible|modéré|élevé|critique\",\"recommandations_public\":[\"\"],\"conseils_evacuation\":\"\"}}"

        try:
            async with httpx.AsyncClient(timeout=GEMINI_TIMEOUT) as client:
                resp = await client.post(GEMINI_URL, json={
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {"temperature": 0.1, "maxOutputTokens": 512}
                })
                resp.raise_for_status()
                parts = resp.json().get("candidates", [{}])[0].get("content", {}).get("parts", [{}])
                if parts:
                    cleaned = parts[0].get("text", "").strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()
                    return json.loads(cleaned)
        except Exception as e:
            print(f"Gemini bg error: {e}")
        return None


analyzer = CycloneAnalyzer()
