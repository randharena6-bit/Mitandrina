/**
 * Routes Users
 */

const express = require('express');
const Joi = require('joi');
const { pgPool } = require('../config/database');
const { requireRole } = require('../middleware/auth');

const router = express.Router();

const updateSchema = Joi.object({
  phoneNumber: Joi.string().optional(),
  firstName: Joi.string().optional(),
  lastName: Joi.string().optional(),
  locationLat: Joi.number().min(-90).max(90).optional(),
  locationLng: Joi.number().min(-180).max(180).optional(),
  alertChannels: Joi.array().items(Joi.string()).optional(),
  alertRadiusKm: Joi.number().integer().min(1).max(500).optional()
});

// GET /api/v1/users/me - Profil utilisateur connecté
router.get('/me', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `SELECT id, email, phone_number, role, first_name, last_name,
              location_lat, location_lng, alert_channels, alert_radius_km,
              is_active, created_at, last_login_at
       FROM users WHERE id = $1`,
      [req.user.id]
    );
    
    res.json({ user: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/users/me - Mettre à jour profil
router.put('/me', async (req, res, next) => {
  try {
    const { error, value } = updateSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    
    const updates = [];
    const values = [];
    let idx = 1;
    
    if (value.phoneNumber !== undefined) {
      updates.push(`phone_number = $${idx++}`);
      values.push(value.phoneNumber);
    }
    if (value.firstName !== undefined) {
      updates.push(`first_name = $${idx++}`);
      values.push(value.firstName);
    }
    if (value.lastName !== undefined) {
      updates.push(`last_name = $${idx++}`);
      values.push(value.lastName);
    }
    if (value.alertChannels !== undefined) {
      updates.push(`alert_channels = $${idx++}`);
      values.push(value.alertChannels);
    }
    if (value.alertRadiusKm !== undefined) {
      updates.push(`alert_radius_km = $${idx++}`);
      values.push(value.alertRadiusKm);
    }
    if (value.locationLat !== undefined && value.locationLng !== undefined) {
      updates.push(`location_lat = $${idx++}`);
      values.push(value.locationLat);
      updates.push(`location_lng = $${idx++}`);
      values.push(value.locationLng);
      updates.push(`location = ST_SetSRID(ST_MakePoint($${idx-1}, $${idx-2}), 4326)::geography`);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }
    
    updates.push(`updated_at = NOW()`);
    values.push(req.user.id);
    
    const result = await pgPool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${idx} RETURNING *`,
      values
    );
    
    res.json({ user: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/users/nearby-danger
router.get('/nearby-danger', async (req, res, next) => {
  try {
    const { lat, lng } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({ error: 'lat and lng required' });
    }
    
    // Appeler la fonction SQL
    const result = await pgPool.query(
      'SELECT * FROM get_nearest_danger_distance($1, $2)',
      [parseFloat(lat), parseFloat(lng)]
    );
    
    res.json({ danger: result.rows[0] || null });
  } catch (err) {
    next(err);
  }
});

// GET /api/v1/users - Liste (admin seulement)
router.get('/', requireRole(['administrateur']), async (req, res, next) => {
  try {
    const { page = 1, limit = 20, role, isActive } = req.query;
    const offset = (page - 1) * limit;
    
    let whereClause = 'WHERE 1=1';
    const params = [];
    
    if (role) {
      whereClause += ` AND role = $${params.length + 1}`;
      params.push(role);
    }
    if (isActive !== undefined) {
      whereClause += ` AND is_active = $${params.length + 1}`;
      params.push(isActive === 'true');
    }
    
    const countResult = await pgPool.query(
      `SELECT COUNT(*) FROM users ${whereClause}`,
      params
    );
    
    params.push(parseInt(limit), parseInt(offset));
    const result = await pgPool.query(
      `SELECT id, email, role, first_name, last_name, is_active, created_at
       FROM users ${whereClause}
       ORDER BY created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );
    
    res.json({
      users: result.rows,
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

module.exports = router;
