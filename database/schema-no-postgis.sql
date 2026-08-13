-- =============================================================================
-- MITANDRINA - Schema PostgreSQL SANS PostGIS (version compatible)
-- Utilise FLOAT pour lat/lng au lieu de GEOGRAPHY
-- =============================================================================

-- Extensions de base
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- ENUMS - Types énumérés
-- =============================================================================
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS disaster_type CASCADE;
DROP TYPE IF EXISTS alert_level CASCADE;
DROP TYPE IF EXISTS incident_status CASCADE;
DROP TYPE IF EXISTS shelter_type CASCADE;
DROP TYPE IF EXISTS model_type CASCADE;
DROP TYPE IF EXISTS urgency_level CASCADE;
DROP TYPE IF EXISTS team_type CASCADE;
DROP TYPE IF EXISTS notification_channel CASCADE;

CREATE TYPE user_role AS ENUM ('population', 'secouriste', 'administrateur');
CREATE TYPE disaster_type AS ENUM ('inondation', 'incendie', 'cyclone', 'seisme', 'glissement_terrain', 'tsunami');
CREATE TYPE alert_level AS ENUM ('info', 'vigilance', 'alerte', 'urgence');
CREATE TYPE incident_status AS ENUM ('signale', 'verifie', 'en_cours', 'resolu', 'archive');
CREATE TYPE shelter_type AS ENUM ('refuge', 'hopital', 'centre_urgence', 'abri_temporaire');
CREATE TYPE model_type AS ENUM ('xgboost', 'lstm', 'cnn', 'ridge_regression', 'bert');
CREATE TYPE urgency_level AS ENUM ('faible', 'moyenne', 'elevee', 'critique');
CREATE TYPE team_type AS ENUM ('pompier', 'police', 'medical', 'secouriste', 'militaire');
CREATE TYPE notification_channel AS ENUM ('sms', 'push', 'email', 'websocket', 'sirene');

-- =============================================================================
-- TABLE: users - Utilisateurs de la plateforme
-- =============================================================================
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role user_role NOT NULL DEFAULT 'population',
    
    -- Localisation (FLOAT au lieu de GEOGRAPHY)
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    
    -- Préférences d'alerte
    alert_channels notification_channel[] DEFAULT ARRAY['push'::notification_channel, 'sms'::notification_channel],
    alert_radius_km INTEGER DEFAULT 50,
    
    -- Métadonnées
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- Profil
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    device_tokens TEXT[]
);

-- =============================================================================
-- TABLE: disaster_zones - Zones de catastrophe
-- =============================================================================
DROP TABLE IF EXISTS disaster_zones CASCADE;
CREATE TABLE disaster_zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    
    -- Géométrie simplifiée (lat/lng + rayon)
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    radius_km DECIMAL(8, 2) DEFAULT 10,
    
    -- Scores et classification
    danger_score DECIMAL(5, 2) CHECK (danger_score >= 0 AND danger_score <= 100),
    type disaster_type NOT NULL,
    level alert_level NOT NULL DEFAULT 'vigilance',
    
    -- Source de la détection
    detected_by model_type,
    confidence_score DECIMAL(5, 2),
    
    -- Timestamps
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Statut
    is_active BOOLEAN DEFAULT true,
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    -- Métadonnées
    affected_population_estimate INTEGER,
    description TEXT
);

-- =============================================================================
-- TABLE: alerts - Alertes émises
-- =============================================================================
DROP TABLE IF EXISTS alerts CASCADE;
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level alert_level NOT NULL,
    type disaster_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Zone géographique (simplifiée)
    zone_center_lat DECIMAL(10, 8),
    zone_center_lng DECIMAL(11, 8),
    zone_radius_km DECIMAL(8, 2),
    
    -- Relations
    zone_id UUID REFERENCES disaster_zones(id) ON DELETE SET NULL,
    
    -- Canaux de notification utilisés
    channels notification_channel[] DEFAULT ARRAY['push'::notification_channel],
    
    -- Statut
    is_confirmed BOOLEAN DEFAULT false,
    confirmed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    
    -- Escalade
    escalated_from_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    escalation_reason TEXT,
    
    -- Timestamps
    emitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    -- Métriques
    recipients_count INTEGER DEFAULT 0,
    acknowledged_count INTEGER DEFAULT 0
);

