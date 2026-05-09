# 🌪️ MITANDRINA — UML Complet

**Plateforme IA de Prédiction, Détection et Coordination des Catastrophes Naturelles**

---

## 📋 Table des matières

1. [Diagramme de Contexte (C4)](#1-diagramme-de-contexte-c4)
2. [Diagramme de Cas d'Utilisation](#2-diagramme-de-cas-dutilisation)
3. [Diagramme de Classes](#3-diagramme-de-classes)
4. [Diagrammes de Séquence](#4-diagrammes-de-séquence)
5. [Diagramme de Composants](#5-diagramme-de-composants)
6. [Diagramme de Déploiement](#6-diagramme-de-déploiement)
7. [Diagramme d'Activité — Algorithme A*](#7-diagramme-dactivité--algorithme-a)
8. [Diagramme d'État — Cycle d'Alerte](#8-diagramme-détat--cycle-dalerte)

---

## 1. Diagramme de Contexte (C4)

```mermaid
C4Context
    title System Context Diagram - MITANDRINA
    
    Person(population, "Population", "Citoyens des zones à risque")
    Person(secouristes, "Forces de Secours", "Pompiers, police, secouristes")
    Person(admin, "Administrateur", "Gestionnaire de la plateforme")
    
    System_Boundary(mitandrina, "MITANDRINA") {
        System(platform, "Plateforme MITANDRINA", "Prédiction IA, détection temps réel, coordination évacuation")
    }
    
    System_Ext(openweather, "OpenWeather API", "Données météorologiques")
    System_Ext(nasa_firms, "NASA FIRMS", "Données satellites incendies")
    System_Ext(social_media, "Réseaux Sociaux", "Signaux sociaux Twitter/X")
    System_Ext(osm, "OpenStreetMap", "Données géographiques et routières")
    System_Ext(twilio, "Twilio", "Service SMS")
    System_Ext(firebase, "Firebase FCM", "Push notifications")
    
    Rel(population, platform, "Reçoit alertes, consulte carte", "Web/Mobile")
    Rel(secouristes, platform, "Coordonne interventions", "Dashboard")
    Rel(admin, platform, "Configure, supervise", "Admin Panel")
    
    Rel(platform, openweather, "Récupère données météo", "HTTPS/REST")
    Rel(platform, nasa_firms, "Détection feux", "HTTPS/REST")
    Rel(platform, social_media, "Analyse NLP", "API Stream")
    Rel(platform, osm, "Graphes routiers", "OSMnx")
    Rel(platform, twilio, "Envoi SMS", "REST API")
    Rel(platform, firebase, "Push notifications", "FCM API")
```

---

## 2. Diagramme de Cas d'Utilisation

```mermaid
usecaseDiagram
    title Diagramme de Cas d'Utilisation - MITANDRINA
    
    left {
        actor "Population Civile" as Population
        actor "Forces de Secours" as Secours
        actor "Administrateur" as Admin
    }
    
    package "MITANDRINA Platform" {
        usecase "Visualiser Carte des Risques" as UC1
        usecase "Recevoir Alertes Multicanal" as UC2
        usecase "Consulter Itinéraire Évacuation" as UC3
        usecase "Signaler Incident" as UC4
        
        usecase "Superviser Incidents Temps Réel" as UC5
        usecase "Coordonner Équipes de Secours" as UC6
        usecase "Générer Rapport Post-Crise" as UC7
        usecase "Valider/Modifier Alertes" as UC8
        
        usecase "Configurer Seuils d'Alerte" as UC9
        usecase "Gérer Utilisateurs" as UC10
        usecase "Simuler Scénario \"What If?\"" as UC11
        usecase "Consulter KPI et Métriques" as UC12
        
        usecase "Prédire Catastrophe (IA)" as UC13
        usecase "Détecter Incendie (CNN)" as UC14
        usecase "Analyser Signaux Sociaux (NLP)" as UC15
        usecase "Calculer Route Évacuation (A*)" as UC16
    }
    
    Population --> UC1
    Population --> UC2
    Population --> UC3
    Population --> UC4
    
    Secours --> UC5
    Secours --> UC6
    Secours --> UC7
    Secours --> UC8
    
    Admin --> UC9
    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    
    UC13 ..> UC2 : <<include>>
    UC14 ..> UC2 : <<include>>
    UC15 ..> UC2 : <<include>>
    UC16 ..> UC3 : <<include>>
    
    UC6 ..> UC5 : <<include>>
    UC8 ..> UC2 : <<extend>>
```

---

## 3. Diagramme de Classes

```mermaid
classDiagram
    title Diagramme de Classes - MITANDRINA
    
    class User {
        +UUID id
        +String email
        +String password_hash
        +String phone_number
        +UserRole role
        +GeoLocation location
        +DateTime created_at
        +login()
        +updateProfile()
        +setAlertPreferences()
    }
    
    class DisasterZone {
        +UUID id
        +String name
        +GeoJSON polygon
        +Float danger_score
        +DisasterType type
        +AlertLevel level
        +DateTime detected_at
        +DateTime updated_at
        +calculateRisk()
        +updateDangerScore()
    }
    
    class Alert {
        +UUID id
        +AlertLevel level
        +DisasterType type
        +String message
        +GeoJSON zone
        +DateTime emitted_at
        +List~Channel~ channels
        +Boolean confirmed
        +send()
        +confirm()
        +escalate()
    }
    
    class Incident {
        +UUID id
        +String title
        +String description
        +GeoLocation location
        +IncidentStatus status
        +DisasterType type
        +DateTime reported_at
        +DateTime resolved_at
        +report()
        +updateStatus()
        +assignTeam()
    }
    
    class EvacuationRoute {
        +UUID id
        +UUID from_zone_id
        +UUID to_shelter_id
        +LineString path
        +Float distance_km
        +Float estimated_time
        +Boolean is_active
        +calculateRoute()
        +updateWeights()
    }
    
    class Shelter {
        +UUID id
        +String name
        +GeoLocation location
        +Integer capacity
        +Integer current_occupancy
        +ShelterType type
        +Boolean is_available
        +checkAvailability()
        +registerEvacuee()
    }
    
    class AIPrediction {
        +UUID id
        +DisasterType type
        +Float confidence_score
        +GeoJSON predicted_zone
        +DateTime prediction_horizon
        +ModelType model_used
        +JSON features_input
        +runPrediction()
        +validateAccuracy()
    }
    
    class SocialSignal {
        +UUID id
        +String source_platform
        +String raw_text
        +GeoLocation inferred_location
        +DisasterType detected_type
        +UrgencyLevel urgency
        +Float nlp_confidence
        +DateTime posted_at
        +processNLP()
        +extractLocation()
    }
    
    class RescueTeam {
        +UUID id
        +String name
        +TeamType type
        +GeoLocation current_position
        +Integer team_size
        +Boolean is_available
        +deploy()
        +updatePosition()
        +reportStatus()
    }
    
    class Simulation {
        +UUID id
        +String name
        +DisasterType scenario_type
        +JSON parameters
        +GeoJSON simulated_impact_zone
        +DateTime created_at
        +run()
        +exportResults()
    }
    
    class WeatherData {
        +UUID id
        +GeoLocation location
        +Float temperature
        +Float precipitation_24h
        +Float humidity
        +Float wind_speed
        +Float river_level
        +DateTime recorded_at
        +fetchFromAPI()
        +aggregate()
    }
    
    User "1" -- "0..*" Alert : reçoit
    User "1" -- "0..*" Incident : signale
    DisasterZone "1" -- "0..*" Alert : génère
    DisasterZone "1" -- "0..*" EvacuationRoute : origine
    Shelter "1" -- "0..*" EvacuationRoute : destination
    Incident "1" -- "0..1" DisasterZone : localisé dans
    Alert "1" -- "0..*" SocialSignal : basé sur
    AIPrediction "1" -- "1" DisasterZone : prédit
    RescueTeam "0..*" -- "0..*" Incident : intervient sur
    Simulation "1" -- "1" DisasterZone : simule
    WeatherData "0..*" -- "1" DisasterZone : alimente
```

---

## 4. Diagrammes de Séquence

### 4.1 Détection et Alerte Catastrophe (Flux Principal)

```mermaid
sequenceDiagram
    title Flux de Détection et Alerte
    
    actor Opérateur
    participant API_Météo as OpenWeather API
    participant NASA_FIRMS as NASA FIRMS
    participant Social as Réseaux Sociaux
    participant Backend as Backend FastAPI
    participant IA_Engine as IA Engine
    participant DB as PostgreSQL
    participant Redis as Redis Cache
    participant Alert_Sys as Système d'Alertes
    participant WebSocket as WebSocket
    participant User as Utilisateur Mobile
    
    par Données Météo
        API_Météo->>Backend: GET /weather/data
        Backend->>Redis: Cache données 5min
    and Données Satellites
        NASA_FIRMS->>Backend: GET /fire/detections
    and Signaux Sociaux
        Social->>Backend: Stream tweets/posts
    end
    
    Backend->>IA_Engine: Analyse données agrégées
    
    par Modèles IA
        IA_Engine->>IA_Engine: Flood Prediction (XGBoost)
        IA_Engine->>IA_Engine: Fire Detection (CNN)
        IA_Engine->>IA_Engine: Cyclone Risk Model
        IA_Engine->>IA_Engine: NLP Analysis (BERT)
    end
    
    IA_Engine->>Backend: Risk Score [0-100] + Type
    
    alt Score > 75 (URGENCE)
        Backend->>DB: Enregistrer DisasterZone
        Backend->>Alert_Sys: Trigger alerte CRITIQUE
        Alert_Sys->>User: SMS (Twilio)
        Alert_Sys->>User: Push (Firebase)
        Alert_Sys->>WebSocket: Broadcast alerte
        WebSocket->>User: Notification temps réel
    else Score 56-75 (ALERTE)
        Backend->>DB: Enregistrer zone VIGILANCE
        Backend->>Alert_Sys: Trigger alerte standard
        Alert_Sys->>User: Notification push
    else Score < 56
        Backend->>DB: Log surveillance seulement
    end
    
    Opérateur->>Backend: Validation manuelle (optionnel)
    Backend->>DB: Mise à jour statut alerte
```

### 4.2 Calcul d'Itinéraire d'Évacuation

```mermaid
sequenceDiagram
    title Calcul Route Évacuation Optimale (A*)
    
    actor Utilisateur
    participant Frontend as React Dashboard
    participant API_Gateway as API Gateway
    participant Routing_Svc as Routing Service
    participant OSMnx as OSMnx
    participant A_Star as Algorithme A*
    participant Redis as Redis Cache
    participant DB as PostgreSQL/PostGIS
    
    Utilisateur->>Frontend: Demande itinéraire évacuation
    Frontend->>API_Gateway: POST /api/evacuation/route
    API_Gateway->>Routing_Svc: Forward request
    
    Routing_Svc->>DB: Récupérer zones danger actives
    DB-->>Routing_Svc: Polygones zones rouges/oranges
    
    Routing_Svc->>Redis: Check cache graphe OSM
    alt Cache hit
        Redis-->>Routing_Svc: Graphe routier
    else Cache miss
        Routing_Svc->>OSMnx: Télécharger réseau routier
        OSMnx->>Routing_Svc: Graph NetworkX
        Routing_Svc->>Redis: Stocker graphe
    end
    
    Routing_Svc->>A_Star: Exécuter A* avec pondération
    
    loop Pour chaque nœud
        A_Star->>A_Star: Calcul g(n) + h(n)
        A_Star->>Routing_Svc: Vérifier intersection danger
        Routing_Svc-->>A_Star: Danger factor [0-1]
        A_Star->>A_Star: Weight = dist × (1 + danger×10)
    end
    
    A_Star-->>Routing_Svc: Chemin optimal + métriques
    Routing_Svc->>DB: Enregistrer route suggérée
    Routing_Svc-->>API_Gateway: Route + temps estimé
    API_Gateway-->>Frontend: GeoJSON itinéraire
    Frontend-->>Utilisateur: Affichage carte avec route
```

### 4.3 Simulation "What If?"

```mermaid
sequenceDiagram
    title Mode Simulation "What If?"
    
    actor Admin
    participant Dashboard as Dashboard React
    participant Simulation_Svc as Simulation Service
    participant IA_Models as Modèles IA
    participant DB as PostgreSQL
    participant Cache as Redis
    
    Admin->>Dashboard: Configure scénario<br/>(Type, Intensité, Localisation)
    Dashboard->>Simulation_Svc: POST /api/simulation/run
    
    Simulation_Svc->>Cache: Stocker paramètres simulation
    
    par Exécution parallèle
        Simulation_Svc->>IA_Models: Simuler Flood Prediction
        Simulation_Svc->>IA_Models: Simuler Fire Spread
        Simulation_Svc->>IA_Models: Simuler Cyclone Trajectory
    end
    
    IA_Models-->>Simulation_Svc: Zones impactées simulées
    
    Simulation_Svc->>Simulation_Svc: Agréger résultats
    Simulation_Svc->>Simulation_Svc: Calculer routes évacuation
    Simulation_Svc->>DB: Persister résultat simulation
    
    Simulation_Svc-->>Dashboard: GeoJSON impact + routes
    Dashboard->>Dashboard: Rendu heatmap zones touchées
    Dashboard->>Dashboard: Animation propagation
    
    Admin->>Dashboard: Ajuste paramètres
    Dashboard->>Simulation_Svc: Re-run simulation
    Simulation_Svc-->>Dashboard: Nouveau résultat (< 30s)
```

---

## 5. Diagramme de Composants

```mermaid
graph TB
    title Diagramme de Composants - Architecture MITANDRINA
    
    subgraph Client_Layer["**CLIENT LAYER**"]
        WebApp["🌐 Dashboard React<br/>Next.js 14 + Tailwind"]
        Mobile["📱 PWA Mobile<br/>Responsive + Offline"]
    end
    
    subgraph API_Gateway_Layer["**API GATEWAY LAYER**"]
        Gateway["🛡️ API Gateway<br/>Express.js + Rate Limiting"]
        Auth["🔐 Auth Service<br/>JWT + Middleware"]
        WebSocket_Server["⚡ WebSocket Server<br/>Socket.io"]
    end
    
    subgraph AI_Layer["**AI ENGINE LAYER**"]
        Flood_AI["🌊 Flood Prediction<br/>XGBoost + LSTM"]
        Fire_AI["🔥 Fire Detection<br/>CNN ResNet-50"]
        Cyclone_AI["🌀 Cyclone Risk<br/>Ridge Regression"]
        NLP_AI["💬 Social NLP<br/>BERT Multilingue"]
    end
    
    subgraph Core_Services_Layer["**CORE SERVICES LAYER**"]
        Decision_Engine["🧠 Decision Engine<br/>Risk Aggregation"]
        Routing_Service["🗺️ Routing Service<br/>A* + OSMnx"]
        Alert_Service["📢 Alert Service<br/>Multi-canal"]
        Simulation_Service["🔮 Simulation Service<br/>What If?"]
    end
    
    subgraph Data_Layer["**DATA LAYER**"]
        PostgreSQL[("🗄️ PostgreSQL<br/>+ PostGIS")]
        Redis[("⚡ Redis Cache<br/>Sessions + Météo")]
        BullQueue["📋 Bull Queue<br/>Traitement async")]
    end
    
    subgraph External_Integrations["**EXTERNAL INTEGRATIONS**"]
        OpenWeather["🌤️ OpenWeather API"]
        NASA["🛰️ NASA FIRMS"]
        Twilio["📲 Twilio SMS"]
        Firebase["🔔 Firebase FCM"]
        OSM["🗺️ OpenStreetMap"]
    end
    
    WebApp --> Gateway
    Mobile --> Gateway
    
    Gateway --> Auth
    Gateway --> WebSocket_Server
    
    Gateway --> Flood_AI
    Gateway --> Fire_AI
    Gateway --> Cyclone_AI
    Gateway --> NLP_AI
    
    Flood_AI --> Decision_Engine
    Fire_AI --> Decision_Engine
    Cyclone_AI --> Decision_Engine
    NLP_AI --> Decision_Engine
    
    Decision_Engine --> Alert_Service
    Decision_Engine --> Routing_Service
    
    Alert_Service --> BullQueue
    Routing_Service --> OSM
    
    Gateway --> Simulation_Service
    
    Gateway --> PostgreSQL
    Decision_Engine --> PostgreSQL
    Routing_Service --> PostgreSQL
    
    Gateway --> Redis
    Alert_Service --> Redis
    
    Gateway --> OpenWeather
    Gateway --> NASA
    Alert_Service --> Twilio
    Alert_Service --> Firebase
    Routing_Service --> OSM
    
    WebSocket_Server --> WebApp
    WebSocket_Server --> Mobile
```

---

## 6. Diagramme de Déploiement

```mermaid
graph TB
    title Diagramme de Déploiement - Infrastructure MITANDRINA
    
    subgraph Internet["**🌐 INTERNET**"]
        Users["Utilisateurs<br/>(Web/Mobile)"]
    end
    
    subgraph CDN_Layer["**CDN / EDGE**"]
        Vercel_EDGE["Vercel Edge Network<br/>Static Assets + SSR"]
    end
    
    subgraph Vercel_Platform["**VERCEL PLATFORM**"]
        NextJS["Next.js 14 App<br/>Frontend + API Routes"]
    end
    
    subgraph Railway_Platform["**RAILWAY / CLOUD**"]
        subgraph Backend_Services["Backend Services"]
            API_Gateway["API Gateway<br/>Node.js + Express"]
            AI_Services["AI Services<br/>Python FastAPI"]
            WebSocket_Node["WebSocket Server<br/>Socket.io"]
        end
        
        subgraph Data_Storage["Data Layer"]
            PostgreSQL[("PostgreSQL<br/>PostGIS Extension")]
            Redis[("Redis<br/>Cache + Pub/Sub")]
        end
        
        subgraph Workers["Async Workers"]
            Bull_Worker["Bull Queue Workers<br/>Alert Processing"]
            ML_Inference["ML Inference<br/>Model Serving"]
        end
    end
    
    subgraph External_APIs["**EXTERNAL APIs**"]
        OpenWeather["OpenWeather<br/>api.openweathermap.org"]
        NASA["NASA FIRMS<br/>firms.modaps.eosdis.nasa.gov"]
        Twilio["Twilio SMS<br/>api.twilio.com"]
        Firebase["Firebase FCM<br/>fcm.googleapis.com"]
        OSM["OpenStreetMap<br/>openstreetmap.org"]
    end
    
    subgraph DevOps_Tools["**DEVOPS**"]
        Docker["Docker<br/>Containers"]
        GitHub["GitHub<br/>CI/CD Actions"]
    end
    
    Users --> Vercel_EDGE
    Vercel_EDGE --> NextJS
    NextJS --> API_Gateway
    
    API_Gateway --> AI_Services
    API_Gateway --> WebSocket_Node
    
    API_Gateway --> PostgreSQL
    API_Gateway --> Redis
    AI_Services --> PostgreSQL
    
    Redis --> Bull_Worker
    AI_Services --> ML_Inference
    
    API_Gateway --> OpenWeather
    API_Gateway --> NASA
    Bull_Worker --> Twilio
    Bull_Worker --> Firebase
    AI_Services --> OSM
    
    GitHub --> Docker
    Docker --> Vercel_Platform
    Docker --> Railway_Platform
```

---

## 7. Diagramme d'Activité — Algorithme A*

```mermaid
flowchart TD
    title Algorithme A* — Calcul Route Évacuation
    
    Start(["Début: Point A → Point B"]) --> Init["Initialisation:<br/>• open_set = {start}<br/>• came_from = {}<br/>• g_score[start] = 0<br/>• f_score[start] = h(start)"]
    
    Init --> Check{"open_set<br/>vide ?"}
    
    Check -->|Non| Pop["Extraire nœud<br/>avec min f_score"]
    Pop --> Goal{"Nœud ==<br/>objectif ?"}
    
    Goal -->|Oui| Reconstruct["Reconstruire chemin<br/>via came_from"]
    Reconstruct --> End(["Retourner chemin optimal"])
    
    Goal -->|Non| Neighbors["Pour chaque voisin<br/>du nœud courant"]
    Neighbors --> Danger["Récupérer<br/>danger_factor<br/>de la zone"]
    
    Danger --> Tentative["tentative_g =<br/>g_score[current] +<br/>dist × (1 + danger×10)"]
    
    Tentative --> Better{"tentative_g <<br/>g_score[neighbor] ?"}
    
    Better -->|Oui| Update["Mettre à jour:<br/>• came_from[neighbor] = current<br/>• g_score[neighbor] = tentative_g<br/>• f_score[neighbor] = tentative_g + h(neighbor)<br/>• Ajouter à open_set"]
    
    Better -->|Non| NextVoisin["Voisin suivant"]
    Update --> NextVoisin
    
    NextVoisin --> Neighbors
    NextVoisin -->|Tous traités| Check
    
    Check -->|Oui| NoPath(["Aucun chemin<br/>Retourner erreur"])
    
    h["📝 Heuristique h(n):<br/>Distance Haversine<br/>à l'objectif"]
    g["📝 g(n): Coût réel<br/>depuis le départ"]
    f["📝 f(n) = g(n) + h(n)"]
    
    style Start fill:#2E7D32,color:#fff
    style End fill:#2E7D32,color:#fff
    style NoPath fill:#C00000,color:#fff
    style Check fill:#F9A825
    style Better fill:#F9A825
    style Goal fill:#F9A825
```

---

## 8. Diagramme d'État — Cycle d'Alerte

```mermaid
stateDiagram-v2
    title Cycle de Vie d'une Alerte MITANDRINA
    
    [*] --> Surveillance: Données détectées
    
    Surveillance --> Analyse: Score IA calculé
    
    state Analyse {
        [*] --> Score_0_30: Normal
        [*] --> Score_31_55: Vigilance
        [*] --> Score_56_75: Alerte
        [*] --> Score_76_100: Urgence
    }
    
    Score_0_30 --> Surveillance: Surveillance passive
    Score_31_55 --> Pre_Alerte: Pré-alerte
    Score_56_75 --> Alerte_Active: Alerte orange
    Score_76_100 --> Urgence_Critique: Alerte rouge
    
    Pre_Alerte --> Surveillance: Danger diminué
    Pre_Alerte --> Alerte_Active: Danger augmenté
    
    Alerte_Active --> Evacuation: Routes calculées
    Alerte_Active --> Surveillance: Danger résolu
    Alerte_Active --> Urgence_Critique: Danger critique
    
    Urgence_Critique --> Evacuation: SMS masse envoyés
    Urgence_Critique --> Intervention: Secours déployés
    
    Evacuation --> Intervention: Équipes sur place
    Intervention --> Resolution: Situation maîtrisée
    Resolution --> Rapport: Génération PDF
    
    Rapport --> Archivage: Données historisées
    Archivage --> [*]
    
    note right of Surveillance
        Analyse continue toutes
        les 5 minutes via
        OpenWeather + NASA FIRMS
    end note
    
    note right of Urgence_Critique
        Déclenchement automatique:
        • SMS via Twilio
        • Push via Firebase
        • WebSocket broadcast
        • Sirène audio Web
    end note
    
    note right of Evacuation
        Calcul A* exécuté
        pour routes optimales
        vers refuges OSM
    end note
```

---

## 📊 Récapitulatif des Diagrammes

| Diagramme | Description | Outil |
|-----------|-------------|-------|
| **Contexte (C4)** | Vue haut niveau système et acteurs externes | Mermaid C4 |
| **Use Case** | Fonctionnalités et interactions utilisateurs | Mermaid |
| **Classes** | Structure des entités métier et relations | Mermaid |
| **Séquence** | Flux temporels détection, évacuation, simulation | Mermaid |
| **Composants** | Architecture logicielle et dépendances | Mermaid |
| **Déploiement** | Infrastructure et répartition des services | Mermaid |
| **Activité (A*)** | Logique algorithmique du routing | Mermaid |
| **État** | Cycle de vie des alertes | Mermaid |

---

## 🛠️ Visualisation

Ces diagrammes utilisent la syntaxe **Mermaid** compatible avec :
- GitHub / GitLab (rendu natif)
- VS Code (extension Markdown Preview Mermaid)
- Notion, Obsidian, Jira
- Outils en ligne: [Mermaid Live Editor](https://mermaid.live)

Pour générer des exports PNG/SVG : Utiliser le Mermaid Live Editor ou CLI `mmdc`.
