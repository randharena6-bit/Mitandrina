"""
Service de calcul d'itinéraire avec Algorithme A*.
Intègre la pondération par zones de danger.
"""

import uuid
import heapq
from datetime import datetime
from typing import List, Dict, Any, Tuple, Optional, Set
from dataclasses import dataclass, field

import networkx as nx


@dataclass(order=True)
class PriorityNode:
    """Nœud pour la priority queue A*."""
    f_score: float
    node: str = field(compare=False)
    

class AStarRouter:
    """
    Routeur A* avec intégration des zones de danger.
    
    Heuristique: Distance Haversine (vol d'oiseau)
    Coût: distance × (1 + danger_factor × 10)
    """
    
    async def find_path(
        self,
        graph: nx.Graph,
        origin: Tuple[float, float],
        destination: Tuple[float, float],
        avoid_zone_ids: Optional[List[str]] = None,
        mode: str = "car"
    ) -> Dict[str, Any]:
        """
        Trouve le chemin optimal avec A*.
        
        Args:
            graph: Graphe routier NetworkX (OSMnx)
            origin: (lat, lng) de départ
            destination: (lat, lng) d'arrivée
            avoid_zone_ids: IDs des zones à éviter
            mode: car, foot, bike
        """
        # Convertir coordonnées en nœuds OSM
        orig_node = self._nearest_node(graph, origin)
        dest_node = self._nearest_node(graph, destination)
        
        # Récupérer zones de danger actives
        danger_zones = await self._fetch_danger_zones(avoid_zone_ids)
        
        # Exécuter A* personnalisé
        path_nodes, metrics = self._astar_with_danger(
            graph, orig_node, dest_node, danger_zones
        )
        
        # Convertir en GeoJSON
        geojson_path = self._nodes_to_geojson(graph, path_nodes)
        
        # Générer alternatives (A* avec poids différents)
        alternatives = await self._generate_alternatives(
            graph, origin, destination, danger_zones
        )
        
        return {
            "id": str(uuid.uuid4()),
            "geojson": geojson_path,
            "distance_km": round(metrics["distance"], 2),
            "time_minutes": self._estimate_time(metrics["distance"], mode),
            "danger_score": round(metrics["danger"], 2),
            "waypoints": self._extract_waypoints(graph, path_nodes),
            "alternatives": alternatives[:2] if alternatives else None
        }
    
    def _astar_with_danger(
        self,
        graph: nx.Graph,
        start: str,
        goal: str,
        danger_zones: List[Dict]
    ) -> Tuple[List[str], Dict[str, float]]:
        """
        Implémentation A* avec prise en compte du danger.
        """
        # Structure: {node: (came_from, g_score)}
        came_from: Dict[str, str] = {}
        g_score: Dict[str, float] = {start: 0}
        f_score: Dict[str, float] = {start: self._heuristic(graph, start, goal)}
        
        open_set: List[PriorityNode] = [PriorityNode(f_score[start], start)]
        closed_set: Set[str] = set()
        
        total_danger = 0.0
        
        while open_set:
            current = heapq.heappop(open_set).node
            
            if current == goal:
                # Reconstruire chemin
                path = self._reconstruct_path(came_from, current)
                return path, {
                    "distance": g_score[goal],
                    "danger": total_danger / len(path) if path else 0
                }
            
            if current in closed_set:
                continue
            closed_set.add(current)
            
            # Explorer voisins
            for neighbor in graph.neighbors(current):
                if neighbor in closed_set:
                    continue
                
                # Calcul poids avec danger
                edge_data = graph.get_edge_data(current, neighbor)
                base_weight = edge_data[0].get('length', 100)  # mètres
                
                # Vérifier si l'arête traverse une zone dangereuse
                edge_coords = self._get_edge_coords(graph, current, neighbor)
                danger_factor = self._calculate_danger(edge_coords, danger_zones)
                
                # Formule: distance × (1 + danger × 10)
                # danger=0.5 (50%) -> poids × 6
                weighted_weight = base_weight * (1 + danger_factor * 10)
                total_danger += danger_factor
                
                tentative_g = g_score[current] + weighted_weight
                
                if neighbor not in g_score or tentative_g < g_score[neighbor]:
                    came_from[neighbor] = current
                    g_score[neighbor] = tentative_g
                    f_score[neighbor] = tentative_g + self._heuristic(graph, neighbor, goal)
                    heapq.heappush(open_set, PriorityNode(f_score[neighbor], neighbor))
        
        raise ValueError("Aucun chemin trouvé")
    
    def _heuristic(self, graph: nx.Graph, node: str, goal: str) -> float:
        """
        Heuristique: distance Haversine (vol d'oiseau).
        Admissible car jamais surestimée.
        """
        node_lat = graph.nodes[node].get('y', 0)
        node_lon = graph.nodes[node].get('x', 0)
        goal_lat = graph.nodes[goal].get('y', 0)
        goal_lon = graph.nodes[goal].get('x', 0)
        
        return self._haversine(node_lat, node_lon, goal_lat, goal_lon)
    
    def _haversine(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Distance Haversine en mètres."""
        from math import radians, cos, sin, asin, sqrt
        
        R = 6371000  # Rayon Terre en mètres
        lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
        
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        return 2 * R * asin(sqrt(a))
    
    def _calculate_danger(
        self, 
        edge_coords: List[Tuple[float, float]], 
        danger_zones: List[Dict]
    ) -> float:
        """
        Calcule le facteur de danger pour une arête (0-1).
        """
        if not danger_zones:
            return 0.0
        
        max_danger = 0.0
        
        for zone in danger_zones:
            # Simplification: zone = cercle (lat, lng, radius_km)
            zone_lat = zone.get('center_lat')
            zone_lng = zone.get('center_lng')
            zone_radius = zone.get('radius_km', 10)
            zone_level = zone.get('danger_level', 0.5)
            
            # Vérifier si l'arête traverse la zone
            for (lat, lng) in edge_coords:
                dist = self._haversine(lat, lng, zone_lat, zone_lng) / 1000  # km
                if dist < zone_radius:
                    # Plus proche du centre = plus dangereux
                    penetration = 1 - (dist / zone_radius)
                    danger = zone_level * penetration
                    max_danger = max(max_danger, danger)
        
        return min(1.0, max_danger)
    
    def _nearest_node(self, graph: nx.Graph, coords: Tuple[float, float]) -> str:
        """Trouve le nœud OSM le plus proche des coordonnées."""
        lat, lng = coords
        min_dist = float('inf')
        nearest = None
        
        for node, data in graph.nodes(data=True):
            if 'y' in data and 'x' in data:
                dist = self._haversine(lat, lng, data['y'], data['x'])
                if dist < min_dist:
                    min_dist = dist
                    nearest = node
        
        return nearest
    
    def _get_edge_coords(self, graph: nx.Graph, n1: str, n2: str) -> List[Tuple[float, float]]:
        """Récupère les coordonnées d'une arête."""
        coords = []
        for node in [n1, n2]:
            data = graph.nodes[node]
            if 'y' in data and 'x' in data:
                coords.append((data['y'], data['x']))
        return coords
    
    def _nodes_to_geojson(self, graph: nx.Graph, nodes: List[str]) -> Dict[str, Any]:
        """Convertit une liste de nœuds en GeoJSON LineString."""
        coordinates = []
        for node in nodes:
            data = graph.nodes[node]
            if 'x' in data and 'y' in data:
                coordinates.append([data['x'], data['y']])  # [lng, lat]
        
        return {
            "type": "LineString",
            "coordinates": coordinates
        }
    
    def _extract_waypoints(self, graph: nx.Graph, nodes: List[str]) -> List[Dict[str, Any]]:
        """Extrait les points de passage importants (intersections, etc.)."""
        waypoints = []
        for i, node in enumerate(nodes):
            if i % 20 == 0:  # Tous les 20 nœuds
                data = graph.nodes[node]
                waypoints.append({
                    "node_id": node,
                    "lat": data.get('y'),
                    "lng": data.get('x'),
                    "index": i
                })
        return waypoints
    
    def _estimate_time(self, distance_km: float, mode: str) -> int:
        """Estime le temps de trajet en minutes."""
        speeds = {
            "car": 40,      # km/h
            "foot": 5,
            "bike": 15
        }
        speed = speeds.get(mode, 40)
        return int((distance_km / speed) * 60)
    
    def _reconstruct_path(self, came_from: Dict[str, str], current: str) -> List[str]:
        """Reconstruit le chemin depuis came_from."""
        path = [current]
        while current in came_from:
            current = came_from[current]
            path.append(current)
        return list(reversed(path))
    
    async def _fetch_danger_zones(self, zone_ids: Optional[List[str]]) -> List[Dict]:
        """Récupère les zones de danger depuis la DB."""
        # Mock pour développement
        # En prod: requête SQL avec PostGIS
        return [
            {
                "id": "zone_1",
                "center_lat": -18.92,
                "center_lng": 47.51,
                "radius_km": 5,
                "danger_level": 0.8
            }
        ]
    
    async def _generate_alternatives(
        self,
        graph: nx.Graph,
        origin: Tuple[float, float],
        destination: Tuple[float, float],
        danger_zones: List[Dict]
    ) -> List[Dict[str, Any]]:
        """Génère des routes alternatives avec pondérations différentes."""
        # Version simplifiée: retourne vide
        return []
