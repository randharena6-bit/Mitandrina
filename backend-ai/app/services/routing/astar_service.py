"""
Service de calcul d'itinéraire avec Algorithme A*.
Intègre la pondération par zones de danger.
"""

import uuid
import heapq
from datetime import datetime
from typing import List, Dict, Any, Tuple, Optional, Set
from dataclasses import dataclass, field


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
        graph,
        origin: Tuple[float, float],
        destination: Tuple[float, float],
        avoid_zone_ids: Optional[List[str]] = None,
        mode: str = "car",
        danger_zones: Optional[List[Dict]] = None
    ) -> Dict[str, Any]:
        if graph is None:
            raise ValueError("Graph non disponible")

        import networkx as nx

        orig_node = self._nearest_node(graph, origin)
        dest_node = self._nearest_node(graph, destination)

        if danger_zones is None:
            danger_zones = await self._fetch_danger_zones(avoid_zone_ids)

        path_nodes, metrics = self._astar_with_danger(
            graph, orig_node, dest_node, danger_zones
        )

        geojson_path = self._nodes_to_geojson(graph, path_nodes)

        alternatives = await self._generate_alternatives(
            graph, origin, destination, danger_zones
        )

        return {
            "id": str(uuid.uuid4()),
            "geojson": geojson_path,
            "distance_km": round(metrics["distance"] / 1000, 2),
            "time_minutes": self._estimate_time(metrics["distance"] / 1000, mode),
            "danger_score": round(metrics["danger"] * 100, 2),
            "waypoints": self._extract_waypoints(graph, path_nodes),
            "alternatives": alternatives[:2] if alternatives else None
        }

    def _astar_with_danger(
        self,
        graph,
        start: str,
        goal: str,
        danger_zones: List[Dict]
    ) -> Tuple[List[str], Dict[str, float]]:
        came_from: Dict[str, str] = {}
        g_score: Dict[str, float] = {start: 0}
        f_score: Dict[str, float] = {start: self._heuristic(graph, start, goal)}

        open_set: List[PriorityNode] = [PriorityNode(f_score[start], start)]
        closed_set: Set[str] = set()

        total_danger = 0.0

        while open_set:
            current = heapq.heappop(open_set).node

            if current == goal:
                path = self._reconstruct_path(came_from, current)
                return path, {
                    "distance": g_score[goal],
                    "danger": total_danger / len(path) if path else 0
                }

            if current in closed_set:
                continue
            closed_set.add(current)

            for neighbor in graph.neighbors(current):
                if neighbor in closed_set:
                    continue

                edge_data = graph.get_edge_data(current, neighbor)
                base_weight = edge_data[0].get('length', 100)

                edge_coords = self._get_edge_coords(graph, current, neighbor)
                danger_factor = self._calculate_danger(edge_coords, danger_zones)

                weighted_weight = base_weight * (1 + danger_factor * 10)
                total_danger += danger_factor

                tentative_g = g_score[current] + weighted_weight

                if neighbor not in g_score or tentative_g < g_score[neighbor]:
                    came_from[neighbor] = current
                    g_score[neighbor] = tentative_g
                    f_score[neighbor] = tentative_g + self._heuristic(graph, neighbor, goal)
                    heapq.heappush(open_set, PriorityNode(f_score[neighbor], neighbor))

        raise ValueError("Aucun chemin trouvé")

    def _heuristic(self, graph, node: str, goal: str) -> float:
        node_lat = graph.nodes[node].get('y', 0)
        node_lon = graph.nodes[node].get('x', 0)
        goal_lat = graph.nodes[goal].get('y', 0)
        goal_lon = graph.nodes[goal].get('x', 0)

        return self._haversine(node_lat, node_lon, goal_lat, goal_lon)

    def _haversine(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        from app.services.geo_utils import haversine_m
        return haversine_m(lat1, lon1, lat2, lon2)

    def _calculate_danger(
        self,
        edge_coords: List[Tuple[float, float]],
        danger_zones: List[Dict]
    ) -> float:
        if not danger_zones:
            return 0.0

        max_danger = 0.0

        for zone in danger_zones:
            zone_lat = zone.get('center_lat')
            zone_lng = zone.get('center_lng')
            zone_radius = zone.get('radius_km', 10)
            zone_level = zone.get('danger_level', 0.5)

            for (lat, lng) in edge_coords:
                dist = self._haversine(lat, lng, zone_lat, zone_lng) / 1000
                if dist < zone_radius:
                    penetration = 1 - (dist / zone_radius)
                    danger = zone_level * penetration
                    max_danger = max(max_danger, danger)

        return min(1.0, max_danger)

    def _nearest_node(self, graph, coords: Tuple[float, float]) -> str:
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

    def _get_edge_coords(self, graph, n1: str, n2: str) -> List[Tuple[float, float]]:
        coords = []
        for node in [n1, n2]:
            data = graph.nodes[node]
            if 'y' in data and 'x' in data:
                coords.append((data['y'], data['x']))
        return coords

    def _nodes_to_geojson(self, graph, nodes: List[str]) -> Dict[str, Any]:
        coordinates = []
        for node in nodes:
            data = graph.nodes[node]
            if 'x' in data and 'y' in data:
                coordinates.append([data['x'], data['y']])

        return {
            "type": "LineString",
            "coordinates": coordinates
        }

    def _extract_waypoints(self, graph, nodes: List[str]) -> List[Dict[str, Any]]:
        waypoints = []
        for i, node in enumerate(nodes):
            if i % 20 == 0:
                data = graph.nodes[node]
                waypoints.append({
                    "node_id": node,
                    "lat": data.get('y'),
                    "lng": data.get('x'),
                    "index": i
                })
        return waypoints

    def _estimate_time(self, distance_km: float, mode: str) -> int:
        speeds = {
            "car": 40,
            "foot": 5,
            "bike": 15
        }
        speed = speeds.get(mode, 40)
        return int((distance_km / speed) * 60)

    def _reconstruct_path(self, came_from: Dict[str, str], current: str) -> List[str]:
        path = [current]
        while current in came_from:
            current = came_from[current]
            path.append(current)
        return list(reversed(path))

    async def _fetch_danger_zones(self, zone_ids: Optional[List[str]]) -> List[Dict]:
        return [
            {
                "id": "zone_1",
                "center_lat": -18.92,
                "center_lng": 47.51,
                "radius_km": 5,
                "danger_level": 0.8
            }
        ]

    async def _generate_alternatives(self, graph, origin, destination, danger_zones) -> List[Dict[str, Any]]:
        return []
