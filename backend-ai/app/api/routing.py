"""Router pour le calcul d'itinéraires avec A* + OSMnx."""

from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, HTTPException, Query

from app.models.schemas import (
    RouteRequest,
    RouteResponse,
    ShelterRouteRequest,
    ShelterRouteResponse
)
from app.services.routing.astar_service import AStarRouter
from app.services.routing.osm_cache import OSMCache

router = APIRouter()
osm_cache = OSMCache()
astar = AStarRouter()


@router.post("/evacuation", response_model=RouteResponse)
async def calculate_evacuation_route(request: RouteRequest):
    """
    Calcule un itinéraire d'évacuation optimal avec l'algorithme A*.
    
    La pondération inclut:
    - Distance
    - Danger des zones traversées (×10)
    - Type de route
    """
    try:
        # Récupérer ou créer le graphe routier
        graph = await osm_cache.get_graph(
            center_lat=request.origin_lat,
            center_lng=request.origin_lng,
            radius_km=min(request.max_distance_km, 50)
        )
        
        # Exécuter A*
        route = await astar.find_path(
            graph=graph,
            origin=(request.origin_lat, request.origin_lng),
            destination=(request.destination_lat, request.destination_lng),
            avoid_zone_ids=request.avoid_zones,
            mode=request.mode
        )
        
        return RouteResponse(
            route_id=route["id"],
            path=route["geojson"],
            distance_km=route["distance_km"],
            estimated_time_minutes=route["time_minutes"],
            danger_score=route["danger_score"],
            waypoints=route["waypoints"],
            alternatives=route.get("alternatives"),
            calculated_at=datetime.utcnow()
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur calcul route: {str(e)}")


@router.post("/to-shelter", response_model=ShelterRouteResponse)
async def find_route_to_nearest_shelter(request: ShelterRouteRequest):
    """
    Trouve le meilleur refuge et calcule la route optimale vers celui-ci.
    """
    try:
        # Trouver les abris disponibles
        from sqlalchemy import text
        from app.core.database import AsyncSessionLocal
        
        async with AsyncSessionLocal() as db:
            # Requête pour abris proches avec capacité
            query = text("""
                SELECT 
                    id, name, type, location_lat, location_lng,
                    capacity, current_occupancy,
                    has_medical_facilities,
                    ST_Distance(
                        ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                        location
                    ) as distance
                FROM shelters
                WHERE is_available = true 
                    AND is_full = false
                    AND ST_DWithin(
                        ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                        location,
                        :radius
                    )
                ORDER BY 
                    CASE WHEN :prefer_medical AND has_medical_facilities THEN 0 ELSE 1 END,
                    distance
                LIMIT 1
            """)
            
            result = await db.execute(
                query,
                {
                    "lat": request.user_lat,
                    "lng": request.user_lng,
                    "radius": request.max_distance_km * 1000,
                    "prefer_medical": request.prefer_medical
                }
            )
            shelter = result.mappings().first()
            
            if not shelter:
                raise HTTPException(status_code=404, detail="Aucun refuge disponible dans le rayon")
        
        # Calculer la route
        route_request = RouteRequest(
            origin_lat=request.user_lat,
            origin_lng=request.user_lng,
            destination_lat=shelter["location_lat"],
            destination_lng=shelter["location_lng"],
            mode="car"
        )
        
        route = await calculate_evacuation_route(route_request)
        
        return ShelterRouteResponse(
            shelter_id=str(shelter["id"]),
            shelter_name=shelter["name"],
            shelter_type=shelter["type"],
            shelter_location={
                "lat": shelter["location_lat"],
                "lng": shelter["location_lng"]
            },
            route=route,
            shelter_capacity={
                "total": shelter["capacity"],
                "occupied": shelter["current_occupancy"],
                "remaining": shelter["capacity"] - shelter["current_occupancy"]
            }
        )
        
    except HTTPException:
        raise
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
    from sqlalchemy import text
    from app.core.database import AsyncSessionLocal
    
    async with AsyncSessionLocal() as db:
        query = text("""
            SELECT 
                id, name, type, address, phone,
                location_lat, location_lng,
                capacity, current_occupancy,
                has_medical_facilities, has_food, has_water,
                ST_Distance(
                    ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                    location
                ) / 1000 as distance_km
            FROM shelters
            WHERE is_available = true
                AND capacity >= :min_capacity
                AND ST_DWithin(
                    ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                    location,
                    :radius
                )
            ORDER BY distance_km
        """)
        
        result = await db.execute(
            query,
            {
                "lat": lat,
                "lng": lng,
                "radius": radius_km * 1000,
                "min_capacity": min_capacity
            }
        )
        shelters = result.mappings().all()
        
        return {
            "shelters": [dict(s) for s in shelters],
            "count": len(shelters),
            "search_params": {
                "lat": lat,
                "lng": lng,
                "radius_km": radius_km
            }
        }


@router.get("/graph/stats")
async def get_graph_statistics(
    lat: float,
    lng: float,
    radius_km: float = 20
):
    """Statistiques sur le graphe routier OSM chargé."""
    try:
        graph = await osm_cache.get_graph(lat, lng, radius_km)
        
        return {
            "nodes": len(graph.nodes),
            "edges": len(graph.edges),
            "area_km2": radius_km ** 2 * 3.14,
            "center": {"lat": lat, "lng": lng},
            "cached": osm_cache.is_cached(lat, lng, radius_km)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
