import React, { useEffect } from "react";
import { Platform } from "react-native";
import Constants from "expo-constants";
import { useAuth } from "../context/AuthContext";
import analytics from "../services/analytics";
import * as notificationService from "../services/notifications";

export const useAppInitialization = () => {
  const { state: authState } = useAuth();

  useEffect(() => {
    const initializeApp = async () => {
      const isExpoGoAndroid =
        Constants.executionEnvironment === "storeClient" &&
        Platform.OS === "android";

      if (isExpoGoAndroid) {
        analytics.trackEvent("app_initialized", {
          isSignedIn: authState.isSignedIn,
          userId: authState.user?.id,
        });
        return;
      }

      try {
        await notificationService.configureNotifications();
        await notificationService.requestNotificationPermissions();

        analytics.trackEvent("app_initialized", {
          isSignedIn: authState.isSignedIn,
          userId: authState.user?.id,
        });

        const notificationListener =
          notificationService.setupNotificationListener((notification) => {
            console.log("Notification reçue:", notification);
          });

        const responseListener =
          notificationService.setupNotificationResponseListener((response) => {
            console.log("Notification cliquée:", response);
          });

        return () => {
          notificationListener.remove();
          responseListener.remove();
        };
      } catch (error) {
        console.error("Erreur initialisation app:", error);
        analytics.trackError(error, { context: "app_initialization" });
      }
    };

    initializeApp();
  }, [authState.isSignedIn]);
};

export default useAppInitialization;
