import React, { useState, useEffect, useCallback, useRef } from "react";
import {
  View,
  StyleSheet,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  Animated,
  Vibration,
  Dimensions,
  ScrollView,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { WebView } from "react-native-webview";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import ChatbotModal from "../components/ChatbotModal";

const FILTERS = [
  { id: "all", label: "Tout" },
  { id: "cyclones", label: "Cyclones" },
  { id: "incidents", label: "Incidents" },
  { id: "shelters", label: "Abris" },
];

// Simulation data (same across all maps)
const SIMULATION_ZONES = [
  { id: 's1', type: 'inondation', level: 'alerte', lat: -18.9078, lng: 47.5208, name: 'Inondation - Antananarivo', desc: "Niveau d'eau élevé dans le district. Évacuation des zones basses en cours.", danger_score: 72, confidence: 88, radius: 6000 },
  { id: 's2', type: 'inondation', level: 'urgence', lat: -18.9300, lng: 47.5400, name: 'Crue éclair - Ambohimanambola', desc: 'Crue soudaine après fortes pluies. Évacuation immédiate requise.', danger_score: 88, confidence: 92, radius: 4000 },
  { id: 's3', type: 'incendie', level: 'urgence', lat: -18.1442, lng: 49.3956, name: 'Incendie - Toamasina', desc: 'Feu de forêt détecté près de la ville. Évacuation des quartiers Est en cours.', danger_score: 91, confidence: 95, radius: 3500 },
  { id: 's4', type: 'incendie', level: 'alerte', lat: -17.8500, lng: 49.2000, name: 'Feu de brousse - Fenoarivo', desc: 'Feu de brousse se propageant rapidement. Intervention en cours.', danger_score: 65, confidence: 78, radius: 5000 },
  { id: 's5', type: 'cyclone', level: 'urgence', lat: -15.7167, lng: 46.3167, name: 'Cyclone - Mahajanga', desc: 'Système cyclonique à 200km. Vents à 180km/h. Préparer évacuation zones côtières.', danger_score: 85, confidence: 82, radius: 15000 },
  { id: 's6', type: 'cyclone', level: 'vigilance', lat: -16.0000, lng: 45.5000, name: 'Dépression tropicale - Canal du Mozambique', desc: 'Formation dépressionnaire. Surveillance renforcée.', danger_score: 45, confidence: 65, radius: 20000 },
  { id: 's7', type: 'tsunami', level: 'alerte', lat: -12.2833, lng: 49.2833, name: 'Alerte Tsunami - Antsiranana', desc: 'Activité sismique détectée. Risque de vague submersion côtière.', danger_score: 70, confidence: 72, radius: 8000 },
  { id: 's8', type: 'glissement_terrain', level: 'alerte', lat: -21.4333, lng: 47.0833, name: 'Glissement terrain - Fianarantsoa', desc: 'Terrain instable après fortes pluies. Routes coupées.', danger_score: 68, confidence: 80, radius: 3000 },
  { id: 's9', type: 'incendie', level: 'alerte', lat: -23.3500, lng: 43.6667, name: 'Incendie - Toliara', desc: 'Feu de végétation se propageant. Zones résidentielles menacées.', danger_score: 60, confidence: 75, radius: 4000 },
  { id: 's10', type: 'cyclone', level: 'vigilance', lat: -13.0000, lng: 50.0000, name: 'Tempête tropicale - Océan Indien', desc: 'Tempête se formant au large. Impact potentiel côte Nord-Est.', danger_score: 55, confidence: 60, radius: 12000 },
  { id: 's11', type: 'inondation', level: 'alerte', lat: -19.8667, lng: 47.0333, name: 'Inondation - Antsirabe', desc: 'Montée des eaux dans le bassin versant. Zones agricoles inondées.', danger_score: 58, confidence: 84, radius: 5000 },
];

const SIMULATION_SHELTERS = [
  { id: 'r1', name: "Centre d'urgence Analakely", lat: -18.9100, lng: 47.5250, capacity: 500, occupied: 120, type: 'Centre communautaire', medical: true, food: true, water: true },
  { id: 'r2', name: 'Refuge Toamasina Centre', lat: -18.1500, lng: 49.4000, capacity: 300, occupied: 45, type: 'École', medical: false, food: true, water: true },
  { id: 'r3', name: 'Stade municipal Mahajanga', lat: -15.7180, lng: 46.3220, capacity: 400, occupied: 210, type: 'Stade municipal', medical: true, food: true, water: true },
  { id: 'r4', name: 'Centre de secours Antsiranana', lat: -12.2800, lng: 49.2900, capacity: 250, occupied: 30, type: 'Centre polyvalent', medical: true, food: true, water: false },
  { id: 'r5', name: 'Refuge Fianarantsoa', lat: -21.4300, lng: 47.0800, capacity: 350, occupied: 85, type: 'École primaire', medical: false, food: true, water: true },
  { id: 'r6', name: 'Centre de loisirs Toliara', lat: -23.3550, lng: 43.6850, capacity: 200, occupied: 55, type: 'Centre de loisirs', medical: false, food: true, water: true },
  { id: 'r7', name: 'Gymnase Antananarivo', lat: -18.8900, lng: 47.5100, capacity: 600, occupied: 310, type: 'Gymnase couvert', medical: true, food: true, water: true },
  { id: 'r8', name: 'Refuge Antsirabe', lat: -19.8600, lng: 47.0300, capacity: 280, occupied: 95, type: 'Centre paroissial', medical: false, food: true, water: false },
];

const SIMULATION_INCIDENTS = [
  { id: 'i1', title: 'Route coupée - RN2', status: 'en_cours', lat: -18.3000, lng: 48.7000, description: 'Glissement de terrain bloque la RN2 entre Toamasina et Antananarivo.', severity: 7 },
  { id: 'i2', title: 'Bâtiment endommagé', status: 'critique', lat: -18.1400, lng: 49.3900, description: 'Immeuble résidentiel partiellement effondré suite à l\'incendie.', severity: 9 },
  { id: 'i3', title: 'Panne électrique massive', status: 'signalé', lat: -18.9200, lng: 47.5300, description: 'Transformateur endommagé. 5000 foyers sans électricité.', severity: 5 },
  { id: 'i4', title: 'Refuge saturé - Mahajanga', status: 'critique', lat: -15.7180, lng: 46.3180, description: 'Capacité d\'accueil dépassée. 50 personnes sans abri.', severity: 8 },
  { id: 'i5', title: 'Voie navigable dangereuse', status: 'en_cours', lat: -15.7000, lng: 46.3000, description: 'Rivière Betsiboka en crue. Traversée interdite.', severity: 6 },
  { id: 'i6', title: 'Fuite de gaz signalée', status: 'signalé', lat: -18.9050, lng: 47.5230, description: 'Fuite de gaz sur un réseau principal. Équipe dépêchée.', severity: 4 },
];

const CycloneMapScreen = ({ navigation }) => {
  const [cyclones, setCyclones] = useState([]);
  const [incidents, setIncidents] = useState([]);
  const [shelters, setShelters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeFilter, setActiveFilter] = useState("all");
  const [aiAdvice, setAiAdvice] = useState(null);
  const [simulationMode, setSimulationMode] = useState(false);
  const [simulationScenario, setSimulationScenario] = useState(null);
  const [simulationDataCache, setSimulationDataCache] = useState(null);
  const timerRef = useRef(null);
  const [criticalAlert, setCriticalAlert] = useState(false);
  const [alertMessage, setAlertMessage] = useState("");
  const [alertTitle, setAlertTitle] = useState("");
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const alertTimerRef = useRef(null);

  const userLat = -18.9078;
  const userLng = 47.5208;

  const maxWind = Math.max(0, ...cyclones.map((c) => c.features_input?.wind_speed || 0));
  const windPct = Math.min(100, (maxWind / 220) * 100);
  const windColor = windPct > 70 ? "#dc2626" : windPct > 40 ? "#d97706" : "#059669";

  const runAIAnalysis = useCallback(async (customData) => {
    const data = customData || {};
    const cyclonesData = data.cyclones || cyclones.map((a) => ({
      lat: a.center_lat || a.lat || userLat,
      lng: a.center_lng || a.lng || userLng,
      title: a.zone_name || a.title || "Cyclone",
      level: a.level || "vigilance",
      wind_speed: a.features_input?.wind_speed || null,
      pressure: a.features_input?.pressure || null,
    }));
    const incidentsData = data.incidents || incidents.map((i) => ({
      lat: i.location_lat || i.lat || userLat,
      lng: i.location_lng || i.lng || userLng,
      title: i.title || "Incident",
      status: i.status || "signalé",
    }));
    const sheltersData = data.shelters || shelters.map((s) => ({
      lat: s.location_lat || s.lat || userLat,
      lng: s.location_lng || s.lng || userLng,
      name: s.name || "Abri",
      capacity: s.capacity || 0,
    }));
    try {
      const aiRes = await api.getAIAnalysis({ cyclones: cyclonesData, incidents: incidentsData, shelters: sheltersData });
      const advice = aiRes.data?.data || aiRes.data;
      setAiAdvice(advice);
      checkCriticalAlert(advice);
    } catch (aiErr) {
      console.log("AI non disponible sur la carte:", aiErr.message);
    }
  }, [cyclones, incidents, shelters, checkCriticalAlert]);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [cycloneRes, incidentsRes, sheltersRes] = await Promise.all([
        api.getAlerts({ type: "cyclone", active: true, limit: 50 }),
        api.getIncidents({ type: "cyclone", limit: 50 }),
        api.getShelters({ available: true, limit: 50 }),
      ]);
      const newCyclones = cycloneRes.data?.alerts || [];
      const newIncidents = incidentsRes.data?.incidents || [];
      const newShelters = sheltersRes.data?.shelters || [];
      setCyclones(newCyclones);
      setIncidents(newIncidents);
      setShelters(newShelters);

      if (!simulationMode) {
        const cyclonesData = newCyclones.map((a) => ({
          lat: a.center_lat || a.lat || userLat,
          lng: a.center_lng || a.lng || userLng,
          title: a.zone_name || a.title || "Cyclone",
          level: a.level || "vigilance",
          wind_speed: a.features_input?.wind_speed || null,
          pressure: a.features_input?.pressure || null,
        }));
        const incidentsData = newIncidents.map((i) => ({
          lat: i.location_lat || i.lat || userLat,
          lng: i.location_lng || i.lng || userLng,
          title: i.title || "Incident",
          status: i.status || "signalé",
        }));
        const sheltersData = newShelters.map((s) => ({
          lat: s.location_lat || s.lat || userLat,
          lng: s.location_lng || s.lng || userLng,
          name: s.name || "Abri",
          capacity: s.capacity || 0,
        }));
        try {
          const aiRes = await api.getAIAnalysis({ cyclones: cyclonesData, incidents: incidentsData, shelters: sheltersData });
          const advice = aiRes.data?.data || aiRes.data;
          setAiAdvice(advice);
          checkCriticalAlert(advice);
        } catch (aiErr) {
          console.log("AI non disponible sur la carte:", aiErr.message);
        }
      }
    } catch (err) {
      console.error("Erreur chargement carte cyclone:", err);
    } finally {
      setLoading(false);
    }
  }, [simulationMode, checkCriticalAlert]);

  useEffect(() => {
    loadData();
    timerRef.current = setInterval(loadData, 60000);
    var safety = setTimeout(function() { setLoading(false); }, 20000);
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      clearTimeout(safety);
    };
  }, [loadData]);

  const dismissAlert = useCallback(() => {
    setCriticalAlert(false);
    setAlertMessage("");
    setAlertTitle("");
    Vibration.cancel();
    pulseAnim.setValue(1);
    if (alertTimerRef.current) {
      clearTimeout(alertTimerRef.current);
      alertTimerRef.current = null;
    }
  }, [pulseAnim]);

  const checkCriticalAlert = useCallback((advice) => {
    if (!advice) return;
    const isCritique = advice.risque_global === "critique";
    const hasUrgence = advice.alertes_generees?.some(a => a.niveau === "urgence");
    if (isCritique || hasUrgence) {
      const msg = advice.resume || (hasUrgence ? "Alerte urgence détectée" : "Risque critique détecté");
      setAlertTitle(isCritique ? "🚨 RISQUE CRITIQUE" : "🚨 ALERTE URGENCE");
      setAlertMessage(msg);
      setCriticalAlert(true);
      Vibration.vibrate([500, 300, 500, 300, 500], true);
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, { toValue: 0.6, duration: 600, useNativeDriver: true }),
          Animated.timing(pulseAnim, { toValue: 1, duration: 600, useNativeDriver: true }),
        ])
      ).start();
      if (alertTimerRef.current) clearTimeout(alertTimerRef.current);
      alertTimerRef.current = setTimeout(() => {
        dismissAlert();
      }, 12000);
    } else {
      dismissAlert();
    }
  }, [dismissAlert, pulseAnim]);

  useEffect(() => {
    return () => {
      Vibration.cancel();
      if (alertTimerRef.current) clearTimeout(alertTimerRef.current);
    };
  }, []);

  useEffect(() => {
    if (simulationMode) {
      const cache = {
        cyclones: SIMULATION_ZONES.filter(z => z.type === 'cyclone').map(z => ({
          lat: z.lat, lng: z.lng,
          title: z.name,
          level: z.level,
          wind_speed: z.danger_score * 1.5,
          pressure: 990 - z.danger_score * 0.5,
        })),
        incidents: SIMULATION_INCIDENTS.map(i => ({
          lat: i.lat, lng: i.lng,
          title: i.title,
          status: i.status,
          description: i.description,
        })),
        shelters: SIMULATION_SHELTERS.map(s => ({
          lat: s.lat, lng: s.lng,
          name: s.name,
          capacity: s.capacity,
        })),
      };
      setSimulationDataCache(cache);
      runAIAnalysis(cache);
    } else {
      setSimulationDataCache(null);
      runAIAnalysis();
    }
  }, [simulationMode]);

  const generateMapHtml = () => {
    const showCyclones = activeFilter === "all" || activeFilter === "cyclones";
    const showIncidents = activeFilter === "all" || activeFilter === "incidents";
    const showShelters = activeFilter === "all" || activeFilter === "shelters";

    const cycloneMarkers = cyclones.map((c) => ({
      lat: c.center_lat || c.lat || userLat,
      lng: c.center_lng || c.lng || userLng,
      title: (c.zone_name || c.title || "Système cyclonique").replace(/'/g, "\\'"),
      level: c.level || "vigilance",
      wind: c.features_input?.wind_speed || 0,
      pressure: c.features_input?.pressure || 0,
    }));

    const incidentMarkers = incidents.map((i) => ({
      lat: i.location_lat || i.lat || userLat,
      lng: i.location_lng || i.lng || userLng,
      title: (i.title || "Incident").replace(/'/g, "\\'"),
      status: (i.status || "signalé").replace(/'/g, "\\'"),
    }));

    const shelterMarkers = shelters.map((s) => ({
      lat: s.location_lat || s.lat || userLat,
      lng: s.location_lng || s.lng || userLng,
      name: (s.name || "Abri").replace(/'/g, "\\'"),
      capacity: s.capacity || 0,
      occupancy: s.current_occupancy || 0,
    }));

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <style>
          html, body, #map { height: 100%; margin: 0; padding: 0; background: #0f172a; }
          .marker-pin {
            width: 36px; height: 36px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; border: 2.5px solid white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            transition: transform 0.2s;
          }
          .marker-pin:hover { transform: scale(1.15); }
          .marker-pin.urgence { background: linear-gradient(135deg, #059669, #dc2626); }
          .marker-pin.alerte { background: linear-gradient(135deg, #059669, #f59e0b); }
          .marker-pin.vigilance { background: linear-gradient(135deg, #059669, #3b82f6); }
          .marker-pin.info { background: #10b981; }
          .marker-pin.incident {
            background: linear-gradient(135deg, #f97316, #ea580c);
            font-size: 16px;
          }
          .marker-pin.shelter {
            background: linear-gradient(135deg, #059669, #047857);
            font-size: 16px;
          }
          .marker-pin.user {
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            font-size: 16px;
            width: 32px; height: 32px;
          }
          .leaflet-popup-content-wrapper {
            background: #1e293b !important; color: #e2e8f0 !important;
            border-radius: 10px !important; font-family: sans-serif !important;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4) !important;
          }
          .leaflet-popup-tip { background: #1e293b !important; }
          .leaflet-popup-content { margin: 12px 16px !important; min-width: 180px; }
          .popup-title { font-weight: 700; font-size: 15px; margin-bottom: 6px; color: #f1f5f9; }
          .popup-label { color: #94a3b8; font-size: 11px; }
          .popup-value { color: #e2e8f0; font-size: 13px; font-weight: 600; }
          .popup-row { margin-bottom: 4px; display: flex; justify-content: space-between; }
          .popup-badge {
            display: inline-block; padding: 3px 10px; border-radius: 4px;
            font-size: 10px; font-weight: 700; color: white; text-transform: uppercase;
            letter-spacing: 0.5px;
          }
          .popup-divider { height: 1px; background: #334155; margin: 6px 0; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          var map = L.map('map', { zoomControl: false }).setView([${userLat}, ${userLng}], 6);
          L.control.zoom({ position: 'topright' }).addTo(map);
          var osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19, attribution: '© OpenStreetMap'
          }).addTo(map);

          var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            maxZoom: 19, attribution: '© Esri, Maxar, Earthstar Geographics'
          });

          L.control.layers({ 'Carte': osmLayer, 'Satellite': satelliteLayer }, null, { position: 'topright', collapsed: true }).addTo(map);

          var userMarker = L.marker([${userLat}, ${userLng}], {
            icon: L.divIcon({
              className: 'custom-marker',
              html: '<div class="marker-pin user">👤</div>',
              iconSize: [32, 32], iconAnchor: [16, 30]
            })
          }).addTo(map).bindPopup('<div class="popup-title">📍 Ma position</div><div class="popup-label">Antananarivo, Madagascar</div>');

          ${showCyclones ? `
          var cyclones = ${JSON.stringify(cycloneMarkers)};
          cyclones.forEach(function(c) {
            var level = c.level || 'vigilance';
            var levelColor = {'urgence':'#dc2626','alerte':'#f59e0b','vigilance':'#3b82f6','info':'#10b981'}[level] || '#3b82f6';
            var radius = Math.max(5000, (c.wind || 30) * 1000);
            L.circle([c.lat, c.lng], {
              color: levelColor, fillColor: levelColor, fillOpacity: 0.08,
              weight: 2, radius: radius
            }).addTo(map);
            L.circle([c.lat, c.lng], {
              color: levelColor, fillColor: levelColor, fillOpacity: 0.12,
              weight: 1, dashArray: '6,8', radius: radius * 0.4
            }).addTo(map);
            var dx = (Math.random() - 0.5) * 3;
            var dy = (Math.random() - 0.5) * 2;
            L.polyline([[c.lat, c.lng], [c.lat + dy, c.lng + dx]], {
              color: levelColor, weight: 2, opacity: 0.5, dashArray: '4,6'
            }).addTo(map);
            L.marker([c.lat, c.lng], {
              icon: L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin ' + level + '">🌀</div>',
                iconSize: [36, 36], iconAnchor: [18, 30]
              })
            }).addTo(map).bindPopup(
              '<div class="popup-title">' + c.title + '</div>' +
              '<div class="popup-row"><span class="popup-badge" style="background:' + levelColor + '">' + level.toUpperCase() + '</span></div>' +
              '<div class="popup-divider"></div>' +
              '<div class="popup-row"><span class="popup-label">Vent max</span><span class="popup-value">' + c.wind + ' km/h</span></div>' +
              '<div class="popup-row"><span class="popup-label">Pression</span><span class="popup-value">' + (c.pressure || '--') + ' hPa</span></div>'
            );
          });
          ` : ''}

          ${showIncidents ? `
          var incidents = ${JSON.stringify(incidentMarkers)};
          incidents.forEach(function(i) {
            L.marker([i.lat, i.lng], {
              icon: L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin incident">📍</div>',
                iconSize: [34, 34], iconAnchor: [17, 28]
              })
            }).addTo(map).bindPopup(
              '<div class="popup-title">' + i.title + '</div>' +
              '<div class="popup-divider"></div>' +
              '<div class="popup-row"><span class="popup-label">Statut</span><span class="popup-value">' + i.status + '</span></div>'
            );
          });
          ` : ''}

          ${showShelters ? `
          var shelters = ${JSON.stringify(shelterMarkers)};
          shelters.forEach(function(s) {
            if (!s.lat || !s.lng) return;
            L.marker([s.lat, s.lng], {
              icon: L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin shelter">🏠</div>',
                iconSize: [34, 34], iconAnchor: [17, 28]
              })
            }).addTo(map).bindPopup(
              '<div class="popup-title">' + s.name + '</div>' +
              '<div class="popup-divider"></div>' +
              '<div class="popup-row"><span class="popup-label">Capacité</span><span class="popup-value">' + s.occupancy + ' / ' + s.capacity + '</span></div>' +
              '<div class="popup-row"><span class="popup-label">Disponibles</span><span class="popup-value">' + Math.max(0, s.capacity - s.occupancy) + '</span></div>'
            );
          });
          ` : ''}

          ${simulationMode ? `
          var LAND_CITIES = [
            { name:'Antananarivo',lat:-18.9078,lng:47.5208 },
            { name:'Toamasina',lat:-18.1442,lng:49.3956 },
            { name:'Mahajanga',lat:-15.7180,lng:46.3220 },
            { name:'Fianarantsoa',lat:-21.4333,lng:47.0833 },
            { name:'Antsiranana',lat:-12.2833,lng:49.2833 },
            { name:'Toliara',lat:-23.3550,lng:43.6850 },
            { name:'Antsirabe',lat:-19.8667,lng:47.0333 },
            { name:'Morondava',lat:-20.2833,lng:44.2833 },
          ];
          function haversineKm(lat1,lng1,lat2,lng2) {
            var R=6371;var dLat=(lat2-lat1)*Math.PI/180;var dLng=(lng2-lng1)*Math.PI/180;
            var a=Math.sin(dLat/2)*Math.sin(dLat/2)+Math.cos(lat1*Math.PI/180)*Math.cos(lat2*Math.PI/180)*Math.sin(dLng/2)*Math.sin(dLng/2);
            return R*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
          }
          function clampToLand(lat,lng) {
            var best=null;var bestDist=Infinity;
            LAND_CITIES.forEach(function(c){var d=haversineKm(lat,lng,c.lat,c.lng);if(d<bestDist){bestDist=d;best=c;}});
            if(best&&bestDist>80)return{lat:best.lat,lng:best.lng};
            return{lat:lat,lng:lng};
          }
          var simZones = ${JSON.stringify(SIMULATION_ZONES)};
          var simShelters = ${JSON.stringify(SIMULATION_SHELTERS)};
          var simIncidents = ${JSON.stringify(SIMULATION_INCIDENTS)};

          ${simulationScenario === 'cyclones' || !simulationScenario ? `
          simZones.forEach(function(z) {
            var zoneColor = z.level === 'urgence' ? '#dc2626' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6';
            L.circle([z.lat, z.lng], {
              color: zoneColor, fillColor: zoneColor, fillOpacity: 0.12,
              weight: 2, radius: z.radius
            }).addTo(map).bindPopup(
              '<div class="popup-title">' + z.name + '</div>' +
              '<div class="popup-row"><span class="popup-badge" style="background:' + zoneColor + '">' + z.level.toUpperCase() + '</span></div>' +
              '<div class="popup-divider"></div>' +
              '<div class="popup-row"><span class="popup-label">Danger</span><span class="popup-value">' + z.danger_score + '/100</span></div>' +
              '<div class="popup-row"><span class="popup-label">Confiance</span><span class="popup-value">' + z.confidence + '%</span></div>' +
              '<div class="popup-divider"></div>' +
              '<div class="popup-label">' + z.desc.replace(/'/g, "\\'") + '</div>'
            );
            L.marker([z.lat, z.lng], {
              icon: L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin ' + z.level + '">⚠️</div>',
                iconSize: [36, 36], iconAnchor: [18, 30]
              })
            }).addTo(map);
          });
          ` : ''}

          ${simulationScenario === 'incidents' || !simulationScenario ? `
          simIncidents.forEach(function(i) {
            var sevColor = i.severity >= 8 ? '#dc2626' : i.severity >= 5 ? '#f59e0b' : '#3b82f6';
            L.marker([i.lat, i.lng], {
              icon: L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin incident">📍</div>',
                iconSize: [34, 34], iconAnchor: [17, 28]
              })
            }).addTo(map).bindPopup(
              '<div class="popup-title">' + i.title + '</div>' +
              '<div class="popup-row"><span class="popup-badge" style="background:' + sevColor + '">Sévérité ' + i.severity + '/10</span></div>' +
              '<div class="popup-divider"></div>' +
              '<div class="popup-label">' + i.description.replace(/'/g, "\\'") + '</div>'
            );
          });
          ` : ''}

           ${simulationScenario === 'shelters' || !simulationScenario ? `
           simShelters.forEach(function(s) {
             var clamped = clampToLand(s.lat,s.lng);
             L.circle([clamped.lat, clamped.lng], {
               color: '#059669', fillColor: '#059669', fillOpacity: 0.1, weight: 2, radius: 2500
             }).addTo(map);
             L.marker([clamped.lat, clamped.lng], {
               icon: L.divIcon({
                 className: 'custom-marker',
                 html: '<div class="marker-pin shelter">🏠</div>',
                 iconSize: [34, 34], iconAnchor: [17, 28]
               })
             }).addTo(map).bindPopup(
               '<div class="popup-title">' + s.name + '</div>' +
               '<div class="popup-divider"></div>' +
               '<div class="popup-row"><span class="popup-label">Capacité</span><span class="popup-value">' + s.occupied + ' / ' + s.capacity + '</span></div>' +
               '<div class="popup-row"><span class="popup-label">Médical</span><span class="popup-value">' + (s.medical ? '✓' : '✗') + '</span></div>' +
               '<div class="popup-row"><span class="popup-label">Type</span><span class="popup-value">' + s.type + '</span></div>'
             );
           });
           ` : ''}
          ` : ''}

          var allPoints = [[${userLat}, ${userLng}]];
          ${showCyclones ? 'cyclones.forEach(function(c) { allPoints.push([c.lat, c.lng]); });' : ''}
          ${showIncidents ? 'incidents.forEach(function(i) { allPoints.push([i.lat, i.lng]); });' : ''}
          ${showShelters ? 'shelters.forEach(function(s) { if (s.lat && s.lng) allPoints.push([s.lat, s.lng]); });' : ''}

          ${simulationMode ? `
          simZones.forEach(function(z) { allPoints.push([z.lat, z.lng]); });
          simShelters.forEach(function(s) { allPoints.push([s.lat, s.lng]); });
          simIncidents.forEach(function(i) { allPoints.push([i.lat, i.lng]); });
          ` : ''}

          if (allPoints.length > 1) {
            map.fitBounds(allPoints, { padding: [50, 50], maxZoom: 8 });
          }
        </script>
      </body>
      </html>
    `;
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.container} edges={["top"]}>
        <View style={styles.loadingContainer}>
          <View style={styles.loadingIcon}>
            <Ionicons name="map-outline" size={40} color={theme.colors.primary} />
          </View>
          <ActivityIndicator size="large" color={theme.colors.primary} style={{ marginTop: 16 }} />
          <Text style={styles.loadingText}>Carte cyclonique</Text>
          <Text style={styles.loadingSubtext}>Chargement des données en temps réel...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container} edges={["top"]}>
      {criticalAlert && (
        <Animated.View style={[styles.alertBanner, { opacity: pulseAnim }]}>
          <View style={styles.alertContent}>
            <Text style={styles.alertTitle}>{alertTitle}</Text>
            <Text style={styles.alertMessage}>{alertMessage}</Text>
          </View>
          <TouchableOpacity style={styles.alertDismiss} onPress={dismissAlert}>
            <Text style={styles.alertDismissText}>OK</Text>
          </TouchableOpacity>
        </Animated.View>
      )}
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <View style={styles.headerIcon}>
            <Ionicons name="map-outline" size={22} color={theme.colors.primary} />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.title}>Carte cyclonique</Text>
            <Text style={styles.subtitle}>Madagascar • {cyclones.length} système(s) actif(s)</Text>
          </View>
          <TouchableOpacity onPress={onRefresh} style={styles.refreshBtn}>
            <Ionicons name="refresh-outline" size={20} color={theme.colors.primary} />
          </TouchableOpacity>
        </View>

        <View style={styles.statsRow}>
          <View style={styles.statCard}>
            <Ionicons name="warning-outline" size={16} color="#3b82f6" />
            <Text style={styles.statNumber}>{cyclones.length}</Text>
            <Text style={styles.statLabel}>Cyclones</Text>
          </View>
          <View style={styles.statCard}>
            <Ionicons name="alert-circle-outline" size={16} color="#f97316" />
            <Text style={styles.statNumber}>{incidents.length}</Text>
            <Text style={styles.statLabel}>Incidents</Text>
          </View>
          <View style={styles.statCard}>
            <Ionicons name="home-outline" size={16} color="#059669" />
            <Text style={styles.statNumber}>{shelters.length}</Text>
            <Text style={styles.statLabel}>Abris</Text>
          </View>
        </View>

        {cyclones.length > 0 && (
          <View style={styles.windBar}>
            <View style={styles.windHeader}>
              <Text style={styles.windLabel}>Vent max</Text>
              <Text style={[styles.windValue, { color: windColor }]}>{maxWind.toFixed(0)} km/h</Text>
            </View>
            <View style={styles.windTrack}>
              <View style={[styles.windFill, { width: windPct + "%", backgroundColor: windColor }]} />
            </View>
          </View>
        )}

        <View style={styles.mapContainer}>
          <WebView
            originWhitelist={["*"]}
            source={{ html: generateMapHtml() }}
            style={styles.map}
            javaScriptEnabled={true}
            domStorageEnabled={true}
            scrollEnabled={false}
          />
        </View>

        <View style={styles.filterRow}>
          {FILTERS.map((f) => (
            <TouchableOpacity
              key={f.id}
              style={[styles.filterBtn, activeFilter === f.id && styles.filterBtnActive]}
              onPress={() => setActiveFilter(f.id)}
            >
              <Text style={[styles.filterText, activeFilter === f.id && styles.filterTextActive]}>
                {f.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        <View style={styles.simToggleRow}>
          <TouchableOpacity
            style={[styles.simToggleBtn, simulationMode && styles.simToggleBtnActive]}
            onPress={() => { setSimulationMode(!simulationMode); setSimulationScenario(null); }}
          >
            <Ionicons
              name={simulationMode ? "flash" : "flash-outline"}
              size={16}
              color={simulationMode ? "#fbbf24" : theme.colors.textGray}
            />
            <Text style={[styles.simToggleText, simulationMode && styles.simToggleTextActive]}>
              {simulationMode ? "Simulation ON" : "Simulation"}
            </Text>
          </TouchableOpacity>
          {simulationMode && (
            <View style={styles.simScenarios}>
              <TouchableOpacity
                style={[styles.simScenarioBtn, !simulationScenario && styles.simScenarioBtnActive]}
                onPress={() => setSimulationScenario(null)}
              >
                <Text style={[styles.simScenarioText, !simulationScenario && styles.simScenarioTextActive]}>Tout</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.simScenarioBtn, simulationScenario === 'cyclones' && styles.simScenarioBtnActive]}
                onPress={() => setSimulationScenario('cyclones')}
              >
                <Text style={[styles.simScenarioText, simulationScenario === 'cyclones' && styles.simScenarioTextActive]}>Cyclones</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.simScenarioBtn, simulationScenario === 'incidents' && styles.simScenarioBtnActive]}
                onPress={() => setSimulationScenario('incidents')}
              >
                <Text style={[styles.simScenarioText, simulationScenario === 'incidents' && styles.simScenarioTextActive]}>Incidents</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.simScenarioBtn, simulationScenario === 'shelters' && styles.simScenarioBtnActive]}
                onPress={() => setSimulationScenario('shelters')}
              >
                <Text style={[styles.simScenarioText, simulationScenario === 'shelters' && styles.simScenarioTextActive]}>Abris</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>

        <View style={styles.legend}>
          <View style={styles.legendItem}>
            <View style={[styles.legendDot, { backgroundColor: "#dc2626" }]} />
            <Text style={styles.legendText}>Urgence</Text>
          </View>
          <View style={styles.legendItem}>
            <View style={[styles.legendDot, { backgroundColor: "#f59e0b" }]} />
            <Text style={styles.legendText}>Alerte</Text>
          </View>
          <View style={styles.legendItem}>
            <View style={[styles.legendDot, { backgroundColor: "#3b82f6" }]} />
            <Text style={styles.legendText}>Vigilance</Text>
          </View>
          <View style={styles.legendItem}>
            <View style={[styles.legendDot, { backgroundColor: "#f97316" }]} />
            <Text style={styles.legendText}>Incident</Text>
          </View>
          <View style={styles.legendItem}>
            <View style={[styles.legendDot, { backgroundColor: "#059669" }]} />
            <Text style={styles.legendText}>Abri</Text>
          </View>
        </View>

        {aiAdvice && (
          <TouchableOpacity
            style={styles.aiCard}
            onPress={() => navigation.navigate("MainTabs", { screen: "AITab" })}
            activeOpacity={0.7}
          >
            <View style={styles.aiCardHeader}>
              <View style={styles.aiIconSmall}>
                <Ionicons name="hardware-chip-outline" size={16} color={theme.colors.primary} />
              </View>
              <View style={styles.aiCardInfo}>
                <Text style={styles.aiRiskText}>
                  Risque {aiAdvice.risque_global?.toUpperCase() || "N/A"}
                </Text>
                <Text style={styles.aiResume} numberOfLines={2}>{aiAdvice.resume || ""}</Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color={theme.colors.textMuted} />
            </View>
            {aiAdvice.recommandations_public?.length > 0 && (
              <View style={styles.aiRecPreview}>
                <Text style={styles.aiRecIcon}>💡</Text>
                <Text style={styles.aiRecText} numberOfLines={1}>{aiAdvice.recommandations_public[0]}</Text>
              </View>
            )}
          </TouchableOpacity>
        )}
      </ScrollView>
      <ChatbotModal />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgWhite,
  },
  scrollContent: {
    paddingBottom: theme.spacing.xl * 2,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  headerIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
  },
  title: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  subtitle: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    marginTop: 1,
  },
  refreshBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: theme.colors.bgGray,
    justifyContent: "center",
    alignItems: "center",
  },
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: theme.spacing.xl,
  },
  loadingIcon: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
  },
  loadingText: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginTop: theme.spacing.md,
  },
  loadingSubtext: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: theme.spacing.xs,
  },
  statsRow: {
    flexDirection: "row",
    gap: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.sm,
    backgroundColor: theme.colors.bgGray,
  },
  statCard: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    backgroundColor: theme.colors.bgWhite,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.sm,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
  },
  statNumber: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  statLabel: {
    fontSize: 10,
    color: theme.colors.textGray,
    fontWeight: "600",
  },
  windBar: {
    marginHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.sm,
    marginBottom: 0,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.sm,
  },
  windHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 6,
  },
  windLabel: {
    fontSize: 10,
    fontWeight: "700",
    color: theme.colors.textGray,
    textTransform: "uppercase",
  },
  windValue: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "800",
  },
  windTrack: {
    height: 6,
    backgroundColor: "#e2e8f0",
    borderRadius: 3,
    overflow: "hidden",
  },
  windFill: {
    height: "100%",
    borderRadius: 3,
  },
  mapContainer: {
    height: Dimensions.get("window").height * 0.42,
    marginHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.sm,
    borderRadius: theme.borderRadius.lg,
    overflow: "hidden",
  },
  map: {
    flex: 1,
  },
  filterRow: {
    flexDirection: "row",
    gap: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  filterBtn: {
    flex: 1,
    paddingVertical: theme.spacing.sm,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.bgGray,
    alignItems: "center",
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
  },
  filterBtnActive: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  filterText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textGray,
  },
  filterTextActive: {
    color: "white",
  },
  legend: {
    flexDirection: "row",
    justifyContent: "center",
    gap: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.lg,
    backgroundColor: theme.colors.bgGray,
    flexWrap: "wrap",
  },
  legendItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  legendDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  legendText: {
    fontSize: 11,
    color: theme.colors.textGray,
    fontWeight: "500",
  },
  aiCard: {
    marginHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
    padding: theme.spacing.md,
  },
  aiCardHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
  },
  aiIconSmall: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
  },
  aiCardInfo: {
    flex: 1,
  },
  aiRiskText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  aiResume: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    marginTop: 1,
  },
  aiRecPreview: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginTop: theme.spacing.sm,
    backgroundColor: theme.colors.primaryLight,
    borderRadius: theme.borderRadius.sm,
    padding: theme.spacing.sm,
  },
  aiRecIcon: {
    fontSize: 14,
  },
  aiRecText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.primaryDark,
    flex: 1,
  },
  simToggleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.sm,
    backgroundColor: theme.colors.bgGray,
    flexWrap: 'wrap',
  },
  simToggleBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.bgWhite,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
  },
  simToggleBtnActive: {
    backgroundColor: '#1e293b',
    borderColor: '#fbbf24',
  },
  simToggleText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: '600',
    color: theme.colors.textGray,
  },
  simToggleTextActive: {
    color: '#fbbf24',
  },
  simScenarios: {
    flexDirection: 'row',
    gap: theme.spacing.xs,
    flexWrap: 'wrap',
  },
  simScenarioBtn: {
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: theme.borderRadius.sm,
    backgroundColor: theme.colors.bgWhite,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
  },
  simScenarioBtnActive: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  simScenarioText: {
    fontSize: 11,
    fontWeight: '600',
    color: theme.colors.textGray,
  },
  simScenarioTextActive: {
    color: 'white',
  },
  alertBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#dc2626',
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.md,
    marginHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.sm,
    borderRadius: theme.borderRadius.md,
    shadowColor: '#dc2626',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 8,
    elevation: 6,
  },
  alertContent: {
    flex: 1,
  },
  alertTitle: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: '800',
    color: '#fff',
  },
  alertMessage: {
    fontSize: theme.typography.sizes.xs,
    color: '#fecaca',
    marginTop: 2,
  },
  alertDismiss: {
    backgroundColor: '#ffffff30',
    borderRadius: theme.borderRadius.sm,
    paddingHorizontal: 14,
    paddingVertical: 6,
    marginLeft: theme.spacing.sm,
  },
  alertDismissText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: '700',
    color: '#fff',
  },
});

export default CycloneMapScreen;