-- =============================================================================
-- TABLE: alert_recipients - Destinataires des alertes
-- =============================================================================
DROP TABLE IF EXISTS alert_recipients CASCADE;
CREATE TABLE alert_recipients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id UUID NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Canal utilisé
    channel notification_channel NOT NULL,
    
    -- Statut de livraison
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT,
    
    UNIQUE(alert_id, user_id)
);

-- =============================================================================
-- TABLE: incidents - Signalements d'incidents
-- =============================================================================
DROP TABLE IF EXISTS incidents CASCADE;
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Localisation
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    
    -- Classification
    status incident_status NOT NULL DEFAULT 'signale',
    type disaster_type NOT NULL,
    
    -- Relations
    reported_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    zone_id UUID REFERENCES disaster_zones(id) ON DELETE SET NULL,
    verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_team_id UUID,
    
    -- Médias
    media_urls TEXT[],
    
    -- Timestamps
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_at TIMESTAMP WITH TIME ZONE,
    assigned_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABLE: shelters - Refuges et abris
-- =============================================================================
DROP TABLE IF EXISTS shelters CASCADE;
CREATE TABLE shelters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    
    -- Localisation
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    address TEXT,
    
    -- Capacité
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    current_occupancy INTEGER DEFAULT 0 CHECK (current_occupancy >= 0),
    type shelter_type NOT NULL DEFAULT 'refuge',
    
    -- Disponibilité
    is_available BOOLEAN DEFAULT true,
    is_full BOOLEAN GENERATED ALWAYS AS (current_occupancy >= capacity) STORED,
    
    -- Contact
    phone VARCHAR(20),
    manager_name VARCHAR(255),
    
    -- Équipements
    has_medical_facilities BOOLEAN DEFAULT false,
    has_food BOOLEAN DEFAULT false,
    has_water BOOLEAN DEFAULT false,
    accessibility_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_status_update TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABLE: evacuation_routes - Itinéraires d'évacuation
-- =============================================================================
DROP TABLE IF EXISTS evacuation_routes CASCADE;
CREATE TABLE evacuation_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Relations
    from_zone_id UUID NOT NULL REFERENCES disaster_zones(id) ON DELETE CASCADE,
    to_shelter_id UUID NOT NULL REFERENCES shelters(id) ON DELETE CASCADE,
    
    -- Métriques
    distance_km DECIMAL(8, 2),
    estimated_time_minutes INTEGER,
    danger_score DECIMAL(5, 2),
    
    -- Points de passage (JSON)
    waypoints JSONB,
    
    -- Statut
    is_active BOOLEAN DEFAULT true,
    is_blocked BOOLEAN DEFAULT false,
    blocked_reason TEXT,
    
    -- Algorithme utilisé
    algorithm_used VARCHAR(50) DEFAULT 'A*',
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    created_for_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL
);

-- =============================================================================
-- TABLE: ai_predictions - Prédictions IA
-- =============================================================================
DROP TABLE IF EXISTS ai_predictions CASCADE;
CREATE TABLE ai_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type disaster_type NOT NULL,
    
    -- Score et zone prédite
    confidence_score DECIMAL(5, 2) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 100),
    
    -- Horizon de prédiction
    prediction_horizon TIMESTAMP WITH TIME ZONE NOT NULL,
    prediction_duration_hours INTEGER,
    
    -- Centre de la zone prédite
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    radius_km DECIMAL(8, 2),
    
    -- Modèle utilisé
    model_used model_type NOT NULL,
    model_version VARCHAR(50),
    
    -- Entrées/features
    features_input JSONB,
    
    -- Validation
    actual_occurred BOOLEAN,
    actual_occurred_at TIMESTAMP WITH TIME ZONE,
    accuracy_measured BOOLEAN DEFAULT false,
    accuracy_score DECIMAL(5, 2),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    triggered_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    
    severity_estimate alert_level
);

