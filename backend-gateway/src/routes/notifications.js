/**
 * Routes Notifications
 */

const express = require('express');
const { pgPool, redis } = require('../config/database');

const router = express.Router();

// GET /api/v1/notifications - Historique notifications user
router.get('/', async (req, res, next) => {
  try {
    const { page = 1, limit = 20, unreadOnly = false } = req.query;
    const offset = (page - 1) * limit;
    
    let whereClause = 'WHERE user_id = $1';
    const params = [req.user.id];
    
    if (unreadOnly === 'true') {
      whereClause += ' AND read_at IS NULL';
    }
    
    const countResult = await pgPool.query(
      `SELECT COUNT(*) FROM notifications ${whereClause}`,
      params
    );
    
    params.push(parseInt(limit), parseInt(offset));
    const result = await pgPool.query(
      `SELECT * FROM notifications ${whereClause}
       ORDER BY created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );
    
    // Count unread
    const unreadResult = await pgPool.query(
      'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND read_at IS NULL',
      [req.user.id]
    );
    
    res.json({
      notifications: result.rows,
      unreadCount: parseInt(unreadResult.rows[0].count),
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

// PUT /api/v1/notifications/:id/read - Marquer comme lu
router.put('/:id/read', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      `UPDATE notifications 
       SET read_at = NOW(), status = 'read'
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [req.params.id, req.user.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    res.json({ notification: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// PUT /api/v1/notifications/read-all - Tout marquer comme lu
router.put('/read-all', async (req, res, next) => {
  try {
    await pgPool.query(
      `UPDATE notifications 
       SET read_at = NOW(), status = 'read'
       WHERE user_id = $1 AND read_at IS NULL`,
      [req.user.id]
    );
    
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/v1/notifications/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const result = await pgPool.query(
      'DELETE FROM notifications WHERE id = $1 AND user_id = $2 RETURNING id',
      [req.params.id, req.user.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
