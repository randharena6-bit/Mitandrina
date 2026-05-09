/**
 * Routes Shelters
 */

const express = require('express');
const { pgPool } = require('../config/database');

const router = express.Router();

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
        total: parseInt(countResult.rows[0].count)
      }
    });
  } catch (err) {
    next(err);
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
