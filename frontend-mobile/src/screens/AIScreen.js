import React, { useState, useEffect, useCallback, useRef } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
  Animated,
  Vibration,
  Linking,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";
import Button from "../components/Button";

const AIScreen = ({ navigation }) => {
  const [analysis, setAnalysis] = useState(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState(null);
  const [criticalAlert, setCriticalAlert] = useState(false);
  const [alertMessage, setAlertMessage] = useState("");
  const [alertTitle, setAlertTitle] = useState("");
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const alertTimerRef = useRef(null);

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

  const checkCriticalAlert = useCallback((data) => {
    if (!data) return;
    const isCritique = data.risque_global === "critique";
    const hasUrgence = data.alertes_generees?.some(a => a.niveau === "urgence");
    if (isCritique || hasUrgence) {
      const msg = data.resume || (hasUrgence ? "Alerte urgence détectée" : "Risque critique détecté");
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

  const loadAnalysis = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const [alertsRes, incidentsRes, sheltersRes] = await Promise.all([
        api.getAlerts({ type: "cyclone", active: true, limit: 10 }),
        api.getIncidents({ type: "cyclone", limit: 10 }),
        api.getShelters({ available: true, limit: 10 }),
      ]);

      const cyclones = (alertsRes.data?.alerts || []).map((a) => ({
        lat: a.center_lat || a.lat || -18.9078,
        lng: a.center_lng || a.lng || 47.5208,
        title: a.zone_name || a.title || "Système cyclonique",
        level: a.level || "vigilance",
        wind_speed: a.features_input?.wind_speed || null,
        pressure: a.features_input?.pressure || null,
      }));

      const incidents = (incidentsRes.data?.incidents || []).map((i) => ({
        lat: i.location_lat || i.lat || -18.9078,
        lng: i.location_lng || i.lng || 47.5208,
        title: i.title || "Incident",
        description: i.description || "",
        status: i.status || "signalé",
      }));

      const shelters = (sheltersRes.data?.shelters || []).map((s) => ({
        lat: s.location_lat || s.lat || -18.9078,
        lng: s.location_lng || s.lng || 47.5208,
        name: s.name || "Abri",
        capacity: s.capacity || 0,
        current_occupancy: s.current_occupancy || 0,
        has_medical: !!s.has_medical_facilities,
        has_food: !!s.has_food,
        has_water: !!s.has_water,
      }));

      const response = await api.getAIAnalysis({
        cyclones,
        incidents,
        shelters,
      });

      const advice = response.data?.data || response.data;
      setAnalysis(advice);
      checkCriticalAlert(advice);
    } catch (err) {
      console.error("Erreur analyse IA:", err);
      setError("Impossible de contacter le conseiller IA");
    } finally {
      setLoading(false);
    }
  }, [checkCriticalAlert]);

  useEffect(() => {
    loadAnalysis();
  }, [loadAnalysis]);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadAnalysis();
    setRefreshing(false);
  };

  const getRiskColor = (risk) => {
    const map = {
      faible: theme.colors.success || "#10b981",
      modéré: theme.colors.warning || "#f59e0b",
      élevé: theme.colors.danger || "#ea580c",
      critique: "#dc2626",
    };
    return map[risk] || theme.colors.warning;
  };

  const getRiskIcon = (risk) => {
    const map = {
      faible: "checkmark-circle",
      modéré: "warning",
      élevé: "warning",
      critique: "close-circle",
    };
    return map[risk] || "warning";
  };

  const getLevelColor = (level) => {
    const map = {
      info: "#3b82f6",
      vigilance: "#f59e0b",
      alerte: "#ea580c",
      urgence: "#dc2626",
    };
    return map[level] || "#6b7280";
  };

  if (loading && !refreshing) {
    return (
      <SafeAreaView style={styles.container} edges={["bottom"]}>
        <View style={styles.loadingContainer}>
          <View style={styles.aiIconLarge}>
            <Ionicons name="hardware-chip-outline" size={40} color={theme.colors.primary} />
          </View>
          <ActivityIndicator size="large" color={theme.colors.primary} style={{ marginTop: 16 }} />
          <Text style={styles.loadingText}>Conseiller IA Gemini</Text>
          <Text style={styles.loadingSubtext}>Analyse des données cycloniques en cours...</Text>
        </View>
      </SafeAreaView>
    );
  }

  const riskColor = getRiskColor(analysis?.risque_global);
  const riskIcon = getRiskIcon(analysis?.risque_global);

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
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
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.aiIcon}>
            <Ionicons name="hardware-chip-outline" size={24} color={theme.colors.primary} />
          </View>
          <View>
            <Text style={styles.title}>Conseiller IA</Text>
            <Text style={styles.subtitle}>Analyse cyclonique par Google Gemini</Text>
          </View>
        </View>

        {error ? (
          <Card style={styles.errorCard}>
            <View style={styles.errorContent}>
              <Ionicons name="cloud-offline-outline" size={32} color={theme.colors.danger} />
              <Text style={styles.errorText}>{error}</Text>
              <Button title="Réessayer" variant="outline" size="small" onPress={loadAnalysis} />
            </View>
          </Card>
        ) : null}

        {analysis && (
          <>
            {/* Risk Global */}
            <Card style={[styles.riskCard, { borderLeftColor: riskColor }]}>
              <View style={styles.riskHeader}>
                <Ionicons name={riskIcon} size={28} color={riskColor} />
                <View style={styles.riskInfo}>
                  <Text style={[styles.riskLevel, { color: riskColor }]}>
                    {analysis.risque_global === "faible" && !analysis.analyse_cyclones?.length
                      ? "RIEN À SIGNALER"
                      : `Risque ${analysis.risque_global?.toUpperCase() || "NON DÉFINI"}`}
                  </Text>
                  <Text style={styles.riskLabel}>Risque cyclonique global</Text>
                </View>
              </View>
              <Text style={styles.resumeText}>{analysis.resume || ""}</Text>
            </Card>

            {/* Cyclones Analysis */}
            {analysis.analyse_cyclones?.length > 0 && (
              <View style={styles.section}>
                <View style={{ flexDirection: "row", alignItems: "center", gap: 6, marginBottom: theme.spacing.md }}>
                  <Ionicons name="warning-outline" size={16} color={theme.colors.textDark} />
                  <Text style={styles.sectionTitle}>Analyse par cyclone</Text>
                </View>
                {analysis.analyse_cyclones.map((c, idx) => {
                  const riskC = getRiskColor(c.risque);
                  return (
                    <Card key={idx} style={styles.cycloneCard} shadow="sm">
                      <View style={styles.cycloneHeader}>
                        <Text style={styles.cycloneName}>{c.nom || `Cyclone #${idx + 1}`}</Text>
                        <View style={[styles.riskBadge, { backgroundColor: riskC + "20" }]}>
                          <Text style={[styles.riskBadgeText, { color: riskC }]}>{c.risque?.toUpperCase()}</Text>
                        </View>
                      </View>
                      {c.vitesse_vent_estimee_kmh != null ? (
                        <View style={styles.cycloneDetail}>
                          <Ionicons name="speedometer-outline" size={14} color={theme.colors.textGray} />
                          <Text style={styles.cycloneDetailText}>Vent: {c.vitesse_vent_estimee_kmh} km/h</Text>
                        </View>
                      ) : null}
                      {c.direction ? (
                        <View style={styles.cycloneDetail}>
                          <Ionicons name="compass-outline" size={14} color={theme.colors.textGray} />
                          <Text style={styles.cycloneDetailText}>Trajectoire: {c.direction}</Text>
                        </View>
                      ) : null}
                      {c.zones_menacees?.length > 0 && (
                        <View style={styles.cycloneDetail}>
                          <Ionicons name="location-outline" size={14} color={theme.colors.textGray} />
                          <Text style={styles.cycloneDetailText}>Zones: {c.zones_menacees.join(", ")}</Text>
                        </View>
                      )}
                      {c.recommandation ? (
                        <View style={styles.recommandBadge}>
                          <Ionicons name="bulb-outline" size={14} color={theme.colors.primary} />
                          <Text style={styles.recommandText}>{c.recommandation}</Text>
                        </View>
                      ) : null}
                    </Card>
                  );
                })}
              </View>
            )}

            {/* Empty state */}
            {(!analysis.analyse_cyclones || analysis.analyse_cyclones.length === 0) && (
              <Card style={styles.emptyCard}>
                <View style={styles.emptyContent}>
                  <Ionicons name="shield-checkmark-outline" size={40} color={theme.colors.success || "#10b981"} />
                  <Text style={styles.emptyTitle}>Aucun cyclone actif</Text>
                  <Text style={styles.emptyText}>Aucun système cyclonique actif détecté à Madagascar. La situation est calme.</Text>
                </View>
              </Card>
            )}

            {/* Recommendations */}
            {analysis.recommandations_public?.length > 0 && (
              <View style={styles.section}>
                <View style={{ flexDirection: "row", alignItems: "center", gap: 6, marginBottom: theme.spacing.md }}>
                  <Ionicons name="bulb-outline" size={16} color="#f59e0b" />
                  <Text style={styles.sectionTitle}>Recommandations</Text>
                </View>
                <Card shadow="sm">
                  {analysis.recommandations_public.map((rec, idx) => (
                    <View key={idx} style={styles.recommendItem}>
                      <Ionicons name="checkmark-circle" size={18} color={theme.colors.primary} />
                      <Text style={styles.recommendText}>{rec}</Text>
                    </View>
                  ))}
                </Card>
              </View>
            )}

            {/* Generated Alerts */}
            {analysis.alertes_generees?.length > 0 && (
              <View style={styles.section}>
                <View style={{ flexDirection: "row", alignItems: "center", gap: 6, marginBottom: theme.spacing.md }}>
                  <Ionicons name="notifications-outline" size={16} color="#dc2626" />
                  <Text style={styles.sectionTitle}>Alertes générées</Text>
                </View>
                {analysis.alertes_generees.map((a, idx) => {
                  const lvlColor = getLevelColor(a.niveau);
                  return (
                    <Card key={idx} style={[styles.alertCard, { borderLeftColor: lvlColor }]} shadow="sm">
                      <View style={styles.alertHeader}>
                        <View style={[styles.alertLevelBadge, { backgroundColor: lvlColor }]}>
                          <Text style={styles.alertLevelText}>{a.niveau?.toUpperCase()}</Text>
                        </View>
                      </View>
                      <Text style={styles.alertTitle}>{a.titre || "Alerte"}</Text>
                      <Text style={styles.alertMessage}>{a.message || ""}</Text>
                      {a.zone_concernee ? (
                        <Text style={styles.alertZone}>📍 {a.zone_concernee}</Text>
                      ) : null}
                    </Card>
                  );
                })}
              </View>
            )}

            {/* Evacuation Advice */}
            {analysis.conseils_evacuation ? (
              <View style={styles.section}>
                <View style={{ flexDirection: "row", alignItems: "center", gap: 6, marginBottom: theme.spacing.md }}>
                  <Ionicons name="car-outline" size={16} color="#3b82f6" />
                  <Text style={styles.sectionTitle}>Évacuation</Text>
                </View>
                <Card style={styles.evacuationCard}>
                  <Ionicons name="information-circle-outline" size={20} color="#3b82f6" />
                  <Text style={styles.evacuationText}>{analysis.conseils_evacuation}</Text>
                </Card>
              </View>
            ) : null}

            {/* Timestamp */}
            {analysis.timestamp_analyse ? (
              <Text style={styles.timestamp}>🕐 Analyse: {analysis.timestamp_analyse}</Text>
            ) : null}

            {/* Refresh Button */}
            <Button
              title="Mettre à jour l'analyse"
              variant="outline"
              onPress={loadAnalysis}
              icon="refresh-outline"
              style={styles.refreshButton}
              loading={loading}
            />

            {/* Simulation Button */}
            <Button
              title="Simulations de trajectoire"
              onPress={() => navigation.navigate("Simulations")}
              icon="pulse-outline"
              style={styles.simButton}
            />
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
  aiIconLarge: {
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
  aiIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
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
  riskCard: {
    borderLeftWidth: 4,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.md,
  },
  riskHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
    marginBottom: theme.spacing.sm,
  },
  riskInfo: {
    flex: 1,
  },
  riskLevel: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "800",
  },
  riskLabel: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
  },
  resumeText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    lineHeight: 20,
  },
  section: {
    marginBottom: theme.spacing.lg,
  },
  sectionTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  cycloneCard: {
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
  },
  cycloneHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: theme.spacing.sm,
  },
  cycloneName: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  riskBadge: {
    paddingHorizontal: theme.spacing.sm,
    paddingVertical: 2,
    borderRadius: theme.borderRadius.sm,
  },
  riskBadgeText: {
    fontSize: 10,
    fontWeight: "800",
  },
  cycloneDetail: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.xs,
    marginBottom: 4,
  },
  cycloneDetailText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
  },
  recommandBadge: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: theme.spacing.xs,
    backgroundColor: theme.colors.primaryLight,
    borderRadius: theme.borderRadius.sm,
    padding: theme.spacing.sm,
    marginTop: theme.spacing.sm,
  },
  recommandText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.primary,
    flex: 1,
  },
  recommendItem: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: theme.spacing.sm,
    paddingVertical: theme.spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  recommendText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    flex: 1,
    lineHeight: 20,
  },
  alertCard: {
    borderLeftWidth: 4,
    padding: theme.spacing.md,
    marginBottom: theme.spacing.sm,
  },
  alertHeader: {
    flexDirection: "row",
    marginBottom: theme.spacing.xs,
  },
  alertLevelBadge: {
    paddingHorizontal: theme.spacing.sm,
    paddingVertical: 2,
    borderRadius: theme.borderRadius.sm,
  },
  alertLevelText: {
    fontSize: 9,
    fontWeight: "800",
    color: "white",
  },
  alertTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "600",
    color: theme.colors.textDark,
    marginBottom: 2,
  },
  alertMessage: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    lineHeight: 18,
  },
  alertZone: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    marginTop: theme.spacing.xs,
  },
  evacuationCard: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: theme.spacing.md,
    padding: theme.spacing.md,
    backgroundColor: "#eff6ff",
    borderColor: "#bfdbfe",
  },
  evacuationText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    flex: 1,
    lineHeight: 20,
  },
  timestamp: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    textAlign: "right",
    marginBottom: theme.spacing.md,
  },
  refreshButton: {
    marginTop: theme.spacing.sm,
  },
  simButton: {
    marginTop: theme.spacing.md,
    backgroundColor: "#7c3aed",
  },
  emptyCard: {
    padding: theme.spacing.lg,
    marginBottom: theme.spacing.md,
    alignItems: "center",
  },
  emptyContent: {
    alignItems: "center",
    gap: theme.spacing.sm,
  },
  emptyTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.success || "#10b981",
  },
  emptyText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
    lineHeight: 20,
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

export default AIScreen;
