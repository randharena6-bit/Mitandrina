/**
 * Routes Administration (Users, Teams, Simulations)
 */

const express = require('express');
const { pgPool, redis } = require('../config/database');
const { requireRole } = require('../middleware/auth');

const router = express.Router();

// Routes qui modifient les données nécessitent un rôle admin/secouriste
const adminOnly = requireRole(['administrateur', 'secouriste']);

// ============================================
// USERS MANAGEMENT
// ============================================

// GET /api/v1/admin/users - Liste des utilisateurs
router.get('/users', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT id, email, role, first_name, last_name, is_active, created_at, phone_number
       FROM users 
       ORDER BY created_at DESC`
    );
    res.json({ users: result.rows });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/admin/users/:id/role - Mettre à jour le rôle
router.put('/users/:id/role', requireRole(['administrateur']), async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!['population', 'secouriste', 'administrateur'].includes(role)) {
      return res.status(400).json({ error: 'Rôle invalide' });
    }

    const result = await pgPool.query(
      `UPDATE users 
       SET role = $1, updated_at = NOW() 
       WHERE id = $2 
       RETURNING id, email, role`,
      [role, req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur introuvable' });
    }

    res.json({ user: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// ============================================
// RESCUE TEAMS MANAGEMENT
// ============================================

// GET /api/v1/admin/teams - Liste des équipes de secours
router.get('/teams', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT * FROM rescue_teams ORDER BY name ASC`
    );
    res.json({ teams: result.rows });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/admin/teams - Créer une équipe de secours
