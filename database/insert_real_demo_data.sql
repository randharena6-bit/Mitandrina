-- =============================================================================
-- 🌪️ MITANDRINA - Peuplement de Données de Démo Réalistes (Antananarivo)
-- =============================================================================

-- Nettoyer les anciennes données de test pour repartir sur une base propre
DELETE FROM team_assignments;
DELETE FROM rescue_teams;
DELETE FROM incidents;
DELETE FROM alert_recipients;
DELETE FROM alerts;
DELETE FROM disaster_zones;
DELETE FROM simulations;

-- =============================================================================
-- 1. INSÉRER LES ZONES DE CATASTROPHE DÉTECTEES PAR L'IA (DISASTER ZONES)
-- =============================================================================

-- Zone 1: Inondation active à Besarety
INSERT INTO disaster_zones (
    id, name, danger_score, type, level, detected_by, confidence_score, 
    detected_at, is_active, center_lat, center_lng, affected_population_estimate, description
) VALUES (
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'Zone Besarety - Inondation active',
    78.50,
    'inondation',
    'alerte',
    'lstm',
    92.40,
    NOW() - INTERVAL '2 hours',
    true,
    -18.9025,
    47.5345,
    4500,
    'Montée critique des eaux dans les bas quartiers de Besarety et Avaradoha suite au débordement du canal de drainage. Risque élevé pour les habitations.'
);

-- Zone 2: Éboulement et glissement de terrain à Ankadifotsy
INSERT INTO disaster_zones (
    id, name, danger_score, type, level, detected_by, confidence_score, 
    detected_at, is_active, center_lat, center_lng, affected_population_estimate, description
) VALUES (
    'b2c3d4e5-f67a-8b9c-0d1e-2f3a4b5c6d7e',
    'Éboulement Ankadifotsy',
    85.00,
    'glissement_terrain',
    'urgence',
    'xgboost',
    88.70,
    NOW() - INTERVAL '1 hour',
    true,
    -18.9050,
    47.5270,
    1200,
    'Instabilité des pentes et des structures de soutènement sur la colline d''Ankadifotsy Haute Ville en raison de l''infiltration d''eau continue.'
);

-- Zone 3: Cyclone Freddy - Passage Analamanga
INSERT INTO disaster_zones (
    id, name, danger_score, type, level, detected_by, confidence_score, 
    detected_at, is_active, center_lat, center_lng, affected_population_estimate, description
) VALUES (
    'c3d4e5f6-7a8b-9c0d-1e2f-3a4b5c6d7e8f',
    'Cyclone Freddy - Passage Analamanga',
    92.00,
    'cyclone',
    'urgence',
    'cnn',
    95.00,
    NOW() - INTERVAL '5 hours',
    true,
    -18.9000,
    47.5200,
    150000,
    'Passage imminent du cœur du cyclone Freddy. Vents extrêmes supérieurs à 120 km/h et cumuls de pluie exceptionnels prévus.'
);

-- Mettre à jour les géométries PostGIS pour les zones (polygones approximatifs)
UPDATE disaster_zones 
SET geometry = ST_SetSRID(ST_MakePolygon(ST_GeomFromText('LINESTRING(' || 
    (center_lng - 0.005) || ' ' || (center_lat - 0.005) || ', ' ||
    (center_lng + 0.005) || ' ' || (center_lat - 0.005) || ', ' ||
    (center_lng + 0.005) || ' ' || (center_lat + 0.005) || ', ' ||
    (center_lng - 0.005) || ' ' || (center_lat + 0.005) || ', ' ||
    (center_lng - 0.005) || ' ' || (center_lat - 0.005) || ')')), 4326)::geography;


-- =============================================================================
-- 2. INSÉRER LES ALERTES ÉMISES (ALERTS)
-- =============================================================================

