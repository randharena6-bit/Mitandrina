import React, { useState, useEffect } from "react";
import {
  View,
  StyleSheet,
  ScrollView,
  Text,
  ActivityIndicator,
  RefreshControl,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";
import api from "../services/api";
import Card from "../components/Card";

const WeatherScreen = ({ navigation }) => {
  const [weather, setWeather] = useState(null);
  const [forecast, setForecast] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    loadWeather();
  }, []);

  const loadWeather = async () => {
    try {
      setLoading(true);
      const [weatherRes, forecastRes] = await Promise.all([
        api.getWeather(-18.8792, 47.5079),
        api.getWeatherForecast(-18.8792, 47.5079),
      ]);
      setWeather(weatherRes.data);
      setForecast(forecastRes.data?.forecast || []);
    } catch (error) {
      console.error("Erreur chargement météo:", error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadWeather();
    setRefreshing(false);
  };

  const getWeatherIcon = (condition) => {
    switch (condition?.toLowerCase()) {
      case "clear": case "sunny": return "sunny";
      case "cloud": case "cloudy": return "cloud";
      case "rain": case "rainy": return "rainy";
      case "wind": case "windy": return "wind";
      default: return "cloud";
    }
  };

  const renderForecastDay = (day) => (
    <Card key={day.date} style={styles.forecastCard} shadow="sm">
      <Text style={styles.forecastDate}>
        {new Date(day.date).toLocaleDateString("fr-FR", { weekday: "short", month: "short", day: "numeric" })}
      </Text>
      <Ionicons name={getWeatherIcon(day.condition)} size={28} color={theme.colors.primary} />
      <Text style={styles.forecastTemp}>{day.tempMax}° / {day.tempMin}°</Text>
      <Text style={styles.forecastDesc}>{day.condition}</Text>
    </Card>
  );

  if (loading && !refreshing) {
    return (
      <View style={[styles.container, styles.loadingContainer]}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container} edges={["bottom"]}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        {weather && (
          <Card style={styles.currentWeatherCard} shadow="md">
            <View style={styles.currentWeatherContent}>
              <View>
                <Text style={styles.currentTemp}>{weather.temp}°C</Text>
                <Text style={styles.currentDesc}>{weather.description}</Text>
                <Text style={styles.currentLocation}>{weather.location || "Antananarivo"}</Text>
              </View>
              <View style={styles.weatherIconWrap}>
                <Ionicons name={getWeatherIcon(weather.condition)} size={60} color={theme.colors.primary} />
              </View>
            </View>

            <View style={styles.weatherDetails}>
              {[
                { icon: "water-outline", label: "Humidité", value: `${weather.humidity}%` },
                { icon: "arrow-forward-outline", label: "Vent", value: `${weather.windSpeed} km/h` },
                { icon: "pulse-outline", label: "Pression", value: `${weather.pressure} hPa` },
                { icon: "eye-outline", label: "Visibilité", value: `${weather.visibility} km` },
              ].map((item, idx) => (
                <View key={idx} style={styles.weatherDetailBox}>
                  <Ionicons name={item.icon} size={18} color={theme.colors.primary} />
                  <Text style={styles.detailLabel}>{item.label}</Text>
                  <Text style={styles.detailValue}>{item.value}</Text>
                </View>
              ))}
            </View>

            {weather.uvIndex !== undefined && (
              <View style={styles.riskBox}>
                {[
                  { label: "Indice UV", value: weather.uvIndex },
                  {
                    label: "Risque Incendie",
                    value: `${weather.fireRisk || "N/A"}%`,
                    color: weather.fireRisk > 70 ? theme.colors.danger : weather.fireRisk > 40 ? theme.colors.warning : theme.colors.primary,
                  },
                ].map((item, idx) => (
                  <View key={idx} style={styles.riskItem}>
                    <Text style={styles.riskLabel}>{item.label}</Text>
                    <Text style={[styles.riskValue, item.color && { color: item.color }]}>{item.value}</Text>
                  </View>
                ))}
              </View>
            )}
          </Card>
        )}

        {forecast.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Prévisions</Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.forecastScroll}
            >
              {forecast.map(renderForecastDay)}
            </ScrollView>
          </View>
        )}

        {weather?.warnings?.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Avertissements</Text>
            {weather.warnings.map((warning, idx) => (
              <Card key={idx} style={styles.warningCard} shadow="sm">
                <View style={styles.warningContent}>
                  <Ionicons name="alert-circle" size={24} color={theme.colors.danger} />
                  <View style={styles.warningInfo}>
                    <Text style={styles.warningTitle}>{warning.title}</Text>
                    <Text style={styles.warningDesc}>{warning.description}</Text>
                  </View>
                </View>
              </Card>
            ))}
          </View>
        )}

        <View style={styles.bottomSpacer} />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
  },
  loadingContainer: {
    justifyContent: "center",
    alignItems: "center",
  },
  currentWeatherCard: {
    marginHorizontal: theme.spacing.lg,
    marginVertical: theme.spacing.lg,
  },
  currentWeatherContent: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: theme.spacing.lg,
  },
  currentTemp: {
    fontSize: 52,
    fontWeight: "700",
    color: theme.colors.textDark,
    letterSpacing: -2,
  },
  currentDesc: {
    fontSize: theme.typography.sizes.base,
    color: theme.colors.textGray,
    marginTop: 2,
    textTransform: "capitalize",
  },
  currentLocation: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textMuted,
    marginTop: 4,
  },
  weatherIconWrap: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: theme.colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
  },
  weatherDetails: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: theme.spacing.sm,
    paddingBottom: theme.spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.borderLight,
  },
  weatherDetailBox: {
    width: "47%",
    alignItems: "center",
    paddingVertical: theme.spacing.md,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.md,
    gap: theme.spacing.xs,
  },
  detailLabel: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
  },
  detailValue: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  riskBox: {
    flexDirection: "row",
    justifyContent: "space-around",
    paddingVertical: theme.spacing.md,
    backgroundColor: theme.colors.bgGray,
    borderRadius: theme.borderRadius.md,
    marginTop: theme.spacing.md,
  },
  riskItem: {
    alignItems: "center",
  },
  riskLabel: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
  },
  riskValue: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "700",
    color: theme.colors.primary,
    marginTop: 4,
  },
  section: {
    paddingHorizontal: theme.spacing.lg,
    marginVertical: theme.spacing.md,
  },
  sectionTitle: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.md,
  },
  forecastScroll: {
    gap: theme.spacing.sm,
    paddingBottom: theme.spacing.sm,
  },
  forecastCard: {
    width: 110,
    alignItems: "center",
    paddingVertical: theme.spacing.md,
    backgroundColor: theme.colors.bgWhite,
  },
  forecastDate: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    marginBottom: theme.spacing.sm,
    textTransform: "capitalize",
  },
  forecastTemp: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginTop: theme.spacing.sm,
  },
  forecastDesc: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    marginTop: 2,
    textTransform: "capitalize",
  },
  warningCard: {
    marginBottom: theme.spacing.md,
    borderLeftWidth: 4,
    borderLeftColor: theme.colors.danger,
  },
  warningContent: {
    flexDirection: "row",
    gap: theme.spacing.md,
  },
  warningInfo: {
    flex: 1,
  },
  warningTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: "700",
    color: theme.colors.textDark,
  },
  warningDesc: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    marginTop: 4,
    lineHeight: 18,
  },
  bottomSpacer: {
    height: theme.spacing.xl,
  },
});

export default WeatherScreen;
