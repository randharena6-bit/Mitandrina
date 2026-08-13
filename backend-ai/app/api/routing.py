"""Router pour le calcul d'itinéraires avec A* + OSMnx."""

import asyncio
from datetime import datetime
from typing import List, Optional, Dict, Any

from fastapi import APIRouter, HTTPException, Query

from app.services.geo_utils import haversine_km

router = APIRouter()

MODE_SPEEDS = {"car": 40, "foot": 5, "bike": 15}

FALLBACK_SHELTERS = [
    {"id": "shelter_tana", "name": "Refuge Antananarivo Centre", "type": "school", "location_lat": -18.9078, "location_lng": 47.5208, "capacity": 500, "current_occupancy": 120},
    {"id": "shelter_majunga", "name": "Refuge Mahajanga", "type": "school", "location_lat": -15.7167, "location_lng": 46.3167, "capacity": 400, "current_occupancy": 60},
    {"id": "shelter_tamatave", "name": "Refuge Toamasina", "type": "stadium", "location_lat": -18.1492, "location_lng": 49.4028, "capacity": 800, "current_occupancy": 50},
    {"id": "shelter_fianar", "name": "Refuge Fianarantsoa", "type": "school", "location_lat": -21.4526, "location_lng": 47.0873, "capacity": 350, "current_occupancy": 40},
    {"id": "shelter_diego", "name": "Refuge Antsiranana", "type": "community_center", "location_lat": -12.2787, "location_lng": 49.2917, "capacity": 300, "current_occupancy": 30},
    {"id": "shelter_tulear", "name": "Refuge Toliara", "type": "school", "location_lat": -23.3499, "location_lng": 43.6788, "capacity": 250, "current_occupancy": 20},
    {"id": "shelter_antsirabe", "name": "Refuge Antsirabe", "type": "hotel", "location_lat": -19.8650, "location_lng": 47.0333, "capacity": 200, "current_occupancy": 35},
    {"id": "shelter_morondava", "name": "Refuge Morondava", "type": "school", "location_lat": -20.2887, "location_lng": 44.3178, "capacity": 200, "current_occupancy": 15},
    {"id": "shelter_nosybe", "name": "Refuge Nosy Be", "type": "community_center", "location_lat": -13.3120, "location_lng": 48.2548, "capacity": 150, "current_occupancy": 10},
    {"id": "shelter_manakara", "name": "Refuge Manakara", "type": "school", "location_lat": -22.1464, "location_lng": 48.0106, "capacity": 180, "current_occupancy": 5},
]


def _interpolate_coords(lat1, lon1, lat2, lon2, num_points=10):
    """Génère des points intermédiaires avec une légère courbure pour simuler une route."""
    import math
    points = []
    for i in range(num_points + 1):
        t = i / num_points
        lat = lat1 + (lat2 - lat1) * t
        lng = lon1 + (lon2 - lon1) * t
        offset = math.sin(t * math.pi) * 0.005
        lat += offset * 0.5
        lng -= offset
        points.append([lng, lat])
    return points


def _compute_fallback_danger_score(coordinates, danger_zones):
    """Calcule le score de danger d'un tracé de secours par rapport aux zones de danger.
    Retourne le score maximum de danger rencontré sur tout le trajet (0-100)."""
    if not danger_zones:
        return 0.0
    max_danger = 0.0
    for coord in coordinates:
        lng, lat = coord[0], coord[1]
        for zone in danger_zones:
            zlat = float(zone.get("center_lat") or 0)
            zlng = float(zone.get("center_lng") or 0)
            radius_km = float(zone.get("radius_km") or 5)
            level = float(zone.get("danger_level") or 0.5)
            dist = haversine_km(lat, lng, zlat, zlng)
            if dist < radius_km:
                penetration = 1.0 - (dist / radius_km)
                danger = level * penetration
                max_danger = max(max_danger, min(1.0, danger))
    return round(min(100.0, max_danger * 100), 2)