-- Alerte 1: Inondations Besarety
INSERT INTO alerts (
    id, level, type, title, message, zone_id, channels, is_confirmed, confirmed_by, confirmed_at, emitted_at, recipients_count, acknowledged_count
) VALUES (
    'd4e5f67a-8b9c-0d1e-2f3a-4b5c6d7e8f9a',
    'alerte',
    'inondation',
    'Alerte Rouge - Inondations à Besarety',
    'Montée critique des eaux dans le canal d''Andriantany. Évacuation immédiate conseillée pour les zones basses de Besarety et Avaradoha. Réfugiez-vous au Centre d''urgence Analakely.',
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    ARRAY['push'::notification_channel, 'sms'::notification_channel, 'websocket'::notification_channel],
    true,
    '23f5105f-213f-4648-9f61-87045ee56442',
    NOW() - INTERVAL '1 hour 55 minutes',
    NOW() - INTERVAL '2 hours',
    1250,
    842
);

-- Alerte 2: Éboulement Ankadifotsy
INSERT INTO alerts (
    id, level, type, title, message, zone_id, channels, is_confirmed, confirmed_by, confirmed_at, emitted_at, recipients_count, acknowledged_count
) VALUES (
    'e5f67a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b',
    'urgence',
    'glissement_terrain',
    'Danger Imminent - Risque d''éboulement à Ankadifotsy',
    'Glissement de terrain en cours constaté sur les hauteurs d''Ankadifotsy. Évacuation d''urgence obligatoire pour tous les résidents de la zone rouge. Rejoignez immédiatement le Refuge Antanimena.',
    'b2c3d4e5-f67a-8b9c-0d1e-2f3a4b5c6d7e',
    ARRAY['push'::notification_channel, 'sms'::notification_channel, 'sirene'::notification_channel],
    true,
    '23f5105f-213f-4648-9f61-87045ee56442',
    NOW() - INTERVAL '25 minutes',
    NOW() - INTERVAL '30 minutes',
    420,
    398
);

-- Alerte 3: Cyclone Freddy
INSERT INTO alerts (
    id, level, type, title, message, zone_id, channels, is_confirmed, confirmed_by, confirmed_at, emitted_at, recipients_count, acknowledged_count
) VALUES (
    'f67a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c',
    'vigilance',
    'cyclone',
    'Alerte Cyclone Freddy - Vigilance Forte Analamanga',
    'Fortes rafales de vent (>100km/h) et pluies torrentielles attendues. Restez confinés, stockez eau potable et nourriture, sécurisez vos toits. Numéro d''urgence : 117/118.',
    'c3d4e5f6-7a8b-9c0d-1e2f-3a4b5c6d7e8f',
    ARRAY['push'::notification_channel, 'sms'::notification_channel, 'email'::notification_channel],
    true,
    '23f5105f-213f-4648-9f61-87045ee56442',
    NOW() - INTERVAL '4 hours 50 minutes',
    NOW() - INTERVAL '5 hours',
    15400,
    11204
);

-- Mettre à jour les géométries PostGIS pour les alertes (calquées sur les zones de danger)
UPDATE alerts a
SET zone_geometry = dz.geometry
FROM disaster_zones dz
WHERE a.zone_id = dz.id;


-- =============================================================================
-- 3. INSÉRER LES SIGNALEMENTS D'INCIDENTS DES UTILISATEURS (INCIDENTS)
-- =============================================================================

-- Incident 1: Inondation Besarety
INSERT INTO incidents (
    id, title, description, location_lat, location_lng, status, type, reported_by, zone_id, verified_by, reported_at
) VALUES (
    '1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
    'Route submergée et véhicules bloqués',
    'Le rond-point de Besarety est entièrement inondé avec plus de 80 cm d''eau. La circulation est totalement coupée, plusieurs minibus Taxis-be sont bloqués au milieu de la chaussée et l''eau s''infiltre dans les habitations riveraines.',
    -18.9025,
    47.5345,
    'verifie',
    'inondation',
    'c2a6598c-da6b-405e-9a61-1b854eb07e46', -- Eric RANDRY
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', -- Zone Besarety
    '7e292fac-95ba-4a9b-b0e2-98e807c60891', -- Secouriste Rasoa
    NOW() - INTERVAL '90 minutes'
);

