import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";

const Logo = ({ size = "medium", showText = true }) => {
  const getIconSize = () => {
    switch (size) {
      case "small": return 28;
      case "medium": return 36;
      case "large": return 56;
      default: return 36;
    }
  };

  const getTextSize = () => {
    switch (size) {
      case "small": return theme.typography.sizes.lg;
      case "medium": return theme.typography.sizes.xxl;
      case "large": return theme.typography.sizes.xxxl;
      default: return theme.typography.sizes.xxl;
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.iconWrap}>
        <Ionicons
          name="shield-checkmark"
          size={getIconSize()}
          color={theme.colors.danger}
        />
      </View>
      {showText && (
        <Text style={[styles.text, { fontSize: getTextSize() }]}>
          MITANDRINA
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: "row",
    alignItems: "center",
    gap: theme.spacing.sm,
  },
  iconWrap: {
    alignItems: "center",
    justifyContent: "center",
  },
  text: {
    fontWeight: theme.typography.weight.extrabold,
    color: theme.colors.textDark,
    letterSpacing: -0.5,
  },
});

export default Logo;
