import React, { useState, useEffect } from "react";
import {
  View,
  StyleSheet,
  ScrollView,
  Text,
  TouchableOpacity,
  Alert,
  Switch,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import { useAuth } from "../context/AuthContext";
import { secureGet, secureSet } from "../services/storage";
import Card from "../components/Card";
import Button from "../components/Button";

const SETTINGS_SECTIONS = [
  {
    title: "Informations personnelles",
    items: [
      { id: "edit-profile", label: "Modifier profil", icon: "person-outline" },
      { id: "change-password", label: "Changer mot de passe", icon: "lock-closed-outline" },
      { id: "location", label: "Localisation", icon: "location-outline" },
    ],
  },
  {
    title: "À propos",
    items: [
      { id: "about", label: "À propos de Mitandrina", icon: "information-circle-outline" },
      { id: "privacy", label: "Politique de confidentialité", icon: "shield-checkmark-outline" },
    ],
  },
];

const PREFERENCES = [
  { id: "notifications", label: "Notifications", icon: "notifications-outline" },
  { id: "emailAlerts", label: "Alertes Email", icon: "mail-outline" },
  { id: "pushAlerts", label: "Alertes Push", icon: "phone-portrait-outline" },
  { id: "darkMode", label: "Mode sombre", icon: "moon-outline" },
];

const ProfileScreen = ({ navigation }) => {
  const { state: authState, logout } = useAuth();
  const [preferences, setPreferences] = useState({
    notifications: true,
    emailAlerts: true,
    pushAlerts: true,
    darkMode: false,
  });

  useEffect(() => {
    loadLocalPreferences();
  }, []);

  const loadLocalPreferences = async () => {
    try {
      const localPrefs = await secureGet("preferences");
      if (localPrefs) {
        setPreferences(localPrefs);
      } else if (authState.user) {
        const channels = authState.user.alert_channels || [];
        setPreferences({
          notifications: channels.includes("push"),
          emailAlerts: channels.includes("email"),
          pushAlerts: channels.includes("sms"),
          darkMode: false,
        });
      }
    } catch (err) {
      console.error("Erreur chargement preferences:", err);
    }
  };

  const handleLogout = () => {
    Alert.alert("Déconnexion", "Êtes-vous sûr de vouloir vous déconnecter ?", [
      { text: "Annuler", style: "cancel" },
      { text: "Déconnexion", onPress: () => logout(), style: "destructive" },
    ]);
  };

  const updatePreference = async (key, value) => {
    try {
      const updated = { ...preferences, [key]: value };
      setPreferences(updated);
      await secureSet("preferences", updated);
      const channels = [];
      if (updated.notifications) channels.push("push");
      if (updated.emailAlerts) channels.push("email");
      if (updated.pushAlerts) channels.push("sms");
      await api.updateProfile({ alertChannels: channels });
    } catch (error) {
      console.error("Erreur mise à jour preferences:", error);
    }
  };

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        <Card style={styles.profileHeader} shadow="sm">
          <View style={styles.profileContent}>
            <View style={styles.avatar}>
              <Ionicons name="person" size={36} color="white" />
            </View>
            <View style={styles.profileInfo}>
              <Text style={styles.userName}>{authState.user?.name || "Utilisateur"}</Text>
              <Text style={styles.userEmail}>{authState.user?.email}</Text>
              <View style={styles.statusBadge}>
                <View style={styles.statusDot} />
                <Text style={styles.statusText}>Compte actif</Text>
              </View>
            </View>
          </View>
        </Card>

        {SETTINGS_SECTIONS.map((section) => (
          <View key={section.title} style={styles.section}>
            <Text style={styles.sectionTitle}>{section.title}</Text>
            <Card shadow="sm">
              {section.items.map((item, idx, arr) => (
                <TouchableOpacity
                  key={item.id}
                  style={[styles.menuItem, idx === arr.length - 1 && styles.lastMenuItem]}
                >
                  <View style={styles.menuIcon}>
                    <Ionicons name={item.icon} size={20} color={theme.colors.primary} />
                  </View>
                  <Text style={styles.menuLabel}>{item.label}</Text>
                  <Ionicons name="chevron-forward" size={20} color={theme.colors.textMuted} />
                </TouchableOpacity>
              ))}
            </Card>
          </View>
        ))}

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Préférences</Text>
          <Card shadow="sm">
            {PREFERENCES.map((pref, idx, arr) => (
              <View
                key={pref.id}
                style={[styles.preferenceItem, idx === arr.length - 1 && styles.lastMenuItem]}
              >
                <View style={styles.preferenceLabel}>
                  <View style={styles.menuIcon}>
                    <Ionicons name={pref.icon} size={20} color={theme.colors.primary} />
                  </View>
                  <Text style={styles.menuLabel}>{pref.label}</Text>
                </View>
                <Switch
                  value={preferences[pref.id]}
                  onValueChange={(value) => updatePreference(pref.id, value)}
                  trackColor={{ false: theme.colors.border, true: theme.colors.primaryLight }}
                  thumbColor={preferences[pref.id] ? theme.colors.primary : theme.colors.textMuted}
                />
              </View>
            ))}
          </Card>
        </View>

        <View style={styles.logoutSection}>
          <Button
            title="Déconnexion"
            onPress={handleLogout}
            variant="danger"
            icon="log-out-outline"
            size="large"
          />
        </View>

        <Text style={styles.versionText}>Version 1.0.0</Text>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
  },
  scrollContent: {
    paddingBottom: theme.spacing.xl,
  },
  profileHeader: {
    marginHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.lg,
    marginBottom: theme.spacing.md,
    padding: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
  },
  profileContent: {
    flexDirection: "row",
    alignItems: "center",
  },
  avatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: theme.colors.primary,
    justifyContent: "center",
    alignItems: "center",
    marginRight: theme.spacing.md,
  },
  profileInfo: {
    flex: 1,
  },
  userName: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  userEmail: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: 2,
  },
  statusBadge: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 6,
    gap: theme.spacing.xs,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: theme.colors.primary,
  },
  statusText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.primary,
    fontWeight: "600",
  },
  section: {
    paddingHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.md,
  },
  sectionTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.sm,
  },
  menuItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: theme.spacing.md + 2,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  lastMenuItem: {
    borderBottomWidth: 0,
  },
  menuIcon: {
    width: 36,
    height: 36,
    borderRadius: theme.borderRadius.sm,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
    marginRight: theme.spacing.md,
  },
  menuLabel: {
    flex: 1,
    fontSize: theme.typography.sizes.base,
    color: theme.colors.textDark,
    fontWeight: "500",
  },
  preferenceItem: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: theme.spacing.sm + 4,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  preferenceLabel: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
  },
  logoutSection: {
    paddingHorizontal: theme.spacing.lg,
    marginTop: theme.spacing.xl,
  },
  versionText: {
    textAlign: "center",
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    marginTop: theme.spacing.lg,
    marginBottom: theme.spacing.xl,
  },
});

export default ProfileScreen;
