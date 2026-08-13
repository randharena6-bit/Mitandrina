import React from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import Logo from "../components/Logo";
import theme from "../theme";

const features = [
  {
    icon: "water",
    color: "#3b82f6",
    bg: "rgba(59, 130, 246, 0.15)",
    title: "Prédiction Inondations",
    desc: "XGBoost analysant précipitations et niveaux d'eau pour prédire les crues 24-72h à l'avance.",
    tags: ["94% précision", "24-72h"],
  },
  {
    icon: "flame",
    color: "#f97316",
    bg: "rgba(249, 115, 22, 0.15)",
    title: "Détection Incendies",
    desc: "CNN ResNet-50 analysant images satellites NASA FIRMS en temps réel.",
    tags: ["CNN ResNet-50", "Temps réel"],
  },
  {
    icon: "chatbubbles",
    color: "#a855f7",
    bg: "rgba(168, 85, 247, 0.15)",
    title: "Analyse Réseaux Sociaux",
    desc: "BERT multilingue pour détecter les signaux d'alerte et localiser les incidents.",
    tags: ["BERT NLP", "Multi-langue"],
  },
  {
    icon: "map",
    color: "#22c55e",
    bg: "rgba(34, 197, 94, 0.15)",
    title: "Routes d'Évacuation",
    desc: "Algorithme A* avec OSM pour des itinéraires optimaux évitant les zones de danger.",
    tags: ["Algorithme A*", "OpenStreetMap"],
  },
  {
    icon: "flash",
    color: "#ef4444",
    bg: "rgba(239, 68, 68, 0.15)",
    title: "Alertes Multicanal",
    desc: "Notifications SMS, Push, Email et WebSocket selon votre localisation.",
    tags: ["SMS", "Push FCM", "WebSocket"],
  },
  {
    icon: "cube",
    color: "#14b8a6",
    bg: "rgba(20, 184, 166, 0.15)",
    title: "Simulation What If?",
    desc: "Simulez des scénarios de catastrophe pour planifier les réponses.",
    tags: ["Scénarios", "< 30s calcul"],
  },
];

