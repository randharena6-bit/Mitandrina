/**
 * Bull Queue Workers
 * Traitement async des notifications et tâches lourdes
 */

const Queue = require('bull');
const logger = require('../utils/logger');
const { pgPool, redis } = require('../config/database');

// Configuration des queues
const alertQueue = new Queue('alerts', process.env.REDIS_URL || 'redis://localhost:6379/1');
const notificationQueue = new Queue('notifications', process.env.REDIS_URL || 'redis://localhost:6379/1');
const emailQueue = new Queue('emails', process.env.REDIS_URL || 'redis://localhost:6379/1');

// ====== ALERT QUEUE ======
alertQueue.process(async (job) => {
  logger.info(`Processing alert job ${job.id}:`, job.data);
  
  const { alertId, zoneId, level } = job.data;
  
  try {
    // 1. Trouver les utilisateurs concernés
    const users = await pgPool.query(
      `SELECT u.id, u.email, u.phone_number, u.alert_channels, u.device_tokens
       FROM users u
       JOIN disaster_zones dz ON dz.id = $1
       WHERE ST_DWithin(u.location, dz.geometry, u.alert_radius_km * 1000)
         AND u.is_active = true`,
      [zoneId]
    );
    
    logger.info(`Alert ${alertId}: ${users.rows.length} users to notify`);
    
    // 2. Créer les alert_recipients
    for (const user of users.rows) {
      for (const channel of user.alert_channels || ['push']) {
        await pgPool.query(
          `INSERT INTO alert_recipients (alert_id, user_id, channel, sent_at)
           VALUES ($1, $2, $3, NOW())
           ON CONFLICT DO NOTHING`,
          [alertId, user.id, channel]
        );
      }
      
      // 3. Enqueue notifications par canal
      for (const channel of user.alert_channels || ['push']) {
        await notificationQueue.add({
          userId: user.id,
          alertId,
          channel,
          email: user.email,
          phone: user.phone_number,
          deviceTokens: user.device_tokens
        }, {
          attempts: 3,
          backoff: 5000
        });
      }
    }
    
    // 4. Mettre à jour le compteur
    await pgPool.query(
      'UPDATE alerts SET recipients_count = $1 WHERE id = $2',
      [users.rows.length, alertId]
    );
    
    return { success: true, recipientsCount: users.rows.length };
    
  } catch (err) {
    logger.error(`Alert job ${job.id} failed:`, err);
    throw err;
  }
});

// ====== NOTIFICATION QUEUE ======
notificationQueue.process(async (job) => {
  const { userId, alertId, channel, email, phone, deviceTokens } = job.data;
  
  try {
    // Récupérer détails de l'alerte
    const alertResult = await pgPool.query(
      'SELECT * FROM alerts WHERE id = $1',
      [alertId]
    );
    
    if (alertResult.rows.length === 0) {
      throw new Error(`Alert ${alertId} not found`);
    }
    
    const alert = alertResult.rows[0];
    
    switch (channel) {
      case 'sms':
        if (phone) {
          await sendSMS(phone, alert);
        }
        break;
        
      case 'push':
        if (deviceTokens && deviceTokens.length > 0) {
          await sendPushNotification(deviceTokens, alert);
        }
        break;
        
      case 'email':
        if (email) {
          await emailQueue.add({ email, alert }, { attempts: 3 });
        }
        break;
        
      case 'websocket':
        // Déjà géré par WebSocket handlers
        break;
    }
    
    // Marquer comme envoyé
    await pgPool.query(
      `UPDATE alert_recipients 
       SET delivered_at = NOW()
       WHERE alert_id = $1 AND user_id = $2 AND channel = $3`,
      [alertId, userId, channel]
    );
    
    // Créer notification
    await pgPool.query(
      `INSERT INTO notifications (user_id, alert_id, title, message, channel, status, sent_at)
       VALUES ($1, $2, $3, $4, $5, 'sent', NOW())`,
      [userId, alertId, alert.title, alert.message, channel]
    );
    
    return { success: true, channel };
    
  } catch (err) {
    logger.error(`Notification job failed:`, err);
    
    // Marquer comme échoué
    await pgPool.query(
      `UPDATE alert_recipients 
       SET failed_at = NOW(), failure_reason = $4
       WHERE alert_id = $1 AND user_id = $2 AND channel = $3`,
      [alertId, userId, channel, err.message]
    );
    
    throw err;
  }
});

// ====== EMAIL QUEUE ======
emailQueue.process(async (job) => {
  const { email, alert } = job.data;
  
  // Intégration SendGrid ou autre
  logger.info(`Sending email to ${email} for alert ${alert.id}`);
  
  // Mock pour l'instant
  return { success: true, email };
});

// ====== FONCTIONS D'ENVOI ======

async function sendSMS(phoneNumber, alert) {
  // Twilio integration
  if (!process.env.TWILIO_ACCOUNT_SID) {
    logger.info(`[MOCK SMS] To ${phoneNumber}: ${alert.title}`);
    return { sid: 'mock-sid' };
  }
  
  const twilio = require('twilio');
  const client = twilio(
    process.env.TWILIO_ACCOUNT_SID,
    process.env.TWILIO_AUTH_TOKEN
  );
  
  const message = await client.messages.create({
    body: `🌪️ ALERTE ${alert.level.toUpperCase()}: ${alert.title}. ${alert.message}`,
    from: process.env.TWILIO_PHONE_NUMBER,
    to: phoneNumber
  });
  
  logger.info(`SMS sent: ${message.sid}`);
  return message;
}

async function sendPushNotification(deviceTokens, alert) {
  // Firebase Cloud Messaging
  if (!process.env.FIREBASE_PROJECT_ID) {
    logger.info(`[MOCK PUSH] To ${deviceTokens.length} devices: ${alert.title}`);
    return { success: true };
  }
  
  // TODO: Intégration FCM
  logger.info(`[PUSH] To ${deviceTokens.length} devices: ${alert.title}`);
  return { success: true };
}

// ====== SETUP ======
function setupQueueWorkers() {
  // Event listeners
  alertQueue.on('completed', (job, result) => {
    logger.info(`Alert job ${job.id} completed:`, result);
  });
  
  alertQueue.on('failed', (job, err) => {
    logger.error(`Alert job ${job.id} failed:`, err);
  });
  
  notificationQueue.on('completed', (job, result) => {
    logger.info(`Notification job ${job.id} completed:`, result);
  });
  
  notificationQueue.on('failed', (job, err) => {
    logger.error(`Notification job ${job.id} failed:`, err);
  });
  
  logger.info('Queue workers initialized');
}

// Exports pour ajouter des jobs depuis les routes
module.exports = {
  setupQueueWorkers,
  alertQueue,
  notificationQueue,
  emailQueue
};
