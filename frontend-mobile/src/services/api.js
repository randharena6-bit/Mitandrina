// 🌪️ MITANDRINA - Service API
import axios from "axios";
import { Platform } from "react-native";
import Constants from "expo-constants";

// Résolution dynamique de l'IP du serveur pour téléphones physiques & émulateurs
const getApiUrl = () => {
  const envUrl = process.env.REACT_APP_API_URL;
  const hostUri = Constants.expoConfig?.hostUri || Constants.manifest?.debuggerHost;
  const devHost = hostUri ? hostUri.split(":")[0] : "localhost";

  // Si l'URL de l'env est définie, on s'assure d'utiliser l'IP dynamique au lieu de localhost
  if (envUrl) {
    // Si l'env a un port 3000 obsolète ou erroné, on le corrige vers 3001 et le bon chemin /api/v1
    const correctedUrl = envUrl.includes("3000/api") 
      ? envUrl.replace("3000/api", "3001/api/v1") 
      : envUrl;
    return correctedUrl.replace(/localhost|127\.0\.0\.1/, devHost);
  }
  return `http://${devHost}:3001/api/v1`;
};

const API_URL = getApiUrl();

const apiClient = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
    "User-Agent": `Mitandrina-Mobile/${Platform.OS}`,
  },
});

// Interceptor pour ajouter le token
apiClient.interceptors.request.use(
  (config) => {
    const token = global.authToken;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

// Interceptor pour gérer les erreurs
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expiré - déconnecter l'utilisateur
      global.authToken = null;
    }
    return Promise.reject(error);
  },
);

const api = {
  // Auth
  login: (email, password) =>
    apiClient.post("/auth/login", { email, password }),
  register: (userData) => apiClient.post("/auth/register", userData),
  logout: () => Promise.resolve({ data: { success: true } }),

  // Users
  getProfile: () => apiClient.get("/users/me"),
  updateProfile: (userData) => apiClient.put("/users/me", userData),
  getPreferences: () => Promise.resolve({ data: { notifications: true, emailAlerts: true, pushAlerts: true, darkMode: false } }),
  updatePreferences: (preferences) => Promise.resolve({ data: preferences }),

  // Alerts
  getAlerts: (params) => apiClient.get("/alerts", { params }),
  getAlertById: (id) => apiClient.get(`/alerts/${id}`),
  createAlert: (data) => apiClient.post("/alerts", data),
  updateAlert: (id, data) =>
    apiClient.put(`/alerts/${id}`, data),
  acknowledgeAlert: (id) =>
    apiClient.post(`/alerts/${id}/acknowledge`),
  subscribeToAlerts: (filters) =>
    apiClient.post("/alerts/subscribe", filters),

  // Shelters
  getShelters: (params) => apiClient.get("/shelters", { params }),
  getShelterById: (id) => apiClient.get(`/shelters/${id}`),
  reportShelter: (id, data) => apiClient.post(`/shelters/${id}/report`, data),

  // Weather
  getWeather: (lat, lon) => apiClient.get("/ai/weather/current", { params: { lat, lng: lon } }),
  getWeatherForecast: (lat, lon) =>
    apiClient.get("/ai/weather/forecast", { params: { lat, lng: lon } }),

  // Notifications
  getNotifications: (params) => apiClient.get("/notifications", { params }),
  createNotification: (data) => apiClient.post("/notifications", data),
  markNotificationAsRead: (id) => apiClient.put(`/notifications/${id}/read`),
  deleteNotification: (id) => apiClient.delete(`/notifications/${id}`),

  // Incidents
  getIncidents: (params) => apiClient.get("/incidents", { params }),
  getIncidentById: (id) => apiClient.get(`/incidents/${id}`),
  reportIncident: (data) => apiClient.post("/incidents", data),

  // AI / Evacuation
  calculateEvacuationRoute: (data) => apiClient.post("/ai/routing/evacuation", data, { timeout: 60000 }),

  // AI Advisor (Gemini)
  getAIAnalysis: (data) => apiClient.post("/ai/ai-advisor/analyze-cyclones", data, { timeout: 30000 }),
  getAIQuickAdvice: (lat, lng, params) => apiClient.get("/ai/ai-advisor/quick-advice", { params: { lat, lng, ...params }, timeout: 20000 }),

  // Simulations
  getSimulations: (params) => apiClient.get("/admin/simulations", { params, timeout: 15000 }),
  getSimulationById: (id) => apiClient.get(`/admin/simulations/${id}`, { timeout: 15000 }),
  runSimulation: (data) => apiClient.post("/admin/simulations", data, { timeout: 60000 }),
  generateTrajectory: (data) => apiClient.post("/ai/simulations/generate-trajectory", data, { timeout: 30000 }),

  // Chatbot (calls JSP backend directly, not the Node.js gateway)
  sendChatbotMessage: (message) => {
    const hostUri = Constants.expoConfig?.hostUri || Constants.manifest?.debuggerHost;
    const devHost = hostUri ? hostUri.split(":")[0] : "localhost";
    const jspUrl = `http://${devHost}:9090/chatbot`;
    return axios.post(jspUrl, { message }, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': global.authToken ? `Bearer ${global.authToken}` : ''
      },
      timeout: 30000
    });
  },

  // Helper methods
  setAuthToken: (token) => {
    global.authToken = token;
  },
  clearAuthToken: () => {
    global.authToken = null;
  },
};

export default api;