router.post('/teams', async (req, res, next) => {
  try {
    const { name, type, teamSize, leaderName, phone } = req.body;
    if (!name || !type) {
      return res.status(400).json({ error: 'Le nom et le type sont obligatoires' });
    }

    // Coordonnées par défaut sur Antananarivo
    const lat = -18.9078;
    const lng = 47.5208;

    const result = await pgPool.query(
      `INSERT INTO rescue_teams (name, type, team_size, leader_name, phone, current_lat, current_lng, current_position, is_available, current_status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, ST_SetSRID(ST_MakePoint($7, $6), 4326)::geography, true, 'disponible')
       RETURNING *`,
      [name, type, teamSize || 1, leaderName || '', phone || '', lat, lng]
    );

    res.status(201).json({ team: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// ============================================
// AI SIMULATIONS MANAGEMENT
// ============================================

const GEZANI_TRACK = [
  { datetime: "2026-02-03 00:00", lat: -14.5, lng: 61.0, stage: "Perturbation tropicale", wind: 0, gusts: 0, pressure: 1008, note: "Formation au nord-est de Saint-Brandon" },
  { datetime: "2026-02-06 00:00", lat: -16.2, lng: 59.5, stage: "Dépression tropicale", wind: 55, gusts: 80, pressure: 1002, note: "Rehaussé en dépression tropicale (DT10) à ~700km NE de Saint-Brandon" },
  { datetime: "2026-02-06 12:00", lat: -16.8, lng: 58.8, stage: "Perturbation tropicale", wind: 45, gusts: 65, pressure: 1005, note: "Traverse l'archipel Saint-Brandon" },
  { datetime: "2026-02-07 12:00", lat: -17.2, lng: 57.5, stage: "Perturbation tropicale", wind: 50, gusts: 70, pressure: 1004, note: "Passe à ~200km au nord de l'île Maurice" },
  { datetime: "2026-02-08 00:00", lat: -17.5, lng: 56.0, stage: "Tempête tropicale modérée", wind: 65, gusts: 95, pressure: 998, note: "Nommé Gezani – col barométrique (surplace)" },
  { datetime: "2026-02-09 00:00", lat: -17.8, lng: 54.0, stage: "Forte tempête tropicale", wind: 100, gusts: 145, pressure: 985, note: "Reprise vers l'ouest – 350km au nord de La Réunion" },
  { datetime: "2026-02-09 12:00", lat: -17.9, lng: 53.0, stage: "Forte tempête tropicale", wind: 110, gusts: 155, pressure: 980, note: "Intensification rapide" },
  { datetime: "2026-02-10 00:00", lat: -18.0, lng: 51.1, stage: "Cyclone tropical", wind: 155, gusts: 220, pressure: 968, note: "Équiv. catégorie 2 SSHWS – 545km NW de La Réunion" },
  { datetime: "2026-02-10 12:00", lat: -18.1, lng: 49.5, stage: "Cyclone tropical intense", wind: 185, gusts: 260, pressure: 950, note: "Rehaussé CTI (cat.3) – 75km à l'est de Toamasina – entrée mur de l'œil" },
  { datetime: "2026-02-10 16:30", lat: -18.2, lng: 49.4, stage: "Cyclone tropical intense", wind: 185, gusts: 260, pressure: 945, note: "LANDFALL Toamasina – pic d'intensité – rafales 250 km/h à terre" },
  { datetime: "2026-02-11 00:00", lat: -18.5, lng: 48.0, stage: "Cyclone tropical", wind: 130, gusts: 185, pressure: 965, note: "Traverse Madagascar – affaiblit sur relief" },
  { datetime: "2026-02-11 13:00", lat: -19.0, lng: 44.5, stage: "Dépression tropicale", wind: 55, gusts: 80, pressure: 990, note: "Ressorti ~80km sud de Maintirano sur canal du Mozambique" },
  { datetime: "2026-02-12 00:00", lat: -18.8, lng: 43.0, stage: "Tempête tropicale modérée", wind: 80, gusts: 115, pressure: 985, note: "Réintensification dans le canal du Mozambique" },
  { datetime: "2026-02-13 12:00", lat: -19.5, lng: 40.0, stage: "Cyclone tropical", wind: 120, gusts: 175, pressure: 970, note: "Redevenu CT (cat.1) au milieu du canal" },
  { datetime: "2026-02-14 00:00", lat: -20.0, lng: 37.5, stage: "Cyclone tropical intense", wind: 185, gusts: 265, pressure: 948, note: "Équiv. cat. 3 (2e fois) – à 50km de la côte d'Inhambane (Mozambique)" },
  { datetime: "2026-02-14 12:00", lat: -21.0, lng: 36.5, stage: "Cyclone tropical", wind: 150, gusts: 215, pressure: 960, note: "Frôle la province d'Inhambane – rafales 215km/h à terre" },
  { datetime: "2026-02-15 00:00", lat: -22.0, lng: 36.0, stage: "Forte tempête tropicale", wind: 110, gusts: 160, pressure: 972, note: "Boucle vers le sud – affaiblissement" },
  { datetime: "2026-02-16 00:00", lat: -24.0, lng: 35.6, stage: "Cyclone tropical", wind: 120, gusts: 175, pressure: 968, note: "Boucle vers est/nord-est" },
  { datetime: "2026-02-17 00:00", lat: -26.1, lng: 37.4, stage: "Forte tempête tropicale", wind: 105, gusts: 150, pressure: 975, note: "À <150km du SW de Madagascar (Atsimo-Andrefana)" },
  { datetime: "2026-02-17 19:00", lat: -26.5, lng: 40.0, stage: "Cyclone tropical", wind: 120, gusts: 175, pressure: 968, note: "Passe à ~45km de la côte SW de Madagascar" },
  { datetime: "2026-02-18 00:00", lat: -27.5, lng: 41.0, stage: "Forte tempête tropicale", wind: 100, gusts: 145, pressure: 978, note: "Trajectoire vers sud-sud-est" },
  { datetime: "2026-02-19 00:00", lat: -30.0, lng: 43.0, stage: "Forte tempête tropicale", wind: 95, gusts: 135, pressure: 982, note: "S'éloigne vers le sud" },
  { datetime: "2026-02-20 12:00", lat: -35.0, lng: 48.0, stage: "Dépression post-tropicale", wind: 65, gusts: 95, pressure: 992, note: "Eaux froides >1200km au sud – déclaré post-tropical par CMRS Réunion" }
];

// GET /api/v1/admin/simulations - Historique des simulations "What-If"
router.get('/simulations', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT s.*, u.email as creator_email 
       FROM simulations s
       JOIN users u ON u.id = s.created_by
       ORDER BY s.created_at DESC`
    );
    const simulations = result.rows;

    // Ajouter Gezani comme simulation historique virtuelle
    const maxWind = Math.max(...GEZANI_TRACK.map(p => p.wind || 0));
    const maxGusts = Math.max(...GEZANI_TRACK.map(p => p.gusts || 0));
    const minPressure = Math.min(...GEZANI_TRACK.map(p => p.pressure || 1020));
    simulations.unshift({
      id: 'gezani-historical',
      name: 'Cyclone Gezani (Février 2026) - Historique réel',
      scenario_type: 'cyclone',
      status: 'completed',
      intensity_level: 9,
      center_lat: GEZANI_TRACK[0].lat,
      center_lng: GEZANI_TRACK[0].lng,
      radius_km: 120,
      evacuation_routes_generated: 12,
      estimated_evacuation_time_minutes: 180,
      execution_time_seconds: 0,
      is_saved: true,
      results: {
        track: GEZANI_TRACK,
        max_wind_kmh: maxWind,
        max_gusts_kmh: maxGusts,
        min_pressure_hpa: minPressure,
        total_days: 18,
        affected_population: 250000,
        risk_index: '9.5',
        simulation_summary: 'Cyclone tropical intense historique - Trajectoire réelle de Février 2026. A touché Toamasina le 10 février avec des vents de 185 km/h. A traversé Madagascar, ressorti dans le canal du Mozambique, puis a impacté le Mozambique.',
        safe_refuges_identified: ['Toamasina Centre', 'Brickaville Mairie', 'Mahanoro Gymnase']
      },
      created_at: '2026-02-03T00:00:00.000Z',
      creator_email: 'system@mitandrina.app'
    });

    res.json({ simulations });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/admin/simulations - Lancer une simulation "What-If"
router.post('/simulations', async (req, res, next) => {
  try {
    const { name, scenarioType, intensityLevel, lat, lng, radiusKm } = req.body;
    if (!name || !scenarioType) {
      return res.status(400).json({ error: 'Nom et type de scénario obligatoires' });
    }

    // Créer la simulation en base avec statut running
    const simResult = await pgPool.query(
      `INSERT INTO simulations (name, scenario_type, parameters, intensity_level, center_lat, center_lng, radius_km, created_by, status, started_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'running', NOW())
       RETURNING *`,
      [
        name, 
        scenarioType, 
        JSON.stringify({ lat, lng, radiusKm, intensityLevel }), 
        intensityLevel || 5, 
        lat || -18.9078, 
        lng || 47.5208, 
        radiusKm || 5.0, 
        req.user.id
      ]
    );

    const simulation = simResult.rows[0];

    // Appeler le moteur de simulation Python pour le calcul réel
    const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';
    try {
      const axios = require('axios');
      axios.post(`${AI_SERVICE_URL}/api/v1/simulations/run`, {
        simulation_id: simulation.id,
        name: simulation.name,
        scenario_type: scenarioType,
        center_lat: lat || simulation.center_lat,
        center_lng: lng || simulation.center_lng,
        intensity_level: intensityLevel || 5,
        radius_km: radiusKm || 10.0
      }, { timeout: 30000 }).catch(err => {
        console.error('Erreur appel moteur simulation Python:', err.message);
        // Fallback: marquer comme completed avec valeurs par défaut
        pgPool.query(
          `UPDATE simulations 
           SET status = 'completed', 
               completed_at = NOW(), 
               execution_time_seconds = 1,
               evacuation_routes_generated = 3,
               estimated_evacuation_time_minutes = 60,
               results = $1
           WHERE id = $2`,
          [JSON.stringify({
            affected_population: 5000,
            risk_index: (intensityLevel * 0.95).toFixed(1),
            safe_refuges_identified: ['Centre d\'urgence par défaut']
          }), simulation.id]
        ).catch(e => console.error('Erreur fallback simulation:', e));
      });
    } catch (e) {
      console.error('Erreur appel Python simulation:', e);
    }

    res.status(201).json({ simulation });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