-- =============================================================================
-- TABLE: social_signals - Signaux réseaux sociaux
-- =============================================================================
DROP TABLE IF EXISTS social_signals CASCADE;
CREATE TABLE social_signals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_platform VARCHAR(50) NOT NULL,
    external_id VARCHAR(255),
    
    -- Contenu
    raw_text TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'fr',
    
    -- Localisation inférée
    inferred_location_lat DECIMAL(10, 8),
    inferred_location_lng DECIMAL(11, 8),
    location_confidence DECIMAL(5, 2),
    
    -- Analyse NLP
    detected_type disaster_type,
    urgency urgency_level,
    nlp_confidence DECIMAL(5, 2),
    sentiment_score DECIMAL(4, 2),
    keywords JSONB,
    entities JSONB,
    
    -- Auteur (anonymisé)
    author_hash VARCHAR(64),
    author_followers_count INTEGER,
    
    -- Timestamps
    posted_at TIMESTAMP WITH TIME ZONE NOT NULL,
    collected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Relations
    linked_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    linked_incident_id UUID REFERENCES incidents(id) ON DELETE SET NULL,
    
    -- Médias
    media_urls TEXT[],
    
    -- Validation
    is_verified BOOLEAN DEFAULT false,
    is_false_positive BOOLEAN DEFAULT false
);

-- =============================================================================
-- TABLE: rescue_teams - Équipes de secours
-- =============================================================================
DROP TABLE IF EXISTS rescue_teams CASCADE;
CREATE TABLE rescue_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type team_type NOT NULL,
    
    -- Position actuelle
    current_position_lat DECIMAL(10, 8),
    current_position_lng DECIMAL(11, 8),
    
    -- Composition
    team_size INTEGER DEFAULT 1,
    equipment JSONB,
    
    -- Statut
    is_available BOOLEAN DEFAULT true,
    current_status VARCHAR(50) DEFAULT 'disponible',
    
    -- Contact
    radio_frequency VARCHAR(20),
    phone VARCHAR(20),
    leader_name VARCHAR(255),
    
    -- Compétences
    specializations VARCHAR(50)[],
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_position_update TIMESTAMP WITH TIME ZONE,
    deployed_at TIMESTAMP WITH TIME ZONE
);

-- =============================================================================
-- TABLE: team_assignments - Assignations équipes
-- =============================================================================
DROP TABLE IF EXISTS team_assignments CASCADE;
CREATE TABLE team_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES rescue_teams(id) ON DELETE CASCADE,
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    priority INTEGER DEFAULT 1,
    notes TEXT,
    
    status VARCHAR(50) DEFAULT 'assigne',
    
    accepted_at TIMESTAMP WITH TIME ZONE,
    arrived_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(team_id, incident_id, assigned_at)
);

-- =============================================================================
-- TABLE: simulations - Simulations "What If?"
-- =============================================================================
DROP TABLE IF EXISTS simulations CASCADE;
CREATE TABLE simulations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    scenario_type disaster_type NOT NULL,
    parameters JSONB NOT NULL,
    intensity_level INTEGER CHECK (intensity_level >= 1 AND intensity_level <= 10),
    
    -- Zone simulée
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    radius_km DECIMAL(8, 2),
    
    -- Résultats
    results JSONB,
    affected_zones UUID[],
    evacuation_routes_generated INTEGER DEFAULT 0,
    estimated_evacuation_time_minutes INTEGER,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    execution_time_seconds INTEGER,
    
    status VARCHAR(50) DEFAULT 'pending',
    error_message TEXT,
    
    exported_results_url TEXT,
    is_saved BOOLEAN DEFAULT false
);