-- Incident 2: Glissement de terrain Ankadifotsy
INSERT INTO incidents (
    id, title, description, location_lat, location_lng, status, type, reported_by, zone_id, verified_by, reported_at
) VALUES (
    '2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e',
    'Effondrement partiel d''habitation flanc de colline',
    'Suite à l''infiltration massive d''eaux pluviales, une grande partie du mur de soutènement en pierre s''est écroulée sur le toit d''une maison en contrebas sur les hauteurs d''Ankadifotsy. Une famille est coincée à l''intérieur.',
    -18.9050,
    47.5270,
    'en_cours',
    'glissement_terrain',
    '2cdf28ff-9fcc-422a-855a-717a6aacd0af', -- Jean Dupont
    'b2c3d4e5-f67a-8b9c-0d1e-2f3a4b5c6d7e', -- Zone Ankadifotsy
    '7e292fac-95ba-4a9b-b0e2-98e807c60891', -- Secouriste Rasoa
    NOW() - INTERVAL '45 minutes'
);

-- Incident 3: Canal bouché provoquant débordement à 67ha
INSERT INTO incidents (
    id, title, description, location_lat, location_lng, status, type, reported_by, reported_at
) VALUES (
    '3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f',
    'Débordement du canal d''eaux usées 67ha',
    'Le grand canal d''évacuation des 67ha est saturé d''ordures ménagères et déborde au niveau du marché. Les eaux usées se déversent sur la chaussée principale, causant une odeur insoutenable et bloquant le passage piétons.',
    -18.9055,
    47.5085,
    'signale',
    'inondation',
    'bc997818-b77a-4ca0-b705-c36259e44429', -- Test User
    NOW() - INTERVAL '15 minutes'
);

-- Mettre à jour les géométries PostGIS pour les incidents
UPDATE incidents SET location = ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326)::geography;


-- =============================================================================
-- 4. INSÉRER LES ÉQUIPES DE SECOURS (RESCUE TEAMS)
-- =============================================================================

INSERT INTO rescue_teams (
    id, name, type, current_lat, current_lng, team_size, is_available, current_status, radio_frequency, phone, leader_name, specializations
) VALUES (
    'f1e2d3c4-b5a6-9f8e-7d6c-5b4a3f2e1d0c',
    'Sapeurs-Pompiers d''Analakely',
    'pompier',
    -18.9078,
    47.5208,
    12,
    false,
    'sur_site',
    '164.500 MHz',
    '+261 34 22 456 78',
    'Capitaine Randrianarisoa',
    ARRAY['incendie', 'sauvetage', 'evacuation']
);

INSERT INTO rescue_teams (
    id, name, type, current_lat, current_lng, team_size, is_available, current_status, radio_frequency, phone, leader_name, specializations
) VALUES (
    'e2d3c4b5-a69f-8e7d-6c5b-4a3f2e1d0c9b',
    'Secouristes Croix Rouge Malagasy',
    'secouriste',
    -18.9120,
    47.5180,
    8,
    true,
    'disponible',
    '158.225 MHz',
    '+261 32 11 987 65',
    'Mme Rasoamanarivo',
    ARRAY['secourisme', 'premiers_soins', 'abri']
);

INSERT INTO rescue_teams (
    id, name, type, current_lat, current_lng, team_size, is_available, current_status, radio_frequency, phone, leader_name, specializations
) VALUES (
    'd3c4b5a6-9f8e-7d6c-5b4a-3f2e1d0c9b8a',
    'Équipe Médicale Soavinandriana',
    'medical',
    -18.9250,
    47.5300,
    5,
    true,
    'disponible',
    '168.100 MHz',
    '+261 33 05 111 22',
    'Dr Rakotomavo',
    ARRAY['urgences_medicales', 'tri', 'soutien_psychologique']
);

-- Mettre à jour les géométries PostGIS pour les équipes de secours
-- UPDATE rescue_teams SET current_position = ST_SetSRID(ST_MakePoint(current_lng, current_lat), 4326)::geography; -- Disabled to avoid trigger error on tables without updated_at


-- =============================================================================
-- 5. ASSIGNATIONS DES EQUIPES (TEAM ASSIGNMENTS)
-- =============================================================================

