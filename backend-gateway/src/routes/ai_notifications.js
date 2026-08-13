/**
 * Route pour diffuser les analyses/recommandations Gemini IA comme notifications
 */

const express = require('express');
const { pgPool, redis } = require('../config/database');
const logger = require('../utils/logger');

const router = express.Router();

// POST /api/v1/notifications/ai-broadcast - Diffuse une analyse IA comme notification
router.post('/ai-broadcast', async (req, res, next) => {
  try {
    const { titre, message, niveau, zone_concernee, cyclones_data } = req.body;

    if (!titre || !message) {
      return res.status(400).json({ error: 'titre et message requis' });
    }

    // 1. Créer l'alerte dans la base
    const alertResult = await pgPool.query(
      `INSERT INTO alerts (title, message, level, type, emitted_by, channels, status)
       VALUES ($1, $2, $3, 'cyclone', $4, ARRAY['push','websocket'], 'active')
       RETURNING id`,
      [titre, message, niveau || 'vigilance', req.user?.id || '00000000-0000-0000-0000-000000000000']
    );
    const alertId = alertResult.rows[0].id;

    // 2. Trouver les utilisateurs dans la zone concernée (ou tous si pas de zone)
    let users = [];
    if (zone_concernee) {
      // Chercher par zone approximative
      const userResult = await pgPool.query(
        `SELECT id, device_tokens, alert_channels FROM users WHERE is_active = true`
      );
      users = userResult.rows;
    } else {
      const userResult = await pgPool.query(
        `SELECT id, device_tokens, alert_channels FROM users WHERE is_active = true`
      );
      users = userResult.rows;
    }

    // 3. Créer les notifications et diffuser en temps réel
    for (const user of users) {
      await pgPool.query(
        `INSERT INTO notifications (user_id, alert_id, title, message, type, channel, status, sent_at)
         VALUES ($1, $2, $3, $4, 'alert', 'push', 'sent', NOW())`,
        [user.id, alertId, `🤖 IA: ${titre}`, message]
      );

      // WebSocket broadcast
      const channel = `user:${user.id}`;
      redis.publish('mitandrina:new-alert', JSON.stringify({
        id: alertId,
        level: niveau || 'vigilance',
        type: 'cyclone',
        title: `🤖 IA Gemini: ${titre}`,
        message,
        emitted_at: new Date().toISOString(),
        ai_generated: true,
        cyclones_data: cyclones_data || null
      }));
    }

    // 4. Compter
    const recipientsCount = users.length;
    await pgPool.query(
      'UPDATE alerts SET recipients_count = $1 WHERE id = $2',
      [recipientsCount, alertId]
    );

    logger.info(`IA Alert broadcast: ${titre} -> ${recipientsCount} users`);

    res.json({
      success: true,
      alertId,
      recipientsCount,
      message: `Alerte IA diffusée à ${recipientsCount} utilisateurs`
    });

  } catch (err) {
    next(err);
  }
});

// POST /api/v1/notifications/ai-recommendation - Envoie une recommandation IA à un utilisateur spécifique
router.post('/ai-recommendation', async (req, res, next) => {
  try {
    const { userId, titre, message, data } = req.body;

    if (!userId || !titre || !message) {
      return res.status(400).json({ error: 'userId, titre et message requis' });
    }

    await pgPool.query(
      `INSERT INTO notifications (user_id, title, message, type, channel, status, sent_at, metadata)
       VALUES ($1, $2, $3, 'info', 'push', 'sent', NOW(), $4)`,
      [userId, `🤖 ${titre}`, message, JSON.stringify({ ai_generated: true, ...data })]
    );

    // Notifier via WebSocket
    redis.publish('mitandrina:new-alert', JSON.stringify({
      id: `ai-${Date.now()}`,
      level: 'info',
      type: 'ai_recommendation',
      title: `🤖 ${titre}`,
      message,
      emitted_at: new Date().toISOString(),
      ai_generated: true,
      target_user: userId
    }));

    res.json({ success: true, message: 'Recommandation IA envoyée' });

  } catch (err) {
    next(err);
  }
});

module.exports = router;
