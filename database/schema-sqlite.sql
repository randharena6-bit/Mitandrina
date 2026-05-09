-- =============================================================================
-- MITANDRINA - Schema SQLite (pour développement rapide)
-- =============================================================================

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone_number TEXT,
    role TEXT DEFAULT 'population' CHECK(role IN ('population', 'secouriste', 'administrateur')),
    location_lat REAL,
    location_lng REAL,
    alert_channels TEXT DEFAULT 'push,sms',
    alert_radius_km INTEGER DEFAULT 50,
    is_active INTEGER DEFAULT 1,
    email_verified INTEGER DEFAULT 0,
    phone_verified INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    first_name TEXT,
    last_name TEXT,
    emergency_contact_phone TEXT,
    device_tokens TEXT
);

-- Table: shelters
CREATE TABLE IF NOT EXISTS shelters (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    location_lat REAL NOT NULL,
    location_lng REAL NOT NULL,
    address TEXT,
    capacity INTEGER NOT NULL,
    current_occupancy INTEGER DEFAULT 0,
    type TEXT DEFAULT 'refuge' CHECK(type IN ('refuge', 'hopital', 'centre_urgence', 'abri_temporaire')),
    is_available INTEGER DEFAULT 1,
    phone TEXT,
    has_medical_facilities INTEGER DEFAULT 0,
    has_food INTEGER DEFAULT 0,
    has_water INTEGER DEFAULT 0
);

-- Table: disaster_zones
CREATE TABLE IF NOT EXISTS disaster_zones (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    center_lat REAL,
    center_lng REAL,
    radius_km REAL DEFAULT 10,
    danger_score REAL,
    type TEXT CHECK(type IN ('inondation', 'incendie', 'cyclone', 'seisme', 'glissement_terrain', 'tsunami')),
    level TEXT DEFAULT 'vigilance' CHECK(level IN ('info', 'vigilance', 'alerte', 'urgence')),
    detected_by TEXT,
    confidence_score REAL,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active INTEGER DEFAULT 1,
    description TEXT
);

-- Table: alerts
CREATE TABLE IF NOT EXISTS alerts (
    id TEXT PRIMARY KEY,
    level TEXT CHECK(level IN ('info', 'vigilance', 'alerte', 'urgence')),
    type TEXT,
    title TEXT NOT NULL,
    message TEXT,
    zone_center_lat REAL,
    zone_center_lng REAL,
    zone_radius_km REAL,
    zone_id TEXT,
    channels TEXT DEFAULT 'push',
    is_confirmed INTEGER DEFAULT 0,
    confirmed_by TEXT,
    confirmed_at TIMESTAMP,
    emitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Table: incidents
CREATE TABLE IF NOT EXISTS incidents (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    location_lat REAL,
    location_lng REAL,
    status TEXT DEFAULT 'signale' CHECK(status IN ('signale', 'verifie', 'en_cours', 'resolu', 'archive')),
    type TEXT,
    reported_by TEXT,
    zone_id TEXT,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed data
INSERT OR IGNORE INTO shelters (id, name, location_lat, location_lng, capacity, type, address, has_medical_facilities) VALUES
('1', 'Centre d urgence Analakely', -18.9078, 47.5208, 500, 'centre_urgence', 'Analakely, Antananarivo', 1),
('2', 'Refuge Antanimena', -18.9156, 47.5123, 300, 'refuge', 'Antanimena, Antananarivo', 0),
('3', 'Hopital Militaire', -18.9250, 47.5300, 200, 'hopital', 'Soavinandriana', 1);

-- Insert test user (password: test123)
INSERT OR IGNORE INTO users (id, email, password_hash, first_name, last_name, role, location_lat, location_lng) VALUES
('test-user-1', 'test@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.VTtYA.qGZvKG6G', 'Test', 'User', 'population', -18.9078, 47.5208);