-- Assigner les Pompiers d'Analakely à l'incident d'éboulement d'Ankadifotsy (en cours d'intervention)
INSERT INTO team_assignments (
    id, team_id, incident_id, assigned_by, assigned_at, priority, notes, status, arrived_at
) VALUES (
    '9a8b7c6d-5e4f-3a2b-1c0d-9e8d7c6b5a4f',
    'f1e2d3c4-b5a6-9f8e-7d6c-5b4a3f2e1d0c', -- Pompiers d'Analakely
    '2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e', -- Éboulement Ankadifotsy
    '23f5105f-213f-4648-9f61-87045ee56442', -- Admin
    NOW() - INTERVAL '35 minutes',
    2,
    'Recherche et extraction de la famille coincée sous les décombres de l''effondrement partiel. Sécurisation du périmètre.',
    'sur_place',
    NOW() - INTERVAL '25 minutes'
);

-- Mettre à jour l'incident pour refléter l'équipe assignée
UPDATE incidents 
SET assigned_team_id = 'f1e2d3c4-b5a6-9f8e-7d6c-5b4a3f2e1d0c', assigned_at = NOW() - INTERVAL '35 minutes'
WHERE id = '2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e';


-- =============================================================================
-- 6. INSÉRER LES REFUGES (SHELTERS)
-- =============================================================================

INSERT INTO shelters (
    id, name, type, location_lat, location_lng, address, capacity, current_occupancy,
    is_available, has_medical_facilities, has_food, has_water, phone, manager_name
) VALUES (
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'Centre d''Urgence Analakely',
    'centre_urgence',
    -18.8950,
    47.5150,
    'Avenue de l''Indépendance, Analakely',
    500,
    320,
    true,
    true,
    true,
    true,
    '+261 34 22 123 45',
    'Dr Rasoarimanana'
);

INSERT INTO shelters (
    id, name, type, location_lat, location_lng, address, capacity, current_occupancy,
    is_available, has_medical_facilities, has_food, has_water, phone, manager_name
) VALUES (
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'Refuge Antanimena',
    'refuge',
    -18.9100,
    47.5250,
    'Quartier Antanimena, Antananarivo',
    300,
    180,
    true,
    false,
    true,
    true,
    '+261 34 22 234 56',
    'Mme Randriamampionona'
);

INSERT INTO shelters (
    id, name, type, location_lat, location_lng, address, capacity, current_occupancy,
    is_available, has_medical_facilities, has_food, has_water, phone, manager_name
) VALUES (
    'c3d4e5f6-7a8b-9c0d-1e2f-3a4b5c6d7e8f',
    'Hôpital Militaire Soavinandriana',
    'hopital',
    -18.9250,
    47.5300,
    'Soavinandriana, Antananarivo',
    200,
    150,
    true,
    true,
    true,
    true,
    '+261 34 22 345 67',
    'Colonel Rakoto'
);

INSERT INTO shelters (
    id, name, type, location_lat, location_lng, address, capacity, current_occupancy,
    is_available, has_medical_facilities, has_food, has_water, phone, manager_name
) VALUES (
    'd4e5f6a7-8b9c-0d1e-2f3a-4b5c6d7e8f9a',
    'Abri Temporaire 67ha',
    'abri_temporaire',
    -18.9055,
    47.5085,
    'Marché 67ha, Antananarivo',
    150,
    45,
    true,
    false,
    true,
    false,
    '+261 34 22 456 78',
    'M. Ravelonjatovo'
);

INSERT INTO shelters (
    id, name, type, location_lat, location_lng, address, capacity, current_occupancy,
    is_available, has_medical_facilities, has_food, has_water, phone, manager_name
) VALUES (
    'e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b',
    'Centre Évacuation Besarety',
    'refuge',
    -18.9025,
    47.5345,
    'Besarety, Antananarivo',
    400,
    280,
    true,
    false,
    true,
    true,
    '+261 34 22 567 89',
    'Mme Randrianarivelo'
);

-- Refuges pour les autres provinces (Toamasina, Mahajanga, Fianarantsoa, Toliara, Antsiranana)
INSERT INTO shelters (
    id, name, type, location_lat, location_lng, address, capacity, current_occupancy,
    is_available, has_medical_facilities, has_food, has_water, phone, manager_name
) VALUES
(
    'f6a7b8c9-0d1e-2f3a-4b5c-6d7e8f9a0b1c',
    'Abri Temporaire Toamasina',
    'abri_temporaire',
    -18.1442, 49.3956,
    'Boulevard Joffre, Toamasina',
    400, 180,
    true, false, true, true,
    '+261 34 22 789 01',
    'M. Rabemananjara'
),
(
    '0b1c2d3e-4f5a-6b7c-8d9e-0f1a2b3c4d5e',
    'Hôpital Général Toamasina',
    'hopital',
    -18.1550, 49.4100,
    'Avenue de la Libération, Toamasina',
    300, 210,
    true, true, true, true,
    '+261 34 22 890 12',
    'Dr Razafindrakoto'
),
(
    '1c2d3e4f-5a6b-7c8d-9e0f-1a2b3c4d5e6f',
    'Centre d''Urgence Mahajanga',
    'centre_urgence',
    -15.7167, 46.3167,
    'Avenue de France, Mahajanga',
    350, 85,
    true, true, true, true,
    '+261 34 22 901 23',
    'M. Andriamampionona'
),
(
    '2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a',
    'Refuge Fianarantsoa',
    'refuge',
    -21.4526, 47.0873,
    'Haute Ville, Fianarantsoa',
    350, 95,
    true, false, true, true,
    '+261 34 22 012 34',
    'Mme Rasoanirina'
),
(
    '3e4f5a6b-7c8d-9e0f-1a2b-3c4d5e6f7a8b',
    'Hôpital Régional Fianarantsoa',
    'hopital',
    -21.4600, 47.0900,
    'Tsianolondroa, Fianarantsoa',
    300, 190,
    true, true, true, true,
    '+261 34 22 123 45',
    'Dr Randriantsiferana'
),
(
    '4f5a6b7c-8d9e-0f1a-2b3c-4d5e6f7a8b9c',
    'Refuge Toliara',
    'refuge',
    -23.3499, 43.6788,
    'Avenue de l''Indépendance, Toliara',
    250, 45,
    true, true, false, true,
    '+261 34 22 234 56',
    'M. Ratsimbazafy'
),
(
    '5a6b7c8d-9e0f-1a2b-3c4d-5e6f7a8b9c0d',
    'Refuge Antsiranana',
    'refuge',
    -12.2787, 49.2917,
    'Place Foch, Antsiranana',
    300, 35,
    true, true, true, true,
    '+261 34 22 345 67',
    'Mme Rabearisoa'
);
UPDATE shelters SET location = ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326)::geography;


