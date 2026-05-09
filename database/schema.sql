-- =============================================================================
-- 🌪️ MITANDRINA - Schéma de Base de Données PostgreSQL + PostGIS
-- Plateforme IA de Prédiction, Détection et Coordination des Catastrophes
-- =============================================================================

-- Activation de l'extension PostGIS pour les données géospatiales
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- ENUMS - Types énumérés
-- =============================================================================

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
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role user_role NOT NULL DEFAULT 'population',
    
    -- Localisation géographique (point GPS)
    location GEOGRAPHY(POINT, 4326),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    
    -- Préférences d'alerte
    alert_channels notification_channel[] DEFAULT ARRAY['push', 'sms'],
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
    device_tokens TEXT[] -- Tokens Firebase pour push notifications
);

COMMENT ON TABLE users IS 'Utilisateurs de la plateforme MITANDRINA';

-- =============================================================================
-- TABLE: disaster_zones - Zones de catastrophe détectées
-- =============================================================================
CREATE TABLE disaster_zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    
    -- Géométrie de la zone (polygone)
    geometry GEOGRAPHY(POLYGON, 4326),
    
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
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    affected_population_estimate INTEGER,
    description TEXT
);

COMMENT ON TABLE disaster_zones IS 'Zones de catastrophe détectées par l IA';

-- =============================================================================
-- TABLE: alerts - Alertes émises
-- =============================================================================
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level alert_level NOT NULL,
    type disaster_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Zone géographique concernée
    zone_geometry GEOGRAPHY(POLYGON, 4326),
    
    -- Relations
    zone_id UUID REFERENCES disaster_zones(id) ON DELETE SET NULL,
    triggered_by_prediction_id UUID,
    
    -- Canaux de notification utilisés
    channels notification_channel[] DEFAULT ARRAY['push'],
    
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

COMMENT ON TABLE alerts IS 'Alertes émises aux utilisateurs';

-- =============================================================================
-- TABLE: alert_recipients - Destinataires des alertes (N:N)
-- =============================================================================
CREATE TABLE alert_recipients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id UUID NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Canal utilisé pour cet utilisateur
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
-- TABLE: incidents - Signalements d incidents par les utilisateurs
-- =============================================================================
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Localisation
    location GEOGRAPHY(POINT, 4326),
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

COMMENT ON TABLE incidents IS 'Signalements d incidents par la population';

-- =============================================================================
-- TABLE: shelters - Refuges et abris
-- =============================================================================
CREATE TABLE shelters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    
    -- Localisation
    location GEOGRAPHY(POINT, 4326),
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

COMMENT ON TABLE shelters IS 'Refuges et centres d évacuation';

-- =============================================================================
-- TABLE: evacuation_routes - Itinéraires d évacuation calculés
-- =============================================================================
CREATE TABLE evacuation_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Relations
    from_zone_id UUID NOT NULL REFERENCES disaster_zones(id) ON DELETE CASCADE,
    to_shelter_id UUID NOT NULL REFERENCES shelters(id) ON DELETE CASCADE,
    
    -- Géométrie du trajet (ligne)
    path GEOGRAPHY(LINESTRING, 4326),
    
    -- Métriques
    distance_km DECIMAL(8, 2),
    estimated_time_minutes INTEGER,
    danger_score DECIMAL(5, 2),
    
    -- Statut
    is_active BOOLEAN DEFAULT true,
    is_blocked BOOLEAN DEFAULT false,
    blocked_reason TEXT,
    
    -- Algorithme utilisé
    algorithm_used VARCHAR(50) DEFAULT 'A*',
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Métadonnées
    waypoints JSONB, -- Points de passage importants
    created_for_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL
);

COMMENT ON TABLE evacuation_routes IS 'Routes d évacuation calculées par A*';

-- =============================================================================
-- TABLE: ai_predictions - Prédictions des modèles IA
-- =============================================================================
CREATE TABLE ai_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type disaster_type NOT NULL,
    
    -- Score et zone prédite
    confidence_score DECIMAL(5, 2) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 100),
    predicted_zone GEOGRAPHY(POLYGON, 4326),
    
    -- Horizon de prédiction
    prediction_horizon TIMESTAMP WITH TIME ZONE NOT NULL,
    prediction_duration_hours INTEGER,
    
    -- Modèle utilisé
    model_used model_type NOT NULL,
    model_version VARCHAR(50),
    
    -- Entrées/features utilisées
    features_input JSONB,
    
    -- Validation
    actual_occurred BOOLEAN,
    actual_occurred_at TIMESTAMP WITH TIME ZONE,
    accuracy_measured BOOLEAN DEFAULT false,
    accuracy_score DECIMAL(5, 2),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    triggered_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    
    -- Métadonnées
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    severity_estimate alert_level
);

