// 🌪️ MITANDRINA - Application racine
import React, { useEffect, useRef } from "react";
import { Platform } from "react-native";
import { StatusBar } from "expo-status-bar";
import Constants from "expo-constants";
import { AuthProvider } from "./src/context/AuthContext";
import AppNavigator from "./src/navigation/AppNavigator";
import {
  configureNotifications,
  requestNotificationPermissions,
  getNotificationToken,
  setupNotificationListener,
  setupNotificationResponseListener,
} from "./src/services/notifications";
import api from "./src/services/api";

export default function App() {
  const notificationListener = useRef(null);
  const responseListener = useRef(null);

  useEffect(() => {
    initNotifications();
    return () => {
      if (notificationListener.current) notificationListener.current.remove();
      if (responseListener.current) responseListener.current.remove();
    };
  }, []);

  const initNotifications = async () => {
    const isExpoGoAndroid = Constants.executionEnvironment === "storeClient" && Platform.OS === "android";
    if (isExpoGoAndroid) {
      console.log("Notifications ignorées dans Expo Go Android. Utilisez un development build.");
      return;
    }

    try {
      await configureNotifications();
      const granted = await requestNotificationPermissions();
      if (granted) {
        const token = await getNotificationToken();
        if (token) {
          try {
            await api.updateProfile({ push_token: token });
          } catch (e) {
            console.log("Push token sync skipped:", e.message);
          }
        }
      }

      notificationListener.current = setupNotificationListener((notification) => {
        const data = notification.request.content.data || {};
        if (data.ai_generated) {
          console.log("AI Notification received:", data.type);
        }
      });

      responseListener.current = setupNotificationResponseListener((response) => {
        const data = response.notification.request.content.data || {};
        if (data.ai_generated || data.type === "ai_recommendation") {
          console.log("AI notification clicked, navigating...");
        }
      });
    } catch (error) {
      console.error("Erreur init notifications:", error);
    }
  };

  return (
    <AuthProvider>
      <AppNavigator />
      <StatusBar style="auto" />
    </AuthProvider>
  );
}