-- =============================================================================
-- 7. INSÉRER LES SIMULATIONS (SIMULATIONS)
-- =============================================================================

INSERT INTO simulations (
    id, name, created_by, scenario_type, parameters, intensity_level, 
    simulated_impact_zone, center_lat, center_lng, radius_km, results, 
    evacuation_routes_generated, estimated_evacuation_time_minutes, created_at, started_at, completed_at, status
) VALUES (
    '8b7c6d5e-4f3a-2b1c-0d9e-8d7c6b5a4f3e',
    'Simulation Inondation Plaine Betsimitatatra',
    '23f5105f-213f-4648-9f61-87045ee56442',
    'inondation',
    '{"pluviometrie_24h": 150, "debit_ikopa_m3s": 320, "duree_pluie_h": 24}',
    8,
    ST_SetSRID(ST_MakePolygon(ST_GeomFromText('LINESTRING(47.480 -18.880, 47.520 -18.880, 47.520 -18.920, 47.480 -18.920, 47.480 -18.880)')), 4326)::geography,
    -18.9000,
    47.5000,
    5.0,
    '{"points_critiques_submerges": 12, "sinistres_estimes": 18500, "abris_requis": 4, "cout_dommages_mga": 420000000}',
    8,
    120,
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days' + INTERVAL '5 seconds',
    NOW() - INTERVAL '3 days' + INTERVAL '35 seconds',
    'completed'
);

