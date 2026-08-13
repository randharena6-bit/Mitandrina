import React, { useState } from "react";
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Text,
  TouchableOpacity,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import Logo from "../components/Logo";
import Input from "../components/Input";
import Button from "../components/Button";
import Card from "../components/Card";
import theme from "../theme";
import { isValidEmail } from "../utils";

const ForgotPasswordScreen = ({ navigation }) => {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSendReset = async () => {
    if (!isValidEmail(email)) {
      setError("Veuillez entrer une adresse email valide");
      return;
    }

    setLoading(true);
    setError("");

    try {
      setSent(true);
    } catch (err) {
      setError("Erreur lors de l'envoi. Veuillez réessayer.");
    } finally {
      setLoading(false);
    }
  };

  if (sent) {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <View style={styles.content}>
            <Card padding="large" style={styles.card}>
              <View style={styles.successContainer}>
                <View style={styles.successIcon}>
                  <Ionicons name="checkmark-circle" size={72} color={theme.colors.primary} />
                </View>
                <Text style={styles.successTitle}>Email envoyé</Text>
                <Text style={styles.successText}>
                  Nous avons envoyé un lien de réinitialisation à {email}. Vérifiez votre boîte mail.
                </Text>
                <Button
                  title="Retour à la connexion"
                  onPress={() => navigation.navigate("Login")}
                  style={styles.button}
                />
              </View>
            </Card>
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        style={styles.flex}
      >
        <ScrollView
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.content}>
            <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
              <Ionicons name="chevron-back" size={24} color={theme.colors.primary} />
              <Text style={styles.backText}>Retour</Text>
            </TouchableOpacity>

            <Card padding="large" style={styles.card}>
              <View style={styles.headerSection}>
                <Logo size="medium" />
              </View>

              <Text style={styles.title}>Mot de passe oublié ?</Text>
              <Text style={styles.subtitle}>
                Entrez votre adresse email pour recevoir un lien de réinitialisation
              </Text>

              {error ? (
                <View style={styles.errorBanner}>
                  <Ionicons name="alert-circle" size={16} color={theme.colors.danger} />
                  <Text style={styles.errorBannerText}>{error}</Text>
              </View>
            ) : null}

            <Input
                label="Adresse email"
                placeholder="exemple@email.com"
                value={email}
                onChangeText={(text) => { setEmail(text); setError(""); }}
                keyboardType="email-address"
                autoCapitalize="none"
                icon="mail-outline"
              />

              <Button
                title="Envoyer le lien"
                onPress={handleSendReset}
                loading={loading}
                size="large"
                style={styles.button}
              />
            </Card>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.bgGray,
  },
  flex: { flex: 1 },
  scrollContent: {
    flexGrow: 1,
    padding: theme.spacing.lg,
    justifyContent: "center",
  },
  content: {
    alignSelf: "stretch",
  },
  backButton: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: theme.spacing.lg,
  },
  backText: {
    fontSize: theme.typography.sizes.base,
    color: theme.colors.primary,
    fontWeight: "600",
    marginLeft: theme.spacing.xs,
  },
  card: {
    backgroundColor: theme.colors.bgWhite,
  },
  headerSection: {
    alignItems: "center",
    marginBottom: theme.spacing.lg,
  },
  title: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.sm,
  },
  subtitle: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    lineHeight: 20,
    marginBottom: theme.spacing.lg,
  },
  errorBanner: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: theme.colors.dangerLight,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: theme.spacing.sm + 2,
    borderRadius: theme.borderRadius.sm,
    marginBottom: theme.spacing.md,
  },
  errorBannerText: {
    flex: 1,
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.danger,
    fontWeight: "500",
    marginLeft: theme.spacing.sm,
  },
  button: {
    marginTop: theme.spacing.sm,
  },
  successContainer: {
    alignItems: "center",
    paddingVertical: theme.spacing.md,
  },
  successIcon: {
    marginBottom: theme.spacing.lg,
  },
  successTitle: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: "700",
    color: theme.colors.textDark,
    marginBottom: theme.spacing.md,
  },
  successText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
    lineHeight: 20,
    marginBottom: theme.spacing.xl,
  },
});

export default ForgotPasswordScreen;
