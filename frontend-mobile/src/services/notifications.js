import Constants from "expo-constants";
import { Platform } from "react-native";
import api from "./api";

let Notifications = null;
let notificationsLoaded = false;

const isExpoGoAndroid =
  Constants.executionEnvironment === "storeClient" &&
  Platform.OS === "android";

const loadNotifications = () => {
  if (notificationsLoaded) return true;
  if (isExpoGoAndroid) return false;
  try {
    Notifications = require("expo-notifications");
    notificationsLoaded = true;
    return true;
  } catch {
    return false;
  }
};

export const configureNotifications = async () => {
  if (!loadNotifications()) return false;
  try {
    await Notifications.setNotificationHandler({
      handleNotification: async () => ({
        shouldShowBanner: true,
        shouldShowList: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
      }),
    });
    return true;
  } catch (error) {
    console.error("Erreur configuration notifications:", error);
    return false;
  }
};

export const requestNotificationPermissions = async () => {
  if (!loadNotifications()) return false;
  try {
    const { status } = await Notifications.requestPermissionsAsync();
    return status === "granted";
  } catch (error) {
    console.error("Erreur permissions notifications:", error);
    return false;
  }
};

export const getNotificationToken = async () => {
  if (isExpoGoAndroid) {
    console.log(
      "Push notifications distantes non disponibles dans Expo Go. Utilisez un development build."
    );
    return null;
  }
  if (!loadNotifications()) return null;
  try {
    const token = (
      await Notifications.getExpoPushTokenAsync({
        projectId: Constants.expoConfig?.extra?.eas?.projectId,
      })
    ).data;
    return token;
  } catch (error) {
    console.warn("Notification push non disponible:", error.message);
    return null;
  }
};

export const showLocalNotification = async (title, body, data = {}) => {
  if (!loadNotifications()) return;
  try {
    const isAI = data.ai_generated || false;
    await Notifications.scheduleNotificationAsync({
      content: {
        title: isAI ? `🤖 ${title}` : title,
        body,
        data,
        sound: "default",
        badge: 1,
      },
      trigger: {
        seconds: 1,
      },
    });
  } catch (error) {
    console.error("Erreur affichage notification:", error);
  }
};

export const showAIRecommendation = async (recommendations) => {
  if (!recommendations || recommendations.length === 0) return;

  const mainRec = recommendations[0];
  await showLocalNotification(
    "Recommandation IA Cyclone",
    mainRec,
    { ai_generated: true, type: "ai_recommendation" }
  );

  try {
    await api.createNotification({
      title: "Recommandation IA Cyclone",
      message: mainRec.substring(0, 200),
      type: "ai_recommendation",
    });
  } catch (e) {
    console.log("Save recommendation to backend skipped:", e.message);
  }
};

export const showAIAnalysisUpdate = async (riskLevel, resume) => {
  const riskEmojis = { faible: "✅", modéré: "⚠️", élevé: "🔶", critique: "🔴" };
  const emoji = riskEmojis[riskLevel] || "ℹ️";

  await showLocalNotification(
    `Mise à jour analyse cyclonique ${emoji}`,
    resume?.substring(0, 120) || "Nouvelle analyse disponible",
    { ai_generated: true, type: "ai_analysis_update" }
  );

  try {
    await api.createNotification({
      title: `Analyse cyclonique: Risque ${riskLevel?.toUpperCase()}`,
      message: resume?.substring(0, 200) || "Nouvelle analyse disponible",
      type: "ai_analysis_update",
    });
  } catch (e) {
    console.log("Save analysis to backend skipped:", e.message);
  }
};

export const setupNotificationListener = (callback) => {
  if (!loadNotifications()) return { remove: () => {} };
  const subscription = Notifications.addNotificationReceivedListener(
    (notification) => {
      callback(notification);
    }
  );
  return subscription;
};

export const setupNotificationResponseListener = (callback) => {
  if (!loadNotifications()) return { remove: () => {} };
  const subscription = Notifications.addNotificationResponseReceivedListener(
    (response) => {
      callback(response);
    }
  );
  return subscription;
};

export default {
  configureNotifications,
  requestNotificationPermissions,
  getNotificationToken,
  showLocalNotification,
  setupNotificationListener,
  setupNotificationResponseListener,
};
