/**
 * Middleware JWT Authentication
 */

const jwt = require('jsonwebtoken');
const { pgPool } = require('../config/database');
const logger = require('../utils/logger');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authorization header required' });
    }
    
    const token = authHeader.substring(7);
    
    // Vérifier token
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Récupérer user depuis DB
    const result = await pgPool.query(
      'SELECT id, email, role, is_active FROM users WHERE id = $1',
      [decoded.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'User not found' });
    }
    
    const user = result.rows[0];
    
    if (!user.is_active) {
      return res.status(401).json({ error: 'Account disabled' });
    }
    
    // Attacher user à la requête
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role
    };
    
    next();
    
  } catch (err) {
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    
    logger.error('Auth middleware error:', err);
    return res.status(500).json({ error: 'Authentication error' });
  }
}

// Middleware pour vérifier les rôles
function requireRole(roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    next();
  };
}

module.exports = authMiddleware;
module.exports.requireRole = requireRole;