def _fallback_route(origin_lat, origin_lng, destination_lat, destination_lng, mode, danger_zones=None):
    import math
    from datetime import datetime

    lat1, lon1 = origin_lat, origin_lng
    lat2, lon2 = destination_lat, destination_lng

    distance_km = haversine_km(lat1, lon1, lat2, lon2)
    if distance_km < 0.1:
        distance_km = 0.1

    speed = MODE_SPEEDS.get(mode, 40)
    estimated_time = max(1, round((distance_km / speed) * 60))

    coordinates = _interpolate_coords(lat1, lon1, lat2, lon2, num_points=15)
    danger_score = _compute_fallback_danger_score(coordinates, danger_zones or [])

    geojson = {
        "type": "LineString",
        "coordinates": coordinates
    }

    waypoints = [
        {"lat": lat1, "lng": lon1, "name": "Départ"},
        {"lat": (lat1 + lat2) / 2, "lng": (lon1 + lon2) / 2, "name": "Point intermédiaire"},
        {"lat": lat2, "lng": lon2, "name": "Destination"}
    ]

    return {
        "route_id": "route_" + datetime.utcnow().strftime("%Y%m%d%H%M%S"),
        "path": geojson,
        "distance_km": round(distance_km, 2),
        "estimated_time_minutes": estimated_time,
        "danger_score": danger_score,
        "waypoints": waypoints,
        "alternatives": [],
        "calculated_at": datetime.utcnow().isoformat()
    }


async def _fetch_active_danger_zones() -> List[Dict[str, Any]]:
    """Récupère les zones de danger actives depuis la base."""
    try:
        from sqlalchemy import text
        from app.core.database import AsyncSessionLocal
        async with AsyncSessionLocal() as db:
            result = await db.execute(
                text("""
                    SELECT a.id, a.title, a.level, a.type,
                           dz.center_lat, dz.center_lng,
                           dz.danger_score, dz.radius_km
                    FROM alerts a
                    LEFT JOIN disaster_zones dz ON dz.id = a.zone_id
                    WHERE a.resolved_at IS NULL
                      AND (dz.id IS NULL OR dz.is_active = true)
                      AND (dz.id IS NULL OR dz.expires_at IS NULL OR dz.expires_at > NOW())
                """)
            )
            zones = []
            for r in result.mappings().all():
                d = dict(r)
                if d.get("center_lat") and d.get("center_lng"):
                    d["radius_km"] = d.pop("radius_km", None) or 5
                    d["danger_level"] = (d.pop("danger_score", None) or 50) / 100.0
                    zones.append(d)
            return zones
    except Exception:
        return []


async def _fetch_available_shelters() -> List[Dict[str, Any]]:
    """Récupère les refuges disponibles depuis la base."""
    try:
        from sqlalchemy import text
        from app.core.database import AsyncSessionLocal
        async with AsyncSessionLocal() as db:
            result = await db.execute(
                text("""
                    SELECT id, name, type, location_lat, location_lng,
                           capacity, current_occupancy, has_medical_facilities
                    FROM shelters
                    WHERE is_available = true AND is_full = false
                """)
            )
            return [dict(r) for r in result.mappings().all()]
    except Exception:
        return list(FALLBACK_SHELTERS)


def _is_in_danger_zone(lat: float, lng: float, danger_zones: List[Dict]) -> Optional[Dict]:
    """Vérifie si un point est dans une zone de danger. Retourne la zone ou None."""
    for zone in danger_zones:
        zlat = float(zone.get("center_lat") or 0)
        zlng = float(zone.get("center_lng") or 0)
        radius_km = float(zone.get("radius_km") or zone.get("radius") or 5)
        dist_km = haversine_km(lat, lng, zlat, zlng)
        if dist_km <= radius_km:
            return {
                "id": str(zone.get("id", "")),
                "title": zone.get("title", "Zone de danger"),
                "type": zone.get("type", "unknown"),
                "level": zone.get("level", 1),
                "distance_km": round(dist_km, 2)
            }
    return None


