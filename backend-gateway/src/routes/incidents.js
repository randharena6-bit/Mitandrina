/**
 * Routes Incidents
 */

const express = require('express');
const Joi = require('joi');
const { pgPool, redis } = require('../config/database');
const { requireRole } = require('../middleware/auth');

const router = express.Router();

const createSchema = Joi.object({
  title: Joi.string().min(5).max(255).required(),
  description: Joi.string().min(10).required(),
  type: Joi.string().valid('inondation', 'incendie', 'cyclone', 'seisme', 'glissement_terrain', 'tsunami').required(),
  lat: Joi.number().min(-90).max(90).required(),
  lng: Joi.number().min(-180).max(180).required(),
  zoneId: Joi.string().uuid().optional(),
  mediaUrls: Joi.array().items(Joi.string()).optional()
});

const updateStatusSchema = Joi.object({
  status: Joi.string().valid('signale', 'verifie', 'en_cours', 'resolu').required(),
  notes: Joi.string().optional()
});

// GET /api/v1/incidents - Liste
router.get('/', async (req, res, next) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      status, 
      type,
      lat,
      lng,
      radius = 50
    } = req.query;
    
    const offset = (page - 1) * limit;
    let whereClause = 'WHERE 1=1';
    const params = [];
    
    if (status) {
      whereClause += ` AND i.status = $${params.length + 1}`;
      params.push(status);
    }
    if (type) {
      whereClause += ` AND i.type = $${params.length + 1}`;
      params.push(type);
    }
    
    // Filtre géo
    if (lat && lng) {
      whereClause += ` AND ST_DWithin(
        i.location,
        ST_SetSRID(ST_MakePoint($${params.length + 2}, $${params.length + 1}), 4326)::geography,
        $${params.length + 3}
      )`;
      params.push(parseFloat(lat), parseFloat(lng), parseFloat(radius) * 1000);
    }
    
    const countResult = await pgPool.query(
      `SELECT COUNT(*) FROM incidents i ${whereClause}`,
      params
    );
    
    params.push(parseInt(limit), parseInt(offset));
    const result = await pgPool.query(
      `SELECT i.*, u.email as reporter_email, dz.name as zone_name
       FROM incidents i
       LEFT JOIN users u ON u.id = i.reported_by
       LEFT JOIN disaster_zones dz ON dz.id = i.zone_id
       ${whereClause}
       ORDER BY i.reported_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );
    
    res.json({
      incidents: result.rows,
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

// GET /api/v1/incidents/:id
router.get('/:id', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT i.*, u.email as reporter_email, rt.name as assigned_team
       FROM incidents i
       LEFT JOIN users u ON u.id = i.reported_by
       LEFT JOIN rescue_teams rt ON rt.id = i.assigned_team_id
       WHERE i.id = $1`,
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Incident not found' });
    }
    
    res.json({ incident: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/incidents - Signaler
router.post('/', async (req, res, next) => {
  try {
    const { error, value } = createSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    
    const { title, description, type, lat, lng, zoneId, mediaUrls } = value;
    
    const result = await pgPool.query(
      `INSERT INTO incidents (title, description, type, location_lat, location_lng, location, 
                            reported_by, zone_id, media_urls, status, reported_at)
       VALUES ($1, $2, $3, $4, $5, ST_SetSRID(ST_MakePoint($5, $4), 4326)::geography,
               $6, $7, $8, 'signale', NOW())
       RETURNING *`,
      [title, description, type, lat, lng, req.user.id, zoneId, mediaUrls || []]
    );
    
    const incident = result.rows[0];
    
    // Notifier les secouristes en temps réel
    await redis.publish('mitandrina:new-incident', JSON.stringify(incident));
    
    res.status(201).json({ incident });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/incidents/:id/status - Mettre à jour statut
router.put('/:id/status', requireRole(['administrateur', 'secouriste']), async (req, res, next) => {
  try {
    const { error, value } = updateStatusSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    
    const updates = ['status = $1', 'updated_at = NOW()'];
    const params = [value.status];
    
    if (value.status === 'resolu') {
      updates.push('resolved_at = NOW()');
    }
    if (value.status === 'verifie') {
      updates.push('verified_by = $' + (params.length + 2));
      updates.push('verified_at = NOW()');
      params.push(req.user.id);
    }
    
    params.push(req.params.id);
    
    const result = await pgPool.query(
      `UPDATE incidents SET ${updates.join(', ')} WHERE id = $${params.length} RETURNING *`,
      params
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Incident not found' });
    }
    
    res.json({ incident: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// POST /api/v1/incidents/:id/assign - Assigner équipe
router.post('/:id/assign', requireRole(['administrateur', 'secouriste']), async (req, res, next) => {
  try {
    const { teamId } = req.body;
    if (!teamId) {
      return res.status(400).json({ error: 'teamId required' });
    }
    
    const result = await pgPool.query(
      `UPDATE incidents 
       SET assigned_team_id = $1, assigned_at = NOW(), status = 'en_cours'
       WHERE id = $2
       RETURNING *`,
      [teamId, req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Incident not found' });
    }
    
    res.json({ incident: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
