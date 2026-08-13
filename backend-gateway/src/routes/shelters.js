/**
 * Routes Shelters
 */

const express = require('express');
const { pgPool } = require('../config/database');

const router = express.Router();

// Fallback shelters (utilisé quand PostgreSQL est vide ou indisponible)
const fallbackShelters = [
      // ===== Province d'Antananarivo (10 refuges) =====
      { id: 1,  name: "Centre d'Urgence Analakely", lat: -18.9078, lng: 47.5208, type: "centre_urgence", address: "Analakely, Antananarivo", capacity: 500, current_occupancy: 320, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 2,  name: "Refuge Antanimena", lat: -18.9156, lng: 47.5123, type: "refuge", address: "Antanimena, Antananarivo", capacity: 300, current_occupancy: 180, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 3,  name: "Hôpital Militaire Soavinandriana", lat: -18.9250, lng: 47.5300, type: "hopital", address: "Soavinandriana, Antananarivo", capacity: 200, current_occupancy: 150, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 4,  name: "Abri Temporaire 67ha", lat: -18.9055, lng: 47.5085, type: "abri_temporaire", address: "Marché 67ha, Antananarivo", capacity: 150, current_occupancy: 45, has_medical_facilities: false, has_food: true, has_water: false, is_available: true, is_full: false },
      { id: 5,  name: "Centre Évacuation Besarety", lat: -18.9025, lng: 47.5345, type: "refuge", address: "Besarety, Antananarivo", capacity: 400, current_occupancy: 280, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 6,  name: "Gymnase Couvert Mahamasina", lat: -18.9160, lng: 47.5230, type: "refuge", address: "Mahamasina, Antananarivo", capacity: 800, current_occupancy: 100, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 7,  name: "Refuge Antsirabe", lat: -19.8650, lng: 47.0333, type: "refuge", address: "Antsirabe", capacity: 350, current_occupancy: 60, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 8,  name: "Hôpital Régional Antsirabe", lat: -19.8580, lng: 47.0400, type: "hopital", address: "Antsirabe", capacity: 250, current_occupancy: 110, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 9,  name: "Centre d'Urgence Ambatolampy", lat: -19.3833, lng: 47.4167, type: "centre_urgence", address: "Ambatolampy", capacity: 200, current_occupancy: 30, has_medical_facilities: true, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 10, name: "Abri Temporaire Tsiroanomandidy", lat: -18.7667, lng: 46.0500, type: "abri_temporaire", address: "Tsiroanomandidy", capacity: 180, current_occupancy: 15, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },

      // ===== Province de Toamasina (10 refuges) =====
      { id: 11, name: "Abri Temporaire Toamasina", lat: -18.1442, lng: 49.3956, type: "abri_temporaire", address: "Toamasina Centre", capacity: 400, current_occupancy: 50, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 12, name: "Hôpital Général Toamasina", lat: -18.1550, lng: 49.4100, type: "hopital", address: "Toamasina", capacity: 300, current_occupancy: 200, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 13, name: "Centre d'Urgence Toamasina", lat: -18.1380, lng: 49.3880, type: "centre_urgence", address: "Toamasina", capacity: 250, current_occupancy: 40, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 14, name: "Refuge Ambatondrazaka", lat: -17.8333, lng: 48.4167, type: "refuge", address: "Ambatondrazaka", capacity: 200, current_occupancy: 25, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 15, name: "Hôpital Régional Ambatondrazaka", lat: -17.8250, lng: 48.4200, type: "hopital", address: "Ambatondrazaka", capacity: 150, current_occupancy: 80, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 16, name: "Centre d'Urgence Moramanga", lat: -18.9333, lng: 48.2000, type: "centre_urgence", address: "Moramanga", capacity: 180, current_occupancy: 20, has_medical_facilities: true, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 17, name: "Refuge Fénérive-Est", lat: -17.3667, lng: 49.5000, type: "refuge", address: "Fénérive-Est", capacity: 220, current_occupancy: 35, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 18, name: "Abri Temporaire Brickaville", lat: -18.8167, lng: 49.0667, type: "abri_temporaire", address: "Brickaville", capacity: 160, current_occupancy: 10, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 19, name: "Centre Évacuation Vatomandry", lat: -19.3333, lng: 48.9833, type: "refuge", address: "Vatomandry", capacity: 250, current_occupancy: 12, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 20, name: "Refuge Soanierana Ivongo", lat: -16.9167, lng: 49.5833, type: "refuge", address: "Soanierana Ivongo", capacity: 140, current_occupancy: 8, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },

      // ===== Province de Mahajanga (10 refuges) =====
      { id: 21, name: "Centre d'Urgence Mahajanga", lat: -15.7167, lng: 46.3167, type: "centre_urgence", address: "Mahajanga Centre", capacity: 350, current_occupancy: 60, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 22, name: "Hôpital Régional Mahajanga", lat: -15.7200, lng: 46.3100, type: "hopital", address: "Mahajanga", capacity: 280, current_occupancy: 180, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 23, name: "Refuge Mahajanga Plage", lat: -15.7100, lng: 46.3300, type: "refuge", address: "Plage de Mahajanga", capacity: 200, current_occupancy: 30, has_medical_facilities: false, has_food: true, has_water: false, is_available: true, is_full: false },
      { id: 24, name: "Refuge Antsohihy", lat: -14.8833, lng: 47.9833, type: "refuge", address: "Antsohihy", capacity: 180, current_occupancy: 15, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 25, name: "Centre d'Urgence Antsohihy", lat: -14.8750, lng: 47.9900, type: "centre_urgence", address: "Antsohihy", capacity: 200, current_occupancy: 10, has_medical_facilities: true, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 26, name: "Abri Temporaire Maintirano", lat: -18.0667, lng: 44.0167, type: "abri_temporaire", address: "Maintirano", capacity: 150, current_occupancy: 5, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 27, name: "Refuge Marovoay", lat: -16.1000, lng: 46.6333, type: "refuge", address: "Marovoay", capacity: 220, current_occupancy: 18, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 28, name: "Centre Évacuation Besalampy", lat: -16.7500, lng: 44.4833, type: "refuge", address: "Besalampy", capacity: 160, current_occupancy: 8, has_medical_facilities: true, has_food: true, has_water: false, is_available: true, is_full: false },
      { id: 29, name: "Hôpital de Base Maevatanana", lat: -16.9500, lng: 46.8333, type: "hopital", address: "Maevatanana", capacity: 120, current_occupancy: 40, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 30, name: "Refuge Tsaratanana", lat: -16.8000, lng: 47.6500, type: "refuge", address: "Tsaratanana", capacity: 130, current_occupancy: 6, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },

      // ===== Province de Fianarantsoa (10 refuges) =====
      { id: 31, name: "Refuge Fianarantsoa", lat: -21.4526, lng: 47.0873, type: "refuge", address: "Fianarantsoa", capacity: 350, current_occupancy: 40, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 32, name: "Hôpital Régional Fianarantsoa", lat: -21.4600, lng: 47.0900, type: "hopital", address: "Fianarantsoa", capacity: 300, current_occupancy: 190, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 33, name: "Centre d'Urgence Fianarantsoa", lat: -21.4450, lng: 47.0780, type: "centre_urgence", address: "Fianarantsoa", capacity: 200, current_occupancy: 25, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 34, name: "Refuge Manakara", lat: -22.1464, lng: 48.0106, type: "refuge", address: "Manakara", capacity: 180, current_occupancy: 5, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 35, name: "Hôpital de Base Manakara", lat: -22.1550, lng: 48.0100, type: "hopital", address: "Manakara", capacity: 120, current_occupancy: 45, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 36, name: "Abri Temporaire Ambositra", lat: -20.5250, lng: 47.2500, type: "abri_temporaire", address: "Ambositra", capacity: 250, current_occupancy: 20, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 37, name: "Centre d'Urgence Ambositra", lat: -20.5200, lng: 47.2430, type: "centre_urgence", address: "Ambositra", capacity: 150, current_occupancy: 12, has_medical_facilities: true, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 38, name: "Refuge Ambalavao", lat: -21.8333, lng: 46.9333, type: "refuge", address: "Ambalavao", capacity: 160, current_occupancy: 8, has_medical_facilities: false, has_food: true, has_water: false, is_available: true, is_full: false },
      { id: 39, name: "Centre Évacuation Farafangana", lat: -22.8000, lng: 47.8167, type: "refuge", address: "Farafangana", capacity: 280, current_occupancy: 15, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 40, name: "Hôpital Régional Farafangana", lat: -22.8050, lng: 47.8220, type: "hopital", address: "Farafangana", capacity: 180, current_occupancy: 70, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },

      // ===== Province de Toliara (10 refuges) =====
      { id: 41, name: "Refuge Toliara", lat: -23.3499, lng: 43.6788, type: "refuge", address: "Toliara", capacity: 250, current_occupancy: 20, has_medical_facilities: true, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 42, name: "Hôpital Régional Toliara", lat: -23.3550, lng: 43.6720, type: "hopital", address: "Toliara", capacity: 300, current_occupancy: 160, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 43, name: "Centre d'Urgence Toliara", lat: -23.3450, lng: 43.6600, type: "centre_urgence", address: "Toliara", capacity: 200, current_occupancy: 18, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 44, name: "Abri Temporaire Morondava", lat: -20.2887, lng: 44.3178, type: "abri_temporaire", address: "Morondava", capacity: 200, current_occupancy: 15, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 45, name: "Centre d'Urgence Morondava", lat: -20.2930, lng: 44.2830, type: "centre_urgence", address: "Morondava", capacity: 180, current_occupancy: 10, has_medical_facilities: true, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 46, name: "Refuge Fort Dauphin", lat: -25.0333, lng: 46.9833, type: "refuge", address: "Fort Dauphin", capacity: 220, current_occupancy: 12, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 47, name: "Hôpital Régional Fort Dauphin", lat: -25.0280, lng: 46.9900, type: "hopital", address: "Fort Dauphin", capacity: 160, current_occupancy: 55, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 48, name: "Centre Évacuation Betioky", lat: -23.7167, lng: 44.3833, type: "refuge", address: "Betioky", capacity: 140, current_occupancy: 5, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },
      { id: 49, name: "Refuge Ampanihy", lat: -24.7000, lng: 44.7500, type: "refuge", address: "Ampanihy", capacity: 120, current_occupancy: 3, has_medical_facilities: false, has_food: true, has_water: false, is_available: true, is_full: false },
      { id: 50, name: "Abri Temporaire Sakaraha", lat: -22.9000, lng: 44.5333, type: "abri_temporaire", address: "Sakaraha", capacity: 100, current_occupancy: 2, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },

      // ===== Province d'Antsiranana (10 refuges) =====
      { id: 51, name: "Refuge Antsiranana", lat: -12.2787, lng: 49.2917, type: "refuge", address: "Antsiranana", capacity: 300, current_occupancy: 30, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 52, name: "Hôpital Régional Antsiranana", lat: -12.2900, lng: 49.2900, type: "hopital", address: "Antsiranana", capacity: 250, current_occupancy: 120, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 53, name: "Centre d'Urgence Antsiranana", lat: -12.2770, lng: 49.2780, type: "centre_urgence", address: "Antsiranana", capacity: 180, current_occupancy: 15, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 54, name: "Refuge Nosy Be", lat: -13.3120, lng: 48.2548, type: "refuge", address: "Nosy Be", capacity: 150, current_occupancy: 10, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 55, name: "Hôpital de Base Nosy Be", lat: -13.3050, lng: 48.2600, type: "hopital", address: "Nosy Be", capacity: 120, current_occupancy: 40, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 56, name: "Abri Temporaire Ambilobe", lat: -13.2000, lng: 49.0500, type: "abri_temporaire", address: "Ambilobe", capacity: 200, current_occupancy: 8, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 57, name: "Centre d'Urgence Sambava", lat: -14.2667, lng: 50.1667, type: "centre_urgence", address: "Sambava", capacity: 180, current_occupancy: 14, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 58, name: "Refuge Antalaha", lat: -14.8833, lng: 50.2667, type: "refuge", address: "Antalaha", capacity: 160, current_occupancy: 9, has_medical_facilities: false, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 59, name: "Hôpital Régional Sambava", lat: -14.2720, lng: 50.1720, type: "hopital", address: "Sambava", capacity: 140, current_occupancy: 50, has_medical_facilities: true, has_food: true, has_water: true, is_available: true, is_full: false },
      { id: 60, name: "Centre Évacuation Vohemar", lat: -13.3667, lng: 50.0000, type: "refuge", address: "Vohemar", capacity: 120, current_occupancy: 4, has_medical_facilities: false, has_food: false, has_water: true, is_available: true, is_full: false },
    ];

