"""
Moteur de simulation cyclonique.
Génération de trajectoire réaliste, zones d'impact, routage A*.
"""

import math
import uuid
import random
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional, Tuple

from app.services.ml_models import cyclone_model
from app.services.geo_utils import haversine_km as haversine, haversine_m
from app.services.routing.astar_service import AStarRouter


router_astar = AStarRouter()


def bearing(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    dlon = math.radians(lon2 - lon1)
    y = math.sin(dlon) * math.cos(math.radians(lat2))
    x = math.cos(math.radians(lat1)) * math.sin(math.radians(lat2)) - math.sin(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.cos(dlon)
    return (math.degrees(math.atan2(y, x)) + 360) % 360


def destination(lat: float, lon: float, bearing_deg: float, dist_km: float) -> Tuple[float, float]:
    R = 6371
    lat1, lon1 = math.radians(lat), math.radians(lon)
    brng = math.radians(bearing_deg)
    d = dist_km / R
    lat2 = math.asin(math.sin(lat1) * math.cos(d) + math.cos(lat1) * math.sin(d) * math.cos(brng))
    lon2 = lon1 + math.atan2(math.sin(brng) * math.sin(d) * math.cos(lat1), math.cos(d) - math.sin(lat1) * math.sin(lat2))
    return math.degrees(lat2), math.degrees(lon2)


def wind_pressure_from_intensity(intensity: int, dist_from_center_km: float, on_land: bool) -> Tuple[float, float]:
    base_wind = 30 + intensity * 15
    max_wind = min(base_wind + random.uniform(-10, 15), 220)
    max_pressure = max(1020 - intensity * 8, 920)
    ratio = max(0, 1 - dist_from_center_km / 300)
    wind = max_wind * ratio * (0.6 if on_land else 1.0)
    pressure = max_pressure + (1 - ratio) * 40 + (random.uniform(-5, 5))
    return round(wind, 1), round(pressure, 1)


def generate_trajectory(
    start_lat: float,
    start_lng: float,
    intensity: int,
    total_hours: int = 168,
    hour_step: int = 6
) -> List[Dict[str, Any]]:
    now = datetime.utcnow()
    track = []

    base_bearing = 270 + random.uniform(-20, 20)
    speed_kmh = 8 + intensity * 2 + random.uniform(-3, 3)
    meander_amplitude = 0.5 + random.uniform(0, 1.0)
    meander_freq = 2 * math.pi / (40 + random.uniform(-10, 10))

    cur_lat, cur_lng = start_lat, start_lng
    on_land = False

    for h in range(0, total_hours + 1, hour_step):
        dist = speed_kmh * hour_step
        wander = meander_amplitude * math.sin(meander_freq * h)
        cur_bearing = (base_bearing + wander) % 360
        cur_lat, cur_lng = destination(cur_lat, cur_lng, cur_bearing, dist)

        if cur_lng < 44 and cur_lat < -12:
            on_land = True

        wind, pressure = wind_pressure_from_intensity(intensity, 0, on_land)

        stage = "Depression tropicale"
        if wind >= 120: stage = "Cyclone tropical intense"
        elif wind >= 80: stage = "Cyclone tropical"
        elif wind >= 55: stage = "Forte tempete tropicale"
        elif wind >= 35: stage = "Tempete tropicale moderee"

        ts = now + timedelta(hours=h)
        track.append({
            "datetime": ts.strftime("%Y-%m-%d %H:%M"),
            "lat": round(cur_lat, 2),
            "lng": round(cur_lng, 2),
            "stage": stage,
            "wind": round(wind),
            "gusts": round(wind * 1.4),
            "pressure": round(pressure),
            "note": f"Vents: {round(wind)} km/h, Position: {round(cur_lat,1)}S {round(cur_lng,1)}E"
        })

    return track


def impact_zone_geojson(track: List[Dict[str, Any]], radius_km: float) -> Dict[str, Any]:
    if not track:
        return {"type": "Polygon", "coordinates": [[]]}

    coords = []
    segments = max(12, int(radius_km))
    for p in track:
        lat, lng = p["lat"], p["lng"]
        for angle in range(0, 360, max(10, 360 // segments)):
            r_km = radius_km * (1 + (p.get("wind", 50) / 200))
            dlng = r_km / (111.32 * math.cos(math.radians(lat)))
            dlat = r_km / 110.574
            coords.append([lng + dlng * math.cos(math.radians(angle)),
                           lat + dlat * math.sin(math.radians(angle))])

    hull = convex_hull(coords)
    return {"type": "Polygon", "coordinates": [hull]}


def convex_hull(points: List[List[float]]) -> List[List[float]]:
    pts = sorted(set((x, y) for x, y in points))
    if len(pts) <= 1:
        return pts

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower = []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)

    upper = []
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)

    return lower[:-1] + upper[:-1]


def estimate_affected_population(impact_zone_geojson: Dict[str, Any]) -> int:
    coords = impact_zone_geojson.get("coordinates", [[]])[0]
    if not coords:
        return 0

    lngs = [c[0] for c in coords]
    lats = [c[1] for c in coords]
    if not lngs or not lats:
        return 0

    min_lat, max_lat = min(lats), max(lats)
    min_lng, max_lng = min(lngs), max(lngs)

    area_deg = (max_lat - min_lat) * (max_lng - min_lng)
    area_km2 = area_deg * 111 * 111 * abs(math.cos(math.radians((min_lat + max_lat) / 2)))

    pop_density = random.uniform(30, 200)
    estimated = int(area_km2 * pop_density)
    return max(1000, min(estimated, 5000000))


async def compute_evacuation_routes(
    impact_zone: Dict[str, Any],
    shelters: List[Dict[str, Any]],
    center_lat: float,
    center_lng: float
) -> Tuple[int, int, List[Dict]]:
    routes = []
    for shelter in (shelters or [])[:5]:
        slat = shelter.get("lat") or shelter.get("location_lat")
        slng = shelter.get("lng") or shelter.get("location_lng")
        if not slat or not slng:
            continue
        try:
            result = await router_astar.find_path(
                graph=None,
                origin=(center_lat, center_lng),
                destination=(slat, slng),
                avoid_zone_ids=None,
                mode="car"
            )
            routes.append(result)
        except Exception:
            alt = {
                "id": str(uuid.uuid4()),
                "distance_km": round(haversine(center_lat, center_lng, slat, slng), 1),
                "time_minutes": int(round(haversine(center_lat, center_lng, slat, slng) / 40 * 60)),
                "danger_score": round(random.uniform(0.1, 0.6), 2)
            }
            routes.append(alt)

    count = len(routes)
    avg_time = int(sum(r.get("time_minutes", 60) for r in routes) / max(count, 1))
    return count, avg_time, routes


async def run_simulation(simulation: Dict[str, Any]) -> Dict[str, Any]:
    sim_type = simulation.get("scenario_type") or simulation.get("scenarioType", "cyclone")
    lat = float(simulation.get("center_lat", -18.9))
    lng = float(simulation.get("center_lng", 47.5))
    intensity = int(simulation.get("intensity_level", 5))
    radius = float(simulation.get("radius_km", 10))

    if sim_type != "cyclone":
        return {
            "affected_population": random.randint(3000, 15000),
            "risk_index": str(round(intensity * 0.95, 1)),
            "safe_refuges_identified": ["Centre d'urgence Analakely", "Refuge Antanimena"],
            "evacuation_routes": [],
            "is_simulation_gezani": False
        }

    total_hours = 72 + intensity * 10
    track = generate_trajectory(lat, lng, intensity, total_hours=total_hours, hour_step=6)
    zone = impact_zone_geojson(track, radius)
    population = estimate_affected_population(zone)
    routes_count, evac_time, evac_routes = await compute_evacuation_routes(zone, [], lat, lng)

    max_wind = max((p.get("wind", 0) for p in track), default=0)
    min_pressure = min((p.get("pressure", 1020) for p in track), default=1020)

    return {
        "affected_population": population,
        "risk_index": str(round(min(10, intensity * 0.9 + max_wind / 100), 1)),
        "is_simulation_gezani": False,
        "is_historical_freddy": False,
        "max_wind_kmh": max_wind,
        "max_gusts_kmh": round(max_wind * 1.4),
        "min_pressure_hpa": min_pressure,
        "total_days": round(total_hours / 24, 1),
        "track": track,
        "impact_zone": zone,
        "safe_refuges_identified": ["Abri prioritaire Toamasina", "Centre d'urgence Brickaville", "Gymnase Mahanoro"],
        "evacuation_routes": evac_routes,
        "simulation_summary": (
            f"Simulation cyclonique de type {sim_type}. "
            f"Trajectoire generee sur {round(total_hours/24,1)} jours. "
            f"Vent max: {max_wind} km/h, Pression min: {min_pressure} hPa. "
            f"Population affectee estimee: {population} personnes. "
            f"{routes_count} routes d'evacuation calculees."
        )
    }
