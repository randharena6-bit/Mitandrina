# 🌪️ MITANDRINA - Plateforme IA de Gestion des Catastrophes

Plateforme complète de **prédiction**, **détection** et **coordination** des catastrophes naturelles pour Madagascar et zones à risque.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTS                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Web App    │  │  Mobile PWA  │  │   Dashboard  │         │
│  │  (Next.js)   │  │  (React)     │  │  (Secours)   │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
└─────────┼─────────────────┼─────────────────┼─────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │ HTTPS/REST + WebSocket
┌───────────────────────────▼───────────────────────────────────┐
│                    API GATEWAY (Node.js)                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Express + Socket.io (WebSocket temps réel)           │   │
│  │  • JWT Auth + Rate Limiting                             │   │
│  │  • Bull Queue (SMS/Push notifications async)              │   │
│  │  • Proxy vers FastAPI AI                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└───────────────────────────┬───────────────────────────────────┘
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│    PostgreSQL   │  │     Redis       │  │   FastAPI AI    │
│    + PostGIS    │  │   (Cache/Queue) │  │    Services     │
│                 │  │                 │  │                 │
│ • Users         │  │ • Sessions      │  │ • Prédictions   │
│ • DisasterZones │  │ • Pub/Sub       │  │ • Fire CNN      │
│ • Alerts        │  │ • Job Queues    │  │ • NLP BERT      │
│ • Incidents     │  │                 │  │ • Routing A*    │
│ • Shelters      │  │                 │  │ • Weather API   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 📁 Structure du Projet

```
mitandrina/
├── 📁 backend-ai/              # FastAPI - Services IA
│   ├── app/
│   │   ├── api/                # Routers (predictions, fire, nlp, routing)
│   │   ├── services/           # ML models, OSMnx, external APIs
│   │   ├── core/               # Config, database
│   │   └── models/             # Schemas Pydantic
│   ├── Dockerfile
│   └── requirements.txt
│
├── 📁 backend-gateway/         # Node.js - API Gateway
│   ├── src/
│   │   ├── routes/             # Auth, Users, Alerts, Incidents...
│   │   ├── websocket/          # Socket.io handlers
│   │   ├── workers/            # Bull queue workers
│   │   ├── middleware/         # Auth, error handling
│   │   └── config/             # Database config
│   ├── Dockerfile
│   └── package.json
│
├── 📁 database/
│   ├── schema.sql              # Schéma PostgreSQL complet
│   └── ERD.md                  # Diagramme relations
│
├── docker-compose.yml          # Orchestration complète
├── .env                        # Variables d'environnement
└── README.md                   # Ce fichier
```

## 🚀 Démarrage Rapide

### Prérequis

- Docker + Docker Compose
- Git

### 1. Cloner et configurer

```bash
git clone <repo-url>
cd mitandrina

# Copier et éditer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos clés API
```

### 2. Lancer l'infrastructure

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier les services
docker-compose ps

# Logs
docker-compose logs -f gateway
docker-compose logs -f ai-service
```

### 3. Accès

| Service | URL | Description |
|---------|-----|-------------|
| API Gateway | `http://localhost:3001` | API REST + WebSocket |
| AI Services | `http://localhost:8000/docs` | Documentation FastAPI |
| PostgreSQL | `localhost:5432` | Base de données |
| Redis | `localhost:6379` | Cache & Queue |

### 4. Tester les APIs

```bash
# Health check
curl http://localhost:3001/health

# Créer un utilisateur
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Prédiction inondation (via AI service proxy)
curl -X POST http://localhost:3001/api/v1/ai/predictions/flood \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"lat":-18.9078,"lng":47.5208,"horizon_hours":24}'
```

## 📡 API Endpoints

### Authentication (Node.js)
| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/v1/auth/register` | POST | Inscription |
| `/api/v1/auth/login` | POST | Connexion |
| `/api/v1/auth/me` | GET | Profil utilisateur |

### Utilisateurs (Node.js)
| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/v1/users/me` | GET/PUT | Profil / Mise à jour |
| `/api/v1/users/nearby-danger` | GET | Danger proche |

### Alertes (Node.js)
| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/v1/alerts` | GET/POST | Liste / Créer |
| `/api/v1/alerts/:id` | GET | Détail |
| `/api/v1/alerts/:id/confirm` | PUT | Confirmer |
| `/api/v1/alerts/:id/resolve` | PUT | Résoudre |

### Incidents (Node.js)
| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/v1/incidents` | GET/POST | Liste / Signaler |
| `/api/v1/incidents/:id/status` | PUT | Changer statut |
| `/api/v1/incidents/:id/assign` | POST | Assigner équipe |

