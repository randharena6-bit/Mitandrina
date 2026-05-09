/**
 * WebSocket Handlers - Temps réel
 */

const logger = require('../utils/logger');

function setupWebSocketHandlers(io, redis) {
  // Connexion principale
  io.on('connection', (socket) => {
    logger.info(`WebSocket connected: ${socket.id}, user: ${socket.userId}`);
    
    // Rejoindre la room personnelle
    socket.join(`user:${socket.userId}`);
    
    // Rejoindre rooms par rôle
    if (socket.userRole) {
      socket.join(`role:${socket.userRole}`);
    }
    
    // ====== ÉVÉNEMENTS CLIENT ======
    
    // Position en temps réel
    socket.on('location:update', async (data) => {
      try {
        const { lat, lng } = data;
        
        // Vérifier danger proche
        const { pgPool } = require('../config/database');
        const danger = await pgPool.query(
          'SELECT * FROM get_nearest_danger_distance($1, $2)',
          [lat, lng]
        );
        
        if (danger.rows[0] && danger.rows[0].distance_meters < 5000) {
          // Danger proche (< 5km), notifier
          socket.emit('danger:nearby', {
            zoneId: danger.rows[0].zone_id,
            zoneName: danger.rows[0].zone_name,
            dangerLevel: danger.rows[0].danger_level,
            distanceMeters: danger.rows[0].distance_meters
          });
        }
        
        // Broadcast aux secouristes si c'en est un
        if (socket.userRole === 'secouriste') {
          socket.to('role:administrateur').emit('rescue:position', {
            userId: socket.userId,
            lat,
            lng,
            timestamp: new Date().toISOString()
          });
        }
        
      } catch (err) {
        logger.error('Location update error:', err);
      }
    });
    
    // Acknowledge alerte
    socket.on('alert:acknowledge', async (data) => {
      try {
        const { alertId } = data;
        const { pgPool } = require('../config/database');
        
        await pgPool.query(
          `UPDATE alert_recipients 
           SET read_at = NOW()
           WHERE alert_id = $1 AND user_id = $2`,
          [alertId, socket.userId]
        );
        
        socket.emit('alert:acknowledged', { alertId, success: true });
        
      } catch (err) {
        logger.error('Alert acknowledge error:', err);
        socket.emit('error', { message: 'Failed to acknowledge alert' });
      }
    });
    
    // Déconnexion
    socket.on('disconnect', () => {
      logger.info(`WebSocket disconnected: ${socket.id}`);
    });
  });
  
  // ====== REDIS SUBSCRIBE ======
  // Écouter les événements depuis Redis (pub/sub)
  
  const subscriber = redis.duplicate();
  
  subscriber.subscribe('mitandrina:new-alert', (err) => {
    if (err) logger.error('Redis subscribe error:', err);
    else logger.info('Subscribed to mitandrina:new-alert');
  });
  
  subscriber.subscribe('mitandrina:new-incident', (err) => {
    if (err) logger.error('Redis subscribe error:', err);
    else logger.info('Subscribed to mitandrina:new-incident');
  });
  
  subscriber.on('message', (channel, message) => {
    const data = JSON.parse(message);
    
    switch (channel) {
      case 'mitandrina:new-alert':
        // Diffuser aux utilisateurs concernés
        broadcastAlert(io, data);
        break;
        
      case 'mitandrina:new-incident':
        // Diffuser aux secouristes et admins
        io.to('role:secouriste').to('role:administrateur').emit('incident:new', data);
        break;
    }
  });
}

async function broadcastAlert(io, alert) {
  const { pgPool } = require('../config/database');
  
  try {
    // Trouver les utilisateurs dans la zone d'alerte
    const usersInZone = await pgPool.query(
      `SELECT id FROM users
       WHERE ST_DWithin(
         location,
         ST_SetSRID(ST_GeomFromGeoJSON($1), 4326)::geography,
         alert_radius_km * 1000
       )
       AND is_active = true`,
      [JSON.stringify(alert.zone_geometry)]
    );
    
    // Envoyer à chaque user
    for (const user of usersInZone.rows) {
      io.to(`user:${user.id}`).emit('alert:new', {
        id: alert.id,
        level: alert.level,
        type: alert.type,
        title: alert.title,
        message: alert.message,
        emittedAt: alert.emitted_at
      });
    }
    
    // Aussi notifier les admins
    io.to('role:administrateur').emit('alert:admin', alert);
    
  } catch (err) {
    logger.error('Broadcast alert error:', err);
  }
}

module.exports = { setupWebSocketHandlers };
