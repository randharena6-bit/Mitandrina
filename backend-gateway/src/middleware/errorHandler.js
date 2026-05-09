/**
 * Global Error Handler
 */

const logger = require('../utils/logger');

function errorHandler(err, req, res, next) {
  logger.error('Error:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method
  });
  
  // Erreurs spécifiques
  if (err.code === '23505') {  // PostgreSQL unique violation
    return res.status(409).json({ 
      error: 'Resource already exists',
      field: err.detail 
    });
  }
  
  if (err.code === '23503') {  // Foreign key violation
    return res.status(400).json({ 
      error: 'Referenced resource not found' 
    });
  }
  
  // Default
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
}

module.exports = errorHandler;