### IA Services (FastAPI via proxy)
| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/v1/ai/predictions/flood` | POST | Prédiction inondation |
| `/api/v1/ai/predictions/cyclone` | POST | Prédiction cyclone |
| `/api/v1/ai/fire/detect` | POST | Détection incendie CNN |
| `/api/v1/ai/fire/satellite/nasa-firms` | GET | Données NASA |
| `/api/v1/ai/nlp/analyze` | POST | Analyse texte NLP |
| `/api/v1/ai/routing/evacuation` | POST | Calcul route A* |
| `/api/v1/ai/routing/to-shelter` | POST | Route vers refuge |
| `/api/v1/ai/weather/current` | GET | Météo actuelle |

## 🔌 WebSocket Événements

### Client → Server
```javascript
socket.emit('location:update', { lat, lng });
socket.emit('alert:acknowledge', { alertId });
```

### Server → Client
```javascript
socket.on('alert:new', (alert) => { ... });
socket.on('danger:nearby', (danger) => { ... });
socket.on('incident:new', (incident) => { ... });
```

## 🐛 Développement Local (sans Docker)

### Backend AI (FastAPI)
```bash
cd backend-ai
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configurer .env
cp .env.example .env
# Éditer DATABASE_URL, REDIS_URL...

# Lancer
uvicorn app.main:app --reload --port 8000
```

### Backend Gateway (Node.js)
```bash
cd backend-gateway
npm install

# Configurer .env
cp .env.example .env

# Lancer
npm run dev
```

### PostgreSQL + PostGIS local
```bash
# Docker pour DB uniquement
docker run -d \
  --name mitandrina-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=mitandrina \
  -p 5432:5432 \
  postgis/postgis:15-3.4

# Initialiser le schéma
psql -h localhost -U postgres -d mitandrina -f database/schema.sql
```

## 🧪 Tests

```bash
# Backend AI
cd backend-ai
pytest

# Backend Gateway
cd backend-gateway
npm test
```

## 📦 Déploiement Production

### Variables obligatoires
```bash
# JWT (même valeur pour tous les services)
JWT_SECRET=your-super-secret-key-min-32-chars

# API Externes
OPENWEATHER_API_KEY=
NASA_FIRMS_API_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
FIREBASE_PROJECT_ID=
SENDGRID_API_KEY=

# URLs
AI_SERVICE_URL=http://ai-service:8000
```

### Docker Compose Production
```bash
docker-compose -f docker-compose.yml up -d --build
```

### Scale AI Service
```bash
docker-compose up -d --scale ai-service=3
```

## 📊 Monitoring

- **Health Check**: `GET /health`
- **Metrics Prometheus**: `GET /metrics` (à ajouter)
- **Logs**: `docker-compose logs -f`

## 🛠️ Stack Technique

| Couche | Technologie |
|--------|-------------|
| **Frontend** | JSP, **Tailwind CSS**, **Bootstrap 5**, Leaflet Maps |
| **API Gateway** | Node.js, Express, Socket.io, Bull |
| **AI Services** | Python, FastAPI, SQLAlchemy 2.0 |
| **ML Models** | XGBoost, TensorFlow (CNN), Transformers (BERT) |
| **Routing** | OSMnx, NetworkX, A* |
| **Database** | PostgreSQL 15 + PostGIS |
| **Cache/Queue** | Redis |
| **DevOps** | Docker, Docker Compose |

### 🎨 Frontend Stack (JSP + Tailwind + Bootstrap)

Le frontend utilise une approche hybride moderne :

- **Tailwind CSS** : Utility-first CSS avec configuration personnalisée
  - Colors : Danger palette (rouge urgence), Dark theme
  - Animations : Float, pulse-glow, fade-in-up
  - Components : glass, glass-card, btn-emergency
  
- **Bootstrap 5** : Components et forms
  - Dark theme override pour forms, modals, dropdowns
  - Bootstrap Icons pour la iconographie
  - Grid system pour le responsive
  
- **JSP** : JavaServer Pages avec JSTL
  - Layout templates (`base-tailwind.jsp`)
  - JSTL Core pour la logique conditionnelle
  - Expression Language pour les données dynamiques
  
- **Leaflet** : Cartographie interactive
  - Custom markers avec emojis
  - Dark map tiles
  - Real-time geolocation

## 📄 Licence

MIT License - Voir [LICENSE](LICENSE)

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add some AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

**🌪️ MITANDRINA** - Protéger les populations par l'intelligence artificielle.
