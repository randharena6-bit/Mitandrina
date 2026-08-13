// 🌪️ MITANDRINA - Hook pour localisation géographique
import { useEffect, useState, useCallback } from "react";

/**
 * Hook pour obtenir la localisation actuelle de l'utilisateur
 * @returns {Object} - { location, loading, error, getCurrentLocation }
 */
export const useLocation = () => {
  const [location, setLocation] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const getCurrentLocation = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Note: Expo Geolocation nécessite expo-location
      // À implémenter avec expo install expo-location
      // Pour maintenant, retourner les coordonnées par défaut (Antananarivo, Madagascar)
      const coords = {
        latitude: -18.8792,
        longitude: 47.5079,
        accuracy: 100,
      };

      setLocation(coords);
      return coords;
    } catch (err) {
      setError("Impossible d'accéder à la localisation");
      console.error("Erreur localisation:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    getCurrentLocation();
  }, [getCurrentLocation]);

  return { location, loading, error, getCurrentLocation };
};

/**
 * Hook pour calculer la distance entre deux points
 */
export const useDistance = (lat1, lon1, lat2, lon2) => {
  const calculateDistance = useCallback(() => {
    const R = 6371; // Rayon terrestre en km
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance en km
  }, [lat1, lon1, lat2, lon2]);

  return calculateDistance();
};

export default useLocation;
