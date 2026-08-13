import React, { useState, useEffect } from "react";
import {
  View,
  StyleSheet,
  ScrollView,
  Text,
  ActivityIndicator,
  TouchableOpacity,
  Alert as RNAlert,
  Linking,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";
import Button from "../components/Button";

const AlertDetailScreen = ({ route, navigation }) => {
  const { alertId } = route.params;
  const [alert, setAlert] = useState(null);
  const [loading, setLoading] = useState(true);
  const [confirming, setConfirming] = useState(false);

  useEffect(() => {
    loadAlert();
  }, []);

  const loadAlert = async () => {
    try {
      setLoading(true);
      const response = await api.getAlertById(alertId);
      setAlert(response.data);
    } catch (error) {
      RNAlert.alert("Erreur", "Impossible de charger l'alerte");
    } finally {
      setLoading(false);
    }
  };

  const handleAcknowledge = async () => {
    try {
      setConfirming(true);
      await api.acknowledgeAlert(alertId);
      setAlert((prev) => ({ ...prev, acknowledged: true }));
      RNAlert.alert("Succès", "Alerte confirmée");
    } catch (error) {
      RNAlert.alert("Erreur", "Impossible de confirmer l'alerte");
    } finally {
      setConfirming(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  if (!alert) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Ionicons name="alert-circle" size={48} color={theme.colors.danger} />
          <Text style={styles.errorText}>Alerte introuvable</Text>
        </View>
      </SafeAreaView>
    );
  }

  const renderShelter = (shelter) => (
    <Card key={shelter.id} style={styles.shelterCard} shadow="sm">
      <View style={styles.shelterContent}>
        <View style={styles.shelterInfo}>
          <Text style={styles.shelterName}>{shelter.name}</Text>
          <Text style={styles.shelterDistance}>{`${(shelter.distance / 1000).toFixed(1)} km`}</Text>
        </View>
        <TouchableOpacity style={styles.navigateButton}>
          <Ionicons name="navigate" size={22} color={theme.colors.primary} />
        </TouchableOpacity>
      </View>
    </Card>
  );

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <Card style={styles.statusCard} shadow="sm">
          <View style={styles.statusHeader}>
            <View style={[styles.statusBadge, { backgroundColor: alert.acknowledged ? theme.colors.primary : theme.colors.danger }]}>
              <Ionicons name={alert.acknowledged ? "checkmark-circle" : "warning"} size={24} color="white" />
            </View>
            <View style={styles.statusInfo}>
              <Text style={styles.statusTitle}>{alert.acknowledged ? "Confirmée" : "Active"}</Text>
              <Text style={styles.statusTime}>
                {new Date(alert.createdAt).toLocaleString("fr-FR", {
                  year: "numeric", month: "long", day: "numeric",
                  hour: "2-digit", minute: "2-digit",
                })}
              </Text>
            </View>
          </View>
        </Card>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Localisation</Text>
          <Card shadow="sm">
            <View style={styles.locationRow}>
              <View style={styles.locationIcon}>
                <Ionicons name="location" size={20} color={theme.colors.primary} />
              </View>
              <View style={styles.locationInfo}>
                <Text style={styles.locationName}>{alert.location}</Text>
                <Text style={styles.coordinates}>
                  {alert.latitude ? alert.latitude.toFixed(4) : "N/A"},{" "}
                  {alert.longitude ? alert.longitude.toFixed(4) : "N/A"}
                </Text>
              </View>
            </View>
          </Card>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Informations</Text>
          <Card shadow="sm">
            <View style={styles.infoGrid}>
              {[
                { label: "Confiance", value: alert.confidence ? `${Math.round(alert.confidence * 100)}%` : "N/A" },
                { label: "Température", value: alert.temperature ? `${alert.temperature}°C` : "N/A" },
                { label: "Type", value: alert.type || "Feu" },
                { label: "Sévérité", value: alert.severity === "critical" ? "CRITIQUE" : "Élevé", isDanger: alert.severity === "critical" },
              ].map((item, idx) => (
                <View key={idx} style={styles.infoCell}>
                  <Text style={styles.infoLabel}>{item.label}</Text>
                  <Text style={[styles.infoValue, item.isDanger && { color: theme.colors.danger }]}>
                    {item.value}
                  </Text>
                </View>
              ))}
            </View>
          </Card>
        </View>

        {alert.observations ? (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Observations</Text>
            <Card shadow="sm">
              <Text style={styles.observationsText}>{alert.observations}</Text>
            </Card>
          </View>
        ) : null}

        {alert.detectedSources?.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Sources</Text>
            {alert.detectedSources.slice(0, 3).map((source, idx) => (
              <Card key={idx} style={styles.sourceCard} shadow="sm">
                <View style={styles.sourceRow}>
                  <Ionicons name="eye-outline" size={16} color={theme.colors.primary} />
                  <Text style={styles.sourceText}>{source.name || `Source ${idx + 1}`}</Text>
                </View>
                {source.url ? (
                  <TouchableOpacity onPress={() => Linking.openURL(source.url)}>
                    <Text style={styles.sourceLink}>Voir</Text>
                  </TouchableOpacity>
                ) : null}
              </Card>
            ))}
          </View>
        )}

        {alert.nearbyShelters?.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Refuges à proximité</Text>
            {alert.nearbyShelters.slice(0, 3).map(renderShelter)}
          </View>
        )}

        {!alert.acknowledged && (
          <View style={styles.actionsContainer}>
            <Button
              title="Confirmer l'alerte"
              onPress={handleAcknowledge}
              loading={confirming}
              icon="checkmark"
              size="large"
            />
          </View>
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
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: theme.colors.bgWhite,
  },
  errorContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: theme.spacing.xl,
  },
  errorText: {
    marginTop: theme.spacing.md,
    fontSize: theme.typography.fontSize.lg,
    color: theme.colors.textGray,
    textAlign: "center",
  },
  statusCard: {
    margin: theme.spacing.lg,
    marginTop: theme.spacing.md,
  },
  statusHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
  },
  statusBadge: {
    width: 48,
    height: 48,
    borderRadius: theme.borderRadius.full,
    justifyContent: "center",
    alignItems: "center",
  },
  statusInfo: {
    flex: 1,
  },
  statusTitle: {
    fontSize: theme.typography.fontSize.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  statusTime: {
    fontSize: theme.typography.fontSize.sm,
    color: theme.colors.textGray,
    marginTop: 4,
  },
  section: {
    paddingHorizontal: theme.spacing.lg,
    marginBottom: theme.spacing.lg,
  },
  sectionTitle: {
    fontSize: theme.typography.fontSize.base,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.sm,
  },
  locationRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.md,
  },
  locationIcon: {
    width: 40,
    height: 40,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
  },
  locationInfo: {
    flex: 1,
  },
  locationName: {
    fontSize: theme.typography.fontSize.base,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  coordinates: {
    fontSize: theme.typography.fontSize.sm,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  infoGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
  },
  infoCell: {
    width: "50%",
    paddingVertical: theme.spacing.sm,
  },
  infoLabel: {
    fontSize: theme.typography.fontSize.xs,
    color: theme.colors.textGray,
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  infoValue: {
    fontSize: theme.typography.fontSize.base,
    fontWeight: "600",
    color: theme.colors.textDark,
    marginTop: 4,
  },
  observationsText: {
    fontSize: theme.typography.fontSize.base,
    color: theme.colors.textDark,
    lineHeight: 24,
  },
  sourceCard: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: theme.spacing.sm,
  },
  sourceRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
  },
  sourceText: {
    fontSize: theme.typography.fontSize.sm,
    fontWeight: "500",
    color: theme.colors.textDark,
  },
  sourceLink: {
    fontSize: theme.typography.fontSize.sm,
    color: theme.colors.primary,
    fontWeight: "600",
  },
  shelterCard: {
    marginBottom: theme.spacing.sm,
  },
  shelterContent: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  shelterInfo: {
    flex: 1,
  },
  shelterName: {
    fontSize: theme.typography.fontSize.base,
    fontWeight: "600",
    color: theme.colors.textDark,
  },
  shelterDistance: {
    fontSize: theme.typography.fontSize.sm,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  navigateButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
  },
  actionsContainer: {
    padding: theme.spacing.lg,
    paddingBottom: theme.spacing.xl * 2,
  },
});

export default AlertDetailScreen;
