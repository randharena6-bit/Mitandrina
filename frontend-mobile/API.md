# 🌪️ MITANDRINA Mobile - API Integration Guide

## Endpoints implémentés

### Authentification

#### `POST /auth/login`
```javascript
// Request
{ email: "user@example.com", password: "..." }

// Response
{ 
  token: "jwt_token",
  user: { id, name, email, ... }
}
```

#### `POST /auth/register`
```javascript
// Request
{ name: "John", email: "john@example.com", password: "..." }

// Response
{ 
  token: "jwt_token",
  user: { id, name, email, ... }
}
```

#### `POST /auth/logout`
Invalide le token côté serveur.

### Utilisateurs

#### `GET /users/profile`
Récupère le profil actuel.

#### `PUT /users/profile`
```javascript
// Request
{ name: "New Name", phone: "..." }

// Response
{ user: { ... } }
```

#### `GET /users/preferences`
Récupère les préférences utilisateur.

#### `PUT /users/preferences`
```javascript
// Request
{ notifications: true, darkMode: false, ... }
```

### Alertes incendies

#### `GET /fire-detection/alerts`
```javascript
// Query params
?limit=20&page=1&sort="-createdAt"&severity=critical

// Response
{ 
  data: [
    { 
      id, location, latitude, longitude, 
      severity, confidence, temperature,
      createdAt, acknowledged, ...
    }
  ],
  total, page, pageSize
}
```

#### `GET /fire-detection/alerts/:id`
Détails d'une alerte spécifique.

#### `POST /fire-detection/alerts/:id/acknowledge`
Marquer une alerte comme confirmée.

#### `POST /fire-detection/alerts/subscribe`
```javascript
// Request
{ 
  latitude, longitude,
  radius: 50000, // en mètres
  minSeverity: "high"
}
```

### Refuges

#### `GET /shelters`
```javascript
// Query params
?latitude=47.5&longitude=4.5&radius=50000&limit=20

// Response
{
  data: [
    {
      id, name, address,
      latitude, longitude,
      capacity, occupancy,
      amenities: { water, food, medical, ... },
      phone, email, website,
      distance, ...
    }
  ]
}
```

#### `GET /shelters/:id`
Détails d'un refuge spécifique.

#### `POST /shelters/:id/report`
```javascript
// Request
{ 
  issue: "capacity_exceeded" | "not_available" | "contact_issue",
  details: "..."
}
```

### Météo

#### `GET /weather`
```javascript
// Query params
?latitude=47.5&longitude=4.5

// Response
{
  location: "Paris",
  temp: 25,
  humidity: 65,
  windSpeed: 15,
  pressure: 1013,
  visibility: 10,
  uvIndex: 6,
  fireRisk: 45,
  condition: "cloudy",
  description: "Nuageux",
  warnings: [...]
}
```

#### `GET /weather/forecast`
```javascript
// Response
{
  forecast: [
    {
      date: "2026-05-16",
      tempMax: 28,
      tempMin: 18,
      condition: "sunny",
      precipitation: 0,
      windSpeed: 12
    }
  ]
}
```

### Notifications

#### `GET /notifications`
```javascript
// Query params
?limit=20&page=1&read=false

// Response
{
  data: [
    {
      id, title, message,
      type: "alert" | "shelter" | "weather" | "system",
      read, createdAt
    }
  ]
}
```

#### `PUT /notifications/:id/read`
Marquer une notification comme lue.

#### `DELETE /notifications/:id`
Supprimer une notification.

### Incidents

#### `GET /incidents`
Liste des incidents signalés.

#### `POST /incidents`
```javascript
// Request
{
  alertId,
  type: "observation" | "evacuation" | "damage",
  description: "...",
  location: { latitude, longitude },
  photos: [...]
}
```

## Erreurs courantes

### 400 Bad Request
```javascript
{
  error: "validation_error",
  details: {
    email: "Format invalide",
    password: "Au moins 8 caractères"
  }
}
```

### 401 Unauthorized
Token expiré ou invalide. Le mobile doit:
1. Nettoyer le token
2. Rediriger vers Login
3. Afficher message "Session expirée"

### 403 Forbidden
Accès refusé (permissions insuffisantes).

### 404 Not Found
Ressource n'existe pas.

### 500 Internal Server Error
Erreur serveur - retry recommandé avec backoff.

## Gestion des erreurs

### Auto-retry avec backoff
```javascript
// retryWithBackoff(apiFn, maxRetries=3, delay=1000)
retryWithBackoff(() => api.getAlerts());
```

### Offline mode (futur)
- Cache les données dernière requête
- Resync automatiquement quand connexion revient
- Indicator "Mode hors ligne"

## Rate limiting

- 100 requêtes/minute par utilisateur
- 10 uploads/minute
- Respecter X-RateLimit-* headers

## WebSocket (futur)

Pour notifications temps réel:
```javascript
ws://localhost:3000/ws?token=jwt_token

// Events
{
  type: "alert_created",
  data: { alertId, ... }
}
```

## Testing API

### Mock data à utiliser
Voir `src/__mocks__/api.js` (à créer)

### Endpoints de test
```javascript
POST /test/reset       // Reset database
POST /test/seed        // Charger données test
GET  /test/status      // Vérifier status
```

## Performance

### Pagination
- Default: 20 items/page
- Max: 100 items/page
- Toujours inclure limit + page

### Caching
- Alertes: Cache 5 minutes
- Météo: Cache 30 minutes
- Refuges: Cache 1 heure
- User: Cache jusqu'à logout

### Compression
- Toutes réponses gzip par défaut
- Images: WebP/AVIF préféré
- Payload max: 5MB