-- =============================================================================
-- SIMULATION CYCLONE FREDDY (Données réelles de février-mars 2023)
-- =============================================================================
INSERT INTO simulations (
    id, name, created_by, scenario_type, parameters, intensity_level, 
    simulated_impact_zone, center_lat, center_lng, radius_km, results, 
    evacuation_routes_generated, estimated_evacuation_time_minutes, created_at, started_at, completed_at, status
) VALUES (
    'f6a7b8c9-d0e1-2f3a-4b5c-6d7e8f9a0b1c',
    'Cyclone Freddy - Trajectoire Complète (36 jours)',
    '23f5105f-213f-4648-9f61-87045ee56442',
    'cyclone',
    '{
        "date_debut": "2023-02-06T00:00:00Z",
        "date_fin": "2023-03-15T00:00:00Z",
        "duree_jours": 36,
        "vents_max_kmh": 185,
        "rafales_max_kmh": 280,
        "pression_min_hpa": 928,
        "stade_max": "Cyclone tropical intense",
        "categorie_sshws": 4,
        "landfalls": [
            {"date": "2023-02-21T22:30:00Z", "lieu": "Mananjary, Madagascar", "vents_kmh": 165, "rafales_kmh": 235},
            {"date": "2023-02-24T12:00:00Z", "lieu": "Beira-Inhambane, Mozambique", "vents_kmh": 95, "rafales_kmh": 145},
            {"date": "2023-03-11T00:00:00Z", "lieu": "Quélimane, Mozambique", "vents_kmh": 170, "rafales_kmh": 265},
            {"date": "2023-03-13T00:00:00Z", "lieu": "Malawi (Blantyre, Zomba)", "vents_kmh": 75, "rafales_kmh": 115}
        ],
        "trajectoire": [
            {"lat": -12.0, "lng": 100.0, "date": "2023-02-06T00:00:00Z", "stade": "Perturbation tropicale"},
            {"lat": -15.0, "lng": 83.5, "date": "2023-02-11T12:00:00Z", "stade": "Cyclone tropical"},
            {"lat": -16.8, "lng": 66.5, "date": "2023-02-17T06:00:00Z", "stade": "Cyclone tropical intense", "pic": true},
            {"lat": -17.4, "lng": 60.5, "date": "2023-02-19T18:00:00Z", "stade": "Cyclone tropical intense"},
            {"lat": -19.8, "lng": 49.9, "date": "2023-02-21T22:30:00Z", "stade": "Cyclone tropical intense", "landfall": "Madagascar"},
            {"lat": -22.0, "lng": 37.0, "date": "2023-02-24T12:00:00Z", "stade": "Forte tempête tropicale", "landfall": "Mozambique 1"},
            {"lat": -23.5, "lng": 42.0, "date": "2023-03-05T00:00:00Z", "stade": "Forte tempête tropicale"},
            {"lat": -20.5, "lng": 36.5, "date": "2023-03-08T12:00:00Z", "stade": "Cyclone tropical intense", "pic2": true},
            {"lat": -20.8, "lng": 36.2, "date": "2023-03-11T00:00:00Z", "stade": "Cyclone tropical intense", "landfall": "Mozambique 2"},
            {"lat": -16.5, "lng": 35.2, "date": "2023-03-13T00:00:00Z", "stade": "Tempête tropicale modérée", "landfall": "Malawi"},
            {"lat": -13.5, "lng": 35.8, "date": "2023-03-15T00:00:00Z", "stade": "Perturbation résiduelle"}
        ]
    }'::jsonb,
    10,
    ST_SetSRID(ST_MakePolygon(ST_GeomFromText('LINESTRING(35.0 -25.0, 50.0 -25.0, 50.0 -10.0, 35.0 -10.0, 35.0 -25.0)')), 4326)::geography,
    -18.5000,
    40.0000,
    1500.0,
    '{
        "pays_touches": ["Australie", "La Réunion", "Maurice", "Madagascar", "Mozambique", "Malawi"],
        "victimes_estimees": 400,
        "deplaces_estimes": 500000,
        "degats_infrastructure": "catastrophiques",
        "zones_inondees": "vastes",
        "cout_dommages_usd": 500000000,
        "duree_totale_jours": 36,
        "record_mondial": "Plus long cyclone tropical enregistré (36 jours)"
    }'::jsonb,
    15,
    180,
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day' + INTERVAL '10 seconds',
    NOW() - INTERVAL '1 day' + INTERVAL '2 minutes',
    'completed'
);

-- =============================================================================
-- FIN DU PEUPLEMENT
-- =============================================================================
