# 🗄️ MITANDRINA - Diagramme Entité-Relation (Database Schema)

## Diagramme ERD

```mermaid
erDiagram
    %% Entités principales
    USERS {
        uuid id PK
        varchar email UK
        varchar password_hash
        varchar phone_number
        user_role role
        geography location
        decimal lat
        decimal lng
        notification_channel[] alert_channels
        int alert_radius_km
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    DISASTER_ZONES {
        uuid id PK
        varchar name
        geography geometry
        decimal danger_score
        disaster_type type
        alert_level level
        model_type detected_by
        decimal confidence_score
        timestamp detected_at
        boolean is_active
        decimal center_lat
        decimal center_lng
    }

    ALERTS {
        uuid id PK
        alert_level level
        disaster_type type
        varchar title
        text message
        geography zone_geometry
        uuid zone_id FK
        notification_channel[] channels
        boolean is_confirmed
        uuid confirmed_by FK
        timestamp emitted_at
        timestamp resolved_at
    }

    ALERT_RECIPIENTS {
        uuid id PK
        uuid alert_id FK
        uuid user_id FK
        notification_channel channel
        timestamp sent_at
        timestamp delivered_at
        timestamp read_at
    }

    INCIDENTS {
        uuid id PK
        varchar title
        text description
        geography location
        decimal lat
        decimal lng
        incident_status status
        disaster_type type
        uuid reported_by FK
        uuid zone_id FK
        uuid verified_by FK
        timestamp reported_at
        timestamp resolved_at
    }

    SHELTERS {
        uuid id PK
        varchar name
        geography location
        decimal lat
        decimal lng
        int capacity
        int current_occupancy
        shelter_type type
        boolean is_available
        boolean is_full
        varchar phone
        boolean has_medical_facilities
        timestamp last_status_update
    }

    EVACUATION_ROUTES {
        uuid id PK
        uuid from_zone_id FK
        uuid to_shelter_id FK
        geography path
        decimal distance_km
        int estimated_time_minutes
        decimal danger_score
        boolean is_active
        varchar algorithm_used
        timestamp calculated_at
    }

    AI_PREDICTIONS {
        uuid id PK
        disaster_type type
        decimal confidence_score
        geography predicted_zone
        timestamp prediction_horizon
        model_type model_used
        jsonb features_input
        boolean actual_occurred
        decimal accuracy_score
        timestamp created_at
    }

    SOCIAL_SIGNALS {
        uuid id PK
        varchar source_platform
        text raw_text
        geography inferred_location
        disaster_type detected_type
        urgency_level urgency
        decimal nlp_confidence
        timestamp posted_at
        uuid linked_alert_id FK
        uuid linked_incident_id FK
    }

    RESCUE_TEAMS {
        uuid id PK
        varchar name
        team_type type
        geography current_position
        int team_size
        boolean is_available
        varchar current_status
        varchar phone
        jsonb equipment
        timestamp last_position_update
    }

    TEAM_ASSIGNMENTS {
        uuid id PK
        uuid team_id FK
        uuid incident_id FK
        uuid assigned_by FK
        timestamp assigned_at
        varchar status
        timestamp arrived_at
        timestamp completed_at
    }

    SIMULATIONS {
        uuid id PK
        varchar name
        uuid created_by FK
        disaster_type scenario_type
        jsonb parameters
        geography simulated_impact_zone
        int evacuation_routes_generated
        timestamp created_at
        varchar status
    }

    WEATHER_DATA {
        uuid id PK
        decimal lat
        decimal lng
        decimal temperature
        decimal precipitation_24h
        decimal humidity
        decimal wind_speed
        decimal river_level
        varchar weather_condition
        timestamp recorded_at
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        uuid alert_id FK
        varchar title
        text message
        notification_channel channel
        varchar status
        timestamp created_at
        timestamp delivered_at
    }

    AUDIT_LOGS {
        uuid id PK
        uuid user_id FK
        varchar action
        varchar entity_type
        jsonb old_values
        jsonb new_values
        timestamp created_at
    }

    %% Relations
    USERS ||--o{ ALERT_RECIPIENTS : "reçoit"
    USERS ||--o{ INCIDENTS : "signale"
    USERS ||--o{ NOTIFICATIONS : "reçoit"
    USERS ||--o{ SIMULATIONS : "crée"
    USERS ||--o{ TEAM_ASSIGNMENTS : "assigne"
    USERS ||--o{ AUDIT_LOGS : "génère"
    
    DISASTER_ZONES ||--o{ ALERTS : "génère"
    DISASTER_ZONES ||--o{ INCIDENTS : "contient"
    DISASTER_ZONES ||--o{ EVACUATION_ROUTES : "origine"
    
    ALERTS ||--o{ ALERT_RECIPIENTS : "envoyée à"
    ALERTS ||--o{ SOCIAL_SIGNALS : "basée sur"
    ALERTS ||--o{ NOTIFICATIONS : "déclenche"
    
    INCIDENTS ||--o{ SOCIAL_SIGNALS : "lié à"
    INCIDENTS ||--o{ TEAM_ASSIGNMENTS : "assigne"
    
    SHELTERS ||--o{ EVACUATION_ROUTES : "destination"
    
    RESCUE_TEAMS ||--o{ TEAM_ASSIGNMENTS : "intervient"
    
    AI_PREDICTIONS ||--o| DISASTER_ZONES : "prédit"
```

---

## 📊 Types ENUM

| Type | Valeurs |
|------|---------|
| `user_role` | population, secouriste, administrateur |
| `disaster_type` | inondation, incendie, cyclone, seisme, glissement_terrain, tsunami |
| `alert_level` | info, vigilance, alerte, urgence |
| `incident_status` | signale, verifie, en_cours, resolu, archive |
| `shelter_type` | refuge, hopital, centre_urgence, abri_temporaire |
| `model_type` | xgboost, lstm, cnn, ridge_regression, bert |
| `urgency_level` | faible, moyenne, elevee, critique |
| `team_type` | pompier, police, medical, secouriste, militaire |
| `notification_channel` | sms, push, email, websocket, sirene |

---

## 🔗 Index Principaux

### Géospatiaux (GIST)
- `disaster_zones(geometry)`
- `incidents(location)`
- `shelters(location)`
- `evacuation_routes(path)`
- `ai_predictions(predicted_zone)`
- `social_signals(inferred_location)`
- `weather_data(location)`
- `users(location)`
- `rescue_teams(current_position)`

### Temporels
- `disaster_zones(detected_at DESC)`
- `alerts(emitted_at DESC)`
- `incidents(reported_at DESC)`
- `weather_data(recorded_at DESC)`

### Relations
- `alerts(zone_id)`
- `incidents(zone_id, reported_by)`
- `evacuation_routes(from_zone_id, to_shelter_id)`
- `social_signals(linked_alert_id)`

---

## 📁 Fichiers du Schéma

| Fichier | Description |
|---------|-------------|
| `/database/schema.sql` | Schéma complet PostgreSQL |
| `/database/ERD.md` | Ce diagramme ERD |

---

## 🚀 Commandes d'Initialisation

```bash
# Créer la base de données
createdb mitandrina

# Charger le schéma
psql -d mitandrina -f database/schema.sql

# Vérifier les tables
psql -d mitandrina -c "\dt"

# Vérifier les extensions PostGIS
psql -d mitandrina -c "SELECT PostGIS_Version();"
```