async def _find_safe_alternatives(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    danger_zones: List[Dict], exclude_id: str = None,
    max_results: int = 3
) -> List[Dict]:
    """Trouve des refuges sûrs (hors zone danger) proches de la destination."""
    shelters = await _fetch_available_shelters()

    safe = []
    for s in shelters:
        if exclude_id and str(s.get("id")) == str(exclude_id):
            continue
        if _is_in_danger_zone(s["location_lat"], s["location_lng"], danger_zones):
            continue
        dist_to_dest = haversine_km(dest_lat, dest_lng, s["location_lat"], s["location_lng"])
        if dist_to_dest > 100:
            continue
        safe.append({
            "id": str(s["id"]),
            "name": s["name"],
            "type": s.get("type", "generic"),
            "lat": s["location_lat"],
            "lng": s["location_lng"],
            "capacity": s["capacity"],
            "occupancy": s.get("current_occupancy", 0),
            "distance_km": round(dist_to_dest, 1),
            "has_medical": s.get("has_medical_facilities", False)
        })

    safe.sort(key=lambda x: x["distance_km"])
    return safe[:max_results]


@router.post("/evacuation")
async def calculate_evacuation_route(request: dict):
    """
    Calcule un itinéraire d'évacuation optimal.
    Utilise A* + OSMnx si disponible, sinon fallback Haversine.
    Vérifie aussi si le refuge de destination est en zone de danger.
    """
    try:
        origin_lat = float(request.get("origin_lat", 0))
        origin_lng = float(request.get("origin_lng", 0))
        dest_lat = float(request.get("destination_lat", 0))
        dest_lng = float(request.get("destination_lng", 0))
        max_distance = float(request.get("max_distance_km", 10))
        mode = request.get("mode", "car")
        avoid_zones = request.get("avoid_zones", [])
        shelter_id = request.get("shelter_id")
        inline_zones = request.get("inline_zones", [])

        danger_zones = await _fetch_active_danger_zones()

        for iz in inline_zones:
            danger_zones.append({
                "id": iz.get("id", "inline_zone"),
                "center_lat": float(iz.get("center_lat", iz.get("lat", 0))),
                "center_lng": float(iz.get("center_lng", iz.get("lng", 0))),
                "radius_km": float(iz.get("radius_km", iz.get("radius", 0))) / 1000,
                "danger_level": float(iz.get("danger_level", iz.get("danger_score", 50))) / 100,
                "title": iz.get("name", iz.get("title", "Zone simulée")),
                "type": iz.get("type", "cyclone"),
                "level": iz.get("level", "urgence")
            })

        shelter_in_danger = _is_in_danger_zone(dest_lat, dest_lng, danger_zones)
        safe_alternatives = []
        if shelter_in_danger:
            safe_alternatives = await _find_safe_alternatives(
                origin_lat, origin_lng, dest_lat, dest_lng, danger_zones,
                exclude_id=shelter_id
            )

        try:
            async with asyncio.timeout(25):
                from app.services.routing.astar_service import AStarRouter
                from app.services.routing.osm_cache import OSMCache

                osm_cache = OSMCache()
                astar = AStarRouter()

                graph = await osm_cache.get_graph(
                    center_lat=origin_lat,
                    center_lng=origin_lng,
                    radius_km=min(max_distance, 50)
                )

                if graph is not None:
                    route = await astar.find_path(
                        graph=graph,
                        origin=(origin_lat, origin_lng),
                        destination=(dest_lat, dest_lng),
                        avoid_zone_ids=avoid_zones,
                        mode=mode,
                        danger_zones=danger_zones
                    )

                    return {
                        "route_id": route["id"],
                        "path": route["geojson"],
                        "distance_km": route["distance_km"],
                        "estimated_time_minutes": route["time_minutes"],
                        "danger_score": route["danger_score"],
                        "waypoints": route["waypoints"],
                        "alternatives": route.get("alternatives"),
                        "calculated_at": datetime.utcnow().isoformat(),
                        "shelter_in_danger": shelter_in_danger,
                        "safe_alternatives": safe_alternatives
                    }
        except (ImportError, TimeoutError, Exception):
            pass

        route = _fallback_route(origin_lat, origin_lng, dest_lat, dest_lng, mode, danger_zones)
        route["shelter_in_danger"] = shelter_in_danger
        route["safe_alternatives"] = safe_alternatives
        return route

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur de calcul d'itinéraire: {str(e)}")


