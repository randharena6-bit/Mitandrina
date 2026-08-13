import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { Ionicons } from "@expo/vector-icons";
import { ActivityIndicator, View, Platform } from "react-native";

import LoginScreen from "../screens/LoginScreen";
import RegisterScreen from "../screens/RegisterScreen";
import ForgotPasswordScreen from "../screens/ForgotPasswordScreen";
import DashboardScreen from "../screens/DashboardScreen";
import AlertsListScreen from "../screens/AlertsListScreen";
import AlertDetailScreen from "../screens/AlertDetailScreen";
import SheltersScreen from "../screens/SheltersScreen";
import WeatherScreen from "../screens/WeatherScreen";
import ProfileScreen from "../screens/ProfileScreen";
import NotificationsScreen from "../screens/NotificationsScreen";

import theme from "../theme";
import { AuthContext } from "../context/AuthContext";

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

const stackScreenOptions = {
  headerStyle: {
    backgroundColor: theme.colors.primary,
    elevation: 0,
    shadowOpacity: 0,
  },
  headerTintColor: theme.colors.textInverse,
  headerTitleStyle: {
    fontWeight: "700",
    fontSize: theme.typography.sizes.lg,
  },
  headerBackTitleVisible: false,
};

const AuthStack = () => (
  <Stack.Navigator screenOptions={{ headerShown: false, cardStyle: { backgroundColor: theme.colors.bgWhite } }}>
    <Stack.Screen name="Login" component={LoginScreen} />
  </Stack.Navigator>
);

const AlertsStack = () => (
  <Stack.Navigator screenOptions={stackScreenOptions}>
    <Stack.Screen name="AlertsList" component={AlertsListScreen} options={{ title: "Alertes Incendie" }} />
    <Stack.Screen name="AlertDetail" component={AlertDetailScreen} options={{ title: "Détails Alerte" }} />
  </Stack.Navigator>
);

const SheltersStack = () => (
  <Stack.Navigator screenOptions={stackScreenOptions}>
    <Stack.Screen name="SheltersList" component={SheltersScreen} options={{ title: "Refuges Disponibles" }} />
  </Stack.Navigator>
);

const WeatherStack = () => (
  <Stack.Navigator screenOptions={stackScreenOptions}>
    <Stack.Screen name="WeatherMain" component={WeatherScreen} options={{ title: "Conditions Météo" }} />
  </Stack.Navigator>
);

const ProfileStack = () => (
  <Stack.Navigator screenOptions={stackScreenOptions}>
    <Stack.Screen name="ProfileMain" component={ProfileScreen} options={{ title: "Mon Profil" }} />
  </Stack.Navigator>
);

const TabNavigator = () => (
  <Tab.Navigator
    screenOptions={{
      tabBarActiveTintColor: theme.colors.primary,
      tabBarInactiveTintColor: theme.colors.textMuted,
      tabBarStyle: {
        backgroundColor: theme.colors.bgWhite,
        borderTopColor: theme.colors.borderLight,
        borderTopWidth: 1,
        paddingBottom: Platform.OS === "ios" ? 20 : 8,
        paddingTop: 8,
        height: Platform.OS === "ios" ? 85 : 65,
      },
      tabBarLabelStyle: {
        fontSize: theme.typography.sizes.xs,
        fontWeight: "500",
      },
      headerShown: false,
    }}
  >
    <Tab.Screen
      name="DashboardTab" component={DashboardScreen}
      options={{ title: "Accueil", tabBarLabel: "Accueil", tabBarIcon: ({ color, size }) => <Ionicons name="home" size={size} color={color} /> }}
    />
    <Tab.Screen
      name="AlertsTab" component={AlertsStack}
      options={{ title: "Alertes", tabBarLabel: "Alertes", headerShown: false, tabBarIcon: ({ color, size }) => <Ionicons name="alert-circle" size={size} color={color} /> }}
    />
    <Tab.Screen
      name="SheltersTab" component={SheltersStack}
      options={{ title: "Refuges", tabBarLabel: "Refuges", headerShown: false, tabBarIcon: ({ color, size }) => <Ionicons name="home-outline" size={size} color={color} /> }}
    />
    <Tab.Screen
      name="WeatherTab" component={WeatherStack}
      options={{ title: "Météo", tabBarLabel: "Météo", headerShown: false, tabBarIcon: ({ color, size }) => <Ionicons name="cloud" size={size} color={color} /> }}
    />
    <Tab.Screen
      name="ProfileTab" component={ProfileStack}
      options={{ title: "Profil", tabBarLabel: "Profil", headerShown: false, tabBarIcon: ({ color, size }) => <Ionicons name="person" size={size} color={color} /> }}
    />
  </Tab.Navigator>
);

export const RootNavigator = ({ isLoading, isSignedIn }) => {
  if (isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: theme.colors.bgWhite }}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  return (
    <NavigationContainer>
      {isSignedIn ? <TabNavigator /> : <AuthStack />}
    </NavigationContainer>
  );
};

export default RootNavigator;
