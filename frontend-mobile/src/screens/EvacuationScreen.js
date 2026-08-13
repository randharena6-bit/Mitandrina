import React, { useState, useEffect } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  Dimensions,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { WebView } from "react-native-webview";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";
import Button from "../components/Button";

const TRANSPORT_MODES = [
  { id: "car", label: "Voiture", icon: "car" },
  { id: "walk", label: "À pied", icon: "walk" },
  { id: "bike", label: "Vélo", icon: "bicycle" },
];

const SIMULATION_ZONES = [
  { id: 's1', type: 'inondation', level: 'alerte', lat: -18.9078, lng: 47.5208, name: 'Inondation - Antananarivo', desc: "Niveau d'eau élevé dans le district. Évacuation des zones basses en cours.", danger_score: 72, confidence: 88, radius: 6000 },
  { id: 's2', type: 'inondation', level: 'urgence', lat: -18.9300, lng: 47.5400, name: 'Crue éclair - Ambohimanambola', desc: 'Crue soudaine après fortes pluies. Évacuation immédiate requise.', danger_score: 88, confidence: 92, radius: 4000 },
  { id: 's3', type: 'incendie', level: 'urgence', lat: -18.1442, lng: 49.3956, name: 'Incendie - Toamasina', desc: 'Feu de forêt détecté près de la ville. Évacuation des quartiers Est en cours.', danger_score: 91, confidence: 95, radius: 3500 },
  { id: 's4', type: 'incendie', level: 'alerte', lat: -17.8500, lng: 49.2000, name: 'Feu de brousse - Fenoarivo', desc: 'Feu de brousse se propageant rapidement. Intervention en cours.', danger_score: 65, confidence: 78, radius: 5000 },
  { id: 's5', type: 'cyclone', level: 'urgence', lat: -15.7167, lng: 46.3167, name: 'Cyclone - Mahajanga', desc: 'Système cyclonique à 200km. Vents à 180km/h. Préparer évacuation zones côtières.', danger_score: 85, confidence: 82, radius: 15000 },
  { id: 's7', type: 'tsunami', level: 'alerte', lat: -12.2833, lng: 49.2833, name: 'Alerte Tsunami - Antsiranana', desc: 'Activité sismique détectée. Risque de vague submersion côtière.', danger_score: 70, confidence: 72, radius: 8000 },
  { id: 's8', type: 'glissement_terrain', level: 'alerte', lat: -21.4333, lng: 47.0833, name: 'Glissement terrain - Fianarantsoa', desc: 'Terrain instable après fortes pluies. Routes coupées.', danger_score: 68, confidence: 80, radius: 3000 },
  { id: 's9', type: 'incendie', level: 'alerte', lat: -23.3500, lng: 43.6667, name: 'Incendie - Toliara', desc: 'Feu de végétation se propageant. Zones résidentielles menacées.', danger_score: 60, confidence: 75, radius: 4000 },
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

const haversineKm = (lat1, lng1, lat2, lng2) => {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng/2) * Math.sin(dLng/2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
};

const EvacuationScreen = () => {
  const [shelters, setShelters] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [selectedShelter, setSelectedShelter] = useState(null);
  const [routingMode, setRoutingMode] = useState("car");
  const [loading, setLoading] = useState(false);
  const [loadingShelters, setLoadingShelters] = useState(true);
  const [routeResult, setRouteResult] = useState(null);
  const [shelterInDanger, setShelterInDanger] = useState(null);
  const [safeAlternatives, setSafeAlternatives] = useState([]);
  const [showShelterList, setShowShelterList] = useState(false);
  const [simulationMode, setSimulationMode] = useState(false);
  const [incidents, setIncidents] = useState([]);

  const userLat = -18.9078;
  const userLng = 47.5208;

  useEffect(() => {
    fetchInitialData();
  }, []);

  const fetchInitialData = async () => {
    try {
      setLoadingShelters(true);
      const [sheltersRes, alertsRes, incidentsRes] = await Promise.all([
        api.getShelters(),
        api.getAlerts({ active: "true" }),
        api.getIncidents({ limit: 100 }),
      ]);
      let fetchedShelters = sheltersRes.data?.shelters || [];
      fetchedShelters.forEach(s => {
        const slat = s.lat || s.location_lat || s.locationLat;
        const slng = s.lng || s.location_lng || s.locationLng;
        s.distance_km = haversineKm(userLat, userLng, slat, slng);
      });
      fetchedShelters.sort((a, b) => a.distance_km - b.distance_km);
      setShelters(fetchedShelters);
      setAlerts(alertsRes.data?.alerts || []);
      setIncidents(incidentsRes.data?.incidents || []);
    } catch (err) {
      console.error("Erreur récupération données:", err);
    } finally {
      setLoadingShelters(false);
    }
  };

  const handleCalculateRoute = async () => {
    if (!selectedShelter) {
      Alert.alert("Sélection requise", "Veuillez choisir un refuge de destination.");
      return;
    }

    try {
      setLoading(true);
      setRouteResult(null);
      setShelterInDanger(null);
      setSafeAlternatives([]);

      const destinationLat = selectedShelter.lat || selectedShelter.locationLat;
      const destinationLng = selectedShelter.lng || selectedShelter.locationLng;

      if (!destinationLat || !destinationLng) {
        Alert.alert("Coordonnées invalides", "Le refuge sélectionné n'a pas de coordonnées valides.");
        return;
      }

      const inlineZones = [];

      // Zones de danger issues des alertes actives
      (alerts || []).forEach(a => {
        if (a.center_lat && a.center_lng) {
          inlineZones.push({
            id: String(a.id),
            center_lat: a.center_lat,
            center_lng: a.center_lng,
            radius: 5000,
            danger_level: a.level === 'urgence' ? 80 : a.level === 'alerte' ? 60 : 40,
            type: a.type,
            name: a.title || 'Alerte ' + a.type,
            level: a.level,
          });
        }
      });

      // Incidents réels non résolus
      (incidents || []).forEach(inc => {
        if (inc.status === 'resolu') return;
        const radiusMap = { incendie: 2000, inondation: 3000, cyclone: 5000, seisme: 2000, glissement_terrain: 1500 };
        const incLat = parseFloat(inc.location_lat);
        const incLng = parseFloat(inc.location_lng);
        if (!incLat || !incLng) return;
        inlineZones.push({
          id: 'incident-' + inc.id,
          center_lat: incLat,
          center_lng: incLng,
          radius: radiusMap[inc.type] || 2000,
          danger_level: inc.status === 'en_cours' ? 80 : inc.status === 'verifie' ? 60 : 40,
          type: inc.type,
          name: inc.title || 'Incident ' + inc.type,
          level: inc.status === 'en_cours' ? 'urgence' : inc.status === 'verifie' ? 'alerte' : 'vigilance',
        });
      });

      // Zones de simulation (optionnel)
      if (simulationMode) {
        SIMULATION_ZONES.forEach(z => {
          inlineZones.push({
            id: z.id,
            center_lat: z.lat,
            center_lng: z.lng,
            radius: z.radius,
            danger_level: z.danger_score || 50,
            type: z.type,
            name: z.name,
            level: z.level,
          });
        });
      }

      const payload = {
        origin_lat: userLat,
        origin_lng: userLng,
        destination_lat: parseFloat(destinationLat),
        destination_lng: parseFloat(destinationLng),
        max_distance_km: 30.0,
        mode: routingMode,
        avoid_zones: [],
        shelter_id: selectedShelter.id,
        inline_zones: inlineZones,
      };

      const res = await api.calculateEvacuationRoute(payload);
      if (res.data?.error || res.data?.detail) {
        Alert.alert("Erreur de calcul", res.data.error || res.data.detail);
      } else {
        setRouteResult(res.data);
        setShelterInDanger(res.data.shelter_in_danger || null);
        setSafeAlternatives(res.data.safe_alternatives || []);
      }
    } catch (err) {
      Alert.alert("Erreur", "Impossible de communiquer avec le service d'itinéraire.");
    } finally {
      setLoading(false);
    }
  };

  const handleSelectAlternative = (shelter) => {
    setSelectedShelter(shelter);
    setSafeAlternatives([]);
    setShelterInDanger(null);
    handleCalculateRoute();
  };

  const getDangerLabel = (score, isInDanger) => {
    if (isInDanger) return "CRITIQUE";
    if (score > 30) return "Critique";
    if (score > 5) return "Modéré";
    return "Sécurisé";
  };

  const getDangerColor = (score, isInDanger) => {
    if (isInDanger) return theme.colors.danger;
    if (score > 30) return theme.colors.danger;
    if (score > 5) return theme.colors.warning;
    return theme.colors.primary;
  };

  const generateMapHtml = () => {
    const hazardPoints = alerts.map((a) => ({
      lat: a.center_lat || -18.905,
      lng: a.center_lng || 47.525,
      level: a.level,
      type: a.type,
    }));

    const shelterPoints = shelters.map((s) => ({
      name: s.name,
      lat: s.lat || s.locationLat,
      lng: s.lng || s.locationLng,
      isSelected: selectedShelter?.id === s.id,
    }));

    const incidentPoints = (incidents || [])
      .filter(inc => inc.status !== 'resolu')
      .map(inc => ({
        lat: parseFloat(inc.location_lat),
        lng: parseFloat(inc.location_lng),
        type: inc.type,
        title: inc.title || 'Incident',
        status: inc.status,
        desc: inc.description,
      }))
      .filter(inc => inc.lat && inc.lng);

    let routeCoords = [];
    if (routeResult && routeResult.path && routeResult.path.coordinates) {
      routeCoords = routeResult.path.coordinates.map((c) => [c[1], c[0]]);
    }

    const dangerScore = routeResult?.danger_score || 0;
    const routeColor = shelterInDanger ? "#dc2626" : dangerScore > 30 ? "#f97316" : dangerScore > 5 ? "#f59e0b" : "#22c55e";
    const routeColorDark = shelterInDanger ? "#b91c1c" : dangerScore > 30 ? "#ea580c" : dangerScore > 5 ? "#d97706" : "#16a34a";

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <style>
          html, body, #map { height: 100%; margin: 0; padding: 0; background-color: #f3f4f6; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          const map = L.map('map', { zoomControl: false }).setView([${userLat}, ${userLng}], 13);
          var osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '© OpenStreetMap' }).addTo(map);
          var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', { maxZoom: 19, attribution: '© Esri, Maxar, Earthstar Geographics' });
          L.control.layers({ 'Carte': osmLayer, 'Satellite': satelliteLayer }, null, { position: 'topright', collapsed: true }).addTo(map);
          L.circleMarker([${userLat}, ${userLng}], { radius: 8, color: '#ffffff', weight: 2, fillColor: '#059669', fillOpacity: 1 }).addTo(map).bindPopup("<b>Position</b>").openPopup();
          const hazards = ${JSON.stringify(hazardPoints)};
          hazards.forEach(h => { L.circle([h.lat, h.lng], { color: '#dc2626', fillColor: '#dc2626', fillOpacity: 0.3, radius: 800 }).addTo(map).bindPopup("<b>Danger: " + h.type + "</b>"); });
          const abris = ${JSON.stringify(shelterPoints)};
          abris.forEach(s => { if (s.lat && s.lng) { L.circleMarker([s.lat, s.lng], { radius: s.isSelected ? 10 : 7, color: '#ffffff', weight: 1.5, fillColor: s.isSelected ? '#2563eb' : '#4b5563', fillOpacity: 1 }).addTo(map).bindPopup("<b>Refuge: " + s.name + "</b>"); } });

          var incidents = ${JSON.stringify(incidentPoints)};
          incidents.forEach(function(inc) {
            if (!inc.lat || !inc.lng) return;
            var iconMap = { incendie: '🔥', inondation: '💧', cyclone: '🌀', seisme: '🏚️', glissement_terrain: '⛰️' };
            var emoji = iconMap[inc.type] || '⚠️';
            var incColor = inc.status === 'en_cours' ? '#dc2626' : inc.status === 'verifie' ? '#f59e0b' : '#3b82f6';
            L.circleMarker([inc.lat, inc.lng], {
              radius: 7, color: incColor, weight: 2, fillColor: incColor, fillOpacity: 0.7
            }).addTo(map).bindPopup('<div style="min-width:180px;"><b>' + emoji + ' ' + inc.title + '</b><br><span style="background:' + incColor + ';color:white;padding:1px 6px;border-radius:3px;font-size:10px;">' + (inc.status || 'Signalé') + '</span><br><small>' + (inc.desc || '') + '</small></div>');
          });

          ${simulationMode ? `
          var simZones = ${JSON.stringify(SIMULATION_ZONES)};
          var simShelters = ${JSON.stringify(SIMULATION_SHELTERS)};
          var simIncidents = ${JSON.stringify(SIMULATION_INCIDENTS)};

          simZones.forEach(function(z) {
            var zoneColor = z.level === 'urgence' ? '#dc2626' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6';
            L.circle([z.lat, z.lng], {
              color: zoneColor, fillColor: zoneColor, fillOpacity: 0.15,
              weight: 2.5, radius: z.radius
            }).addTo(map).bindPopup(
              '<b>' + z.name + '</b><br>' +
              '<span style=\"background:' + zoneColor + ';color:white;padding:2px 6px;border-radius:3px;font-size:11px\">' + z.level.toUpperCase() + '</span>' +
              '<hr style=\"border-color:#555;margin:4px 0\">' +
              '<span>Danger: ' + z.danger_score + '/100 &bull; Confiance: ' + z.confidence + '%</span>' +
              '<br><small>' + z.desc.replace(/'/g, "\\'") + '</small>'
            );
            L.circleMarker([z.lat, z.lng], {
              radius: 6, color: zoneColor, weight: 2, fillColor: zoneColor, fillOpacity: 0.8
            }).addTo(map);
          });

          simShelters.forEach(function(s) {
            L.circleMarker([s.lat, s.lng], {
              radius: 8, color: '#ffffff', weight: 2, fillColor: '#059669', fillOpacity: 1
            }).addTo(map).bindPopup('<b>' + s.name + '</b><br>Capacité: ' + s.occupied + '/' + s.capacity + '<br>Médical: ' + (s.medical ? '✓' : '✗'));
          });

          simIncidents.forEach(function(i) {
            var sevColor = i.severity >= 8 ? '#dc2626' : i.severity >= 5 ? '#f59e0b' : '#3b82f6';
            L.circleMarker([i.lat, i.lng], {
              radius: 7, color: sevColor, weight: 2, fillColor: sevColor, fillOpacity: 0.7
            }).addTo(map).bindPopup('<b>' + i.title + '</b><br>Sévérité: ' + i.severity + '/10<br><small>' + i.description.replace(/'/g, "\\'") + '</small>');
          });
          ` : ''}
          const routeCoordsParsed = ${JSON.stringify(routeCoords)};
          if (routeCoordsParsed.length > 2) {
            const routePoints = routeCoordsParsed;
            L.polyline(routePoints, { color: '${routeColor}', weight: 7, opacity: 0.4 }).addTo(map);
            L.polyline(routePoints, { color: '${routeColorDark}', weight: 4, opacity: 1 }).addTo(map);
            map.fitBounds(L.polyline(routePoints).getBounds(), { padding: [40, 40] });
          } else { const allPts = abris.filter(a => a.lat && a.lng).map(a => [a.lat, a.lng]).concat([[${userLat}, ${userLng}]]); if (allPts.length > 0) map.fitBounds(allPts, { padding: [40, 40] }); }
        </script>
      </body>
      </html>
    `;
  };

  return (
    <SafeAreaView style={styles.container} edges={["top"]}>
      <View style={styles.mapContainer}>
        <WebView
          originWhitelist={["*"]}
          source={{ html: generateMapHtml() }}
          style={styles.map}
          javaScriptEnabled={true}
          domStorageEnabled={true}
        />
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Text style={styles.title}>Évacuation</Text>
          <Text style={styles.subtitle}>Itinéraire optimal contournant les dangers</Text>
        </View>

        <View style={styles.simToggleRow}>
          <TouchableOpacity
            style={[styles.simToggleBtn, simulationMode && styles.simToggleBtnActive]}
            onPress={() => setSimulationMode(!simulationMode)}
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
        </View>

        <Card style={styles.card} shadow="sm">
          <Text style={styles.cardTitle}>Configuration du trajet</Text>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Départ</Text>
            <View style={styles.disabledInput}>
              <Ionicons name="location-outline" size={18} color={theme.colors.textMuted} />
              <Text style={styles.disabledInputText}>Ma position ({userLat.toFixed(4)}, {userLng.toFixed(4)})</Text>
            </View>
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Refuge cible</Text>
            <TouchableOpacity
              style={styles.selectButton}
              onPress={() => setShowShelterList(!showShelterList)}
            >
              <Text style={selectedShelter ? styles.selectButtonText : styles.placeholderText}>
                {selectedShelter ? `${selectedShelter.name}` : "Choisir un refuge"}
              </Text>
              <Ionicons name={showShelterList ? "chevron-up" : "chevron-down"} size={20} color={theme.colors.textGray} />
            </TouchableOpacity>

            {showShelterList && (
              <View style={styles.shelterDropdown}>
                {loadingShelters ? (
                  <ActivityIndicator size="small" color={theme.colors.primary} style={{ padding: 10 }} />
                ) : shelters.length === 0 ? (
                  <Text style={styles.emptyText}>Aucun refuge disponible</Text>
                ) : (
                  shelters.map((s) => (
                    <TouchableOpacity
                      key={s.id}
                      style={[styles.dropdownItem, selectedShelter?.id === s.id && styles.activeDropdownItem]}
                      onPress={() => { setSelectedShelter(s); setShowShelterList(false); }}
                    >
                      <Text style={styles.dropdownItemText}>{s.name}</Text>
                      <Text style={styles.dropdownItemSub}>
                        {s.distance_km ? (Math.round(s.distance_km * 10) / 10) + ' km · ' : ''}
                        Capacité: {s.current_occupancy || 0}/{s.capacity}
                      </Text>
                    </TouchableOpacity>
                  ))
                )}
              </View>
            )}
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Mode de transport</Text>
            <View style={styles.modeContainer}>
              {TRANSPORT_MODES.map((mode) => (
                <TouchableOpacity
                  key={mode.id}
                  style={[styles.modeButton, routingMode === mode.id && styles.activeModeButton]}
                  onPress={() => setRoutingMode(mode.id)}
                >
                  <Ionicons name={mode.icon} size={18} color={routingMode === mode.id ? theme.colors.primary : theme.colors.textGray} />
                  <Text style={[styles.modeText, routingMode === mode.id && styles.activeModeText]}>{mode.label}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <Button
            title="Calculer l'itinéraire"
            onPress={handleCalculateRoute}
            loading={loading}
            size="large"
            icon="flash"
          />
        </Card>

          {routeResult && (
          <Card style={[styles.card, styles.resultsCard]} shadow="md">
            <View style={styles.resultsHeader}>
              <Ionicons name="pulse" size={24} color={theme.colors.primary} />
              <Text style={styles.resultsTitle}>Résultats du trajet</Text>
            </View>

            <View style={styles.metricsContainer}>
              <View style={styles.metricCard}>
                <Text style={styles.metricLabel}>Distance</Text>
                <Text style={styles.metricValue}>{routeResult.distance_km?.toFixed(2)} km</Text>
              </View>
              <View style={styles.metricCard}>
                <Text style={styles.metricLabel}>Temps estimé</Text>
                <Text style={styles.metricValue}>{Math.ceil(routeResult.estimated_time_minutes || 0)} min</Text>
              </View>
            </View>

            <View style={styles.dangerMeter}>
              <Text style={styles.dangerLabel}>Risque du trajet</Text>
              <View style={[styles.dangerBadge, { backgroundColor: getDangerColor(routeResult.danger_score || 0, shelterInDanger) }]}>
                <Text style={styles.dangerBadgeText}>{getDangerLabel(routeResult.danger_score || 0, shelterInDanger)}</Text>
              </View>
            </View>

            {shelterInDanger && (
              <View style={styles.dangerWarning}>
                <View style={styles.dangerWarningHeader}>
                  <Ionicons name="warning" size={18} color="#dc2626" />
                  <Text style={styles.dangerWarningTitle}>
                    CRITIQUE - Refuge en zone dangereuse
                  </Text>
                </View>
                <Text style={styles.dangerWarningText}>
                  {typeof shelterInDanger === 'object' && shelterInDanger.distance_km
                    ? `Le refuge est à ${shelterInDanger.distance_km} km d'une zone ${shelterInDanger.type || 'de danger'} (${shelterInDanger.title || ''}). Il est dangereux de s'y réfugier.`
                    : typeof shelterInDanger === 'object' && shelterInDanger.title
                      ? shelterInDanger.title
                      : 'Le refuge sélectionné est dans une zone de danger actif.'}
                </Text>
              </View>
            )}

            {safeAlternatives.length > 0 && (
              <View style={styles.alternativesSection}>
                <View style={styles.alternativesHeader}>
                  <Ionicons name="shield-checkmark" size={16} color={theme.colors.primary} />
                  <Text style={styles.alternativesTitle}>Refuges alternatifs sûrs</Text>
                </View>
                {safeAlternatives.map((alt) => (
                  <TouchableOpacity
                    key={alt.id}
                    style={styles.alternativeItem}
                    onPress={() => handleSelectAlternative(alt)}
                  >
                    <View style={styles.alternativeInfo}>
                      <Text style={styles.alternativeName}>{alt.name}</Text>
                      <Text style={styles.alternativeDetail}>
                        {alt.distance_km} km · {alt.type}{alt.has_medical ? ' · 🏥 Médical' : ''}
                      </Text>
                    </View>
                    <View style={styles.alternativeBadge}>
                      <Text style={styles.alternativeBadgeText}>Choisir</Text>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            )}

            <View style={styles.tipsContainer}>
              <Text style={styles.tipsTitle}>Conseils d'évacuation</Text>
              <Text style={styles.tipText}>Le tracé vert contourne les zones de danger.</Text>
              <Text style={styles.tipText}>Partez immédiatement si la zone est critique.</Text>
            </View>
          </Card>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
  },
  mapContainer: {
    height: Dimensions.get("window").height * 0.3,
    width: "100%",
    backgroundColor: theme.colors.bgGray,
  },
  map: {
    flex: 1,
  },
  scrollContent: {
    padding: theme.spacing.lg,
  },
  header: {
    marginBottom: theme.spacing.lg,
  },
  title: {
    fontSize: theme.typography.sizes.xxl,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  subtitle: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: 4,
  },
  card: {
    backgroundColor: theme.colors.bgWhite,
    marginBottom: theme.spacing.lg,
  },
  cardTitle: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.lg,
  },
  inputGroup: {
    marginBottom: theme.spacing.lg,
  },
  label: {
    fontSize: theme.typography.sizes.xs,
    fontWeight: "700",
    textTransform: "uppercase",
    color: theme.colors.textGray,
    marginBottom: theme.spacing.sm,
  },
  disabledInput: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    backgroundColor: theme.colors.bgGray,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
  },
  disabledInputText: {
    color: theme.colors.textMuted,
    fontSize: theme.typography.sizes.sm,
    flex: 1,
  },
  selectButton: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: theme.colors.bgGray,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
  },
  selectButtonText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textDark,
    fontWeight: "500",
    flex: 1,
  },
  placeholderText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textMuted,
    flex: 1,
  },
  shelterDropdown: {
    backgroundColor: theme.colors.bgWhite,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderTopWidth: 0,
    borderBottomLeftRadius: theme.borderRadius.md,
    borderBottomRightRadius: theme.borderRadius.md,
    maxHeight: 200,
  },
  dropdownItem: {
    padding: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  activeDropdownItem: {
    backgroundColor: theme.colors.primaryLight,
  },
  dropdownItemText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  dropdownItemSub: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  emptyText: {
    padding: theme.spacing.md,
    textAlign: "center",
    color: theme.colors.textMuted,
  },
  modeContainer: {
    flexDirection: "row",
    gap: theme.spacing.sm,
  },
  modeButton: {
    flex: 1,
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    gap: theme.spacing.xs,
    paddingVertical: theme.spacing.md,
    backgroundColor: theme.colors.bgGray,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: theme.borderRadius.md,
  },
  activeModeButton: {
    backgroundColor: theme.colors.primaryLight,
    borderColor: theme.colors.primary,
  },
  modeText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    fontWeight: "500",
  },
  activeModeText: {
    color: theme.colors.primaryDark,
    fontWeight: "700",
  },
  resultsCard: {
    borderColor: theme.colors.primaryLight,
    borderWidth: 1.5,
  },
  resultsHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    marginBottom: theme.spacing.lg,
  },
  resultsTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  metricsContainer: {
    flexDirection: "row",
    gap: theme.spacing.md,
    marginBottom: theme.spacing.lg,
  },
  metricCard: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    alignItems: "center",
  },
  metricLabel: {
    fontSize: 10,
    fontWeight: "700",
    color: theme.colors.textGray,
    textTransform: "uppercase",
    marginBottom: 4,
  },
  metricValue: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  dangerMeter: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.lg,
  },
  dangerLabel: {
    fontSize: 10,
    fontWeight: "700",
    color: theme.colors.textGray,
  },
  dangerBadge: {
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 4,
    borderRadius: theme.borderRadius.sm,
  },
  dangerBadgeText: {
    color: "white",
    fontSize: 10,
    fontWeight: "700",
    textTransform: "uppercase",
  },
  tipsContainer: {
    backgroundColor: theme.colors.primaryLight,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
  },
  tipsTitle: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "700",
    color: theme.colors.primaryDark,
    marginBottom: theme.spacing.sm,
  },
  tipText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textDark,
    lineHeight: 18,
    marginBottom: 4,
  },
  dangerWarning: {
    backgroundColor: "#fef2f2",
    borderWidth: 1,
    borderColor: "#fecaca",
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.lg,
  },
  dangerWarningHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: 4,
  },
  dangerWarningTitle: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "700",
    color: "#dc2626",
  },
  dangerWarningText: {
    fontSize: theme.typography.sizes.xs,
    color: "#b91c1c",
    lineHeight: 16,
  },
  alternativesSection: {
    marginBottom: theme.spacing.lg,
  },
  alternativesHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: theme.spacing.sm,
  },
  alternativesTitle: {
    fontSize: theme.typography.sizes.xs,
    fontWeight: "700",
    color: theme.colors.textGray,
    textTransform: "uppercase",
  },
  alternativeItem: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#f0fdf4",
    borderWidth: 1,
    borderColor: "#bbf7d0",
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
  },
  alternativeInfo: {
    flex: 1,
  },
  alternativeName: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  alternativeDetail: {
    fontSize: 10,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  alternativeBadge: {
    backgroundColor: theme.colors.primary,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 6,
    borderRadius: theme.borderRadius.sm,
  },
  alternativeBadgeText: {
    color: "white",
    fontSize: 10,
    fontWeight: "700",
  },
  simToggleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: theme.spacing.lg,
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
});

export default EvacuationScreen;
