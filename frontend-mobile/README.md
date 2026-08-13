// 🌪️ MITANDRINA - README Frontend Mobile

# 📱 Mitandrina Mobile

Application mobile React Native (Expo) pour la gestion des alertes incendies, refuges et informations météo.

## 🎯 Objectif

Fournir aux utilisateurs une plateforme mobile pour:
- Recevoir des alertes incendies en temps réel
- Localiser les refuges disponibles
- Consulter les conditions météo et indices de risque
- Gérer leur profil et préférences
- Accéder rapidement aux informations critiques

## ✨ Fonctionnalités principales

### 🔐 Authentification
- Connexion/inscription sécurisée
- Stockage du token avec `expo-secure-store`
- Récupération automatique de session

### 🔔 Tableau de bord
- Vue d'ensemble des alertes récentes
- Conditions météo actuelles
- Actions rapides vers les refuges/météo

### ⚠️ Alertes incendies
- Liste complète des alertes
- Filtrage (Tous, Critique, Confirmés)
- Détails complets de chaque alerte
- Confirmation d'alerte par l'utilisateur
- Localisation et refuges recommandés

### 🏠 Refuges
- Recherche et localisation
- Affichage de la capacité en temps réel
- Équipements disponibles
- Navigation GPS
- Contact direct

### 🌦️ Météo
- Conditions actuelles détaillées
- Prévisions 5 jours
- Indice UV
- Indice de risque incendie
- Avertissements météorologiques

### 👤 Profil utilisateur
- Édition des informations personnelles
- Gestionnaire de préférences (notifications, dark mode, etc.)
- Accès aux paramètres et support

## 🏗️ Architecture

```
app/
├── App.js                      # Point d'entrée, AuthProvider
├── src/
│   ├── navigation/             # Navigation (5 stacks + tabs)
│   ├── screens/                # 8 écrans principaux
│   ├── components/             # 4 composants réutilisables
│   ├── services/               # Service API centralisé
│   ├── context/                # Contexte d'authentification
│   ├── theme/                  # Design tokens (couleurs, espacement)
│   ├── hooks.js                # Hooks personnalisés
│   ├── utils.js                # Utilitaires globaux
│   └── constants.js            # Constantes métier
```

## 🎨 Design System

Basé sur le SKILL UI/UX Pro Max avec priorités appliquées:

### Priorité 1 - Accessibilité
- ✅ Contraste WCAG AA minimum (4.5:1)
- ✅ Targets tactiles 44x44pt
- ✅ Navigation aux gestes naturels
- ✅ Aria-labels sur tous les composants critiques

### Priorité 2 - Interactions tactiles
- ✅ 8px+ d'espacement entre éléments
- ✅ Feedback visuel immédiat (< 100ms)
- ✅ États visuels distincts (hover/pressed/disabled)
- ✅ Indicateurs de chargement clairs

### Priorité 3 - Performance
- ✅ Optimisation des images
- ✅ Lazy loading des listes
- ✅ FlatList virtualisée (si > 50 items)
- ✅ Réduction des re-renders

### Priorité 4 - Style cohérent
- ✅ Design minimaliste et professionnel
- ✅ Palette de couleurs limitée (3 primaires)
- ✅ Icons SVG uniquement (Ionicons)
- ✅ Espacement régulier (4, 8, 16, 24, 32, 48px)

### Priorité 5 - Responsive
- ✅ Mobile-first (375px)
- ✅ Pas de scroll horizontal
- ✅ Safe area respectée
- ✅ Support orientation verticale

## 🎨 Palette de couleurs

- **Primaire**: `#22c55e` (Vert - Sécurité/Santé)
- **Danger**: `#dc3545` (Rouge - Alertes critiques)
- **Texte Dark**: `#0f172a` (Bleu très sombre)
- **Texte Muted**: `#94a3b8` (Gris neutre)
- **Backgrounds**: Blanc et gris très clair

## 📦 Dépendances principales

- `react-native`: 0.81.5
- `expo`: ~54.0.33
- `@react-navigation/*`: Navigation multi-stack
- `axios`: HTTP client avec intercepteurs
- `expo-secure-store`: Stockage sécurisé du token
- `@expo/vector-icons`: Icons Ionicons

## 🚀 Guide de démarrage

### Installation
```bash
cd frontend-mobile
npm install
cp .env.example .env
npm start
```

### Développement
```bash
# Web (debug facile)
expo start
# Puis presser 'w'

# Android
expo start --android

# iOS
expo start --ios
```

