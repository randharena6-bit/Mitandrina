import React, { useState, useEffect } from "react";
import {
  View,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Text,
  RefreshControl,
  ActivityIndicator,
  TextInput,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";
import Button from "../components/Button";

const SheltersScreen = ({ navigation }) => {
  const [shelters, setShelters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [search, setSearch] = useState("");

  useEffect(() => {
    loadShelters();
  }, []);

  const loadShelters = async () => {
    try {
      setLoading(true);
      const response = await api.getShelters({ limit: 50 });
      setShelters(response.data?.shelters || []);
    } catch (error) {
      console.error("Erreur chargement refuges:", error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadShelters();
    setRefreshing(false);
  };

  const filteredShelters = shelters.filter(
    (shelter) =>
      shelter.name?.toLowerCase().includes(search.toLowerCase()) ||
      shelter.address?.toLowerCase().includes(search.toLowerCase()),
  );

  const renderShelter = ({ item }) => {
    const occupancyPercent = item.capacity
      ? Math.round(((item.current_occupancy || 0) / item.capacity) * 100)
      : 0;

    return (
      <Card style={styles.shelterCard} shadow="sm">
        <View style={styles.shelterHeader}>
          <View style={styles.shelterInfo}>
            <Text style={styles.shelterName}>{item.name}</Text>
            <Text style={styles.shelterAddress}>{item.address}</Text>
          </View>
          <View style={[styles.capacityBadge, occupancyPercent > 80 && styles.capacityHigh]}>
            <Text style={styles.capacityText}>{occupancyPercent}%</Text>
          </View>
        </View>

        <View style={styles.shelterDetails}>
          {[
            { icon: "people-outline", text: `${item.capacity || 0} places` },
            { icon: "water-outline", text: item.is_available ? "Eau dispo" : "-" },
            { icon: "medkit-outline", text: item.has_medical_facilities ? "Médical" : "-" },
            { icon: "call-outline", text: item.phone || "N/A" },
          ].map((detail, idx) => (
            <View key={idx} style={styles.detailItem}>
              <Ionicons name={detail.icon} size={15} color={theme.colors.textGray} />
              <Text style={styles.detailText}>{detail.text}</Text>
            </View>
          ))}
        </View>

        <View style={styles.shelterActions}>
          <Button title="Direction" variant="secondary" size="small" icon="navigate-outline" onPress={() => {}} style={styles.actionButton} />
          <Button title="Appeler" variant="secondary" size="small" icon="call-outline" onPress={() => {}} style={styles.actionButton} />
        </View>
      </Card>
    );
  };

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
      <View style={styles.searchContainer}>
        <Ionicons name="search" size={20} color={theme.colors.textGray} />
        <TextInput
          style={styles.searchInput}
          placeholder="Rechercher un refuge..."
          value={search}
          onChangeText={setSearch}
          placeholderTextColor={theme.colors.textMuted}
        />
        {search ? (
          <TouchableOpacity onPress={() => setSearch("")}>
            <Ionicons name="close-circle" size={20} color={theme.colors.textMuted} />
          </TouchableOpacity>
        ) : null}
      </View>

      {loading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
        </View>
      ) : (
        <FlatList
          data={filteredShelters}
          renderItem={renderShelter}
          keyExtractor={(item) => item.id.toString()}
          contentContainerStyle={styles.listContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="home-outline" size={52} color={theme.colors.textGray} />
              <Text style={styles.emptyText}>Aucun refuge trouvé</Text>
            </View>
          }
          showsVerticalScrollIndicator={false}
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginHorizontal: theme.spacing.lg,
    marginVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.bgWhite,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
  searchInput: {
    flex: 1,
    paddingVertical: theme.spacing.sm + 4,
    marginLeft: theme.spacing.sm,
    fontSize: 16,
    color: theme.colors.textDark,
  },
  listContent: {
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.md,
    paddingBottom: theme.spacing.xl,
  },
  shelterCard: {
    marginBottom: theme.spacing.md,
    padding: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
  },
  shelterHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: theme.spacing.md,
  },
  shelterInfo: {
    flex: 1,
    marginRight: theme.spacing.sm,
  },
  shelterName: {
    fontSize: 16,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  shelterAddress: {
    fontSize: 12,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  capacityBadge: {
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.xs + 2,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.bgGray,
  },
  capacityHigh: {
    backgroundColor: theme.colors.dangerLight,
  },
  capacityText: {
    fontSize: 14,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  shelterDetails: {
    flexDirection: "row",
    flexWrap: "wrap",
    paddingBottom: theme.spacing.md,
    marginBottom: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  detailItem: {
    width: "50%",
    flexDirection: "row",
    alignItems: "center",
    marginBottom: theme.spacing.sm,
    gap: theme.spacing.xs,
  },
  detailText: {
    fontSize: 12,
    color: theme.colors.textGray,
  },
  shelterActions: {
    flexDirection: "row",
    gap: theme.spacing.sm,
  },
  actionButton: {
    flex: 1,
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
  emptyText: {
    fontSize: 14,
    color: theme.colors.textGray,
    marginTop: theme.spacing.md,
  },
});

export default SheltersScreen;