// GET /api/v1/shelters - Liste
router.get('/', async (req, res, next) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      available,
      lat,
      lng,
      radius = 50,
      hasMedical
    } = req.query;
    
    const offset = (page - 1) * limit;
    let whereClause = 'WHERE 1=1';
    const params = [];
    
    if (available === 'true') {
      whereClause += ' AND is_available = true AND is_full = false';
    }
    if (hasMedical === 'true') {
      whereClause += ' AND has_medical_facilities = true';
    }
    
    // Filtre géo
    if (lat && lng) {
      whereClause += ` AND ST_DWithin(
        location,
        ST_SetSRID(ST_MakePoint($${params.length + 2}, $${params.length + 1}), 4326)::geography,
        $${params.length + 3}
      )`;
      params.push(parseFloat(lat), parseFloat(lng), parseFloat(radius) * 1000);
    }
    
    const countResult = await pgPool.query(
      `SELECT COUNT(*) FROM shelters ${whereClause}`,
      params
    );
    
    const total = parseInt(countResult.rows[0].count);
    
    // Si la table shelters est vide, utiliser les données de secours
    if (total === 0) {
      return res.json({
        shelters: fallbackShelters,
        pagination: { page: 1, limit: 20, total: fallbackShelters.length }
      });
    }
    
    params.push(parseInt(limit), parseInt(offset));
    const result = await pgPool.query(
      `SELECT *, ST_X(location::geometry) as lng, ST_Y(location::geometry) as lat
       FROM shelters ${whereClause}
       ORDER BY name
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );
    
    res.json({
      shelters: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: total
      }
    });
  } catch (err) {
    // Fallback shelters si PostgreSQL est indisponible
    res.json({
      shelters: fallbackShelters,
      pagination: { page: 1, limit: 20, total: fallbackShelters.length }
    });
  }
});

// GET /api/v1/shelters/nearby - Utilise la fonction SQL
router.get('/nearby', async (req, res, next) => {
  try {
    const { lat, lng, radius = 50 } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({ error: 'lat and lng required' });
    }
    
    const result = await pgPool.query(
      'SELECT * FROM find_nearby_shelters($1, $2, $3)',
      [parseFloat(lat), parseFloat(lng), parseInt(radius)]
    );
    
    res.json({ 
      shelters: result.rows,
      count: result.rows.length,
      search: { lat: parseFloat(lat), lng: parseFloat(lng), radiusKm: parseInt(radius) }
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/shelters/:id
router.get('/:id', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT *, ST_X(location::geometry) as lng, ST_Y(location::geometry) as lat
       FROM shelters WHERE id = $1`,
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Shelter not found' });
    }
    
    res.json({ shelter: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/shelters/:id/occupancy - Mise à jour occupation
router.put('/:id/occupancy', async (req, res, next) => {
  try {
    const { occupancy } = req.body;
    if (occupancy === undefined || occupancy < 0) {
      return res.status(400).json({ error: 'Valid occupancy required' });
    }
    
    const result = await pgPool.query(
      `UPDATE shelters 
       SET current_occupancy = $1, last_status_update = NOW()
       WHERE id = $2
       RETURNING *`,
      [occupancy, req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Shelter not found' });
    }
    
    res.json({ shelter: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
