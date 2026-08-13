// 🌪️ MITANDRINA - Contexte d'authentification
import React, {
  createContext,
  useReducer,
  useCallback,
  useEffect,
} from "react";
import * as SecureStore from "expo-secure-store";
import api from "../services/api";

export const AuthContext = createContext({
  state: {
    isLoading: true,
    isSignedIn: false,
    user: null,
    token: null,
  },
  login: async (email, password) => {},
  register: async (userData) => {},
  logout: async () => {},
  restoreToken: async () => {},
});

const initialState = {
  isLoading: true,
  isSignedIn: false,
  user: null,
  token: null,
};

const authReducer = (state, action) => {
  switch (action.type) {
    case "RESTORE_TOKEN":
      return {
        ...state,
        isLoading: false,
        isSignedIn: !!action.payload.token,
        token: action.payload.token,
        user: action.payload.user,
      };
    case "SIGN_IN":
      return {
        ...state,
        isSignedIn: true,
        user: action.payload.user,
        token: action.payload.token,
      };
    case "SIGN_UP":
      return {
        ...state,
        isSignedIn: true,
        user: action.payload.user,
        token: action.payload.token,
      };
    case "SIGN_OUT":
      return {
        ...state,
        isSignedIn: false,
        user: null,
        token: null,
      };
    case "UPDATE_USER":
      return {
        ...state,
        user: { ...state.user, ...action.payload },
      };
    default:
      return state;
  }
};

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Restaurer le token au démarrage
  const restoreToken = useCallback(async () => {
    try {
      const token = await SecureStore.getItemAsync("authToken");
      const userStr = await SecureStore.getItemAsync("user");

      if (token && userStr) {
        const user = JSON.parse(userStr);
        api.setAuthToken(token);
        dispatch({
          type: "RESTORE_TOKEN",
          payload: { token, user },
        });
      } else {
        dispatch({
          type: "RESTORE_TOKEN",
          payload: { token: null, user: null },
        });
      }
    } catch (error) {
      console.error("Erreur restauration token:", error);
      dispatch({
        type: "RESTORE_TOKEN",
        payload: { token: null, user: null },
      });
    }
  }, []);

  // Connexion
  const login = useCallback(async (email, password) => {
    try {
      const response = await api.login(email, password);
      const { token, user } = response.data;

      await SecureStore.setItemAsync("authToken", token);
      await SecureStore.setItemAsync("user", JSON.stringify(user));
      api.setAuthToken(token);

      dispatch({
        type: "SIGN_IN",
        payload: { token, user },
      });

      return { success: true, user };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || "Erreur de connexion",
      };
    }
  }, []);

  // Inscription
  const register = useCallback(async (userData) => {
    try {
      const response = await api.register(userData);
      const { token, user } = response.data;

      await SecureStore.setItemAsync("authToken", token);
      await SecureStore.setItemAsync("user", JSON.stringify(user));
      api.setAuthToken(token);

      dispatch({
        type: "SIGN_UP",
        payload: { token, user },
      });

      return { success: true, user };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || "Erreur inscription",
      };
    }
  }, []);

  // Déconnexion
  const logout = useCallback(async () => {
    try {
      await api.logout();
      await SecureStore.deleteItemAsync("authToken");
      await SecureStore.deleteItemAsync("user");
      api.clearAuthToken();

      dispatch({ type: "SIGN_OUT" });
    } catch (error) {
      console.error("Erreur déconnexion:", error);
    }
  }, []);

  // Mettre à jour utilisateur
  const updateUser = useCallback(async (userData) => {
    try {
      const response = await api.updateProfile(userData);
      const updated = response.data.user;

      await SecureStore.setItemAsync("user", JSON.stringify(updated));
      dispatch({
        type: "UPDATE_USER",
        payload: updated,
      });

      return { success: true, user: updated };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || "Erreur mise à jour",
      };
    }
  }, []);

  useEffect(() => {
    restoreToken();
  }, [restoreToken]);

  const value = {
    state,
    login,
    register,
    logout,
    updateUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = React.useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth doit être utilisé avec AuthProvider");
  }
  return context;
};
