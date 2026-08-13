import React from "react";
import { View, StyleSheet } from "react-native";
import theme from "../theme";

const Card = ({ children, style, padding = "medium", shadow = "sm" }) => {
  const getPaddingStyle = () => {
    switch (padding) {
      case "small": return { padding: theme.spacing.sm + 2 };
      case "medium": return { padding: theme.spacing.md };
      case "large": return { padding: theme.spacing.lg };
      case "none": return { padding: 0 };
      default: return { padding: theme.spacing.md };
    }
  };

  const getShadowStyle = () => {
    switch (shadow) {
      case "none": return {};
      case "sm": return theme.shadows.sm;
      case "md": return theme.shadows.md;
      case "lg": return theme.shadows.lg;
      case "xl": return theme.shadows.xl;
      default: return theme.shadows.sm;
    }
  };

  return (
    <View style={[styles.card, getPaddingStyle(), getShadowStyle(), style]}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: theme.colors.bgWhite,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
});

export default Card;