const LandingScreen = ({ navigation }) => {
  return (
    <SafeAreaView style={styles.container} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Hero Section */}
        <View style={styles.hero}>
          <View style={styles.heroBg} />
          <View style={styles.heroGlow1} />
          <View style={styles.heroGlow2} />

          <View style={styles.heroContent}>
            <View style={styles.badge}>
              <View style={styles.badgeDot} />
              <Text style={styles.badgeText}>Système opérationnel</Text>
            </View>

            <Logo size="large" />
            <Text style={styles.heroTitle}>Mitandrina</Text>
            <Text style={styles.heroSubtitle}>
              Plateforme de prévention et de gestion des catastrophes
            </Text>
            <Text style={styles.heroDesc}>
              MITANDRINA utilise l'intelligence artificielle pour prédire,
              détecter et coordonner les réponses aux catastrophes naturelles en
              temps réel.
            </Text>

            <View style={styles.heroButtons}>
              <TouchableOpacity
                style={styles.ctaButton}
                onPress={() => navigation.navigate("Login")}
                activeOpacity={0.9}
              >
                <View style={styles.ctaGradient}>
                  <Ionicons name="log-in" size={20} color="#fff" />
                  <Text style={styles.ctaText}>Se connecter</Text>
                </View>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.outlineButton}
                onPress={() => navigation.navigate("Register")}
                activeOpacity={0.8}
              >
                <Ionicons name="person-add" size={20} color="#059669" />
                <Text style={styles.outlineButtonText}>S'inscrire</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Features Section */}
        <View style={styles.featuresSection}>
          <View style={styles.sectionHeader}>
            <View style={styles.sectionBadge}>
              <Ionicons name="hardware-chip" size={14} color={theme.colors.textGray} />
              <Text style={styles.sectionBadgeText}>IA & Machine Learning</Text>
            </View>
            <Text style={styles.sectionTitle}>Technologies de pointe</Text>
          </View>

          <View style={styles.featuresGrid}>
            {features.map((feature, index) => (
              <View key={index} style={styles.featureCard}>
                <View
                  style={[styles.featureIcon, { backgroundColor: feature.bg }]}
                >
                  <Ionicons
                    name={feature.icon}
                    size={24}
                    color={feature.color}
                  />
                </View>
                <Text style={styles.featureTitle}>{feature.title}</Text>
                <Text style={styles.featureDesc}>{feature.desc}</Text>
                <View style={styles.tagRow}>
                  {feature.tags.map((tag, i) => (
                    <View
                      key={i}
                      style={[styles.tag, { backgroundColor: feature.bg }]}
                    >
                      <Text style={[styles.tagText, { color: feature.color }]}>
                        {tag}
                      </Text>
                    </View>
                  ))}
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* How It Works */}
        <View style={styles.howSection}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Comment ça marche</Text>
          </View>

          <View style={styles.stepsContainer}>
            {[
              {
                icon: "cloud-download",
                step: "1",
                title: "Collecte",
                desc: "Données satellites, météo et réseaux sociaux",
              },
              {
                icon: "analytics",
                step: "2",
                title: "Analyse IA",
                desc: "Modèles de deep learning en temps réel",
              },
              {
                icon: "search",
                step: "3",
                title: "Détection",
                desc: "Identification des risques et des dangers",
              },
              {
                icon: "notifications",
                step: "4",
                title: "Alerte",
                desc: "Notifications multicanal instantanées",
              },
              {
                icon: "navigate",
                step: "5",
                title: "Évacuation",
                desc: "Itinéraires optimaux vers les refuges",
              },
            ].map((item, index) => (
              <View key={index} style={styles.stepRow}>
                <View style={styles.stepNumber}>
                  <Text style={styles.stepNumberText}>{item.step}</Text>
                </View>
                <View style={styles.stepContent}>
                  <View style={styles.stepIconWrap}>
                    <Ionicons
                      name={item.icon}
                      size={20}
                      color={theme.colors.primary}
                    />
                  </View>
                  <View style={styles.stepTextWrap}>
                    <Text style={styles.stepTitle}>{item.title}</Text>
                    <Text style={styles.stepDesc}>{item.desc}</Text>
                  </View>
                </View>
                {index < 4 && <View style={styles.stepConnector} />}
              </View>
            ))}
          </View>
        </View>

        {/* Footer CTA */}
        <View style={styles.footerCta}>
          <Text style={styles.footerTitle}>
            Prêt à protéger votre communauté ?
          </Text>
          <Text style={styles.footerDesc}>
            Rejoignez MITANDRINA et restez informé des risques naturels en temps
            réel.
          </Text>
          <TouchableOpacity
            style={styles.ctaButton}
            onPress={() => navigation.navigate("Register")}
            activeOpacity={0.9}
          >
            <View style={styles.ctaGradientGreen}>
              <Ionicons name="rocket" size={20} color="#fff" />
              <Text style={styles.ctaText}>Créer un compte gratuit</Text>
            </View>
          </TouchableOpacity>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <Logo size="small" />
          <Text style={styles.footerText}>
            MITANDRINA © {new Date().getFullYear()} — Protection par l'IA
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgWhite,
  },
  scrollContent: {
    flexGrow: 1,
  },

  // Hero
  hero: {
    minHeight: 560,
    paddingTop: 40,
    paddingBottom: 60,
    paddingHorizontal: theme.spacing.lg,
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
    position: "relative",
  },
  heroBg: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: theme.colors.bgGray,
  },
  heroGlow1: {
    position: "absolute",
    top: -80,
    right: -80,
    width: 240,
    height: 240,
    borderRadius: 120,
    backgroundColor: "rgba(220, 38, 38, 0.08)",
  },
  heroGlow2: {
    position: "absolute",
    bottom: -60,
    left: -60,
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: "rgba(5, 150, 105, 0.06)",
  },
  heroContent: {
    alignItems: "center",
    zIndex: 1,
  },
  badge: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    backgroundColor: theme.colors.primaryLight,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
    borderRadius: 50,
    marginBottom: theme.spacing.lg,
  },
  badgeDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#22c55e",
  },
  badgeText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.primaryDark,
    letterSpacing: 0.5,
  },
  heroTitle: {
    fontSize: 36,
    fontWeight: theme.typography.weight.extrabold,
    color: theme.colors.textDark,
    marginTop: theme.spacing.md,
    letterSpacing: -0.5,
  },
  heroSubtitle: {
    fontSize: theme.typography.sizes.base,
    color: theme.colors.textGray,
    textAlign: "center",
    marginTop: theme.spacing.xs,
    lineHeight: 22,
  },
  heroDesc: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
    marginTop: theme.spacing.lg,
    lineHeight: 20,
    paddingHorizontal: theme.spacing.sm,
  },
  heroButtons: {
    flexDirection: "row",
    gap: theme.spacing.md,
    marginTop: theme.spacing.xl,
    flexWrap: "wrap",
    justifyContent: "center",
  },
  ctaButton: {
    borderRadius: theme.borderRadius.md,
    overflow: "hidden",
    elevation: 4,
    shadowColor: theme.colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
  },
  ctaGradient: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    paddingVertical: theme.spacing.md - 2,
    paddingHorizontal: theme.spacing.xl,
    backgroundColor: theme.colors.primary,
  },
  ctaGradientGreen: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    paddingVertical: theme.spacing.md - 2,
    paddingHorizontal: theme.spacing.xl,
    backgroundColor: theme.colors.primary,
  },
  ctaText: {
    fontSize: theme.typography.sizes.base,
    fontWeight: theme.typography.weight.bold,
    color: "#fff",
  },
  outlineButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
    paddingVertical: theme.spacing.md - 2,
    paddingHorizontal: theme.spacing.xl,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1.5,
    borderColor: theme.colors.primary,
    backgroundColor: theme.colors.primaryLight,
  },
  outlineButtonText: {
    fontSize: theme.typography.sizes.base,
    fontWeight: theme.typography.weight.bold,
    color: theme.colors.primary,
  },

  // Features Section
  featuresSection: {
    paddingHorizontal: theme.spacing.lg,
    paddingTop: theme.spacing.xxl,
    paddingBottom: theme.spacing.xl,
  },
  sectionHeader: {
    alignItems: "center",
    marginBottom: theme.spacing.xl,
  },
  sectionBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    backgroundColor: theme.colors.bgGray,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.xs + 2,
    borderRadius: 50,
    marginBottom: theme.spacing.sm,
  },
  sectionBadgeText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
  },
  sectionTitle: {
    fontSize: theme.typography.sizes.xxl,
    fontWeight: theme.typography.weight.bold,
    color: theme.colors.textDark,
    textAlign: "center",
  },
  featuresGrid: {
    gap: theme.spacing.md,
  },
  featureCard: {
    backgroundColor: theme.colors.bgWhite,
    borderRadius: theme.borderRadius.lg,
    borderWidth: 1,
    borderColor: theme.colors.border,
    padding: theme.spacing.lg,
  },
  featureIcon: {
    width: 48,
    height: 48,
    borderRadius: theme.borderRadius.md,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: theme.spacing.md,
  },
  featureTitle: {
    fontSize: theme.typography.sizes.lg,
    fontWeight: theme.typography.weight.bold,
    color: theme.colors.textDark,
    marginBottom: theme.spacing.xs,
  },
  featureDesc: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    lineHeight: 20,
    marginBottom: theme.spacing.md,
  },
  tagRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: theme.spacing.sm,
  },
  tag: {
    paddingHorizontal: theme.spacing.sm + 2,
    paddingVertical: 4,
    borderRadius: 50,
  },
  tagText: {
    fontSize: 11,
    fontWeight: theme.typography.weight.medium,
  },

  // How It Works
  howSection: {
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.xxl,
  },
  stepsContainer: {
    gap: 0,
  },
  stepRow: {
    position: "relative",
    flexDirection: "row",
    alignItems: "flex-start",
    gap: theme.spacing.md,
  },
  stepNumber: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: theme.colors.primary,
    alignItems: "center",
    justifyContent: "center",
    zIndex: 1,
  },
  stepNumberText: {
    fontSize: theme.typography.sizes.sm,
    fontWeight: theme.typography.weight.bold,
    color: "#fff",
  },
  stepContent: {
    flex: 1,
    flexDirection: "row",
    gap: theme.spacing.md,
    paddingBottom: theme.spacing.xl,
    paddingTop: 4,
  },
  stepIconWrap: {
    width: 40,
    height: 40,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.primaryLight,
    alignItems: "center",
    justifyContent: "center",
  },
  stepTextWrap: {
    flex: 1,
  },
  stepTitle: {
    fontSize: theme.typography.sizes.base,
    fontWeight: theme.typography.weight.semibold,
    color: theme.colors.textDark,
    marginBottom: 2,
  },
  stepDesc: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
  },
  stepConnector: {
    position: "absolute",
    left: 15,
    top: 32,
    width: 2,
    height: 32,
    backgroundColor: theme.colors.primaryLight,
  },

  // Footer CTA
  footerCta: {
    alignItems: "center",
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.xxl,
    marginHorizontal: theme.spacing.lg,
    marginBottom: theme.spacing.xl,
    borderRadius: theme.borderRadius.lg,
    borderWidth: 1,
    borderColor: theme.colors.border,
    backgroundColor: theme.colors.bgGray,
  },
  footerTitle: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: theme.typography.weight.bold,
    color: theme.colors.textDark,
    textAlign: "center",
    marginBottom: theme.spacing.sm,
  },
  footerDesc: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
    lineHeight: 20,
    marginBottom: theme.spacing.xl,
  },
  footer: {
    alignItems: "center",
    paddingVertical: theme.spacing.xl,
    paddingHorizontal: theme.spacing.lg,
    gap: theme.spacing.sm,
  },
  footerText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textMuted,
    textAlign: "center",
  },
});

export default LandingScreen;
