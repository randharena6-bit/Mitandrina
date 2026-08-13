import React from "react";
import { View, ActivityIndicator, Platform } from "react-native";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import { useAuth } from "../context/AuthContext";

import LandingScreen from "../screens/LandingScreen";
import LoginScreen from "../screens/LoginScreen";
import RegisterScreen from "../screens/RegisterScreen";
import ForgotPasswordScreen from "../screens/ForgotPasswordScreen";
import DashboardScreen from "../screens/DashboardScreen";
import AlertsListScreen from "../screens/AlertsListScreen";
import WeatherScreen from "../screens/WeatherScreen";
import SheltersScreen from "../screens/SheltersScreen";
import ProfileScreen from "../screens/ProfileScreen";
import AlertDetailScreen from "../screens/AlertDetailScreen";
import NotificationsScreen from "../screens/NotificationsScreen";
import EvacuationScreen from "../screens/EvacuationScreen";
import IncidentsScreen from "../screens/IncidentsScreen";
import AIScreen from "../screens/AIScreen";
import SimulationScreen from "../screens/SimulationScreen";
import CycloneMapScreen from "../screens/CycloneMapScreen";

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

const screenOptions = {
  headerStyle: {
    backgroundColor: theme.colors.bgWhite,
    elevation: 0,
    shadowOpacity: 0,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  headerTintColor: theme.colors.textDark,
  headerTitleStyle: {
    fontWeight: theme.typography.fontWeight.bold,
    fontSize: theme.typography.fontSize.lg,
  },
  headerBackTitleVisible: false,
};

const MainTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          if (route.name === "DashboardTab") iconName = focused ? "home" : "home-outline";
          else if (route.name === "AlertsTab") iconName = focused ? "warning" : "warning-outline";
          else if (route.name === "IncidentsTab") iconName = focused ? "alert-circle" : "alert-circle-outline";
          else if (route.name === "AITab") iconName = focused ? "hardware-chip" : "hardware-chip-outline";
          else if (route.name === "EvacuationTab") iconName = focused ? "navigate" : "navigate-outline";
          else if (route.name === "ProfileTab") iconName = focused ? "person" : "person-outline";
          return <Ionicons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.textMuted,
        tabBarStyle: {
          backgroundColor: theme.colors.bgWhite,
          borderTopWidth: 1,
          borderTopColor: theme.colors.borderLight,
          paddingBottom: Platform.OS === "ios" ? 20 : 8,
          paddingTop: 8,
          height: Platform.OS === "ios" ? 85 : 65,
        },
        tabBarLabelStyle: {
          fontSize: theme.typography.sizes.xs,
          fontWeight: theme.typography.weight.medium,
        },
        headerShown: false,
      })}
    >
      <Tab.Screen name="DashboardTab" component={DashboardScreen} options={{ title: "Accueil" }} />
      <Tab.Screen name="AlertsTab" component={AlertsListScreen} options={{ title: "Alertes" }} />
      <Tab.Screen name="IncidentsTab" component={IncidentsScreen} options={{ title: "Incidents" }} />
      <Tab.Screen name="AITab" component={AIScreen} options={{ title: "IA Conseil" }} />
      <Tab.Screen name="EvacuationTab" component={EvacuationScreen} options={{ title: "Évacuation" }} />
      <Tab.Screen name="ProfileTab" component={ProfileScreen} options={{ title: "Profil" }} />
    </Tab.Navigator>
  );
};

const AppNavigator = () => {
  const { state } = useAuth();

  if (state.isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: theme.colors.bgWhite }}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={screenOptions}>
        {!state.isSignedIn ? (
          <>
            <Stack.Screen name="Landing" component={LandingScreen} options={{ headerShown: false }} />
            <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
            <Stack.Screen name="Register" component={RegisterScreen} options={{ headerShown: false }} />
            <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} options={{ title: "Mot de passe oublié" }} />
          </>
        ) : (
          <>
            <Stack.Screen name="MainTabs" component={MainTabs} options={{ headerShown: false }} />
            <Stack.Screen name="AlertDetail" component={AlertDetailScreen} options={{ title: "Détail de l'alerte" }} />
            <Stack.Screen name="NotificationsTab" component={NotificationsScreen} options={{ title: "Notifications" }} />
            <Stack.Screen name="WeatherTab" component={WeatherScreen} options={{ title: "Météo" }} />
            <Stack.Screen name="SheltersTab" component={SheltersScreen} options={{ title: "Refuges de secours" }} />
            <Stack.Screen name="Simulations" component={SimulationScreen} options={{ title: "Simulations cycloniques" }} />
            <Stack.Screen name="CycloneMap" component={CycloneMapScreen} options={{ title: "Carte cyclonique" }} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
