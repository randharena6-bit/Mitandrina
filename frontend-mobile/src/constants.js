// 🌪️ MITANDRINA - Constantes et utilitaires

export const ALERT_SEVERITY = {
  LOW: "low",
  MEDIUM: "medium",
  HIGH: "high",
  CRITICAL: "critical",
};

export const ALERT_STATUS = {
  ACTIVE: "active",
  ACKNOWLEDGED: "acknowledged",
  RESOLVED: "resolved",
  FALSE_ALARM: "false_alarm",
};

export const SHELTER_AMENITIES = {
  WATER: "water",
  FOOD: "food",
  MEDICAL: "medical",
  PETCARE: "petcare",
  DISABLED_ACCESS: "disabled_access",
};

export const WEATHER_CONDITIONS = {
  CLEAR: "clear",
  CLOUDY: "cloudy",
  RAINY: "rainy",
  WINDY: "windy",
  THUNDERSTORM: "thunderstorm",
};

// API Error handling
export const API_ERROR_MESSAGES = {
  401: "Session expirée. Veuillez vous reconnecter.",
  403: "Accès refusé.",
  404: "Ressource non trouvée.",
  500: "Erreur serveur. Veuillez réessayer.",
  NETWORK: "Erreur de connexion réseau.",
};

// Validation
export const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
export const PASSWORD_MIN_LENGTH = 8;

// Distance constants
export const NEARBY_SHELTER_DISTANCE_KM = 50; // Refuges à proximité
export const ALERT_CRITICAL_DISTANCE_KM = 10; // Alertes critiques à proximité
