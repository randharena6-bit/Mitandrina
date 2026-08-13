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

-- Seed data - 60 refuges (10 par province)
INSERT OR IGNORE INTO shelters (id, name, location_lat, location_lng, capacity, type, address, has_medical_facilities, has_food, has_water) VALUES
-- Province d'Antananarivo
('1',  'Centre d urgence Analakely', -18.9078, 47.5208, 500, 'centre_urgence', 'Analakely, Antananarivo', 1, 1, 1),
('2',  'Refuge Antanimena', -18.9156, 47.5123, 300, 'refuge', 'Antanimena, Antananarivo', 0, 1, 1),
('3',  'Hopital Militaire Soavinandriana', -18.9250, 47.5300, 200, 'hopital', 'Soavinandriana, Antananarivo', 1, 1, 1),
('4',  'Abri Temporaire 67ha', -18.9055, 47.5085, 150, 'abri_temporaire', 'Marche 67ha, Antananarivo', 0, 1, 0),
('5',  'Centre Evacuation Besarety', -18.9025, 47.5345, 400, 'refuge', 'Besarety, Antananarivo', 0, 1, 1),
('6',  'Gymnase Couvert Mahamasina', -18.9160, 47.5230, 800, 'refuge', 'Mahamasina, Antananarivo', 1, 1, 1),
('7',  'Refuge Antsirabe', -19.8650, 47.0333, 350, 'refuge', 'Antsirabe', 1, 1, 1),
('8',  'Hopital Regional Antsirabe', -19.8580, 47.0400, 250, 'hopital', 'Antsirabe', 1, 1, 1),
('9',  'Centre Urgence Ambatolampy', -19.3833, 47.4167, 200, 'centre_urgence', 'Ambatolampy', 1, 0, 1),
('10', 'Abri Temporaire Tsiroanomandidy', -18.7667, 46.0500, 180, 'abri_temporaire', 'Tsiroanomandidy', 0, 0, 1),
-- Province de Toamasina
('11', 'Abri Temporaire Toamasina', -18.1442, 49.3956, 400, 'abri_temporaire', 'Toamasina Centre', 0, 1, 1),
('12', 'Hopital General Toamasina', -18.1550, 49.4100, 300, 'hopital', 'Toamasina', 1, 1, 1),
('13', 'Centre Urgence Toamasina', -18.1380, 49.3880, 250, 'centre_urgence', 'Toamasina', 1, 1, 1),
('14', 'Refuge Ambatondrazaka', -17.8333, 48.4167, 200, 'refuge', 'Ambatondrazaka', 0, 1, 1),
('15', 'Hopital Regional Ambatondrazaka', -17.8250, 48.4200, 150, 'hopital', 'Ambatondrazaka', 1, 1, 1),
('16', 'Centre Urgence Moramanga', -18.9333, 48.2000, 180, 'centre_urgence', 'Moramanga', 1, 0, 1),
('17', 'Refuge Fenerive Est', -17.3667, 49.5000, 220, 'refuge', 'Fenerive-Est', 0, 1, 1),
('18', 'Abri Temporaire Brickaville', -18.8167, 49.0667, 160, 'abri_temporaire', 'Brickaville', 0, 0, 1),
('19', 'Centre Evacuation Vatomandry', -19.3333, 48.9833, 250, 'refuge', 'Vatomandry', 1, 1, 1),
('20', 'Refuge Soanierana Ivongo', -16.9167, 49.5833, 140, 'refuge', 'Soanierana Ivongo', 0, 1, 1),
-- Province de Mahajanga
('21', 'Centre Urgence Mahajanga', -15.7167, 46.3167, 350, 'centre_urgence', 'Mahajanga Centre', 1, 1, 1),
('22', 'Hopital Regional Mahajanga', -15.7200, 46.3100, 280, 'hopital', 'Mahajanga', 1, 1, 1),
('23', 'Refuge Mahajanga Plage', -15.7100, 46.3300, 200, 'refuge', 'Plage de Mahajanga', 0, 1, 0),
('24', 'Refuge Antsohihy', -14.8833, 47.9833, 180, 'refuge', 'Antsohihy', 0, 1, 1),
('25', 'Centre Urgence Antsohihy', -14.8750, 47.9900, 200, 'centre_urgence', 'Antsohihy', 1, 0, 1),
('26', 'Abri Temporaire Maintirano', -18.0667, 44.0167, 150, 'abri_temporaire', 'Maintirano', 0, 0, 1),
('27', 'Refuge Marovoay', -16.1000, 46.6333, 220, 'refuge', 'Marovoay', 0, 1, 1),
('28', 'Centre Evacuation Besalampy', -16.7500, 44.4833, 160, 'refuge', 'Besalampy', 1, 1, 0),
('29', 'Hopital de Base Maevatanana', -16.9500, 46.8333, 120, 'hopital', 'Maevatanana', 1, 1, 1),
('30', 'Refuge Tsaratanana', -16.8000, 47.6500, 130, 'refuge', 'Tsaratanana', 0, 0, 1),
-- Province de Fianarantsoa
('31', 'Refuge Fianarantsoa', -21.4526, 47.0873, 350, 'refuge', 'Fianarantsoa', 0, 1, 1),
('32', 'Hopital Regional Fianarantsoa', -21.4600, 47.0900, 300, 'hopital', 'Fianarantsoa', 1, 1, 1),
('33', 'Centre Urgence Fianarantsoa', -21.4450, 47.0780, 200, 'centre_urgence', 'Fianarantsoa', 1, 1, 1),
('34', 'Refuge Manakara', -22.1464, 48.0106, 180, 'refuge', 'Manakara', 0, 1, 1),
('35', 'Hopital de Base Manakara', -22.1550, 48.0100, 120, 'hopital', 'Manakara', 1, 1, 1),
('36', 'Abri Temporaire Ambositra', -20.5250, 47.2500, 250, 'abri_temporaire', 'Ambositra', 0, 1, 1),
('37', 'Centre Urgence Ambositra', -20.5200, 47.2430, 150, 'centre_urgence', 'Ambositra', 1, 0, 1),
('38', 'Refuge Ambalavao', -21.8333, 46.9333, 160, 'refuge', 'Ambalavao', 0, 1, 0),
('39', 'Centre Evacuation Farafangana', -22.8000, 47.8167, 280, 'refuge', 'Farafangana', 1, 1, 1),
('40', 'Hopital Regional Farafangana', -22.8050, 47.8220, 180, 'hopital', 'Farafangana', 1, 1, 1),
-- Province de Toliara
('41', 'Refuge Toliara', -23.3499, 43.6788, 250, 'refuge', 'Toliara', 1, 0, 1),
('42', 'Hopital Regional Toliara', -23.3550, 43.6720, 300, 'hopital', 'Toliara', 1, 1, 1),
('43', 'Centre Urgence Toliara', -23.3450, 43.6600, 200, 'centre_urgence', 'Toliara', 1, 1, 1),
('44', 'Abri Temporaire Morondava', -20.2887, 44.3178, 200, 'abri_temporaire', 'Morondava', 0, 1, 1),
('45', 'Centre Urgence Morondava', -20.2930, 44.2830, 180, 'centre_urgence', 'Morondava', 1, 0, 1),
('46', 'Refuge Fort Dauphin', -25.0333, 46.9833, 220, 'refuge', 'Fort Dauphin', 0, 1, 1),
('47', 'Hopital Regional Fort Dauphin', -25.0280, 46.9900, 160, 'hopital', 'Fort Dauphin', 1, 1, 1),
('48', 'Centre Evacuation Betioky', -23.7167, 44.3833, 140, 'refuge', 'Betioky', 0, 0, 1),
('49', 'Refuge Ampanihy', -24.7000, 44.7500, 120, 'refuge', 'Ampanihy', 0, 1, 0),
('50', 'Abri Temporaire Sakaraha', -22.9000, 44.5333, 100, 'abri_temporaire', 'Sakaraha', 0, 0, 1),
-- Province d'Antsiranana
('51', 'Refuge Antsiranana', -12.2787, 49.2917, 300, 'refuge', 'Antsiranana', 1, 1, 1),
('52', 'Hopital Regional Antsiranana', -12.2900, 49.2900, 250, 'hopital', 'Antsiranana', 1, 1, 1),
('53', 'Centre Urgence Antsiranana', -12.2770, 49.2780, 180, 'centre_urgence', 'Antsiranana', 1, 1, 1),
('54', 'Refuge Nosy Be', -13.3120, 48.2548, 150, 'refuge', 'Nosy Be', 1, 1, 1),
('55', 'Hopital de Base Nosy Be', -13.3050, 48.2600, 120, 'hopital', 'Nosy Be', 1, 1, 1),
('56', 'Abri Temporaire Ambilobe', -13.2000, 49.0500, 200, 'abri_temporaire', 'Ambilobe', 0, 1, 1),
('57', 'Centre Urgence Sambava', -14.2667, 50.1667, 180, 'centre_urgence', 'Sambava', 1, 1, 1),
('58', 'Refuge Antalaha', -14.8833, 50.2667, 160, 'refuge', 'Antalaha', 0, 1, 1),
('59', 'Hopital Regional Sambava', -14.2720, 50.1720, 140, 'hopital', 'Sambava', 1, 1, 1),
('60', 'Centre Evacuation Vohemar', -13.3667, 50.0000, 120, 'refuge', 'Vohemar', 0, 0, 1);

-- Insert test user (password: test123)
INSERT OR IGNORE INTO users (id, email, password_hash, first_name, last_name, role, location_lat, location_lng) VALUES
('test-user-1', 'test@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.VTtYA.qGZvKG6G', 'Test', 'User', 'population', -18.9078, 47.5208);