@router.post("/to-shelter")
async def find_route_to_nearest_shelter(request: dict):
    """
    Trouve le meilleur refuge et calcule la route optimale vers celui-ci.
    """
    try:
        user_lat = float(request.get("user_lat", 0))
        user_lng = float(request.get("user_lng", 0))
        max_distance_km = float(request.get("max_distance_km", 50))
        prefer_medical = request.get("prefer_medical", False)

        try:
            from sqlalchemy import text
            from app.core.database import AsyncSessionLocal

            async with AsyncSessionLocal() as db:
                query = text("""
                    SELECT id, name, type, location_lat, location_lng,
                           capacity, current_occupancy,
                           has_medical_facilities
                    FROM shelters
                    WHERE is_available = true AND is_full = false
                    ORDER BY
                        CASE WHEN :prefer_medical AND has_medical_facilities THEN 0 ELSE 1 END,
                        ABS(location_lat - :lat) + ABS(location_lng - :lng)
                    LIMIT 1
                """)

                result = await db.execute(query, {
                    "lat": user_lat, "lng": user_lng,
                    "prefer_medical": prefer_medical
                })
                shelter = result.mappings().first()

                if shelter:
                    route = await calculate_evacuation_route({
                        "origin_lat": user_lat,
                        "origin_lng": user_lng,
                        "destination_lat": shelter["location_lat"],
                        "destination_lng": shelter["location_lng"],
                        "mode": "car",
                        "max_distance_km": max_distance_km,
                        "avoid_zones": []
                    })

                    return {
                        "shelter_id": str(shelter["id"]),
                        "shelter_name": shelter["name"],
                        "shelter_type": shelter["type"],
                        "shelter_location": {
                            "lat": shelter["location_lat"],
                            "lng": shelter["location_lng"]
                        },
                        "route": route,
                        "shelter_capacity": {
                            "total": shelter["capacity"],
                            "occupied": shelter["current_occupancy"],
                            "remaining": shelter["capacity"] - shelter["current_occupancy"]
                        }
                    }
        except Exception:
            pass

        fallback_shelters = [
            {"name": "Refuge Antananarivo Centre", "lat": -18.9078, "lng": 47.5208, "capacity": 500},
            {"name": "Refuge Mahajanga", "lat": -15.7167, "lng": 46.3167, "capacity": 400},
            {"name": "Refuge Toamasina", "lat": -18.1492, "lng": 49.4028, "capacity": 800},
            {"name": "Refuge Fianarantsoa", "lat": -21.4526, "lng": 47.0873, "capacity": 350},
            {"name": "Refuge Antsiranana", "lat": -12.2787, "lng": 49.2917, "capacity": 300},
            {"name": "Refuge Toliara", "lat": -23.3499, "lng": 43.6788, "capacity": 250},
        ]
        nearest = min(fallback_shelters, key=lambda s: haversine_km(user_lat, user_lng, s["lat"], s["lng"]))

        route = _fallback_route(user_lat, user_lng, nearest["lat"], nearest["lng"], "car")

        return {
            "shelter_id": "shelter_fallback",
            "shelter_name": nearest["name"],
            "shelter_type": "generic",
            "shelter_location": {"lat": nearest["lat"], "lng": nearest["lng"]},
            "route": route,
            "shelter_capacity": {"total": nearest["capacity"], "occupied": 0, "remaining": nearest["capacity"]}
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur: {str(e)}")


@router.get("/shelters/nearby")
async def get_nearby_shelters(
    lat: float,
    lng: float,
    radius_km: float = Query(default=50, le=200),
    min_capacity: int = 10
):
    """
    Liste les refuges disponibles à proximité.
    """
    try:
        from sqlalchemy import text
        from app.core.database import AsyncSessionLocal

        async with AsyncSessionLocal() as db:
            query = text("""
                SELECT id, name, type, address, phone,
                       location_lat, location_lng,
                       capacity, current_occupancy,
                       has_medical_facilities, has_food, has_water
                FROM shelters
                WHERE is_available = true AND capacity >= :min_capacity
                ORDER BY ABS(location_lat - :lat) + ABS(location_lng - :lng)
            """)

            result = await db.execute(query, {
                "lat": lat, "lng": lng,
                "min_capacity": min_capacity
            })
            shelters = result.mappings().all()

            return {
                "shelters": [dict(s) for s in shelters],
                "count": len(shelters),
                "search_params": {"lat": lat, "lng": lng, "radius_km": radius_km}
            }
    except Exception:
        all_shelters = [
            {"id": "shelter_tana", "name": "Refuge Antananarivo Centre", "type": "school", "address": "Antananarivo", "location_lat": -18.9078, "location_lng": 47.5208, "capacity": 500, "current_occupancy": 120, "has_medical_facilities": True, "has_food": True, "has_water": True},
            {"id": "shelter_majunga", "name": "Refuge Mahajanga", "type": "school", "address": "Mahajanga", "location_lat": -15.7167, "location_lng": 46.3167, "capacity": 400, "current_occupancy": 60, "has_medical_facilities": True, "has_food": True, "has_water": True},
            {"id": "shelter_tamatave", "name": "Refuge Toamasina", "type": "stadium", "address": "Toamasina", "location_lat": -18.1492, "location_lng": 49.4028, "capacity": 800, "current_occupancy": 50, "has_medical_facilities": True, "has_food": True, "has_water": True},
            {"id": "shelter_fianar", "name": "Refuge Fianarantsoa", "type": "school", "address": "Fianarantsoa", "location_lat": -21.4526, "location_lng": 47.0873, "capacity": 350, "current_occupancy": 40, "has_medical_facilities": False, "has_food": True, "has_water": True},
            {"id": "shelter_diego", "name": "Refuge Antsiranana", "type": "community_center", "address": "Antsiranana", "location_lat": -12.2787, "location_lng": 49.2917, "capacity": 300, "current_occupancy": 30, "has_medical_facilities": True, "has_food": True, "has_water": True},
            {"id": "shelter_tulear", "name": "Refuge Toliara", "type": "school", "address": "Toliara", "location_lat": -23.3499, "location_lng": 43.6788, "capacity": 250, "current_occupancy": 20, "has_medical_facilities": True, "has_food": False, "has_water": True},
            {"id": "shelter_antsirabe", "name": "Refuge Antsirabe", "type": "hotel", "address": "Antsirabe", "location_lat": -19.8650, "location_lng": 47.0333, "capacity": 200, "current_occupancy": 35, "has_medical_facilities": False, "has_food": True, "has_water": True},
            {"id": "shelter_morondava", "name": "Refuge Morondava", "type": "school", "address": "Morondava", "location_lat": -20.2887, "location_lng": 44.3178, "capacity": 200, "current_occupancy": 15, "has_medical_facilities": False, "has_food": True, "has_water": True},
            {"id": "shelter_nosybe", "name": "Refuge Nosy Be", "type": "community_center", "address": "Nosy Be", "location_lat": -13.3120, "location_lng": 48.2548, "capacity": 150, "current_occupancy": 10, "has_medical_facilities": True, "has_food": True, "has_water": True},
            {"id": "shelter_manakara", "name": "Refuge Manakara", "type": "school", "address": "Manakara", "location_lat": -22.1464, "location_lng": 48.0106, "capacity": 180, "current_occupancy": 5, "has_medical_facilities": False, "has_food": True, "has_water": True},
        ]

        for s in all_shelters:
            s["distance_km"] = round(haversine_km(lat, lng, s["location_lat"], s["location_lng"]), 1)

        all_shelters.sort(key=lambda s: s["distance_km"])
        return {
            "shelters": all_shelters,
            "count": len(all_shelters),
            "search_params": {"lat": lat, "lng": lng, "radius_km": radius_km}
        }


@router.get("/graph/stats")
async def get_graph_statistics(
    lat: float,
    lng: float,
    radius_km: float = 20
):
    """Statistiques sur le graphe routier OSM chargé."""
    try:
        from app.services.routing.osm_cache import OSMCache
        osm_cache = OSMCache()
        graph = await osm_cache.get_graph(lat, lng, radius_km)

        if graph is None:
            return {"nodes": 0, "edges": 0, "area_km2": 0, "center": {"lat": lat, "lng": lng}, "cached": False, "error": "Graph non disponible"}

        return {
            "nodes": len(graph.nodes),
            "edges": len(graph.edges),
            "area_km2": radius_km ** 2 * 3.14,
            "center": {"lat": lat, "lng": lng},
            "cached": osm_cache.is_cached(lat, lng, radius_km)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
