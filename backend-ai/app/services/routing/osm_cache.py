"""Cache pour les graphes routiers OSMnx."""

import pickle
import hashlib
from pathlib import Path
from typing import Optional, Tuple

import networkx as nx
import osmnx as ox

from app.core.config import settings


class OSMCache:
    """
    Cache local pour les graphes routiers OpenStreetMap.
    Évite de retélécharger les mêmes zones.
    """
    
    def __init__(self):
        self.cache_dir = Path(settings.OSM_CACHE_DIR)
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        # Cache en mémoire
        self._memory_cache: dict = {}
    
    def _get_cache_key(self, lat: float, lng: float, radius_km: float) -> str:
        """Génère une clé de cache unique."""
        key_str = f"{lat:.4f}_{lng:.4f}_{radius_km}"
        return hashlib.md5(key_str.encode()).hexdigest()[:16]
    
    def _get_cache_path(self, cache_key: str) -> Path:
        """Chemin du fichier de cache."""
        return self.cache_dir / f"graph_{cache_key}.pkl"
    
    async def get_graph(
        self,
        center_lat: float,
        center_lng: float,
        radius_km: float,
        network_type: str = "drive"
    ) -> nx.Graph:
        """
        Récupère un graphe routier (cache ou téléchargement).
        
        Args:
            center_lat, center_lng: Centre de la zone
            radius_km: Rayon de téléchargement
            network_type: drive, walk, bike, all
        """
        cache_key = self._get_cache_key(center_lat, center_lng, radius_km)
        
        # 1. Vérifier cache mémoire
        if cache_key in self._memory_cache:
            return self._memory_cache[cache_key]
        
        # 2. Vérifier cache disque
        cache_path = self._get_cache_path(cache_key)
        if cache_path.exists():
            try:
                with open(cache_path, 'rb') as f:
                    graph = pickle.load(f)
                self._memory_cache[cache_key] = graph
                return graph
            except Exception:
                pass  # Cache corrompu, retélécharger
        
        # 3. Télécharger depuis OSM
        graph = await self._download_graph(
            center_lat, center_lng, radius_km, network_type
        )
        
        # 4. Sauvegarder en cache
        self._memory_cache[cache_key] = graph
        with open(cache_path, 'wb') as f:
            pickle.dump(graph, f)
        
        return graph
    
    async def _download_graph(
        self,
        center_lat: float,
        center_lng: float,
        radius_km: float,
        network_type: str
    ) -> nx.Graph:
        """Télécharge le graphe depuis OpenStreetMap."""
        # OSMnx utilise l'API Overpass
        # Note: En production, utiliser un cache plus agressif pour respecter les limites
        
        graph = ox.graph_from_point(
            (center_lat, center_lng),
            dist=radius_km * 1000,  # mètres
            network_type=network_type,
            simplify=True,
            retain_all=False
        )
        
        # Ajouter les attributs de vitesse pour estimation temps
        graph = ox.add_edge_speeds(graph)
        graph = ox.add_edge_travel_times(graph)
        
        return graph
    
    def is_cached(self, lat: float, lng: float, radius_km: float) -> bool:
        """Vérifie si une zone est en cache."""
        cache_key = self._get_cache_key(lat, lng, radius_km)
        return (
            cache_key in self._memory_cache or
            self._get_cache_path(cache_key).exists()
        )
    
    def clear_cache(self):
        """Vide le cache disque et mémoire."""
        self._memory_cache.clear()
        for f in self.cache_dir.glob("*.pkl"):
            f.unlink()
    
    def get_cache_stats(self) -> dict:
        """Statistiques du cache."""
        disk_files = list(self.cache_dir.glob("*.pkl"))
        total_size = sum(f.stat().st_size for f in disk_files)
        
        return {
            "memory_entries": len(self._memory_cache),
            "disk_files": len(disk_files),
            "disk_size_mb": round(total_size / (1024 * 1024), 2)
        }
