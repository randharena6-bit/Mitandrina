import React, { useState, useEffect } from "react";
import {
  View,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Text,
  RefreshControl,
  ActivityIndicator,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";

const FILTERS = [
  { id: "all", label: "Tous" },
  { id: "critical", label: "Critique" },
  { id: "acknowledged", label: "Confirmés" },
];

const AlertsListScreen = ({ navigation }) => {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    loadAlerts();
  }, [filter]);

  const loadAlerts = async () => {
    try {
      setLoading(true);
      const params = { limit: 50, sort: "-emitted_at" };
      if (filter === "critical") params.level = "urgence";
      else if (filter === "acknowledged") params.acknowledged = true;

      const response = await api.getAlerts(params);
      setAlerts(response.data?.alerts || []);
    } catch (error) {
      console.error("Erreur chargement alertes:", error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadAlerts();
    setRefreshing(false);
  };

  const renderAlert = ({ item }) => {
    const isUrgent = item.level === "urgence" || item.level === "alerte";
    const alertTitle = item.zone_name || item.title || "Alerte de sécurité";

    return (
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={() => navigation.navigate("AlertDetail", { alertId: item.id })}
      >
        <Card style={styles.alertCard} shadow="sm">
          <View style={styles.alertHeader}>
            <View style={[styles.alertBadge, { backgroundColor: isUrgent ? theme.colors.danger : theme.colors.primary }]}>
              <Ionicons name="warning" size={20} color="white" />
            </View>
            <View style={styles.alertMeta}>
              <Text style={styles.alertLocation} numberOfLines={1}>{alertTitle}</Text>
              <Text style={styles.alertTime}>
                {new Date(item.emitted_at || Date.now()).toLocaleDateString("fr-FR", {
                  year: "numeric", month: "numeric", day: "numeric",
                  hour: "2-digit", minute: "2-digit",
                })}
              </Text>
            </View>
            {item.is_confirmed && (
              <Ionicons name="checkmark-circle" size={20} color={theme.colors.primary} />
            )}
          </View>

          <View style={styles.alertDetails}>
            <View style={styles.detailRow}>
              <Ionicons name="location-outline" size={14} color={theme.colors.textGray} />
              <Text style={styles.detailText} numberOfLines={1}>{alertTitle}</Text>
            </View>
            {item.confidence ? (
              <View style={styles.detailRow}>
                <Ionicons name="pulse-outline" size={14} color={theme.colors.textGray} />
                <Text style={styles.detailText}>Confiance: {Math.round(item.confidence * 100)}%</Text>
              </View>
            ) : null}
          </View>

          <View style={styles.alertFooter}>
            <View style={[styles.severityBadge, { backgroundColor: isUrgent ? theme.colors.danger : theme.colors.primary }]}>
              <Text style={styles.severityText}>{(item.level || "INFO").toUpperCase()}</Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={theme.colors.textMuted} />
          </View>
        </Card>
      </TouchableOpacity>
    );
  };

  const renderEmpty = () => (
    <View style={styles.emptyContainer}>
      <Ionicons name="checkmark-circle-outline" size={64} color={theme.colors.textMuted} />
      <Text style={styles.emptyTitle}>Aucune alerte</Text>
      <Text style={styles.emptyText}>Pas d'alertes correspondant à vos critères</Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
      <View style={styles.filterContainer}>
        {FILTERS.map((item) => (
          <TouchableOpacity
            key={item.id}
            style={[styles.filterButton, filter === item.id && styles.filterButtonActive]}
            onPress={() => setFilter(item.id)}
          >
            <Text style={[styles.filterButtonText, filter === item.id && styles.filterButtonTextActive]}>
              {item.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {loading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
        </View>
      ) : (
        <FlatList
          data={alerts}
          renderItem={renderAlert}
          keyExtractor={(item) => item.id.toString()}
          contentContainerStyle={styles.listContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          ListEmptyComponent={renderEmpty}
          showsVerticalScrollIndicator={false}
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgWhite,
  },
  filterContainer: {
    flexDirection: "row",
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
    gap: theme.spacing.sm,
  },
  filterButton: {
    paddingHorizontal: theme.spacing.md + 2,
    paddingVertical: theme.spacing.sm,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
  filterButtonActive: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  filterButtonText: {
    fontSize: 14,
    fontWeight: "600",
    color: theme.colors.textGray,
  },
  filterButtonTextActive: {
    color: "white",
  },
  listContent: {
    padding: theme.spacing.lg,
    paddingBottom: theme.spacing.xl,
  },
  alertCard: {
    marginBottom: theme.spacing.md,
    padding: theme.spacing.md,
  },
  alertHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: theme.spacing.md,
  },
  alertBadge: {
    width: 40,
    height: 40,
    borderRadius: theme.borderRadius.sm,
    justifyContent: "center",
    alignItems: "center",
    marginRight: theme.spacing.md,
  },
  alertMeta: {
    flex: 1,
  },
  alertLocation: {
    fontSize: 16,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  alertTime: {
    fontSize: 12,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  alertDetails: {
    marginBottom: theme.spacing.md,
  },
  detailRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 4,
    gap: theme.spacing.xs,
  },
  detailText: {
    fontSize: 14,
    color: theme.colors.textGray,
    flex: 1,
  },
  alertFooter: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingTop: theme.spacing.md,
    borderTopWidth: 1,
    borderTopColor: theme.colors.borderLight,
  },
  severityBadge: {
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 4,
    borderRadius: theme.borderRadius.sm,
  },
  severityText: {
    fontSize: 11,
    fontWeight: "800",
    color: "white",
  },
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  emptyContainer: {
    alignItems: "center",
    paddingVertical: theme.spacing.xl * 2,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginTop: theme.spacing.md,
  },
  emptyText: {
    fontSize: 14,
    color: theme.colors.textGray,
    textAlign: "center",
    marginTop: theme.spacing.sm,
    paddingHorizontal: theme.spacing.xl,
  },
});

export default AlertsListScreen;
