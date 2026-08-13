// 🌪️ MITANDRINA - Storage utilities
import * as SecureStore from "expo-secure-store";

const STORAGE_KEY_PREFIX = "mitandrina_";

/**
 * Sauvegarde une valeur de manière sécurisée
 */
export const secureSet = async (key, value) => {
  try {
    await SecureStore.setItemAsync(
      `${STORAGE_KEY_PREFIX}${key}`,
      JSON.stringify(value),
    );
    return true;
  } catch (error) {
    console.error(`Erreur secure set (${key}):`, error);
    return false;
  }
};

/**
 * Récupère une valeur de manière sécurisée
 */
export const secureGet = async (key) => {
  try {
    const value = await SecureStore.getItemAsync(`${STORAGE_KEY_PREFIX}${key}`);
    return value ? JSON.parse(value) : null;
  } catch (error) {
    console.error(`Erreur secure get (${key}):`, error);
    return null;
  }
};

/**
 * Supprime une valeur de manière sécurisée
 */
export const secureRemove = async (key) => {
  try {
    await SecureStore.deleteItemAsync(`${STORAGE_KEY_PREFIX}${key}`);
    return true;
  } catch (error) {
    console.error(`Erreur secure remove (${key}):`, error);
    return false;
  }
};

/**
 * Vide tout le stockage sécurisé
 */
export const secureClear = async () => {
  try {
    // Note: SecureStore n'a pas de méthode clear natif, il faut le faire manuellement
    const keysToDelete = ["authToken", "user", "preferences"];
    await Promise.all(keysToDelete.map((key) => secureRemove(key)));
    return true;
  } catch (error) {
    console.error("Erreur secure clear:", error);
    return false;
  }
};

export default {
  secureSet,
  secureGet,
  secureRemove,
  secureClear,
};
