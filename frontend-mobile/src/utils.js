// 🌪️ MITANDRINA - Utilitaires globaux

/**
 * Format une date en français
 */
export const formatDate = (date, options = {}) => {
  const defaultOptions = {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    ...options,
  };

  return new Date(date).toLocaleDateString("fr-FR", defaultOptions);
};

/**
 * Format une distance en km ou m
 */
export const formatDistance = (meters) => {
  if (meters < 1000) {
    return `${Math.round(meters)}m`;
  }
  return `${(meters / 1000).toFixed(1)}km`;
};

/**
 * Valide un email
 */
export const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Valide un mot de passe
 */
export const isValidPassword = (password) => {
  // Au minimum 8 caractères
  return password && password.length >= 8;
};

/**
 * Calcule le pourcentage de capacité occupée
 */
export const getCapacityStatus = (occupancy) => {
  if (occupancy >= 90) return { status: "PLEIN", color: "#dc3545" };
  if (occupancy >= 70) return { status: "PRESQUE PLEIN", color: "#f97316" };
  if (occupancy >= 50)
    return { status: "MOYENNEMENT REMPLI", color: "#f59e0b" };
  return { status: "DISPONIBLE", color: "#22c55e" };
};

/**
 * Classe de risque d'incendie selon l'indice
 */
export const getFireRiskLevel = (riskIndex) => {
  if (riskIndex < 30) return "FAIBLE";
  if (riskIndex < 50) return "MODÉRÉ";
  if (riskIndex < 70) return "ÉLEVÉ";
  if (riskIndex < 90) return "TRÈS ÉLEVÉ";
  return "EXTRÊME";
};

/**
 * Retry avec backoff exponentiel
 */
export const retryWithBackoff = async (fn, maxRetries = 3, delay = 1000) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise((resolve) =>
        setTimeout(resolve, delay * Math.pow(2, i)),
      );
    }
  }
};

/**
 * Debounce une fonction
 */
export const debounce = (fn, delay) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};

/**
 * Throttle une fonction
 */
export const throttle = (fn, delay) => {
  let lastCall = 0;
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= delay) {
      fn(...args);
      lastCall = now;
    }
  };
};