COMMENT ON TABLE ai_predictions IS 'Prédictions générées par les modèles IA';

-- =============================================================================
-- TABLE: social_signals - Signaux des réseaux sociaux (NLP)
-- =============================================================================
CREATE TABLE social_signals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_platform VARCHAR(50) NOT NULL, -- twitter, facebook, etc.
    external_id VARCHAR(255), -- ID du post original
    
    -- Contenu
    raw_text TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'fr',
    
    -- Localisation inférée
    inferred_location GEOGRAPHY(POINT, 4326),
    inferred_location_lat DECIMAL(10, 8),
    inferred_location_lng DECIMAL(11, 8),
    location_confidence DECIMAL(5, 2),
    
    -- Analyse NLP
    detected_type disaster_type,
    urgency urgency_level,
    nlp_confidence DECIMAL(5, 2),
    sentiment_score DECIMAL(4, 2), -- -1 à 1
    keywords JSONB,
    entities JSONB, -- Entités nommées extraites
    
    -- Auteur (anonymisé)
    author_hash VARCHAR(64), -- Hash anonyme de l'auteur
    author_followers_count INTEGER,
    
    -- Timestamps
    posted_at TIMESTAMP WITH TIME ZONE NOT NULL,
    collected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Relations
    linked_alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    linked_incident_id UUID REFERENCES incidents(id) ON DELETE SET NULL,
    
    -- Médias attachés
    media_urls TEXT[],
    
    -- Validation
    is_verified BOOLEAN DEFAULT false,
    is_false_positive BOOLEAN DEFAULT false
);

COMMENT ON TABLE social_signals IS 'Signaux analysés depuis les réseaux sociaux';

-- =============================================================================
-- TABLE: rescue_teams - Équipes de secours
-- =============================================================================
CREATE TABLE rescue_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type team_type NOT NULL,
    
    -- Position actuelle
    current_position GEOGRAPHY(POINT, 4326),
    current_lat DECIMAL(10, 8),
    current_lng DECIMAL(11, 8),
    
    -- Composition
    team_size INTEGER DEFAULT 1,
    equipment JSONB, -- Liste d'équipements
    
    -- Statut
    is_available BOOLEAN DEFAULT true,
    current_status VARCHAR(50) DEFAULT 'disponible', -- disponible, en_deplacement, sur_site, indisponible
    
    -- Contact
    radio_frequency VARCHAR(20),
    phone VARCHAR(20),
    leader_name VARCHAR(255),
    
    -- Compétences
    specializations VARCHAR(50)[], -- eau, feu, medical, etc.
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_position_update TIMESTAMP WITH TIME ZONE,
    deployed_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE rescue_teams IS 'Équipes de secours et interventions';

-- =============================================================================
-- TABLE: team_assignments - Assignations des équipes aux incidents (N:N)
-- =============================================================================
CREATE TABLE team_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES rescue_teams(id) ON DELETE CASCADE,
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    
    -- Détails de l'assignation
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    priority INTEGER DEFAULT 1,
    notes TEXT,
    
    -- Statut
    status VARCHAR(50) DEFAULT 'assigne', -- assigne, accepte, refuse, en_route, sur_place, termine
    
    -- Timestamps
    accepted_at TIMESTAMP WITH TIME ZONE,
    arrived_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(team_id, incident_id, assigned_at)
);

-- =============================================================================
-- TABLE: simulations - Simulations "What If?"
-- =============================================================================
CREATE TABLE simulations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Paramètres du scénario
    scenario_type disaster_type NOT NULL,
    parameters JSONB NOT NULL, -- Paramètres de la simulation
    intensity_level INTEGER CHECK (intensity_level >= 1 AND intensity_level <= 10),
    
    -- Zone simulée
    simulated_impact_zone GEOGRAPHY(POLYGON, 4326),
    center_lat DECIMAL(10, 8),
    center_lng DECIMAL(11, 8),
    radius_km DECIMAL(8, 2),
    
    -- Résultats
    results JSONB, -- Résultats agrégés
    affected_zones UUID[], -- IDs des zones simulées
    evacuation_routes_generated INTEGER DEFAULT 0,
    estimated_evacuation_time_minutes INTEGER,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    execution_time_seconds INTEGER,
    
    -- Statut
    status VARCHAR(50) DEFAULT 'pending', -- pending, running, completed, failed
    error_message TEXT,
    
    -- Export
    exported_results_url TEXT,
    is_saved BOOLEAN DEFAULT false
);

COMMENT ON TABLE simulations IS 'Simulations What If pour la planification';

