import React, { useState, useEffect, useRef, useCallback } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
  LayoutChangeEvent,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { WebView } from "react-native-webview";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";

const SPEEDS = [
  { value: 1, label: "1x" },
  { value: 2, label: "2x" },
  { value: 4, label: "4x" },
];

const SimulationScreen = () => {
  const [simulations, setSimulations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSim, setSelectedSim] = useState(null);
  const [track, setTrack] = useState([]);
  const [frameIndex, setFrameIndex] = useState(0);
  const [playing, setPlaying] = useState(false);
  const [speed, setSpeed] = useState(1);
  const [sliderWidth, setSliderWidth] = useState(0);
  const [generatingTrack, setGeneratingTrack] = useState(false);
  const [totalAffectedPopulation, setTotalAffectedPopulation] = useState(0);
  const [totalImpactedArea, setTotalImpactedArea] = useState(0);
  const [maxWindObserved, setMaxWindObserved] = useState(0);
  const [showSummary, setShowSummary] = useState(false);
  const [heatmapCells, setHeatmapCells] = useState({});
  const timerRef = useRef(null);
  const heatmapRef = useRef({});

  useEffect(() => {
    fetchSimulations();
    var safety = setTimeout(function() { setLoading(false); }, 20000);
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      clearTimeout(safety);
    };
  }, []);

  const fetchSimulations = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await api.getSimulations();
      const sims = (res.data?.simulations || []).filter(
        (s) => s.status === "completed"
      );
      setSimulations(sims);
      if (sims.length === 0) setError("Aucune simulation terminée disponible");
    } catch (err) {
      console.error("Erreur chargement simulations:", err);
      setError("Impossible de charger les simulations");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (playing) {
      timerRef.current = setInterval(() => {
        setFrameIndex((prev) => {
          if (prev >= track.length - 1) {
            setPlaying(false);
            setShowSummary(true);
            return prev;
          }
          return prev + 1;
        });
      }, 400 / speed);
    }
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [playing, speed, track.length]);

  useEffect(() => {
    if (!track.length) return;
    const pt = track[frameIndex];
    if (!pt) return;
    setMaxWindObserved((prev) => Math.max(prev, pt.wind || 0));
    const wind = pt.wind || 50;
    const damageRadiusKm = Math.max(5, wind * 0.15);
    const area = Math.PI * damageRadiusKm * damageRadiusKm;
    setTotalImpactedArea((prev) => prev + area);
    const density = 200 + Math.random() * 200;
    setTotalAffectedPopulation((prev) => prev + Math.round(area * density / 100));
    const rLat = Math.round(pt.lat * 4) / 4;
    const rLng = Math.round(pt.lng * 4) / 4;
    const key = rLat + ',' + rLng;
    if (!heatmapRef.current[key]) heatmapRef.current[key] = 0;
    heatmapRef.current[key] += 1;
    setHeatmapCells({ ...heatmapRef.current });
  }, [frameIndex]);

  const selectSimulation = (sim) => {
    stopPlayback();
    setSelectedSim(sim);
    const t = sim.results?.track || [];
    setTrack(t);
    setFrameIndex(0);
    setTotalAffectedPopulation(0);
    setTotalImpactedArea(0);
    setMaxWindObserved(0);
    setShowSummary(false);
    setHeatmapCells({});
    heatmapRef.current = {};
  };

  const stopPlayback = () => {
    setPlaying(false);
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  };

  const togglePlayback = () => {
    if (track.length === 0) return;
    if (playing) {
      stopPlayback();
    } else {
      if (frameIndex >= track.length - 1) { setFrameIndex(0); setShowSummary(false); }
      setPlaying(true);
    }
  };

  const handleSliderChange = (val) => {
    stopPlayback();
    setFrameIndex(Math.round(val));
  };

  const handleSpeedChange = (s) => {
    setSpeed(s);
    if (playing) {
      if (timerRef.current) clearInterval(timerRef.current);
      timerRef.current = setInterval(() => {
        setFrameIndex((prev) => {
          if (prev >= track.length - 1) {
            setPlaying(false);
            return prev;
          }
          return prev + 1;
        });
      }, 400 / s);
    }
  };

  const generateMapHtml = () => {
    if (!track || track.length === 0)
      return "<html><body style='background:#f8fafc;display:flex;align-items:center;justify-content:center;color:#94a3b8;font-family:sans-serif'><p>Chargement de la trajectoire...</p></body></html>";

    const pts = track.map((p) => `[${p.lat}, ${p.lng}]`).join(",");
    const current = track[frameIndex] || track[0];
    const currentLat = current.lat;
    const currentLng = current.lng;
    const stage = (current.stage || "Cyclone").replace(/'/g, "\\'");
    const wind = current.wind || 0;
    const pressure = current.pressure || 0;
    const datetime = (current.datetime || "").replace(/'/g, "\\'");
    const ptsArr = track.map((p) => [p.lat, p.lng]);
    const damagePts = ptsArr.slice(0, frameIndex + 1).map((p) => `[${p[0]}, ${p[1]}]`).join(",");
    const heatmapData = JSON.stringify(Object.entries(heatmapCells).map(([k, v]) => {
      const [lat, lng] = k.split(",").map(Number);
      return { lat, lng, count: v };
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
          html, body, #map { height: 100%; margin: 0; padding: 0; background: #f8fafc; }
          .marker-cyclone {
            width: 40px; height: 40px; border-radius: 50%;
            background: linear-gradient(135deg, #7c3aed, #ec4899);
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; box-shadow: 0 4px 16px rgba(124,58,237,0.5);
            border: 2.5px solid white;
          }
          @keyframes pulse-damage {
            0% { opacity: 0.7; transform: scale(1); }
            50% { opacity: 0.4; transform: scale(1.08); }
            100% { opacity: 0.7; transform: scale(1); }
          }
          .damage-circle { animation: pulse-damage 2s ease-in-out infinite; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          var pts = [${pts}];
          var damagePts = [${damagePts}];
          var map = L.map('map', { zoomControl: false }).setView([${currentLat}, ${currentLng}], 6);
          var osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '© OpenStreetMap' }).addTo(map);
          var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', { maxZoom: 19, attribution: '© Esri, Maxar, Earthstar Geographics' });
          L.control.layers({ 'Carte': osmLayer, 'Satellite': satelliteLayer }, null, { position: 'topright', collapsed: true }).addTo(map);

          var fullLine = L.polyline(pts, { color: '#7c3aed', weight: 2.5, opacity: 0.5, dashArray: '6,4' }).addTo(map);
          var currentIdx = ${frameIndex};
          var playedPts = pts.slice(0, currentIdx + 1);
          var playedLine = L.polyline(playedPts, { color: '#7c3aed', weight: 5, opacity: 1 }).addTo(map);

          var marker = L.marker([${currentLat}, ${currentLng}], {
            icon: L.divIcon({
              className: 'custom-marker',
              html: '<div class="marker-cyclone">🌀</div>',
              iconSize: [40, 40],
              iconAnchor: [20, 20]
            })
          }).addTo(map).bindPopup(
            '<div style="font-size:12px;font-family:sans-serif">' +
            '<strong>' + '${stage}' + '</strong><br>' +
            'Vent: ${wind} km/h<br>Pression: ${pressure} hPa<br>' +
            '${datetime}' + '</div>'
          ).openPopup();

          var LAND_CITIES = [
            { name:'Antananarivo', lat:-18.9078, lng:47.5208 },
            { name:'Toamasina', lat:-18.1442, lng:49.3956 },
            { name:'Mahajanga', lat:-15.7180, lng:46.3220 },
            { name:'Fianarantsoa', lat:-21.4333, lng:47.0833 },
            { name:'Antsiranana', lat:-12.2833, lng:49.2833 },
            { name:'Toliara', lat:-23.3550, lng:43.6850 },
            { name:'Antsirabe', lat:-19.8667, lng:47.0333 },
            { name:'Morondava', lat:-20.2833, lng:44.2833 },
          ];
          function haversineKm(lat1,lng1,lat2,lng2) {
            var R=6371; var dLat=(lat2-lat1)*Math.PI/180; var dLng=(lng2-lng1)*Math.PI/180;
            var a=Math.sin(dLat/2)*Math.sin(dLat/2)+Math.cos(lat1*Math.PI/180)*Math.cos(lat2*Math.PI/180)*Math.sin(dLng/2)*Math.sin(dLng/2);
            return R*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
          }
          function clampToLand(lat,lng) {
            var best=null; var bestDist=Infinity;
            LAND_CITIES.forEach(function(c) {
              var d=haversineKm(lat,lng,c.lat,c.lng);
              if(d<bestDist){bestDist=d;best=c;}
            });
            if(best&&bestDist>80) return {lat:best.lat,lng:best.lng};
            return {lat:lat,lng:lng};
          }

          var SIMULATION_SHELTERS = [
            { id:'r1',name:"Centre d'urgence Analakely",lat:-18.9100,lng:47.5250,capacity:500,type:'Centre communautaire',medical:true },
            { id:'r2',name:'Refuge Toamasina Centre',lat:-18.1500,lng:49.4000,capacity:300,type:'École',medical:false },
            { id:'r3',name:'Stade municipal Mahajanga',lat:-15.7180,lng:46.3220,capacity:400,type:'Stade municipal',medical:true },
            { id:'r4',name:'Centre de secours Antsiranana',lat:-12.2800,lng:49.2900,capacity:250,type:'Centre polyvalent',medical:true },
            { id:'r5',name:'Refuge Fianarantsoa',lat:-21.4300,lng:47.0800,capacity:350,type:'École primaire',medical:false },
            { id:'r6',name:'Centre de loisirs Toliara',lat:-23.3550,lng:43.6850,capacity:200,type:'Centre de loisirs',medical:false },
            { id:'r7',name:'Gymnase Antananarivo',lat:-18.8900,lng:47.5100,capacity:600,type:'Gymnase couvert',medical:true },
            { id:'r8',name:'Refuge Antsirabe',lat:-19.8600,lng:47.0300,capacity:280,type:'Centre paroissial',medical:false },
          ];

          var shelterLayer = L.layerGroup().addTo(map);
          SIMULATION_SHELTERS.forEach(function(s) {
            var clamped = clampToLand(s.lat,s.lng);
            L.circle([clamped.lat,clamped.lng], {
              color:'#059669', fillColor:'#059669', fillOpacity:0.1, weight:2, radius: 2500
            }).addTo(shelterLayer);
            L.marker([clamped.lat,clamped.lng], {
              icon: L.divIcon({ className:'custom-marker', html:'<div style="width:28px;height:28px;border-radius:50%;background:linear-gradient(135deg,#059669,#047857);display:flex;align-items:center;justify-content:center;font-size:14px;border:2px solid white;box-shadow:0 2px 8px rgba(0,0,0,0.3)">🏠</div>', iconSize:[28,28], iconAnchor:[14,26] })
            }).addTo(shelterLayer).bindPopup(
              '<div style="font-size:12px;font-family:sans-serif">' +
              '<strong>' + s.name + '</strong><br>' +
              'Capacité: ' + s.capacity + '<br>' +
              (s.medical ? 'Soins médicaux ✓' : '') + '</div>'
            );
          });

          var damageLayer = L.layerGroup().addTo(map);
          var evacLayer = L.layerGroup().addTo(map);
          damagePts.forEach(function(dp) {
            var dRadius = Math.max(3000, 15000 * Math.random());
            var circle = L.circle([dp[0], dp[1]], {
              color:'#dc2626', fillColor:'#dc2626', fillOpacity:0.15, weight:2, radius: dRadius,
              className:'damage-circle'
            }).addTo(damageLayer);
            L.circle([dp[0], dp[1]], {
              color:'#ef4444', fillColor:'transparent', fillOpacity:0, weight:1.5, radius: dRadius*1.3,
              dashArray:'4,6'
            }).addTo(damageLayer);

            var nearest = null; var nearDist = Infinity;
            SIMULATION_SHELTERS.forEach(function(s) {
              var d = haversineKm(dp[0],dp[1],s.lat,s.lng);
              if(d < nearDist){nearDist=d;nearest=s;}
            });
            if(nearest&&nearDist<200) {
              L.polyline([[dp[0],dp[1]],[nearest.lat,nearest.lng]], {
                color:'#f97316', weight:1.5, opacity:0.5, dashArray:'6,4'
              }).addTo(evacLayer);
            }
          });

          ${showSummary && heatmapData ? `
          var heatmapCells = ${heatmapData};
          var heatLayer = L.layerGroup().addTo(map);
          var maxCount = 1;
          heatmapCells.forEach(function(c) { if(c.count>maxCount)maxCount=c.count; });
          heatmapCells.forEach(function(c) {
            var intensity = Math.min(1, c.count / maxCount);
            var r = Math.round(255 * intensity);
            var g = Math.round(50 * (1 - intensity));
            var b = Math.round(50 * (1 - intensity));
            L.rectangle([[c.lat-0.125, c.lng-0.125], [c.lat+0.125, c.lng+0.125]], {
              color:'transparent', fillColor:'rgb('+r+','+g+','+b+')', fillOpacity:0.3*intensity+0.1, weight:0
            }).addTo(heatLayer);
          });
          ` : ''}

          map.fitBounds(fullLine.getBounds(), { padding: [40, 40] });
        </script>
      </body>
      </html>
    `;
  };

  const windPct = Math.min(100, ((track[frameIndex]?.wind || 0) / 220) * 100);
  const windColor =
    windPct > 70
      ? "#dc2626"
      : windPct > 40
        ? "#d97706"
        : "#059669";

  if (loading) {
    return (
      <SafeAreaView style={styles.container} edges={["top"]}>
        <View style={styles.loadingContainer}>
          <View style={styles.loadingIcon}>
            <Ionicons name="pulse-outline" size={40} color={theme.colors.primary} />
          </View>
          <ActivityIndicator size="large" color={theme.colors.primary} style={{ marginTop: 16 }} />
          <Text style={styles.loadingText}>Simulations cycloniques</Text>
          <Text style={styles.loadingSubtext}>Chargement des simulations terminées...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <View style={styles.headerIcon}>
            <Ionicons name="pulse-outline" size={24} color={theme.colors.primary} />
          </View>
          <View>
            <Text style={styles.title}>Simulations</Text>
            <Text style={styles.subtitle}>Trajectoire "What-If" pas-à-pas</Text>
          </View>
        </View>

        {error && !selectedSim && (
          <Card style={styles.errorCard}>
            <View style={styles.errorContent}>
              <Ionicons name="cloud-offline-outline" size={32} color={theme.colors.danger} />
              <Text style={styles.errorText}>{error}</Text>
              <TouchableOpacity style={styles.retryBtn} onPress={fetchSimulations}>
                <Ionicons name="refresh-outline" size={16} color={theme.colors.primary} />
                <Text style={styles.retryText}>Réessayer</Text>
              </TouchableOpacity>
            </View>
          </Card>
        )}

        {!selectedSim && simulations.length > 0 && (
          <View style={styles.section}>
            <View style={{ flexDirection: "row", alignItems: "center", gap: 6, marginBottom: theme.spacing.md }}>
              <Ionicons name="list-outline" size={16} color={theme.colors.textDark} />
              <Text style={styles.sectionTitle}>Simulations disponibles</Text>
            </View>
            {simulations.map((sim) => (
              <TouchableOpacity
                key={sim.id}
                style={styles.simCard}
                onPress={() => selectSimulation(sim)}
              >
                <View style={styles.simCardHeader}>
                  <View style={styles.simBadge}>
                    <Ionicons name="flash-outline" size={14} color="#7c3aed" />
                  </View>
                  <View style={styles.simInfo}>
                    <Text style={styles.simName}>{sim.name}</Text>
                    <Text style={styles.simMeta}>
                      {sim.results?.track ? `${sim.results.track.length} étapes · ${sim.results.max_wind_kmh || "?"} km/h` : "Données de trajectoire indisponibles"}
                    </Text>
                  </View>
                  <Ionicons name="chevron-forward" size={18} color={theme.colors.textMuted} />
                </View>
              </TouchableOpacity>
            ))}
          </View>
        )}

        {selectedSim && track.length === 0 && (
          <>
            <Card shadow="sm" style={styles.simDetailCard}>
              <Text style={styles.simDetailTitle}>{selectedSim.name}</Text>
              <View style={styles.simDetailRow}>
                <Ionicons name="flash-outline" size={14} color={theme.colors.textMuted} />
                <Text style={styles.simDetailLabel}>Type :</Text>
                <Text style={styles.simDetailValue}>{selectedSim.scenario_type}</Text>
              </View>
              <View style={styles.simDetailRow}>
                <Ionicons name="trending-up-outline" size={14} color={theme.colors.textMuted} />
                <Text style={styles.simDetailLabel}>Intensité :</Text>
                <Text style={styles.simDetailValue}>{selectedSim.intensity_level}/10</Text>
              </View>
              <View style={styles.simDetailRow}>
                <Ionicons name="location-outline" size={14} color={theme.colors.textMuted} />
                <Text style={styles.simDetailLabel}>Position :</Text>
                <Text style={styles.simDetailValue}>
                  {Number(selectedSim.center_lat || 0).toFixed(2)}S, {Number(selectedSim.center_lng || 0).toFixed(2)}E
                </Text>
              </View>
              {selectedSim.radius_km && (
                <View style={styles.simDetailRow}>
                  <Ionicons name="resize-outline" size={14} color={theme.colors.textMuted} />
                  <Text style={styles.simDetailLabel}>Rayon :</Text>
                  <Text style={styles.simDetailValue}>{selectedSim.radius_km} km</Text>
                </View>
              )}
            </Card>

            {selectedSim.results && (
              <Card shadow="sm" style={styles.simResultsCard}>
                <Text style={styles.simResultsTitle}>Résultats de la simulation</Text>
                <View style={styles.simResultsGrid}>
                  {selectedSim.results.affected_population != null && (
                    <View style={styles.simResultItem}>
                      <Text style={styles.simResultValue}>
                        {selectedSim.results.affected_population.toLocaleString()}
                      </Text>
                      <Text style={styles.simResultLabel}>Population affectée</Text>
                    </View>
                  )}
                  {selectedSim.results.risk_index != null && (
                    <View style={styles.simResultItem}>
                      <Text style={styles.simResultValue}>{selectedSim.results.risk_index}</Text>
                      <Text style={styles.simResultLabel}>Indice de risque</Text>
                    </View>
                  )}
                  {selectedSim.results.max_wind_kmh != null && (
                    <View style={styles.simResultItem}>
                      <Text style={styles.simResultValue}>{selectedSim.results.max_wind_kmh}</Text>
                      <Text style={styles.simResultLabel}>Vent max (km/h)</Text>
                    </View>
                  )}
                  {selectedSim.results.min_pressure_hpa != null && (
                    <View style={styles.simResultItem}>
                      <Text style={styles.simResultValue}>{selectedSim.results.min_pressure_hpa}</Text>
                      <Text style={styles.simResultLabel}>Pression min (hPa)</Text>
                    </View>
                  )}
                </View>
                {selectedSim.results.safe_refuges_identified?.length > 0 && (
                  <View style={styles.simRefuges}>
                    <Text style={styles.simRefugesLabel}>Abris recommandés :</Text>
                    {selectedSim.results.safe_refuges_identified.map((r, i) => (
                      <Text key={i} style={styles.simRefugeItem}>• {r}</Text>
                    ))}
                  </View>
                )}
              </Card>
            )}

            <TouchableOpacity
              style={[styles.generateBtn, generatingTrack && styles.generateBtnDisabled]}
              onPress={async () => {
                if (generatingTrack) return;
                setGeneratingTrack(true);
                try {
                  const res = await api.generateTrajectory({
                    lat: selectedSim.center_lat || -18.9,
                    lng: selectedSim.center_lng || 47.5,
                    intensity: selectedSim.intensity_level || 5,
                    hours: 168,
                    step: 6,
                  });
                  const newTrack = res.data?.track || [];
                  setTrack(newTrack);
                  setFrameIndex(0);
                } catch (err) {
                  console.error("Erreur génération trajectoire:", err);
                } finally {
                  setGeneratingTrack(false);
                }
              }}
              disabled={generatingTrack}
            >
              {generatingTrack ? (
                <ActivityIndicator size="small" color="#fff" />
              ) : (
                <Ionicons name="pulse-outline" size={18} color="#fff" />
              )}
              <Text style={styles.generateBtnText}>
                {generatingTrack ? "Génération en cours..." : "Générer la trajectoire"}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.backToListBtn}
              onPress={() => { setSelectedSim(null); stopPlayback(); }}
            >
              <Ionicons name="arrow-back-outline" size={16} color={theme.colors.primary} />
              <Text style={styles.backToListText}>Retour à la liste</Text>
            </TouchableOpacity>
          </>
        )}

        {selectedSim && track.length > 0 && (
          <>
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

            <Card style={styles.controlsCard} shadow="sm">
              <View style={styles.infoGrid}>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Position</Text>
                  <Text style={styles.infoValueSm}>
                    {(track[frameIndex]?.lat || 0).toFixed(2)}S, {(track[frameIndex]?.lng || 0).toFixed(2)}E
                  </Text>
                </View>
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Stade</Text>
                  <Text style={styles.infoValueSm}>{track[frameIndex]?.stage || "--"}</Text>
                </View>
              </View>

              <View style={styles.statsRow}>
                <View style={[styles.statBox, { borderLeftColor: windColor }]}>
                  <Text style={styles.statLabel}>Vent</Text>
                  <Text style={[styles.statValue, { color: windColor }]}>
                    {track[frameIndex]?.wind || 0}
                  </Text>
                  <Text style={styles.statUnit}>km/h</Text>
                </View>
                <View style={[styles.statBox, { borderLeftColor: "#3b82f6" }]}>
                  <Text style={styles.statLabel}>Pression</Text>
                  <Text style={styles.statValue}>{track[frameIndex]?.pressure || 0}</Text>
                  <Text style={styles.statUnit}>hPa</Text>
                </View>
                <View style={[styles.statBox, { borderLeftColor: "#f59e0b" }]}>
                  <Text style={styles.statLabel}>Rafales</Text>
                  <Text style={styles.statValue}>{track[frameIndex]?.gusts || 0}</Text>
                  <Text style={styles.statUnit}>km/h</Text>
                </View>
              </View>

              {totalAffectedPopulation > 0 && (
                <View style={styles.popRow}>
                  <Ionicons name="people-outline" size={14} color="#dc2626" />
                  <Text style={styles.popLabel}>Population affectée estimée</Text>
                  <Text style={styles.popValue}>{totalAffectedPopulation.toLocaleString()}</Text>
                </View>
              )}
            </Card>

            {showSummary && (
              <Card style={styles.summaryCard} shadow="md">
                <View style={styles.summaryHeader}>
                  <Ionicons name="stats-chart-outline" size={20} color={theme.colors.primary} />
                  <Text style={styles.summaryTitle}>Bilan de la simulation</Text>
                </View>
                <View style={styles.summaryGrid}>
                  <View style={styles.summaryItem}>
                    <Ionicons name="people-outline" size={18} color="#dc2626" />
                    <Text style={styles.summaryValue}>{totalAffectedPopulation.toLocaleString()}</Text>
                    <Text style={styles.summaryLabel}>Population affectée</Text>
                  </View>
                  <View style={styles.summaryItem}>
                    <Ionicons name="resize-outline" size={18} color="#f59e0b" />
                    <Text style={styles.summaryValue}>{totalImpactedArea.toFixed(0)} km²</Text>
                    <Text style={styles.summaryLabel}>Superficie impactée</Text>
                  </View>
                  <View style={styles.summaryItem}>
                    <Ionicons name="trending-up-outline" size={18} color="#7c3aed" />
                    <Text style={styles.summaryValue}>{maxWindObserved} km/h</Text>
                    <Text style={styles.summaryLabel}>Vent max observé</Text>
                  </View>
                  <View style={styles.summaryItem}>
                    <Ionicons name="map-outline" size={18} color="#3b82f6" />
                    <Text style={styles.summaryValue}>{track.length}</Text>
                    <Text style={styles.summaryLabel}>Points de trajectoire</Text>
                  </View>
                </View>
                <Text style={styles.summaryNote}>
                  Les abris et les lignes d'évacuation sont affichés sur la carte. La chaleur des points de passage indique la densité de passage du cyclone.
                </Text>
              </Card>
            )}

            <View style={styles.playbackCard}>
              <View style={styles.timeRow}>
                <Text style={styles.timeText}>{track[frameIndex]?.datetime || "--"}</Text>
                <Text style={styles.timeProgress}>
                  {frameIndex + 1} / {track.length}
                </Text>
              </View>

              <View
                style={styles.sliderContainer}
                onLayout={(e) => setSliderWidth(e.nativeEvent.layout.width)}
              >
                <View style={styles.sliderTrack}>
                  <View
                    style={[
                      styles.sliderFill,
                      { width: `${track.length > 1 ? (frameIndex / (track.length - 1)) * 100 : 0}%` },
                    ]}
                  />
                </View>
                <TouchableOpacity
                  style={[
                    styles.sliderThumb,
                    { left: `${track.length > 1 ? (frameIndex / (track.length - 1)) * 100 : 0}%` },
                  ]}
                  onPress={() => {}}
                />
                <TouchableOpacity
                  style={styles.sliderTouchArea}
                  activeOpacity={1}
                  onPress={(e) => {
                    const x = e.nativeEvent.locationX;
                    const ratio = Math.max(0, Math.min(1, x / sliderWidth));
                    const idx = Math.round(ratio * (track.length - 1));
                    handleSliderChange(idx);
                  }}
                />
              </View>

              <View style={styles.playbackControls}>
                <TouchableOpacity
                  style={styles.speedBtn}
                  onPress={() => selectSimulation(selectedSim)}
                >
                  <Ionicons name="refresh-outline" size={18} color={theme.colors.textGray} />
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.playBtn}
                  onPress={togglePlayback}
                  disabled={track.length === 0}
                >
                  <Ionicons
                    name={playing ? "pause" : "play"}
                    size={24}
                    color="white"
                  />
                </TouchableOpacity>

                <View style={styles.speedGroup}>
                  {SPEEDS.map((s) => (
                    <TouchableOpacity
                      key={s.value}
                      style={[
                        styles.speedOption,
                        speed === s.value && styles.speedOptionActive,
                      ]}
                      onPress={() => handleSpeedChange(s.value)}
                    >
                      <Text
                        style={[
                          styles.speedText,
                          speed === s.value && styles.speedTextActive,
                        ]}
                      >
                        {s.label}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </View>
            </View>

            <Card style={styles.trackCard} shadow="sm">
              <TouchableOpacity
                style={styles.trackHeader}
                onPress={() => { setSelectedSim(null); stopPlayback(); }}
              >
                <Ionicons name="arrow-back-outline" size={16} color={theme.colors.textGray} />
                <Text style={styles.trackBackText}>Retour à la liste</Text>
              </TouchableOpacity>
              <Text style={styles.trackTitle}>
                {selectedSim.name}
              </Text>
              <Text style={styles.trackSubtitle}>
                {track.length} points de trajectoire · Simulation "What-If"
              </Text>
              <View style={styles.trackList}>
                {track.map((p, i) => (
                  <TouchableOpacity
                    key={i}
                    style={[
                      styles.trackItem,
                      i === frameIndex && styles.trackItemActive,
                    ]}
                    onPress={() => handleSliderChange(i)}
                  >
                    <View
                      style={[
                        styles.trackDot,
                        i === frameIndex && styles.trackDotActive,
                      ]}
                    />
                    <View style={styles.trackItemInfo}>
                      <Text style={styles.trackItemTime}>{p.datetime}</Text>
                      <Text style={styles.trackItemStage}>{p.stage}</Text>
                    </View>
                    <Text style={styles.trackItemWind}>{p.wind} km/h</Text>
                  </TouchableOpacity>
                ))}
              </View>
            </Card>
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgWhite,
  },
  scrollContent: {
    padding: theme.spacing.lg,
    paddingBottom: theme.spacing.xl * 2,
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
    textAlign: "center",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
    marginBottom: theme.spacing.lg,
  },
  headerIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: "#f5f3ff",
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
    marginTop: 2,
  },
  errorCard: {
    padding: theme.spacing.lg,
    marginBottom: theme.spacing.md,
  },
  errorContent: {
    alignItems: "center",
    gap: theme.spacing.md,
  },
  errorText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
  },
  retryBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: theme.borderRadius.sm,
    borderWidth: 1,
    borderColor: theme.colors.primary,
  },
  retryText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.primary,
    fontWeight: "600",
  },
  section: {
    marginBottom: theme.spacing.lg,
  },
  sectionTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  simCard: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
  },
  simCardHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
  },
  simBadge: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "#f5f3ff",
    justifyContent: "center",
    alignItems: "center",
  },
  simInfo: {
    flex: 1,
  },
  simName: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  simMeta: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    marginTop: 2,
  },
  mapContainer: {
    height: Dimensions.get("window").height * 0.35,
    width: "100%",
    borderRadius: theme.borderRadius.lg,
    overflow: "hidden",
    marginBottom: theme.spacing.md,
  },
  map: {
    flex: 1,
  },
  controlsCard: {
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
  },
  infoGrid: {
    flexDirection: "row",
    gap: theme.spacing.md,
    marginBottom: theme.spacing.md,
  },
  infoItem: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.sm,
    padding: theme.spacing.sm,
  },
  infoLabel: {
    fontSize: 10,
    color: theme.colors.textMuted,
    fontWeight: "600",
    textTransform: "uppercase",
    marginBottom: 2,
  },
  infoValueSm: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  statsRow: {
    flexDirection: "row",
    gap: theme.spacing.sm,
  },
  statBox: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.sm,
    borderLeftWidth: 3,
    padding: theme.spacing.sm,
    alignItems: "center",
  },
  statLabel: {
    fontSize: 10,
    color: theme.colors.textMuted,
    fontWeight: "600",
    textTransform: "uppercase",
  },
  statValue: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  statUnit: {
    fontSize: 10,
    color: theme.colors.textMuted,
  },
  playbackCard: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
  },
  timeRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: theme.spacing.xs,
  },
  timeText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  timeProgress: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
  },
  sliderContainer: {
    height: 40,
    justifyContent: "center",
    marginBottom: theme.spacing.sm,
    position: "relative",
  },
  sliderTrack: {
    height: 6,
    backgroundColor: theme.colors.bgGrayDark,
    borderRadius: 3,
    overflow: "hidden",
  },
  sliderFill: {
    height: "100%",
    backgroundColor: "#7c3aed",
    borderRadius: 3,
  },
  sliderThumb: {
    position: "absolute",
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: "#7c3aed",
    borderWidth: 3,
    borderColor: "white",
    shadowColor: "#7c3aed",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 4,
    marginLeft: -9,
    top: "50%",
    marginTop: -9,
    zIndex: 2,
  },
  sliderTouchArea: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 3,
  },
  playbackControls: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  speedBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.bgGray,
    justifyContent: "center",
    alignItems: "center",
  },
  playBtn: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: "#7c3aed",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#7c3aed",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  speedGroup: {
    flexDirection: "row",
    gap: 6,
  },
  speedOption: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: theme.borderRadius.sm,
    backgroundColor: theme.colors.bgGray,
  },
  speedOptionActive: {
    backgroundColor: "#7c3aed",
  },
  speedText: {
    fontSize: theme.typography.sizes.xs,
    fontWeight: "700",
    color: theme.colors.textGray,
  },
  speedTextActive: {
    color: "white",
  },
  trackCard: {
    padding: theme.spacing.md,
  },
  trackHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: theme.spacing.md,
  },
  trackBackText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    fontWeight: "500",
  },
  trackTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  trackSubtitle: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    marginTop: 2,
    marginBottom: theme.spacing.md,
  },
  trackList: {
    maxHeight: 200,
  },
  trackItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    paddingVertical: theme.spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  trackItemActive: {
    backgroundColor: "#f5f3ff",
    borderRadius: theme.borderRadius.sm,
    marginHorizontal: -theme.spacing.sm,
    paddingHorizontal: theme.spacing.sm,
  },
  trackDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: theme.colors.border,
  },
  trackDotActive: {
    backgroundColor: "#7c3aed",
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  trackItemInfo: {
    flex: 1,
  },
  trackItemTime: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textDark,
    fontWeight: "500",
  },
  trackItemStage: {
    fontSize: 10,
    color: theme.colors.textMuted,
  },
  trackItemWind: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "700",
    color: "#7c3aed",
  },
  simDetailCard: {
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
  },
  simDetailTitle: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.md,
  },
  simDetailRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.xs,
    marginBottom: theme.spacing.sm,
  },
  simDetailLabel: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textMuted,
    fontWeight: "500",
  },
  simDetailValue: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textDark,
    fontWeight: "600",
  },
  simResultsCard: {
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
  },
  simResultsTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.md,
  },
  simResultsGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: theme.spacing.sm,
    marginBottom: theme.spacing.md,
  },
  simResultItem: {
    flex: 1,
    minWidth: "45%",
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.sm,
    padding: theme.spacing.sm,
    alignItems: "center",
  },
  simResultValue: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  simResultLabel: {
    fontSize: 10,
    color: theme.colors.textMuted,
    fontWeight: "600",
    textTransform: "uppercase",
    marginTop: 2,
    textAlign: "center",
  },
  simRefuges: {
    borderTopWidth: 1,
    borderTopColor: theme.colors.borderLight,
    paddingTop: theme.spacing.sm,
  },
  simRefugesLabel: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.xs,
  },
  simRefugeItem: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginBottom: 2,
  },
  generateBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: theme.spacing.sm,
    backgroundColor: "#7c3aed",
    borderRadius: theme.borderRadius.md,
    paddingVertical: theme.spacing.md - 2,
    marginBottom: theme.spacing.md,
  },
  generateBtnDisabled: {
    opacity: 0.6,
  },
  generateBtnText: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: "#fff",
  },
  backToListBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: theme.spacing.xs,
    paddingVertical: theme.spacing.sm,
  },
  backToListText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.primary,
    fontWeight: "600",
  },
  popRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    backgroundColor: "#fef2f2",
    borderRadius: theme.borderRadius.sm,
    padding: theme.spacing.sm,
    marginTop: theme.spacing.sm,
  },
  popLabel: {
    flex: 1,
    fontSize: theme.typography.sizes.xs,
    fontWeight: "600",
    color: theme.colors.textGray,
  },
  popValue: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "800",
    color: "#dc2626",
  },
  summaryCard: {
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
    borderWidth: 1,
    borderColor: theme.colors.primaryLight,
  },
  summaryHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    marginBottom: theme.spacing.md,
  },
  summaryTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  summaryGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: theme.spacing.sm,
    marginBottom: theme.spacing.sm,
  },
  summaryItem: {
    flex: 1,
    minWidth: "45%",
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.sm,
    padding: theme.spacing.sm,
    alignItems: "center",
    gap: 2,
  },
  summaryValue: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  summaryLabel: {
    fontSize: 9,
    color: theme.colors.textMuted,
    fontWeight: "600",
    textTransform: "uppercase",
    textAlign: "center",
  },
  summaryNote: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    fontStyle: "italic",
    textAlign: "center",
    marginTop: theme.spacing.xs,
  },
});

export default SimulationScreen;
