"""Analyse cyclonique: ML + OpenRouter. Les données sont d'abord analysées par les modèles ML, puis enrichies par OpenRouter."""

import asyncio
import json
import hashlib
import httpx
from typing import List, Dict, Any, Optional
from datetime import datetime, timezone

from app.core.config import settings
from app.services.ml_models import cyclone_model, nlp_model

OPENROUTER_API_KEY = settings.OPENROUTER_API_KEY
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
OPENROUTER_MODEL = settings.OPENROUTER_MODEL or "deepseek/deepseek-chat"

OR_TIMEOUT = 15

_or_cache: Dict[str, Dict[str, Any]] = {}
_or_cache_max_size = 10


class OpenRouterAnalyzer:
    """Analyse cyclonique: ML d'abord, puis OpenRouter pour enrichir."""

    # ----- ÉTAPE 1: ANALYSE ML -----

    async def _ml_analyze_cyclones(self, cyclones: List[Dict]) -> List[Dict]:
        """Analyse chaque cyclone avec le modèle ML (CyclonePredictionModel)."""
        results = []
        for c in (cyclones or []):
            lat = c.get("lat", -18.9078)
            lng = c.get("lng", 47.5208)
            ml = await cyclone_model.predict(lat, lng, 24)
            results.append({
                "nom": c.get("title", "Système cyclonique")[:40],
                "lat": lat,
                "lng": lng,
                "wind_speed": c.get("wind_speed") or ml["features"]["wind_speed"],
                "pressure": c.get("pressure") or ml["features"]["pressure"],
                "level": c.get("level", "vigilance"),
                "ml_confidence": ml["confidence"],
                "ml_risk_score": ml["confidence"],
                "ml_season": ml["features"]["season"],
                "ml_sst": ml["features"]["sea_surface_temp"],
            })
        return results

    async def _ml_nlp_analyze(self, cyclones: List[Dict], incidents: List[Dict]) -> Dict:
        """Analyse NLP des titres/descriptions des cyclones et incidents."""
        texts = []
        for c in (cyclones or []):
            if c.get("title"):
                texts.append(c["title"])
        for i in (incidents or []):
            if i.get("title"):
                texts.append(i["title"])
            if i.get("description"):
                texts.append(i["description"])
        nlp_results = []
        for t in texts[:10]:
            r = await nlp_model.analyze(t)
            nlp_results.append(r)
        return {
            "nlp_analyses": nlp_results,
            "nlp_urgency_count": sum(1 for r in nlp_results if r.get("urgency") in ["critique", "elevee"]),
            "nlp_disaster_types": list(set(r.get("disaster_type") for r in nlp_results if r.get("disaster_type"))),
        }

    # ----- ÉTAPE 2: CONSTRUCTION CONTEXTE POUR OPENROUTER -----

    def _build_ml_context(self, ml_cyclones: List[Dict], ml_nlp: Dict,
                           incidents: List[Dict], shelters: List[Dict],
                           weather: Optional[Dict]) -> str:
        """Construit un prompt structuré avec les résultats ML pour OpenRouter."""
        parts = ["CONTEXTE ML - Analyse préliminaire des données:"]

        if ml_cyclones:
            parts.append("\n[Cyclones analysés par ML (Ridge Regression)]:")
            for c in ml_cyclones:
                parts.append(
                    f"  - {c['nom']}: vent {c['wind_speed']}km/h, pression {c['pressure']}hPa, "
                    f"score ML {c['ml_confidence']:.0f}/100, saison {c['ml_season']}, "
                    f"SST {c['ml_sst']}°C"
                )

        if ml_nlp.get("nlp_analyses"):
            parts.append(f"\n[Analyse NLP des signalements]:")
            parts.append(f"  - Urgences détectées: {ml_nlp['nlp_urgency_count']}")
            parts.append(f"  - Types de catastrophes: {', '.join(ml_nlp['nlp_disaster_types']) or 'aucun'}")

        if incidents:
            parts.append(f"\n[Incidents signalés ({len(incidents)}):]")
            for i in incidents[:5]:
                parts.append(f"  - {i.get('title', 'Incident')}: {i.get('description', '')[:80]}")

        if shelters:
            parts.append(f"\n[Abris disponibles ({len(shelters)}):]")
            for s in shelters[:5]:
                parts.append(f"  - {s.get('name', 'Abri')} (capacité: {s.get('capacity', '?')})")

        if weather:
            parts.append(f"\n[Météo actuelle]: temp {weather.get('temperature')}°C, "
                         f"humidité {weather.get('humidity')}%, vent {weather.get('wind_speed')}km/h, "
                         f"pression {weather.get('pressure')}hPa")

        return "\n".join(parts)

    # ----- ÉTAPE 3: APPEL OPENROUTER AVEC CONTEXTE ML -----

    async def _call_openrouter_with_ml(
        self, ml_context: str, ml_cyclones: List[Dict], ml_nlp: Dict
    ) -> Optional[Dict]:
        if not OPENROUTER_API_KEY:
            return None

        prompt = (
            f"{ml_context}\n\n"
            f"À partir des données ci-dessus (analysées par ML), réponds UNIQUEMENT en JSON valide:\n"
            f"{{\n"
            f'  "resume": "résumé concis de la situation (max 200 char.)",\n'
            f'  "risque_global": "faible|modéré|élevé|critique",\n'
            f'  "recommandations_public": ["recommandation1", "recommandation2", "recommandation3", "recommandation4"],\n'
            f'  "conseils_evacuation": "conseil d\'évacuation spécifique (max 150 char.)",\n'
            f'  "analyse_cyclones": [{{\n'
            f'    "nom": "nom du cyclone",\n'
            f'    "risque": "faible|modéré|élevé|critique",\n'
            f'    "vitesse_vent_estimee_kmh": nombre,\n'
            f'    "direction": "direction estimée",\n'
            f'    "zones_menacees": ["zone1", "zone2"],\n'
            f'    "recommandation": "reco spécifique pour ce cyclone"\n'
            f'  }}]\n'
            f"}}\n"
            f"RÈGLE: utilise UNIQUEMENT les données ML fournies. Ne sors que du JSON."
        )

        try:
            async with httpx.AsyncClient(timeout=OR_TIMEOUT) as client:
                resp = await client.post(
                    OPENROUTER_URL,
                    headers={
                        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
                        "Content-Type": "application/json",
                        "HTTP-Referer": "https://mitandrina.app",
                        "X-Title": "Mitandrina"
                    },
                    json={
                        "model": OPENROUTER_MODEL,
                        "messages": [
                            {"role": "system", "content": "Tu es un expert en météorologie et catastrophes naturelles à Madagascar. Analyse les données ML et réponds UNIQUEMENT en JSON valide."},
                            {"role": "user", "content": prompt}
                        ],
                        "max_tokens": 800,
                        "temperature": 0.1
                    }
                )
                resp.raise_for_status()
                data = resp.json()
                parts = data.get("choices", [{}])[0].get("message", {}).get("content", "")
                cleaned = parts.strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()
                parsed = json.loads(cleaned)

                # Post-processing NLP sur le résumé OpenRouter
                if parsed.get("resume"):
                    nlp_on_or = await nlp_model.analyze(parsed["resume"])
                    parsed["_nlp_verification"] = {
                        "urgence_detectee": nlp_on_or.get("urgency"),
                        "type_catastrophe": nlp_on_or.get("disaster_type"),
                        "mots_cles": nlp_on_or.get("keywords", [])[:5],
                    }

                return parsed
        except Exception as e:
            print(f"OpenRouter ML call error: {e}")
        return None

    # ----- ÉTAPE 4: GÉNÉRATION LOCALE À PARTIR DES SCORES ML -----

    def _ml_local_analysis(
        self, ml_cyclones: List[Dict], ml_nlp: Dict,
        shelters: List[Dict], weather: Optional[Dict],
        user_location: Optional[Dict]
    ) -> Dict:
        now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

        if not ml_cyclones:
            return {
                "resume": "Rien à signaler. Aucun système cyclonique actif détecté par le modèle ML.",
                "risque_global": "faible",
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
                "source": "ml_local",
                "_ml_scores": {"cyclone_scores": [], "nlp_urgency": 0}
            }

        max_ml_score = max(c["ml_confidence"] for c in ml_cyclones)
        n_high = sum(1 for c in ml_cyclones if c.get("level") in ["alerte", "urgence"])
        nlp_urgency = ml_nlp.get("nlp_urgency_count", 0)

        risk_score = (max_ml_score * 0.6) + (n_high * 10) + min(nlp_urgency * 8, 20)
        is_season = any(c.get("ml_season") == "cyclone" for c in ml_cyclones)
        if is_season:
            risk_score += 5

        if risk_score >= 70:
            risk = "critique"
            recs = [
                "Évacuez immédiatement si vous êtes en zone côtière ou inondable",
                "Mettez-vous à l'abri dans un bâtiment solide",
                "Suivez ABSOLUMENT les instructions des autorités",
                "N'empruntez pas les routes inondées",
            ]
            evac = "ÉVACUATION OBLIGATOIRE dans les zones côtières et à risque. Rendez-vous immédiatement à l'abri le plus proche."
            alertes = [{"titre": "ALERTE ROUGE - Cyclone majeur", "message": f"Score ML {max_ml_score:.0f}/100. Évacuation obligatoire.", "niveau": "urgence", "zone_concernee": "Zones côtières et à risque"}]
        elif risk_score >= 45:
            risk = "élevé"
            recs = [
                "Préparez-vous à évacuer si l'ordre est donné",
                "Sécurisez votre maison (volets, objets extérieurs)",
                "Faites des réserves d'eau et de nourriture pour 72h",
                "Restez informé en continu",
            ]
            evac = "Préparez votre évacuation. Faites le plein, préparez vos documents et un sac d'urgence."
            alertes = [{"titre": "Alerte orange - Cyclone puissant", "message": f"Score ML {max_ml_score:.0f}/100. Préparez-vous à évacuer.", "niveau": "alerte", "zone_concernee": "Zones menacées"}]
        elif risk_score >= 25:
            risk = "modéré"
            recs = [
                "Restez informé de l'évolution de la situation",
                "Vérifiez votre kit d'urgence",
                "Repérez l'abri le plus proche",
                "Évitez les déplacements non essentiels",
            ]
            evac = "Surveillez la situation. Identifiez votre abri le plus proche et préparez un sac d'urgence."
            alertes = [{"titre": "Vigilance cyclonique", "message": f"Score ML {max_ml_score:.0f}/100. Restez informé.", "niveau": "vigilance", "zone_concernee": "À déterminer"}]
        else:
            risk = "faible"
            recs = [
                "Aucune action immédiate nécessaire",
                "Restez informé des prévisions météo",
                "Profitez-en pour vérifier votre kit d'urgence",
            ]
            evac = "Aucune évacuation nécessaire pour le moment. Restez vigilant."
            alertes = []

        cyc_analysis = []
        for c in ml_cyclones:
            w = c.get("wind_speed") or 0
            lvl = c.get("level", "vigilance")
            ml_conf = c.get("ml_confidence", 50)
            c_lat = c.get("lat") or 0
            c_lng = c.get("lng") or 0
            cyc_risk = "critique" if ml_conf >= 76 else "élevé" if ml_conf >= 56 else "modéré" if ml_conf >= 31 else "faible"

            if c_lng > 48:
                dir_str = "Se déplace vers l'Ouest - impact côtier probable"
                zones = ["Côte Est", "Toamasina", "Brickaville"]
            elif c_lng > 44:
                dir_str = "Trajectoire vers les Hautes Terres"
                zones = ["Antananarivo", "Régions intérieures"]
            elif c_lat < -20:
                dir_str = "Trajectoire Sud"
                zones = ["Toliara", "Côte Sud"]
            elif c_lat < -15:
                dir_str = "Trajectoire Ouest"
                zones = ["Morondava", "Côte Ouest"]
            elif c_lat < -12:
                dir_str = "Trajectoire Nord"
                zones = ["Mahajanga", "Côte Nord"]
            else:
                dir_str = "Trajectoire estimée Ouest"
                zones = ["Régions côtières"]

            cyc_analysis.append({
                "nom": c["nom"],
                "risque": cyc_risk,
                "vitesse_vent_estimee_kmh": round(w, 1),
                "ml_confidence": round(ml_conf, 1),
                "direction": dir_str,
                "zones_menacees": zones,
                "recommandation": recs[0] if recs else "Restez vigilant"
            })

        # Construire résumé avec positions
        resume_parts = [f"Situation cyclonique {risk} à Madagascar."]
        resume_parts.append(f"{len(ml_cyclones)} système(s) actif(s), score ML max {max_ml_score:.0f}/100.")
        for c in ml_cyclones[:3]:
            c_lng = c.get("lng") or 0
            c_lat = c.get("lat") or 0
            pos = "Côte Est" if c_lng > 48 else "Intérieur des terres" if c_lng > 44 else "Côte Ouest" if c_lng < 44 else "Centre"
            resume_parts.append(f"Position: {pos} ({abs(c_lat):.1f}°S, {c_lng:.1f}°E).")
        if is_season:
            resume_parts.append("Saison cyclonique active.")

        return {
            "resume": " ".join(resume_parts),
            "risque_global": risk,
            "analyse_cyclones": cyc_analysis,
            "recommandations_public": recs,
            "recommandations_autorites": [
                "Activez les cellules de crise communales" if risk in ["élevé", "critique"] else "Maintenez la veille",
                "Préparez l'ouverture des abris" if risk in ["modéré", "élevé", "critique"] else "Vérifiez les stocks",
            ],
            "alertes_generees": alertes,
            "abris_recommandes": [
                {"nom": s.get("name", "Abri")[:30], "raison": "Abri disponible à proximité"}
                for s in (shelters or [])[:3]
            ],
            "conseils_evacuation": evac,
            "timestamp_analyse": now,
            "source": "ml_local",
            "_ml_scores": {
                "cyclone_scores": [c["ml_confidence"] for c in ml_cyclones],
                "nlp_urgency": nlp_urgency,
                "max_score": max_ml_score,
                "risk_score": risk_score
            }
        }

    # ----- API PUBLIQUE -----

    async def analyze(
        self,
        cyclones: List[Dict[str, Any]],
        incidents: List[Dict[str, Any]],
        shelters: List[Dict[str, Any]],
        weather: Optional[Dict[str, Any]] = None,
        user_location: Optional[Dict[str, float]] = None,
    ) -> Dict[str, Any]:
        cache_key = hashlib.md5(
            json.dumps([cyclones[:5], incidents[:5]], sort_keys=True, default=str).encode()
        ).hexdigest()
        if cached := _or_cache.get(cache_key):
            return cached

        if len(_or_cache) >= _or_cache_max_size:
            _or_cache.pop(next(iter(_or_cache)))

        # 1. ANALYSE ML: exécute les modèles sur les données
        ml_cyclones = await self._ml_analyze_cyclones(cyclones)
        ml_nlp = await self._ml_nlp_analyze(cyclones, incidents)

        # 2. GÉNÉRATION LOCALE basée sur les scores ML (fallback)
        local = self._ml_local_analysis(ml_cyclones, ml_nlp, shelters, weather, user_location)

        # 3. ENRICHISSEMENT OPENROUTER avec contexte ML
        ml_context = self._build_ml_context(ml_cyclones, ml_nlp, incidents, shelters, weather)
        or_result = await self._call_openrouter_with_ml(ml_context, ml_cyclones, ml_nlp)

        if or_result:
            # Fusion: les données ML remplacent les heuristiques, OpenRouter enrichit le texte
            nlp_verify = or_result.pop("_nlp_verification", {})
            local.update({
                "resume": or_result.get("resume", local["resume"]),
                "risque_global": or_result.get("risque_global", local["risque_global"]),
                "recommandations_public": or_result.get("recommandations_public", local["recommandations_public"]),
                "conseils_evacuation": or_result.get("conseils_evacuation", local["conseils_evacuation"]),
                "analyse_cyclones": or_result.get("analyse_cyclones", local["analyse_cyclones"]),
                "source": "openrouter+ml",
                "_or_raw": or_result,
                "_nlp_verification": nlp_verify,
            })
        else:
            local["source"] = "ml_local"

        _or_cache[cache_key] = local
        return local

    async def analyze_zone(
        self,
        cyclone: Dict[str, Any],
        user_lat: float,
        user_lng: float,
        nearby_shelters: List[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Analyse ML + OpenRouter pour une zone spécifique."""

        # 1. ML: score du cyclone modèle
        ml = await cyclone_model.predict(user_lat, user_lng, 6)
        ml_score = ml["confidence"]
        features = ml["features"]

        # 2. NLP sur le titre du cyclone
        nlp_on_title = await nlp_model.analyze(cyclone.get("title", "Cyclone") + " " + cyclone.get("level", ""))

        # 3. OpenRouter avec contexte ML
        if OPENROUTER_API_KEY:
            context = (
                f"ML Score: {ml_score:.0f}/100 pour cette zone. "
                f"Vent estimé ML: {features['wind_speed']}km/h. "
                f"Pression: {features['pressure']}hPa. "
                f"SST: {features['sea_surface_temp']}°C. "
                f"NLP urgence: {nlp_on_title.get('urgency')}. "
                f"Cyclone: vent {cyclone.get('wind_speed', '?')}km/h, "
                f"niveau {cyclone.get('level', '?')}."
            )

            prompt = (
                f"Zone touchée par un cyclone à Madagascar. {context}\n"
                f"Abris à proximité: {json.dumps([{'nom': s.get('name',''), 'capacite': s.get('capacity',0)} for s in (nearby_shelters or [])[:3]], ensure_ascii=False)}.\n"
                f"Réponds UNIQUEMENT en JSON: {{\"conseil_zone\":\"...\",\"abri_conseille\":\"...\",\"action_immediate\":\"...\",\"duree_alerte\":\"...\"}}"
            )

            try:
                async with httpx.AsyncClient(timeout=OR_TIMEOUT) as client:
                    resp = await client.post(
                        OPENROUTER_URL,
                        headers={
                            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
                            "Content-Type": "application/json",
                            "HTTP-Referer": "https://mitandrina.app",
                            "X-Title": "Mitandrina"
                        },
                        json={
                            "model": OPENROUTER_MODEL,
                            "messages": [
                                {"role": "system", "content": "Expert catastrophes Madagascar. JSON uniquement."},
                                {"role": "user", "content": prompt}
                            ],
                            "max_tokens": 300,
                            "temperature": 0.1
                        }
                    )
                    resp.raise_for_status()
                    data = resp.json()
                    content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
                    cleaned = content.strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()
                    result = json.loads(cleaned)
                    result["_ml_score"] = ml_score
                    result["_nlp_urgency"] = nlp_on_title.get("urgency")
                    return result
            except Exception as e:
                print(f"OpenRouter zone ML error: {e}")

        # Fallback: utilise les scores ML
        shelter_name = nearby_shelters[0].get("name", "Abri le plus proche") if nearby_shelters else "Abri inconnu"
        w = cyclone.get("wind_speed") or features.get("wind_speed", 50)
        lvl = cyclone.get("level", "vigilance")
        if ml_score >= 76 or w >= 100 or lvl == "urgence":
            return {
                "conseil_zone": "DANGER IMMÉDIAT. Évacuez vers l'abri le plus proche sans attendre.",
                "abri_conseille": shelter_name,
                "action_immediate": "Évacuez immédiatement vers l'intérieur des terres ou l'abri désigné.",
                "duree_alerte": "Impact imminent (moins d'1 heure)",
                "_ml_score": ml_score
            }
        elif ml_score >= 56 or w >= 60 or lvl == "alerte":
            return {
                "conseil_zone": "Situation dangereuse. Préparez-vous à évacuer rapidement.",
                "abri_conseille": shelter_name,
                "action_immediate": "Sécurisez votre maison et faites vos bagages d'urgence.",
                "duree_alerte": "Arrivée estimée dans 2 à 4 heures",
                "_ml_score": ml_score
            }
        else:
            return {
                "conseil_zone": "Surveillez la situation. Restez informé via les canaux officiels.",
                "abri_conseille": shelter_name,
                "action_immediate": "Préparez un kit d'urgence par précaution.",
                "duree_alerte": "Non déterminée avec précision",
                "_ml_score": ml_score
            }


openrouter_analyzer = OpenRouterAnalyzer()
