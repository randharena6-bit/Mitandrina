import React from "react";
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  View,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import theme from "../theme";

const Button = ({
  title,
  onPress,
  variant = "primary",
  size = "medium",
  disabled = false,
  loading = false,
  icon,
  style,
}) => {
  const getButtonStyle = () => {
    const base = [styles.button];

    if (variant === "primary") base.push(styles.primary);
    else if (variant === "secondary") base.push(styles.secondary);
    else if (variant === "danger") base.push(styles.danger);
    else if (variant === "outline") base.push(styles.outline);
    else if (variant === "ghost") base.push(styles.ghost);

    if (size === "small") base.push(styles.small);
    else if (size === "large") base.push(styles.large);
    else base.push(styles.medium);

    if (disabled) base.push(styles.disabled);

    return base;
  };

  const getTextStyle = () => {
    const base = [styles.text];

    if (variant === "outline") base.push(styles.outlineText);
    else if (variant === "ghost") base.push(styles.ghostText);
    else if (variant === "secondary") base.push(styles.secondaryText);

    if (size === "small") base.push(styles.smallText);
    else if (size === "large") base.push(styles.largeText);

    return base;
  };

  const getIconSize = () => {
    switch (size) {
      case "small": return 16;
      case "large": return 22;
      default: return 20;
    }
  };

  const getIconColor = () => {
    if (disabled) return theme.colors.textMuted;
    if (variant === "outline" || variant === "ghost") return theme.colors.primary;
    if (variant === "secondary") return theme.colors.textGray;
    return "#fff";
  };

  return (
    <TouchableOpacity
      style={[getButtonStyle(), style]}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.85}
    >
      {loading ? (
        <ActivityIndicator
          size="small"
          color={disabled ? theme.colors.textMuted : variant === "outline" || variant === "ghost" ? theme.colors.primary : "#fff"}
        />
      ) : (
        <View style={styles.content}>
          {icon && (
            typeof icon === "string" ? (
              <Ionicons name={icon} size={getIconSize()} color={getIconColor()} />
            ) : (
              icon
            )
          )}
          {title ? <Text style={getTextStyle()}>{title}</Text> : null}
        </View>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: theme.borderRadius.md,
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
  },
  content: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: theme.spacing.sm,
  },
  primary: {
    backgroundColor: theme.colors.primary,
  },
  secondary: {
    backgroundColor: theme.colors.bgGray,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
  danger: {
    backgroundColor: theme.colors.danger,
  },
  outline: {
    backgroundColor: "transparent",
    borderWidth: 1.5,
    borderColor: theme.colors.primary,
  },
  ghost: {
    backgroundColor: "transparent",
  },
  small: {
    paddingVertical: theme.spacing.xs + 2,
    paddingHorizontal: theme.spacing.md,
  },
  medium: {
    paddingVertical: theme.spacing.md - 2,
    paddingHorizontal: theme.spacing.lg,
  },
  large: {
    paddingVertical: theme.spacing.md + 2,
    paddingHorizontal: theme.spacing.xl,
  },
  disabled: {
    opacity: 0.45,
  },
  text: {
    color: "#fff",
    fontSize: theme.typography.sizes.base,
    fontWeight: theme.typography.weight.semibold,
  },
  outlineText: {
    color: theme.colors.primary,
  },
  ghostText: {
    color: theme.colors.primary,
  },
  secondaryText: {
    color: theme.colors.textDark,
  },
  smallText: {
    fontSize: theme.typography.sizes.sm,
  },
  largeText: {
    fontSize: theme.typography.sizes.lg,
  },
});

export default Button;
