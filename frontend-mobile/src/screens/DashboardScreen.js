import React, { useState, useEffect, useCallback } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  RefreshControl,
  Text,
  TouchableOpacity,
  AppState,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import { useAuth } from "../context/AuthContext";
import Card from "../components/Card";

const DashboardScreen = ({ navigation }) => {
  const { state: authState } = useAuth();
  const [alerts, setAlerts] = useState([]);
  const [weather, setWeather] = useState(null);
  const [aiAdvice, setAiAdvice] = useState(null);
  const [stats, setStats] = useState({ cyclones: 0, incidents: 0, shelters: 0 });
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  const getRiskColor = (risk) => {
    const map = { critique: "#dc2626", élevé: "#ea580c", modéré: "#f59e0b", faible: "#10b981" };
    return map[risk] || "#10b981";
  };

  const loadDashboard = useCallback(async () => {
    try {
      setLoading(true);
      const [alertsRes, weatherRes, cycloneRes, incidentsRes, sheltersRes] = await Promise.all([
        api.getAlerts({ limit: 5, sort: "-emitted_at" }),
        api.getWeather(47.5, 4.5),
        api.getAlerts({ type: "cyclone", active: true, limit: 10 }),
        api.getIncidents({ type: "cyclone", limit: 10 }),
        api.getShelters({ available: true, limit: 10 }),
      ]);
      setAlerts(alertsRes.data?.alerts || []);
      setStats({
        cyclones: (cycloneRes.data?.alerts || []).length,
        incidents: (incidentsRes.data?.incidents || []).length,
        shelters: (sheltersRes.data?.shelters || []).length,
      });

      const wData = weatherRes.data;
      let parsedWeather = null;
      if (wData && wData.data) {
        if (wData.source === "cache") {
          parsedWeather = {
            temp: Math.round(wData.data.temperature),
            description: wData.data.weather_condition || "Nuageux",
            humidity: wData.data.humidity || 0,
            windSpeed: Math.round(wData.data.wind_speed || 0),
          };
        } else {
          parsedWeather = {
            temp: Math.round(wData.data.main?.temp || 0),
            description: wData.data.weather?.[0]?.description || "Clair",
            humidity: wData.data.main?.humidity || 0,
            windSpeed: Math.round((wData.data.wind?.speed || 0) * 3.6),
          };
        }
      }
      setWeather(parsedWeather);

      const cyclones = (cycloneRes.data?.alerts || []).map((a) => ({
        lat: a.center_lat || a.lat || -18.9078,
        lng: a.center_lng || a.lng || 47.5208,
        title: a.zone_name || a.title || "Cyclone",
        level: a.level || "vigilance",
        wind_speed: a.features_input?.wind_speed || null,
        pressure: a.features_input?.pressure || null,
      }));
      const incidents = (incidentsRes.data?.incidents || []).map((i) => ({
        lat: i.location_lat || i.lat || -18.9078,
        lng: i.location_lng || i.lng || 47.5208,
        title: i.title || "Incident",
        status: i.status || "signalé",
      }));
      const shelters = (sheltersRes.data?.shelters || []).map((s) => ({
        lat: s.location_lat || s.lat || -18.9078,
        lng: s.location_lng || s.lng || 47.5208,
        name: s.name || "Abri",
        capacity: s.capacity || 0,
      }));

      try {
        const aiRes = await api.getAIAnalysis({ cyclones, incidents, shelters });
        const aiData = aiRes.data?.data || aiRes.data;
        setAiAdvice(aiData);
      } catch (aiErr) {
        console.log("AI analysis not available:", aiErr.message);
      }
    } catch (error) {
      console.error("Erreur chargement dashboard:", error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadDashboard();
  }, [loadDashboard]);

  useEffect(() => {
    const subscription = AppState.addEventListener("change", (state) => {
      if (state === "active") loadDashboard();
    });
    return () => subscription.remove();
  }, [loadDashboard]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadDashboard();
    setRefreshing(false);
  };

  const riskColor = aiAdvice ? getRiskColor(aiAdvice.risque_global) : null;

  return (
    <SafeAreaView style={styles.container} edges={["top"]}>
      <ScrollView
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>
              {authState.user?.name?.split(" ")[0] || "Utilisateur"}
            </Text>
            <Text style={styles.date}>
              {new Date().toLocaleDateString("fr-FR", {
                weekday: "long",
                day: "numeric",
                month: "long",
              })}
            </Text>
          </View>
          <TouchableOpacity onPress={() => navigation.navigate("NotificationsTab")} style={styles.notifButton}>
            <Ionicons name="notifications-outline" size={24} color={theme.colors.textDark} />
            {alerts.length > 0 && (
              <View style={styles.badge}>
                <Text style={styles.badgeText}>{alerts.length}</Text>
              </View>
            )}
          </TouchableOpacity>
        </View>

        {/* Risk Banner */}
        {aiAdvice ? (
          <TouchableOpacity
            style={[styles.riskBanner, { backgroundColor: riskColor }]}
            onPress={() => navigation.navigate("AITab")}
            activeOpacity={0.9}
          >
            <View style={styles.riskBannerContent}>
              <View style={styles.riskBannerLeft}>
                <Text style={styles.riskBannerLabel}>Risque cyclonique</Text>
                <Text style={styles.riskBannerLevel}>{aiAdvice.risque_global?.toUpperCase()}</Text>
                <Text style={styles.riskBannerResume} numberOfLines={1}>{aiAdvice.resume}</Text>
              </View>
              <View style={styles.riskBannerRight}>
                <Ionicons name="warning" size={32} color="rgba(255,255,255,0.9)" />
              </View>
            </View>
          </TouchableOpacity>
        ) : (
          <Card style={styles.riskBannerPlaceholder} shadow="sm">
            <View style={styles.riskBannerContent}>
              <View style={styles.riskBannerLeft}>
                <Text style={styles.riskBannerLabel}>Risque cyclonique</Text>
                <Text style={styles.riskBannerLevelMuted}>EN ATTENTE</Text>
                <Text style={styles.riskBannerResume}>Analyse en cours...</Text>
              </View>
              <View style={styles.riskBannerRight}>
                <Ionicons name="time-outline" size={28} color={theme.colors.textMuted} />
              </View>
            </View>
          </Card>
        )}

        {/* Stats Row */}
        <View style={styles.statsRow}>
          <TouchableOpacity style={styles.statCard} onPress={() => navigation.navigate("AlertsTab")}>
            <Ionicons name="warning-outline" size={20} color={theme.colors.info} />
            <Text style={styles.statNumber}>{stats.cyclones}</Text>
            <Text style={styles.statLabel}>Cyclones</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.statCard} onPress={() => navigation.navigate("IncidentsTab")}>
            <Ionicons name="alert-circle-outline" size={20} color={theme.colors.warning} />
            <Text style={styles.statNumber}>{stats.incidents}</Text>
            <Text style={styles.statLabel}>Incidents</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.statCard} onPress={() => navigation.navigate("SheltersTab")}>
            <Ionicons name="home-outline" size={20} color={theme.colors.primary} />
            <Text style={styles.statNumber}>{stats.shelters}</Text>
            <Text style={styles.statLabel}>Abris</Text>
          </TouchableOpacity>
        </View>

        {/* Quick Actions Grid */}
        <Text style={styles.sectionLabel}>Accès rapide</Text>
        <View style={styles.quickGrid}>
          <TouchableOpacity style={styles.quickItem} onPress={() => navigation.navigate("CycloneMap")}>
            <View style={[styles.quickIconWrap, { backgroundColor: "#e0f2fe" }]}>
              <Ionicons name="map-outline" size={24} color={theme.colors.info} />
            </View>
            <Text style={styles.quickItemLabel}>Carte</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.quickItem} onPress={() => navigation.navigate("AITab")}>
            <View style={[styles.quickIconWrap, { backgroundColor: theme.colors.primaryLight }]}>
              <Ionicons name="hardware-chip-outline" size={24} color={theme.colors.primary} />
            </View>
            <Text style={styles.quickItemLabel}>IA Conseil</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.quickItem} onPress={() => navigation.navigate("EvacuationTab")}>
            <View style={[styles.quickIconWrap, { backgroundColor: "#fef3c7" }]}>
              <Ionicons name="navigate-outline" size={24} color={theme.colors.warning} />
            </View>
            <Text style={styles.quickItemLabel}>Évacuation</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.quickItem} onPress={() => navigation.navigate("Simulations")}>
            <View style={[styles.quickIconWrap, { backgroundColor: "#f3e8ff" }]}>
              <Ionicons name="pulse-outline" size={24} color="#7c3aed" />
            </View>
            <Text style={styles.quickItemLabel}>Simulations</Text>
          </TouchableOpacity>
        </View>

        {/* Weather + AI combined row */}
        <View style={styles.doubleRow}>
          {weather && (
            <View style={styles.weatherMini}>
              <View style={styles.weatherMiniHeader}>
                <Ionicons name="cloud-outline" size={16} color={theme.colors.textMuted} />
                <Text style={styles.weatherMiniTemp}>{weather.temp}°</Text>
              </View>
              <Text style={styles.weatherMiniDesc}>{weather.description}</Text>
              <View style={styles.weatherMiniDetails}>
                <Text style={styles.weatherMiniDetail}>{weather.humidity}%</Text>
                <Text style={styles.weatherMiniDot}>·</Text>
                <Text style={styles.weatherMiniDetail}>{weather.windSpeed} km/h</Text>
              </View>
            </View>
          )}
          {aiAdvice?.recommandations_public?.length > 0 && (
            <View style={styles.recMini}>
              <View style={styles.recMiniHeader}>
                <Text style={styles.recMiniLabel}>💡 Conseil IA</Text>
              </View>
              <Text style={styles.recMiniText} numberOfLines={2}>{aiAdvice.recommandations_public[0]}</Text>
            </View>
          )}
        </View>

        {/* Recent Alerts */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionLabel}>Alertes récentes</Text>
          <TouchableOpacity onPress={() => navigation.navigate("AlertsTab")}>
            <Text style={styles.sectionLink}>Voir tout</Text>
          </TouchableOpacity>
        </View>
        {alerts.length === 0 ? (
          <Card style={styles.emptyCard} shadow="sm">
            <Ionicons name="checkmark-circle-outline" size={32} color={theme.colors.primary} />
            <Text style={styles.emptyText}>Aucune alerte récente</Text>
          </Card>
        ) : (
          alerts.slice(0, 3).map((alert) => (
            <TouchableOpacity
              key={alert.id}
              onPress={() => navigation.navigate("AlertDetail", { alertId: alert.id })}
            >
              <View style={styles.alertRow}>
                <View style={[styles.alertDot, {
                  backgroundColor: alert.level === "urgence" ? "#dc2626"
                    : alert.level === "alerte" ? "#f59e0b"
                    : "#3b82f6"
                }]} />
                <View style={styles.alertRowInfo}>
                  <Text style={styles.alertRowTitle} numberOfLines={1}>{alert.zone_name || alert.title}</Text>
                  <Text style={styles.alertRowTime}>
                    {new Date(alert.emitted_at || Date.now()).toLocaleDateString("fr-FR", {
                      hour: "2-digit", minute: "2-digit", day: "numeric", month: "short"
                    })}
                  </Text>
                </View>
                <Ionicons name="chevron-forward" size={16} color={theme.colors.textMuted} />
              </View>
            </TouchableOpacity>
          ))
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
    paddingBottom: theme.spacing.xl * 2,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: theme.spacing.lg,
    paddingTop: theme.spacing.md,
    paddingBottom: theme.spacing.md,
  },
  greeting: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  date: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  notifButton: {
    position: "relative",
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.bgGray,
    justifyContent: "center",
    alignItems: "center",
  },
  badge: {
    position: "absolute",
    top: -2,
    right: -2,
    backgroundColor: theme.colors.danger,
    borderRadius: 10,
    width: 20,
    height: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  badgeText: {
    color: "white",
    fontSize: 10,
    fontWeight: "700",
  },
  riskBanner: {
    marginHorizontal: theme.spacing.lg,
    borderRadius: theme.borderRadius.lg,
    overflow: "hidden",
  },
  riskBannerPlaceholder: {
    marginHorizontal: theme.spacing.lg,
    borderRadius: theme.borderRadius.lg,
  },
  riskBannerContent: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: theme.spacing.lg,
  },
  riskBannerLeft: {
    flex: 1,
    marginRight: theme.spacing.md,
  },
  riskBannerLabel: {
    fontSize: 12,
    fontWeight: "600",
    color: "rgba(255,255,255,0.8)",
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  riskBannerLevel: {
    fontSize: 32,
    fontWeight: "800",
    color: "white",
    marginTop: 2,
    letterSpacing: 1,
  },
  riskBannerLevelMuted: {
    fontSize: 32,
    fontWeight: "800",
    color: theme.colors.textMuted,
    marginTop: 2,
    letterSpacing: 1,
  },
  riskBannerResume: {
    fontSize: 13,
    color: "rgba(255,255,255,0.9)",
    marginTop: 4,
  },
  riskBannerRight: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: "rgba(255,255,255,0.15)",
    justifyContent: "center",
    alignItems: "center",
  },
  statsRow: {
    flexDirection: "row",
    gap: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.md,
  },
  statCard: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    alignItems: "center",
    gap: 4,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  statLabel: {
    fontSize: 10,
    fontWeight: "600",
    color: theme.colors.textGray,
    textTransform: "uppercase",
    letterSpacing: 0.3,
  },
  sectionLabel: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
    paddingHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.lg,
    marginBottom: theme.spacing.sm,
  },
  quickGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    paddingHorizontal: theme.spacing.lg,
    gap: theme.spacing.sm,
  },
  quickItem: {
    width: "48%",
    backgroundColor: theme.colors.bgWhite,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
    padding: theme.spacing.md,
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
  },
  quickIconWrap: {
    width: 44,
    height: 44,
    borderRadius: theme.borderRadius.md,
    justifyContent: "center",
    alignItems: "center",
  },
  quickItemLabel: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  doubleRow: {
    flexDirection: "row",
    gap: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.md,
  },
  weatherMini: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    borderWidth: 1,
    borderColor: theme.colors.borderLight,
  },
  weatherMiniHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  weatherMiniTemp: {
    fontSize: 22,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  weatherMiniDesc: {
    fontSize: 12,
    color: theme.colors.textGray,
    marginTop: 2,
    textTransform: "capitalize",
  },
  weatherMiniDetails: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    marginTop: 6,
  },
  weatherMiniDetail: {
    fontSize: 11,
    color: theme.colors.textMuted,
  },
  weatherMiniDot: {
    fontSize: 11,
    color: theme.colors.textMuted,
  },
  recMini: {
    flex: 1,
    backgroundColor: theme.colors.primaryLight,
    borderRadius: theme.borderRadius.md,
    padding: theme.spacing.md,
    borderWidth: 1,
    borderColor: theme.colors.primary,
  },
  recMiniHeader: {
    marginBottom: 4,
  },
  recMiniLabel: {
    fontSize: 11,
    fontWeight: "700",
    color: theme.colors.primaryDark,
  },
  recMiniText: {
    fontSize: 12,
    color: theme.colors.textDark,
    lineHeight: 17,
  },
  sectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.lg,
    marginBottom: theme.spacing.sm,
  },
  sectionLink: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.primary,
    fontWeight: "600",
  },
  emptyCard: {
    marginHorizontal: theme.spacing.lg,
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
    padding: theme.spacing.lg,
  },
  emptyText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
  },
  alertRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
    marginHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  alertDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  alertRowInfo: {
    flex: 1,
  },
  alertRowTitle: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  alertRowTime: {
    fontSize: 11,
    color: theme.colors.textMuted,
    marginTop: 2,
  },
});

export default DashboardScreen;
