import React, { useState, useEffect } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  Modal,
  RefreshControl,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";
import Button from "../components/Button";
import Input from "../components/Input";

const INCIDENT_TYPES = [
  { id: "fire", label: "Feu / Incendie", icon: "flame" },
  { id: "flood", label: "Inondation", icon: "water" },
  { id: "storm", label: "Tempête / Cyclone", icon: "thunderstorm" },
  { id: "other", label: "Autre Danger", icon: "warning" },
];

const IncidentsScreen = () => {
  const [incidents, setIncidents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [alarmActive, setAlarmActive] = useState(true);

  const [formType, setFormType] = useState("fire");
  const [formLocation, setFormLocation] = useState("");
  const [formDescription, setFormDescription] = useState("");

  const userLat = -18.9078;
  const userLng = 47.5208;

  useEffect(() => {
    fetchIncidents();
  }, []);

  const fetchIncidents = async () => {
    try {
      setLoading(true);
      const res = await api.getIncidents();
      setIncidents(res.data?.incidents || []);
    } catch (err) {
      console.error("Erreur récupération incidents:", err);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchIncidents();
    setRefreshing(false);
  };

  const handleSubmitIncident = async () => {
    if (!formLocation.trim() || !formDescription.trim()) {
      Alert.alert("Champs requis", "Veuillez renseigner le lieu et la description.");
      return;
    }
    if (formDescription.trim().length < 10) {
      Alert.alert("Description trop courte", "La description doit faire au moins 10 caractères.");
      return;
    }

    try {
      setSubmitting(true);
      let dbType = "incendie";
      if (formType === "flood") dbType = "inondation";
      else if (formType === "storm") dbType = "cyclone";

      const payload = {
        title: `${formType === "fire" ? "Incendie" : formType === "flood" ? "Inondation" : formType === "storm" ? "Cyclone" : "Danger"} à ${formLocation}`,
        type: dbType,
        description: formDescription,
        lat: userLat,
        lng: userLng,
      };

      await api.reportIncident(payload);
      Alert.alert("Signalement envoyé", "Merci pour votre contribution. Les secours ont été notifiés.");
      setFormLocation("");
      setFormDescription("");
      setFormType("fire");
      setModalVisible(false);
      fetchIncidents();
    } catch (err) {
      Alert.alert("Erreur", "Impossible de transmettre le signalement.");
    } finally {
      setSubmitting(false);
    }
  };

  const getIncidentTypeColor = (type) => {
    switch (type) {
      case "fire": case "incendie": return theme.colors.danger;
      case "flood": case "inondation": return theme.colors.info;
      case "storm": case "cyclone": return "#7c3aed";
      default: return theme.colors.warning;
    }
  };

  const getIncidentTypeLabel = (type) => {
    switch (type) {
      case "fire": case "incendie": return "Incendie";
      case "flood": case "inondation": return "Inondation";
      case "storm": case "cyclone": return "Cyclone";
      default: return "Danger";
    }
  };

  return (
    <SafeAreaView style={styles.container} edges={["top"]}>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Incidents</Text>
          <Text style={styles.subtitle}>Signalez ou consultez les dangers en temps réel</Text>
        </View>
        <TouchableOpacity style={styles.addButton} onPress={() => setModalVisible(true)}>
          <Ionicons name="add" size={24} color="white" />
        </TouchableOpacity>
      </View>

      {incidents.some(i => i.status !== 'resolu') && alarmActive && (
        <View style={styles.alarmBanner}>
          <View style={styles.alarmBannerContent}>
            <Ionicons name="warning" size={20} color="#fff" />
            <Text style={styles.alarmBannerText}>
              Incidents non résolus — {incidents.filter(i => i.status !== 'resolu').length} actif(s)
            </Text>
          </View>
          <TouchableOpacity onPress={() => setAlarmActive(false)} style={styles.alarmDismiss}>
            <Ionicons name="close" size={20} color="#fff" />
          </TouchableOpacity>
        </View>
      )}

      {loading && !refreshing ? (
        <View style={styles.loaderContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
        </View>
      ) : (
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          showsVerticalScrollIndicator={false}
        >
          {incidents.length === 0 ? (
            <Card style={styles.emptyCard}>
              <Ionicons name="checkmark-circle-outline" size={60} color={theme.colors.primary} />
              <Text style={styles.emptyTitle}>Tout est calme</Text>
              <Text style={styles.emptySubtitle}>Aucun incident signalé récemment.</Text>
            </Card>
          ) : (
            incidents.map((item) => (
              <Card key={item.id} style={styles.incidentCard} shadow="sm">
                <View style={styles.incidentHeader}>
                  <View style={[styles.typeBadge, { backgroundColor: getIncidentTypeColor(item.type) }]}>
                    <Text style={styles.typeBadgeText}>{getIncidentTypeLabel(item.type)}</Text>
                  </View>
                  <Text style={styles.incidentDate}>
                    {new Date(item.reported_at || item.createdAt || Date.now()).toLocaleDateString("fr-FR", {
                      hour: "2-digit", minute: "2-digit",
                    })}
                  </Text>
                </View>
                <Text style={styles.incidentTitle}>{item.title}</Text>
                <Text style={styles.incidentDesc} numberOfLines={3}>{item.description}</Text>
                <View style={styles.incidentFooter}>
                  <View style={styles.locationContainer}>
                    <Ionicons name="pin" size={14} color={theme.colors.textGray} />
                    <Text style={styles.locationText}>Antananarivo</Text>
                  </View>
                  <View style={styles.statusBadge}>
                    <Text style={styles.statusText}>{item.status || "Signalé"}</Text>
                  </View>
                </View>
                {item.assigned_team && (
                  <View style={styles.teamRow}>
                    <Ionicons name="people" size={12} color={theme.colors.primaryDark} />
                    <Text style={styles.teamText}>Équipe: {item.assigned_team}</Text>
                  </View>
                )}
              </Card>
            ))
          )}
        </ScrollView>
      )}

      <Modal animationType="slide" transparent={true} visible={modalVisible} onRequestClose={() => setModalVisible(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Signaler un danger</Text>
              <TouchableOpacity onPress={() => setModalVisible(false)} style={styles.modalClose}>
                <Ionicons name="close" size={24} color={theme.colors.textDark} />
              </TouchableOpacity>
            </View>

            <ScrollView contentContainerStyle={styles.modalForm} showsVerticalScrollIndicator={false}>
              <Text style={styles.label}>Type de danger</Text>
              <View style={styles.typeSelector}>
                {INCIDENT_TYPES.map((type) => (
                  <TouchableOpacity
                    key={type.id}
                    style={[styles.typeButton, formType === type.id && { backgroundColor: getIncidentTypeColor(type.id) + "18", borderColor: getIncidentTypeColor(type.id) }]}
                    onPress={() => setFormType(type.id)}
                  >
                    <Ionicons name={type.icon} size={18} color={formType === type.id ? getIncidentTypeColor(type.id) : theme.colors.textGray} />
                    <Text style={[styles.typeButtonText, formType === type.id && { color: getIncidentTypeColor(type.id), fontWeight: "700" }]}>
                      {type.label}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Input
                label="Lieu / Quartier"
                placeholder="Ex: Ampandrana, Lot II Y 45"
                value={formLocation}
                onChangeText={setFormLocation}
                icon="location-outline"
              />

              <Input
                label="Description des faits"
                placeholder="Décrivez ce que vous observez (10 caractères min.)"
                value={formDescription}
                onChangeText={setFormDescription}
                multiline={true}
                numberOfLines={4}
              />

              <View style={styles.infoBanner}>
                <Ionicons name="information-circle" size={20} color={theme.colors.primary} />
                <Text style={styles.infoText}>Vos coordonnées GPS seront transmises pour guider les secours.</Text>
              </View>

              <Button title="Envoyer le signalement" onPress={handleSubmitIncident} loading={submitting} size="large" />
            </ScrollView>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  title: {
    fontSize: theme.typography.sizes.xxl,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  subtitle: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  addButton: {
    backgroundColor: theme.colors.danger,
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: "center",
    alignItems: "center",
  },
  loaderContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  scrollContent: {
    padding: theme.spacing.lg,
    paddingBottom: theme.spacing.xl,
  },
  emptyCard: {
    alignItems: "center",
    paddingVertical: 40,
    marginTop: 20,
  },
  emptyTitle: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginTop: theme.spacing.md,
  },
  emptySubtitle: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
    marginTop: theme.spacing.sm,
  },
  incidentCard: {
    marginBottom: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
  },
  incidentHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: theme.spacing.sm,
  },
  typeBadge: {
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 4,
    borderRadius: 12,
  },
  typeBadgeText: {
    color: "white",
    fontSize: theme.typography.sizes.xs,
    fontWeight: "700",
  },
  incidentDate: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
  },
  incidentTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: 6,
  },
  incidentDesc: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    lineHeight: 20,
    marginBottom: theme.spacing.md,
  },
  incidentFooter: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    borderTopWidth: 1,
    borderTopColor: theme.colors.borderLight,
    paddingTop: theme.spacing.sm,
  },
  locationContainer: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
  },
  locationText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    fontWeight: "500",
  },
  statusBadge: {
    backgroundColor: theme.colors.primaryLight,
    paddingHorizontal: theme.spacing.sm,
    paddingVertical: 2,
    borderRadius: 4,
  },
  statusText: {
    fontSize: 10,
    color: theme.colors.primaryDark,
    fontWeight: "700",
    textTransform: "uppercase",
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "flex-end",
  },
  modalContent: {
    backgroundColor: theme.colors.bgWhite,
    borderTopLeftRadius: theme.borderRadius.xl,
    borderTopRightRadius: theme.borderRadius.xl,
    maxHeight: "90%",
    padding: theme.spacing.lg,
  },
  modalHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: theme.spacing.xl,
  },
  modalTitle: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "800",
    color: theme.colors.textDark,
  },
  modalClose: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: theme.colors.bgGray,
    justifyContent: "center",
    alignItems: "center",
  },
  modalForm: {
    paddingBottom: 40,
  },
  label: {
    fontSize: theme.typography.sizes.xs,
    fontWeight: "700",
    textTransform: "uppercase",
    color: theme.colors.textGray,
    marginBottom: theme.spacing.sm,
  },
  typeSelector: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: theme.spacing.sm,
    marginBottom: theme.spacing.lg,
  },
  typeButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.xs,
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.bgGray,
  },
  typeButtonText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
  },
  infoBanner: {
    flexDirection: "row",
    backgroundColor: theme.colors.primaryLight,
    padding: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    alignItems: "center",
    gap: theme.spacing.sm,
    marginVertical: theme.spacing.lg,
  },
  infoText: {
    flex: 1,
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.primaryDark,
    fontWeight: "500",
  },
  alarmBanner: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#dc2626",
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.sm + 2,
  },
  alarmBannerContent: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    flex: 1,
  },
  alarmBannerText: {
    color: "#fff",
    fontSize: theme.typography.sizes.sm,
    fontWeight: "700",
    flex: 1,
  },
  alarmDismiss: {
    padding: 4,
  },
  teamRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    backgroundColor: "#eff6ff",
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 4,
    borderRadius: 4,
    marginTop: theme.spacing.sm,
  },
  teamText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.primaryDark,
    fontWeight: "600",
  },
});

export default IncidentsScreen;