-- =============================================================================
-- TABLE: weather_data - Données météorologiques
-- =============================================================================
CREATE TABLE weather_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Localisation
    location GEOGRAPHY(POINT, 4326),
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    
    -- Mesures
    temperature DECIMAL(5, 2), -- Celsius
    precipitation_24h DECIMAL(6, 2), -- mm
    precipitation_1h DECIMAL(6, 2), -- mm
    humidity DECIMAL(5, 2), -- %
    wind_speed DECIMAL(6, 2), -- km/h
    wind_direction INTEGER, -- degrés 0-360
    wind_gust DECIMAL(6, 2), -- km/h
    pressure DECIMAL(7, 2), -- hPa
    visibility DECIMAL(6, 2), -- km
    cloud_cover INTEGER, -- %
    
    -- Niveaux d'eau
    river_level DECIMAL(8, 3), -- m
    river_level_trend VARCHAR(20), -- stable, rising, falling
    
    -- Conditions
    weather_condition VARCHAR(100),
    weather_code INTEGER, -- Code OWM
    
    -- Source
    source VARCHAR(50) DEFAULT 'openweather',
    station_id VARCHAR(50),
    
    -- Timestamps
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Index unique sur location + time pour éviter les doublons
    UNIQUE(location_lat, location_lng, recorded_at)
);

COMMENT ON TABLE weather_data IS 'Données météorologiques collectées';

-- =============================================================================
-- TABLE: notifications - Historique des notifications envoyées
-- =============================================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    alert_id UUID REFERENCES alerts(id) ON DELETE SET NULL,
    
    -- Contenu
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- alert, info, warning
    
    -- Canal
    channel notification_channel NOT NULL,
    
    -- Statut
    status VARCHAR(50) DEFAULT 'pending', -- pending, sent, delivered, failed, read
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    
    -- Métadonnées
    external_message_id VARCHAR(255), -- ID chez Twilio/FCM
    error_message TEXT,
    device_info JSONB
);

-- =============================================================================
-- TABLE: audit_logs - Journal d audit
-- =============================================================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    
    -- Détails
    old_values JSONB,
    new_values JSONB,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- INDEXES - Pour optimiser les performances
-- =============================================================================

-- Indexes géospatiaux
CREATE INDEX idx_disaster_zones_geometry ON disaster_zones USING GIST(geometry);
CREATE INDEX idx_incidents_location ON incidents USING GIST(location);
CREATE INDEX idx_shelters_location ON shelters USING GIST(location);
CREATE INDEX idx_evacuation_routes_path ON evacuation_routes USING GIST(path);
CREATE INDEX idx_ai_predictions_zone ON ai_predictions USING GIST(predicted_zone);
CREATE INDEX idx_social_signals_location ON social_signals USING GIST(inferred_location);
CREATE INDEX idx_weather_data_location ON weather_data USING GIST(location);
CREATE INDEX idx_users_location ON users USING GIST(location);
CREATE INDEX idx_rescue_teams_position ON rescue_teams USING GIST(current_position);
CREATE INDEX idx_simulations_zone ON simulations USING GIST(simulated_impact_zone);

-- Indexes temporels
CREATE INDEX idx_disaster_zones_detected_at ON disaster_zones(detected_at DESC);
CREATE INDEX idx_disaster_zones_active ON disaster_zones(is_active, detected_at DESC);
CREATE INDEX idx_alerts_emitted_at ON alerts(emitted_at DESC);
CREATE INDEX idx_incidents_reported_at ON incidents(reported_at DESC);
CREATE INDEX idx_social_signals_posted_at ON social_signals(posted_at DESC);
CREATE INDEX idx_weather_data_recorded_at ON weather_data(recorded_at DESC);
CREATE INDEX idx_ai_predictions_horizon ON ai_predictions(prediction_horizon);

