/**
 * Routes Alerts
 */

const express = require('express');
const Joi = require('joi');
const { pgPool, redis } = require('../config/database');
const { requireRole } = require('../middleware/auth');

const router = express.Router();

const createSchema = Joi.object({
  level: Joi.string().valid('info', 'vigilance', 'alerte', 'urgence').required(),
  type: Joi.string().valid('inondation', 'incendie', 'cyclone', 'seisme', 'glissement_terrain', 'tsunami').required(),
  title: Joi.string().min(5).max(255).required(),
  message: Joi.string().min(10).required(),
  zoneId: Joi.string().uuid().optional(),
  channels: Joi.array().items(Joi.string()).optional(),
  affectedArea: Joi.object({
    type: Joi.string().valid('Polygon').required(),
    coordinates: Joi.array().required()
  }).optional()
});

// GET /api/v1/alerts - Liste des alertes actives
router.get('/', async (req, res, next) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      level, 
      type, 
      active = 'true',
      lat,
      lng,
      radius = 50
    } = req.query;
    
    const offset = (page - 1) * limit;
    let whereClause = 'WHERE 1=1';
    const params = [];
    
    if (active === 'true') {
      whereClause += ' AND resolved_at IS NULL';
    }
    if (level) {
      whereClause += ` AND level = $${params.length + 1}`;
      params.push(level);
    }
    if (type) {
      whereClause += ` AND type = $${params.length + 1}`;
      params.push(type);
    }
    
    // Filtre géographique
    if (lat && lng) {
      whereClause += ` AND ST_DWithin(
        zone_geometry,
        ST_SetSRID(ST_MakePoint($${params.length + 2}, $${params.length + 1}), 4326)::geography,
        $${params.length + 3}
      )`;
      params.push(parseFloat(lat), parseFloat(lng), parseFloat(radius) * 1000);
    }
    
    const countResult = await pgPool.query(
      `SELECT COUNT(*) FROM alerts ${whereClause}`,
      params
    );
    
    params.push(parseInt(limit), parseInt(offset));
    const result = await pgPool.query(
      `SELECT a.*, dz.name as zone_name, dz.center_lat, dz.center_lng
       FROM alerts a
       LEFT JOIN disaster_zones dz ON dz.id = a.zone_id
       ${whereClause}
       ORDER BY a.emitted_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );
    
    res.json({
      alerts: result.rows,
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

// GET /api/v1/alerts/:id - Détail alerte
router.get('/:id', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT a.*, dz.name as zone_name, dz.geometry as zone_geometry
       FROM alerts a
       LEFT JOIN disaster_zones dz ON dz.id = a.zone_id
       WHERE a.id = $1`,
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }
    
    res.json({ alert: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/alerts - Créer alerte (admin/secouriste)
router.post('/', requireRole(['administrateur', 'secouriste']), async (req, res, next) => {
  try {
    const { error, value } = createSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    
    const { level, type, title, message, zoneId, channels, affectedArea } = value;
    
    const result = await pgPool.query(
      `INSERT INTO alerts (level, type, title, message, zone_id, channels, zone_geometry, emitted_at)
       VALUES ($1, $2, $3, $4, $5, $6, ST_GeomFromGeoJSON($7), NOW())
       RETURNING *`,
      [level, type, title, message, zoneId, channels || ['push'], JSON.stringify(affectedArea)]
    );
    
    const alert = result.rows[0];
    
    // Publier sur Redis pour notification temps réel
    await redis.publish('mitandrina:new-alert', JSON.stringify(alert));
    
    res.status(201).json({ alert });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/alerts/:id/confirm - Confirmer alerte
router.put('/:id/confirm', requireRole(['administrateur', 'secouriste']), async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `UPDATE alerts 
       SET is_confirmed = true, confirmed_by = $2, confirmed_at = NOW()
       WHERE id = $1
       RETURNING *`,
      [req.params.id, req.user.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }
    
    res.json({ alert: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/alerts/:id/resolve - Résoudre alerte
router.put('/:id/resolve', requireRole(['administrateur', 'secouriste']), async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `UPDATE alerts SET resolved_at = NOW() WHERE id = $1 RETURNING *`,
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }
    
    res.json({ alert: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/alerts/:id/recipients - Liste des destinataires
router.get('/:id/recipients', requireRole(['administrateur', 'secouriste']), async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT ar.*, u.email, u.phone_number
       FROM alert_recipients ar
       JOIN users u ON u.id = ar.user_id
       WHERE ar.alert_id = $1`,
      [req.params.id]
    );
    
    res.json({ recipients: result.rows });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
