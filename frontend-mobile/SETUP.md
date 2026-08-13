# 🌪️ MITANDRINA Mobile - Guide de démarrage

## Architecture

### Structure du projet
```
src/
  ├── navigation/       # Navigation (RootNavigator, stacks)
  ├── screens/          # Écrans principaux
  ├── components/       # Composants réutilisables
  ├── services/         # Services API
  ├── context/          # Contexte React (Auth)
  └── theme/            # Thème global (couleurs, espacements, typographie)

App.js                  # Point d'entrée
package.json           # Dépendances
```

## Installation

### Prérequis
- Node.js >= 16
- npm ou yarn
- Expo CLI (`npm install -g expo-cli`)

### Étapes
1. **Cloner/accéder au projet**
```bash
cd frontend-mobile
```

2. **Installer les dépendances**
```bash
npm install
# ou
yarn install
```

3. **Configurer les variables d'environnement**
```bash
cp .env.example .env
# Éditer .env avec votre configuration
```

4. **Démarrer le serveur de développement**
```bash
# Tous les systèmes
npm start

# Ou directement
expo start
```

5. **Accéder à l'app**
- **Web**: Pressez `w` dans le terminal
- **iOS**: Pressez `i` (require macOS + Xcode)
- **Android**: Pressez `a` (require Android Studio/Emulator)

## Architecture de navigation

### Stack de navigation
- **Auth**: `LoginScreen` (non authentifié)
- **App** (authentifié):
  - `DashboardScreen` (accueil)
  - `AlertsStack` (alertes incendies)
  - `SheltersStack` (refuges)
  - `WeatherStack` (météo)
  - `ProfileStack` (profil)

### Flux d'authentification
1. L'app vérifie le token stocké dans `SecureStore`
2. Si token existe → affiche `TabNavigator`
3. Si token absent → affiche `AuthStack` (Login)

## Services

### API (`src/services/api.js`)
- Intercepteurs pour le token d'authentification
- Gestion des erreurs 401 (token expiré)
- Endpoints organisés par domaine (auth, users, alerts, etc)

### Contexte d'authentification (`src/context/AuthContext.js`)
- Gestion du state d'authentification
- Fonctions: `login`, `register`, `logout`, `updateUser`
- Stockage sécurisé du token avec `expo-secure-store`

## Composants réutilisables

### `Button`
```jsx
<Button 
  title="Action" 
  onPress={() => {}}
  variant="primary|secondary|danger|outline"
  size="small|medium|large"
  icon="icon-name"
  loading={false}
/>
```

### `Card`
```jsx
<Card padding="small|medium|large" shadow="sm|md|lg|xl">
  {content}
</Card>
```

### `Input`
```jsx
<Input
  label="Label"
  placeholder="..."
  value={value}
  onChangeText={setValue}
  icon="icon-name"
  secureTextEntry={false}
/>
```

### `Logo`
```jsx
<Logo size="small|medium|large" showText={true} />
```

## Thème

### Couleurs (`src/theme/colors.js`)
```javascript
theme.colors.primary       // Vert #22c55e
theme.colors.danger        // Rouge
theme.colors.textDark      // Texte sombre
theme.colors.bgWhite       // Fond blanc
```

### Espacements (`src/theme/spacing.js`)
```javascript
theme.spacing.xs   // 4px
theme.spacing.sm   // 8px
theme.spacing.md   // 16px
theme.spacing.lg   // 24px
theme.spacing.xl   // 32px
```

### Typographie (`src/theme/typography.js`)
```javascript
theme.typography.sizes.xs    // 12px
theme.typography.sizes.base  // 16px
theme.typography.sizes.lg    // 18px
```

## Écrans

### DashboardScreen
- Affichage des alertes récentes (3)
- Météo actuelle
- Widget de statut
- Actions rapides

### AlertsListScreen
- Liste des alertes avec pagination
- Filtres (Tous, Critique, Confirmés)
- Pull-to-refresh

### AlertDetailScreen
- Détails complets de l'alerte
- Localisation sur carte
- Refuges recommandés
- Bouton de confirmation

### SheltersScreen
- Liste des refuges avec capacité
- Recherche et localisation
- Navigation GPS
- Contact direct

### WeatherScreen
- Conditions actuelles
- Prévisions 5 jours
- Indice UV et risque feu
- Avertissements météo

### ProfileScreen
- Affichage du profil utilisateur
- Préférences (notifications, dark mode)
- À propos et support
- Déconnexion

## API Endpoints

### Authentification
- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/logout`

### Utilisateurs
- `GET /users/profile`
- `PUT /users/profile`
- `GET /users/preferences`
- `PUT /users/preferences`

### Alertes
- `GET /fire-detection/alerts`
- `GET /fire-detection/alerts/:id`
- `POST /fire-detection/alerts/:id/acknowledge`

### Refuges
- `GET /shelters`
- `GET /shelters/:id`

### Météo
- `GET /weather`
- `GET /weather/forecast`

## Bonnes pratiques UX/UI (du SKILL)

### Accessibilité (Critical)
✅ Contraste 4.5:1 minimum
✅ Cibles tactiles 44x44pt minimum
✅ Navigation au clavier
✅ Espacements 8px+ entre éléments

### Performance (High)
✅ Lazy loading des listes
✅ Images réactives
✅ Réduction des re-renders
✅ Virtualisation des listes légères

### Interactions (Critical)
✅ Feedback visuel immédiat (< 100ms)
✅ Touch targets confortables
✅ États visuels clairs (hover, pressed, disabled)
✅ Progression visible pour les async actions

### Layout (High)
✅ Mobile-first design
✅ Pas de scroll horizontal
✅ Safe area respectée
✅ Orientation supportée

## Débogage

### DevTools
```bash
expo start  # Puis Shift+M pour les options
```

### Logs
```javascript
console.log('Debug message');
// Visible dans le terminal Expo
```

### Connexion backend
Les appels API pointent par défaut vers `http://localhost:3000/api`.
Modifier `REACT_APP_API_URL` dans `.env` si nécessaire.

## Prochaines étapes

- [ ] Implémenter WebSockets pour notifications temps réel
- [ ] Ajouter localisation GPS
- [ ] Intégrer cartes (react-native-maps)
- [ ] Ajouter biométrie (face/empreinte)
- [ ] Tests unitaires et E2E
- [ ] Analytics et crash reporting
- [ ] Build APK/IPA pour publication