-- Indexes sur les relations
CREATE INDEX idx_alerts_zone_id ON alerts(zone_id);
CREATE INDEX idx_alerts_level ON alerts(level);
CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_type ON incidents(type);
CREATE INDEX idx_incidents_zone_id ON incidents(zone_id);
CREATE INDEX idx_incidents_reported_by ON incidents(reported_by);
CREATE INDEX idx_evacuation_routes_zone ON evacuation_routes(from_zone_id);
CREATE INDEX idx_evacuation_routes_shelter ON evacuation_routes(to_shelter_id);
CREATE INDEX idx_social_signals_alert ON social_signals(linked_alert_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- Indexes pour la recherche textuelle
CREATE INDEX idx_social_signals_text_search ON social_signals USING GIN(to_tsvector('french', raw_text));
CREATE INDEX idx_incidents_description_search ON incidents USING GIN(to_tsvector('french', description));

-- =============================================================================
-- VUES - Pour faciliter les requêtes courantes
-- =============================================================================

-- Vue des zones actives avec métriques
CREATE VIEW active_disaster_zones AS
SELECT 
    dz.*,
    COUNT(DISTINCT i.id) as incident_count,
    COUNT(DISTINCT a.id) as alert_count,
    ST_Area(dz.geometry::geography) / 1000000 as area_km2
FROM disaster_zones dz
LEFT JOIN incidents i ON i.zone_id = dz.id AND i.status != 'archive'
LEFT JOIN alerts a ON a.zone_id = dz.id AND a.resolved_at IS NULL
WHERE dz.is_active = true
GROUP BY dz.id;

-- Vue des équipes disponibles avec position
CREATE VIEW available_rescue_teams AS
SELECT 
    rt.*,
    ST_X(rt.current_position::geometry) as lng,
    ST_Y(rt.current_position::geometry) as lat
FROM rescue_teams rt
WHERE rt.is_available = true;

-- Vue des abris avec capacité restante
CREATE VIEW shelters_with_availability AS
SELECT 
    s.*,
    s.capacity - s.current_occupancy as remaining_capacity,
    (s.current_occupancy::float / s.capacity * 100) as occupancy_percentage
FROM shelters s
WHERE s.is_available = true;

-- Vue des alertes en cours avec statistiques
CREATE VIEW active_alerts_summary AS
SELECT 
    a.*,
    COUNT(ar.id) as recipient_count,
    COUNT(CASE WHEN ar.read_at IS NOT NULL THEN 1 END) as read_count,
    COUNT(CASE WHEN ar.delivered_at IS NOT NULL THEN 1 END) as delivered_count
FROM alerts a
LEFT JOIN alert_recipients ar ON ar.alert_id = a.id
WHERE a.resolved_at IS NULL
GROUP BY a.id;

-- =============================================================================
-- FONCTIONS - Fonctions utilitaires
-- =============================================================================

-- Fonction pour mettre à jour le timestamp updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_disaster_zones_updated_at BEFORE UPDATE ON disaster_zones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shelters_updated_at BEFORE UPDATE ON shelters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incidents_updated_at BEFORE UPDATE ON incidents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rescue_teams_updated_at BEFORE UPDATE ON rescue_teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer la distance entre un point et la zone de danger la plus proche
CREATE OR REPLACE FUNCTION get_nearest_danger_distance(
    user_lat DECIMAL,
    user_lng DECIMAL
) RETURNS TABLE (
    zone_id UUID,
    zone_name VARCHAR,
    danger_level alert_level,
    distance_meters FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dz.id,
        dz.name,
        dz.level,
        ST_Distance(
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
            dz.geometry
        ) as distance
    FROM disaster_zones dz
    WHERE dz.is_active = true
    ORDER BY distance
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour trouver les abris disponibles proches
CREATE OR REPLACE FUNCTION find_nearby_shelters(
    lat DECIMAL,
    lng DECIMAL,
    radius_km INTEGER DEFAULT 50
) RETURNS TABLE (
    shelter_id UUID,
    shelter_name VARCHAR,
    distance_meters FLOAT,
    remaining_capacity INTEGER,
    shelter_type shelter_type
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name,
        ST_Distance(
            ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
            s.location
        ) as distance,
        s.capacity - s.current_occupancy as remaining,
        s.type
    FROM shelters s
    WHERE s.is_available = true
        AND s.is_full = false
        AND ST_DWithin(
            ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
            s.location,
            radius_km * 1000
        )
    ORDER BY distance;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- DONNÉES DE TEST / SEDDING
-- =============================================================================

-- Insérer quelques abris de test
INSERT INTO shelters (name, location_lat, location_lng, capacity, type, address, phone, has_medical_facilities) VALUES
('Centre d urgence Analakely', -18.9078, 47.5208, 500, 'centre_urgence', 'Analakely, Antananarivo', '+261 20 22 123 45', true),
('Refuge Antanimena', -18.9156, 47.5123, 300, 'refuge', 'Antanimena, Antananarivo', '+261 20 22 678 90', false),
('Hôpital Militaire Soavinandriana', -18.9250, 47.5300, 200, 'hopital', 'Soavinandriana, Antananarivo', '+261 20 22 111 22', true),
('Abri Temporaire Tamatave', -18.1442, 49.3956, 400, 'abri_temporaire', 'Toamasina Centre', '+261 20 53 333 44', false),
('Centre d Urgence Majunga', -15.7167, 46.3167, 350, 'centre_urgence', 'Mahajanga Centre', '+261 20 62 555 66', true);

-- Mettre à jour les géométries PostGIS pour les abris
UPDATE shelters SET location = ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326)::geography;

-- =============================================================================
-- COMMENTAIRES FINALS
-- =============================================================================

COMMENT ON DATABASE current_database() IS '🌪️ MITANDRINA - Base de données de la plateforme IA de gestion des catastrophes naturelles';
