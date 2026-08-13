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
import { useAuth } from "../context/AuthContext";
import { isValidEmail, isValidPassword } from "../utils";

const RegisterScreen = ({ navigation }) => {
  const { register } = useAuth();
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: "",
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [showPasswords, setShowPasswords] = useState(false);

  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = "Le nom est requis";
    }

    if (!isValidEmail(formData.email)) {
      newErrors.email = "Email invalide";
    }

    if (!isValidPassword(formData.password)) {
      newErrors.password = "Au moins 8 caractères requis";
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = "Les mots de passe ne correspondent pas";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleRegister = async () => {
    if (!validateForm()) return;

    setLoading(true);
    const result = await register({
      name: formData.name,
      email: formData.email,
      password: formData.password,
    });
    setLoading(false);

    if (result.success) {
    } else {
      setErrors({ submit: result.error });
    }
  };

  const updateField = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

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
          <View style={styles.topSection}>
            <Logo size="medium" />
            <Text style={styles.appName}>Créer un compte</Text>
            <Text style={styles.tagline}>
              Rejoignez Mitandrina dès maintenant
            </Text>
          </View>

          <Card padding="large" style={styles.card}>
            {errors.submit ? (
              <View style={styles.errorBanner}>
                <Ionicons name="alert-circle" size={16} color={theme.colors.danger} />
                <Text style={styles.errorBannerText}>{errors.submit}</Text>
              </View>
            ) : null}

            <Input
              label="Nom complet"
              placeholder="Jean Dupont"
              value={formData.name}
              onChangeText={(text) => updateField("name", text)}
              icon="person-outline"
              error={errors.name}
            />

            <Input
              label="Adresse email"
              placeholder="exemple@email.com"
              value={formData.email}
              onChangeText={(text) => updateField("email", text)}
              keyboardType="email-address"
              autoCapitalize="none"
              icon="mail-outline"
              error={errors.email}
            />

            <Input
              label="Mot de passe"
              placeholder="••••••••"
              value={formData.password}
              onChangeText={(text) => updateField("password", text)}
              secureTextEntry={!showPasswords}
              icon="lock-closed-outline"
              onTogglePassword={() => setShowPasswords(!showPasswords)}
              error={errors.password}
            />

            <Input
              label="Confirmer le mot de passe"
              placeholder="••••••••"
              value={formData.confirmPassword}
              onChangeText={(text) => updateField("confirmPassword", text)}
              secureTextEntry={!showPasswords}
              icon="lock-closed-outline"
              error={errors.confirmPassword}
            />

            <Text style={styles.termsText}>
              En créant un compte, j'accepte les{" "}
              <Text style={styles.termsLink}>conditions d'utilisation</Text>
            </Text>

            <Button
              title="S'inscrire"
              onPress={handleRegister}
              loading={loading}
              size="large"
              style={styles.registerButton}
            />

            <View style={styles.loginContainer}>
              <Text style={styles.loginText}>Vous avez déjà un compte ? </Text>
              <TouchableOpacity onPress={() => navigation.navigate("Login")}>
                <Text style={styles.loginLink}>Se connecter</Text>
              </TouchableOpacity>
            </View>
          </Card>
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
  topSection: {
    alignItems: "center",
    marginBottom: theme.spacing.xl,
  },
  appName: {
    fontSize: theme.typography.sizes.xl,
    fontWeight: theme.typography.weight.extrabold,
    color: theme.colors.textDark,
    marginTop: theme.spacing.sm,
  },
  tagline: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
    textAlign: "center",
    marginTop: theme.spacing.xs,
  },
  card: {
    backgroundColor: theme.colors.bgWhite,
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
  termsText: {
    fontSize: theme.typography.sizes.xs,
    color: theme.colors.textGray,
    lineHeight: 18,
    textAlign: "center",
    marginVertical: theme.spacing.md,
  },
  termsLink: {
    fontWeight: theme.typography.weight.bold,
    color: theme.colors.primary,
  },
  registerButton: {
    marginBottom: theme.spacing.lg,
  },
  loginContainer: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
  },
  loginText: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.textGray,
  },
  loginLink: {
    fontSize: theme.typography.sizes.sm,
    color: theme.colors.primary,
    fontWeight: theme.typography.weight.bold,
  },
});

export default RegisterScreen;