-- =============================================================================
-- TABLE: weather_data - Données météo
-- =============================================================================
DROP TABLE IF EXISTS weather_data CASCADE;
CREATE TABLE weather_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    
    temperature DECIMAL(5, 2),
    precipitation_24h DECIMAL(6, 2),
    precipitation_1h DECIMAL(6, 2),
    humidity DECIMAL(5, 2),
    wind_speed DECIMAL(6, 2),
    wind_direction INTEGER,
    wind_gust DECIMAL(6, 2),
    pressure DECIMAL(7, 2),
    visibility DECIMAL(6, 2),
    cloud_cover INTEGER,
    river_level DECIMAL(8, 3),
    river_level_trend VARCHAR(20),
    
    weather_condition VARCHAR(100),
    weather_code INTEGER,
    
    source VARCHAR(50) DEFAULT 'openweather',
    station_id VARCHAR(50),
    
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(location_lat, location_lng, recorded_at)
);

-- =============================================================================
-- TABLE: notifications - Historique notifications
-- =============================================================================
DROP TABLE IF EXISTS notifications CASCADE;
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    
    channel notification_channel NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    
    external_message_id VARCHAR(255),
    error_message TEXT,
    device_info JSONB
);

-- =============================================================================
-- TABLE: audit_logs - Journal d'audit
-- =============================================================================
DROP TABLE IF EXISTS audit_logs CASCADE;
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    
    old_values JSONB,
    new_values JSONB,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================
CREATE INDEX idx_disaster_zones_detected_at ON disaster_zones(detected_at DESC);
CREATE INDEX idx_disaster_zones_active ON disaster_zones(is_active, detected_at DESC);
CREATE INDEX idx_alerts_emitted_at ON alerts(emitted_at DESC);
CREATE INDEX idx_alerts_zone_id ON alerts(zone_id);
CREATE INDEX idx_incidents_reported_at ON incidents(reported_at DESC);
CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_zone_id ON incidents(zone_id);
CREATE INDEX idx_social_signals_posted_at ON social_signals(posted_at DESC);
CREATE INDEX idx_weather_data_recorded_at ON weather_data(recorded_at DESC);

-- =============================================================================
-- DONNÉES DE TEST
-- =============================================================================
-- Insérer les refuges de test (10 par province = 60 refuges)
INSERT INTO shelters (name, location_lat, location_lng, capacity, type, address, phone, has_medical_facilities, has_food, has_water) VALUES
-- Province d'Antananarivo
('Centre d Urgence Analakely', -18.9078, 47.5208, 500, 'centre_urgence', 'Analakely, Antananarivo', '+261 20 22 123 45', true, true, true),
('Refuge Antanimena', -18.9156, 47.5123, 300, 'refuge', 'Antanimena, Antananarivo', '+261 20 22 678 90', false, true, true),
('Hôpital Militaire Soavinandriana', -18.9250, 47.5300, 200, 'hopital', 'Soavinandriana, Antananarivo', '+261 20 22 111 22', true, true, true),
('Abri Temporaire 67ha', -18.9055, 47.5085, 150, 'abri_temporaire', 'Marché 67ha, Antananarivo', '+261 20 22 444 55', false, true, false),
('Centre Évacuation Besarety', -18.9025, 47.5345, 400, 'refuge', 'Besarety, Antananarivo', '+261 20 22 555 66', false, true, true),
('Gymnase Couvert Mahamasina', -18.9160, 47.5230, 800, 'refuge', 'Mahamasina, Antananarivo', '+261 20 22 777 88', true, true, true),
('Refuge Antsirabe', -19.8650, 47.0333, 350, 'refuge', 'Antsirabe', '+261 20 44 123 45', true, true, true),
('Hôpital Régional Antsirabe', -19.8580, 47.0400, 250, 'hopital', 'Antsirabe', '+261 20 44 678 90', true, true, true),
('Centre d Urgence Ambatolampy', -19.3833, 47.4167, 200, 'centre_urgence', 'Ambatolampy', '+261 20 44 333 22', true, false, true),
('Abri Temporaire Tsiroanomandidy', -18.7667, 46.0500, 180, 'abri_temporaire', 'Tsiroanomandidy', '+261 20 22 888 99', false, false, true),

