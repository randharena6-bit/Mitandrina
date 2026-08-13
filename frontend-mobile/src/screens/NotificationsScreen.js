import React, { useState, useCallback } from "react";
import { useFocusEffect } from "@react-navigation/native";
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

const NotificationsScreen = ({ navigation }) => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useFocusEffect(
    useCallback(() => {
      loadNotifications();
    }, [])
  );

  const loadNotifications = async () => {
    try {
      setLoading(true);
      const response = await api.getNotifications({ limit: 50 });
      setNotifications(response.data?.notifications || []);
    } catch (error) {
      console.error("Erreur chargement notifications:", error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadNotifications();
    setRefreshing(false);
  };

  const handleMarkAsRead = async (notificationId) => {
    try {
      await api.markNotificationAsRead(notificationId);
      setNotifications((prev) =>
        prev.map((n) =>
          n.id === notificationId ? { ...n, read_at: new Date().toISOString() } : n,
        ),
      );
    } catch (error) {
      console.error("Erreur:", error);
    }
  };

  const handleDelete = async (notificationId) => {
    try {
      await api.deleteNotification(notificationId);
      setNotifications((prev) => prev.filter((n) => n.id !== notificationId));
    } catch (error) {
      console.error("Erreur:", error);
    }
  };

  const getIcon = (type) => {
    switch (type) {
      case "alert": return "alert-circle";
      case "shelter": return "home-outline";
      case "weather": return "cloud-outline";
      default: return "notifications-outline";
    }
  };

  const formatDate = (createdAt) => {
    const date = new Date(createdAt);
    return date.toLocaleDateString("fr-FR", { hour: "2-digit", minute: "2-digit" });
  };

  const renderNotification = ({ item }) => {
    const isUnread = !item.read_at;

    return (
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={() => isUnread && handleMarkAsRead(item.id)}
      >
        <Card style={[styles.notificationCard, isUnread && styles.unreadCard]} shadow="sm">
          <View style={styles.notificationContent}>
            <View style={styles.iconBox}>
              <Ionicons name={getIcon(item.type)} size={22} color={theme.colors.primary} />
            </View>
            <View style={styles.notificationInfo}>
              <Text style={styles.notificationTitle}>{item.title}</Text>
              <Text style={styles.notificationMessage} numberOfLines={2}>{item.message}</Text>
              <Text style={styles.notificationTime}>{formatDate(item.created_at)}</Text>
            </View>
            <TouchableOpacity onPress={() => handleDelete(item.id)} style={styles.deleteButton}>
              <Ionicons name="close" size={18} color={theme.colors.textMuted} />
            </TouchableOpacity>
          </View>
        </Card>
      </TouchableOpacity>
    );
  };

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
      {loading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
        </View>
      ) : (
        <FlatList
          data={notifications}
          renderItem={renderNotification}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="notifications-off-outline" size={52} color={theme.colors.textMuted} />
              <Text style={styles.emptyText}>Aucune notification</Text>
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
    backgroundColor: theme.colors.bgWhite,
  },
  listContent: {
    padding: theme.spacing.lg,
    paddingBottom: theme.spacing.xl,
  },
  notificationCard: {
    marginBottom: theme.spacing.sm,
    padding: theme.spacing.md,
  },
  unreadCard: {
    backgroundColor: theme.colors.primaryLight,
    borderLeftWidth: 3,
    borderLeftColor: theme.colors.primary,
  },
  notificationContent: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: theme.spacing.md,
  },
  iconBox: {
    width: 40,
    height: 40,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.bgGray,
    justifyContent: "center",
    alignItems: "center",
    flexShrink: 0,
  },
  notificationInfo: {
    flex: 1,
  },
  notificationTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  notificationMessage: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: 4,
    lineHeight: 20,
  },
  notificationTime: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    marginTop: 6,
  },
  deleteButton: {
    padding: theme.spacing.xs,
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
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: theme.spacing.md,
  },
});

export default NotificationsScreen;
