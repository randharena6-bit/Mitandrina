# 🌪️ MITANDRINA Mobile - Fichier de configuration

## Configuration de base

Cette application mobile utilise:
- **Framework**: React Native avec Expo
- **Navigation**: React Navigation (Stack + Bottom Tabs)
- **State Management**: React Context API
- **HTTP Client**: Axios avec intercepteurs
- **Stockage sécurisé**: expo-secure-store
- **Icons**: Expo Vector Icons (Ionicons)

## Fichiers de configuration

### `.env` - Variables d'environnement
```
REACT_APP_API_URL=http://localhost:3000/api
REACT_APP_ENV=development
REACT_APP_ENABLE_DEBUG=false
```

### `app.json` - Configuration Expo
- Permissions nécessaires (localisation, notifications, camera)
- Icons et splash screen
- Orientation (portrait uniquement)
- Adaptée par plateforme (iOS/Android)

### `package.json` - Dépendances
Voir le fichier principal pour la liste complète des dépendances.

## Architecture des fichiers

```
src/
├── navigation/
│   └── RootNavigator.js         # Stack auth + Tab navigator
├── screens/                      # 10 écrans principaux
├── components/                   # Composants réutilisables (4)
├── services/
│   ├── api.js                   # Axios client centralisé
│   ├── storage.js               # Gestion SecureStore
│   ├── notifications.js         # Expo Notifications wrapper
│   └── analytics.js             # Service d'analytics
├── context/
│   └── AuthContext.js           # State d'authentification global
├── theme/                        # Design tokens
│   ├── colors.js
│   ├── spacing.js
│   ├── typography.js
│   └── index.js
├── hooks/                        # Hooks custom
│   ├── useAppInitialization.js
│   └── useLocation.js
├── constants.js                  # Constantes métier
├── utils.js                      # Utilitaires globaux
└── hooks.js                      # Hooks API (useFetch, useForm, etc)
```

## Points de configuration clés

### API Backend
- URL par défaut: `http://localhost:3000/api`
- Modifiable via `REACT_APP_API_URL` dans `.env`
- Authentification via Bearer token
- Déconnexion auto sur 401

### Authentification
- Token stocké dans `expo-secure-store` (sécurisé)
- Restauration auto au démarrage
- Context API pour accès global
- Logout nettoie aussi les préférences

### Permissions (Android/iOS)
À activer si nécessaire:
- Localisation (GPS)
- Notifications push
- Appareil photo
- Calendrier
- Contacts

### Notifications
- Configuration via `expo-notifications`
- Listeners activés au démarrage
- Analytics track des interactions
- Token de notification envoyé au backend

### Analytics
- Service simple en mémoire
- À remplacer par Amplitude/Segment en prod
- Track: events, screen views, user actions, errors

## Développement local

### Configuration API locale
```bash
# Backend sur http://localhost:3000
# Mobile connect via même réseau

# Android: adb reverse tcp:3000 tcp:3000
# iOS: direct connection aux 192.168.x.x addresses
```

### Environment
- `development`: Debug actif, API errors visibles
- `staging`: Préparation production
- `production`: Optimisé, analytics complète

## Performance

### Optimisations appliquées
- ✅ Lazy loading des listes (FlatList)
- ✅ Memoization des componentes
- ✅ Images optimisées via API
- ✅ Debounce sur recherche
- ✅ Throttle si nécessaire

### Monitoring (à implémenter)
- Sentry pour crash reporting
- LogRocket pour session replay
- Amplitude pour analytics avancée

## Sécurité

### Données sensibles
- Token: SecureStore (inaccessible)
- User data: Context + SecureStore
- Préférences: SecureStore
- Cache: AsyncStorage (non-sensible)

### API
- HTTPS en production
- Certificate pinning (optional)
- CORS configuré côté backend
- Rate limiting recommandé

### Code
- Secrets NOT en code
- Pas de logs de sensitive data
- Validation côté client + serveur
- Sanitization inputs

## Testing

### À implémenter
- Jest + React Native Testing Library
- E2E avec Detox
- Workflow GitHub Actions

## Deployment

### Build APK (Android)
```bash
eas build --platform android --type apk
```

### Build IPA (iOS)
```bash
eas build --platform ios
```

### Submission
- Google Play Store (Android)
- Apple App Store (iOS)
- Microsoft Store (Windows)