### Build
```bash
# APK Android
expo build:android

# IPA iOS
expo build:ios
```

## 📡 Communication API

### Base URL
Par défaut: `http://localhost:3000/api` (modifiable dans `.env`)

### Authentification
Tous les appels incluent le header: `Authorization: Bearer {token}`

### Endpoints prédéfinis
- `POST /auth/login`
- `GET /fire-detection/alerts`
- `GET /shelters`
- `GET /weather`
- etc. (voir [API.md](../API.md))

## 🔄 Flux d'authentification

```
App.js (AuthProvider en wrapper)
  ↓
AuthContext.useAuth() (check SecureStore)
  ↓
isSignedIn? 
  ├─ true  → RootNavigator (TabNavigator)
  └─ false → AuthStack (LoginScreen)
      ↓
   Login → api.login() → SecureStore.setItem(token) → RootNavigator
```

## 🛠️ Hooks personnalisés

### `useFetch(apiFn, dependencies)`
Fetch avec loading/error/retry.

### `usePaginatedFetch(apiFn, pageSize)`
Pagination automatique avec `loadMore()`.

### `useForm(initialValues, onSubmit)`
Gestion d'un formulaire avec validation.

### `useDebouncedFetch(searchFn, delay)`
Recherche avec debounce (500ms par défaut).

## 📱 Écrans détail

### LoginScreen
- Inputs email/password
- "Se souvenir de moi"
- Options SSO (Google, Microsoft, GitHub)
- Lien inscription

### DashboardScreen
- Salutation personnalisée
- Météo actuelle (temp, humidité, vent)
- Top 3 alertes récentes
- Actions rapides (Refuges, Météo, Profil)

### AlertsListScreen
- Filtres: Tous, Critique, Confirmés
- Carte d'alerte: sévérité, localisation, heure
- Pull-to-refresh
- Navigation vers détail

### AlertDetailScreen
- Badge de statut (Actif/Confirmé)
- Localisation avec coordonnées
- Données techniques (confiance, température, type)
- Sources détectées
- Refuges proches (top 3)
- Bouton de confirmation

### SheltersScreen
- Barre de recherche
- Carte refuge: capacité, équipements
- Actions: Navigation GPS, Appel direct

### WeatherScreen
- Conditions actuelles (large affichage)
- Détails: Humidité, Vent, Pression, Visibilité
- Indice UV + Risque Incendie
- Prévisions (scroll horizontal)
- Avertissements si présents

### ProfileScreen
- Avatar + infos utilisateur
- Sections: Infos perso, Préférences, À propos, Support
- Switches pour notifications, dark mode
- Bouton déconnexion

### NotificationsScreen
- Liste notifications (lues/non-lues)
- Type d'icône selon notification
- Suppression individuelle
- Pull-to-refresh

## ⚠️ Bonnes pratiques respectées

✅ **Accessibilité**
- Cibles tactiles > 44x44pt
- Labels explicites sur tous les champs
- Alternations de couleur + icônes (pas couleur seule)
- Support des états visuels clairs

✅ **Performance**
- Images optimisées (WebP/AVIF via API)
- Lazy loading des listes
- Réduction des re-renders via memoization
- Compression des actions async

✅ **UX**
- Feedback visuel immédiat (< 100ms)
- États distincts (loading, error, empty)
- Navigation prévisible et intuitive
- Safe areas respectées

✅ **Code**
- Structure modulaire par domaine
- Réutilisabilité des composants
- Hooks personnalisés pour logique commune
- Gestion centralisée du state (Context API)

## 🐛 Débogage

### Logs de navigation
```javascript
<NavigationContainer onStateChange={(state) => console.log('Nav:', state)}>
```

### Logs API
```javascript
// Tous les appels sont loggés via axios interceptors
```

### Redux DevTools (futur)
Option pour next version si complexité du state augmente.

## 📝 TODO

- [ ] Offline mode (AsyncStorage fallback)
- [ ] Push notifications (Expo Notifications)
- [ ] Location services (Geolocation API)
- [ ] Maps intégrée (React Native Maps)
- [ ] Biometric auth (Expo SecureStore extension)
- [ ] Dark mode global (AppDarkMode context)
- [ ] Tests E2E (Detox)
- [ ] Analytics (Amplitude/Segment)
- [ ] Sentry pour crash reporting
- [ ] Build et distribution (EAS Build)

## 📞 Support

- Email: support@mitandrina.com
- Doc: Voir `SETUP.md`
- Issues: GitHub Discussions