-- Province de Toamasina
('Abri Temporaire Toamasina', -18.1442, 49.3956, 400, 'abri_temporaire', 'Toamasina Centre', '+261 20 53 333 44', false, true, true),
('Hôpital Général Toamasina', -18.1550, 49.4100, 300, 'hopital', 'Toamasina', '+261 20 53 111 22', true, true, true),
('Centre d Urgence Toamasina', -18.1380, 49.3880, 250, 'centre_urgence', 'Toamasina', '+261 20 53 444 55', true, true, true),
('Refuge Ambatondrazaka', -17.8333, 48.4167, 200, 'refuge', 'Ambatondrazaka', '+261 20 54 123 45', false, true, true),
('Hôpital Régional Ambatondrazaka', -17.8250, 48.4200, 150, 'hopital', 'Ambatondrazaka', '+261 20 54 678 90', true, true, true),
('Centre d Urgence Moramanga', -18.9333, 48.2000, 180, 'centre_urgence', 'Moramanga', '+261 20 56 123 45', true, false, true),
('Refuge Fénérive-Est', -17.3667, 49.5000, 220, 'refuge', 'Fénérive-Est', '+261 20 57 333 44', false, true, true),
('Abri Temporaire Brickaville', -18.8167, 49.0667, 160, 'abri_temporaire', 'Brickaville', '+261 20 56 777 88', false, false, true),
('Centre Évacuation Vatomandry', -19.3333, 48.9833, 250, 'refuge', 'Vatomandry', '+261 20 56 999 00', true, true, true),
('Refuge Soanierana Ivongo', -16.9167, 49.5833, 140, 'refuge', 'Soanierana Ivongo', '+261 20 57 555 66', false, true, true),

-- Province de Mahajanga
('Centre d Urgence Mahajanga', -15.7167, 46.3167, 350, 'centre_urgence', 'Mahajanga Centre', '+261 20 62 555 66', true, true, true),
('Hôpital Régional Mahajanga', -15.7200, 46.3100, 280, 'hopital', 'Mahajanga', '+261 20 62 111 22', true, true, true),
('Refuge Mahajanga Plage', -15.7100, 46.3300, 200, 'refuge', 'Plage de Mahajanga', '+261 20 62 333 44', false, true, false),
('Refuge Antsohihy', -14.8833, 47.9833, 180, 'refuge', 'Antsohihy', '+261 20 67 123 45', false, true, true),
('Centre d Urgence Antsohihy', -14.8750, 47.9900, 200, 'centre_urgence', 'Antsohihy', '+261 20 67 678 90', true, false, true),
('Abri Temporaire Maintirano', -18.0667, 44.0167, 150, 'abri_temporaire', 'Maintirano', '+261 20 62 777 88', false, false, true),
('Refuge Marovoay', -16.1000, 46.6333, 220, 'refuge', 'Marovoay', '+261 20 62 444 55', false, true, true),
('Centre Évacuation Besalampy', -16.7500, 44.4833, 160, 'refuge', 'Besalampy', '+261 20 62 999 00', true, true, false),
('Hôpital de Base Maevatanana', -16.9500, 46.8333, 120, 'hopital', 'Maevatanana', '+261 20 62 222 33', true, true, true),
('Refuge Tsaratanana', -16.8000, 47.6500, 130, 'refuge', 'Tsaratanana', '+261 20 62 666 77', false, false, true),

-- Province de Fianarantsoa
('Refuge Fianarantsoa', -21.4526, 47.0873, 350, 'refuge', 'Fianarantsoa', '+261 20 75 123 45', false, true, true),
('Hôpital Régional Fianarantsoa', -21.4600, 47.0900, 300, 'hopital', 'Fianarantsoa', '+261 20 75 678 90', true, true, true),
('Centre d Urgence Fianarantsoa', -21.4450, 47.0780, 200, 'centre_urgence', 'Fianarantsoa', '+261 20 75 333 44', true, true, true),
('Refuge Manakara', -22.1464, 48.0106, 180, 'refuge', 'Manakara', '+261 20 72 123 45', false, true, true),
('Hôpital de Base Manakara', -22.1550, 48.0100, 120, 'hopital', 'Manakara', '+261 20 72 678 90', true, true, true),
('Abri Temporaire Ambositra', -20.5250, 47.2500, 250, 'abri_temporaire', 'Ambositra', '+261 20 76 123 45', false, true, true),
('Centre d Urgence Ambositra', -20.5200, 47.2430, 150, 'centre_urgence', 'Ambositra', '+261 20 76 678 90', true, false, true),
('Refuge Ambalavao', -21.8333, 46.9333, 160, 'refuge', 'Ambalavao', '+261 20 75 444 55', false, true, false),
('Centre Évacuation Farafangana', -22.8000, 47.8167, 280, 'refuge', 'Farafangana', '+261 20 72 333 44', true, true, true),
('Hôpital Régional Farafangana', -22.8050, 47.8220, 180, 'hopital', 'Farafangana', '+261 20 72 555 66', true, true, true),

-- Province de Toliara
('Refuge Toliara', -23.3499, 43.6788, 250, 'refuge', 'Toliara', '+261 20 94 123 45', true, false, true),
('Hôpital Régional Toliara', -23.3550, 43.6720, 300, 'hopital', 'Toliara', '+261 20 94 678 90', true, true, true),
('Centre d Urgence Toliara', -23.3450, 43.6600, 200, 'centre_urgence', 'Toliara', '+261 20 94 333 44', true, true, true),
('Abri Temporaire Morondava', -20.2887, 44.3178, 200, 'abri_temporaire', 'Morondava', '+261 20 95 123 45', false, true, true),
('Centre d Urgence Morondava', -20.2930, 44.2830, 180, 'centre_urgence', 'Morondava', '+261 20 95 678 90', true, false, true),
('Refuge Fort Dauphin', -25.0333, 46.9833, 220, 'refuge', 'Fort Dauphin', '+261 20 92 123 45', false, true, true),
('Hôpital Régional Fort Dauphin', -25.0280, 46.9900, 160, 'hopital', 'Fort Dauphin', '+261 20 92 678 90', true, true, true),
('Centre Évacuation Betioky', -23.7167, 44.3833, 140, 'refuge', 'Betioky', '+261 20 94 444 55', false, false, true),
('Refuge Ampanihy', -24.7000, 44.7500, 120, 'refuge', 'Ampanihy', '+261 20 94 555 66', false, true, false),
('Abri Temporaire Sakaraha', -22.9000, 44.5333, 100, 'abri_temporaire', 'Sakaraha', '+261 20 94 777 88', false, false, true),

-- Province d'Antsiranana
('Refuge Antsiranana', -12.2787, 49.2917, 300, 'refuge', 'Antsiranana', '+261 20 82 123 45', true, true, true),
('Hôpital Régional Antsiranana', -12.2900, 49.2900, 250, 'hopital', 'Antsiranana', '+261 20 82 678 90', true, true, true),
('Centre d Urgence Antsiranana', -12.2770, 49.2780, 180, 'centre_urgence', 'Antsiranana', '+261 20 82 333 44', true, true, true),
('Refuge Nosy Be', -13.3120, 48.2548, 150, 'refuge', 'Nosy Be', '+261 20 86 123 45', true, true, true),
('Hôpital de Base Nosy Be', -13.3050, 48.2600, 120, 'hopital', 'Nosy Be', '+261 20 86 678 90', true, true, true),
('Abri Temporaire Ambilobe', -13.2000, 49.0500, 200, 'abri_temporaire', 'Ambilobe', '+261 20 82 444 55', false, true, true),
('Centre d Urgence Sambava', -14.2667, 50.1667, 180, 'centre_urgence', 'Sambava', '+261 20 88 123 45', true, true, true),
('Refuge Antalaha', -14.8833, 50.2667, 160, 'refuge', 'Antalaha', '+261 20 88 678 90', false, true, true),
('Hôpital Régional Sambava', -14.2720, 50.1720, 140, 'hopital', 'Sambava', '+261 20 88 333 44', true, true, true),
('Centre Évacuation Vohemar', -13.3667, 50.0000, 120, 'refuge', 'Vohemar', '+261 20 82 555 66', false, false, true);

-- Fin du schéma
