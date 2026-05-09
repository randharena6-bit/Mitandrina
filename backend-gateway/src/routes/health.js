/**
 * Health Check Routes
 */

const express = require('express');
const { pgPool, redis } = require('../config/database');

const router = express.Router();

// GET /health - Health check complet
router.get('/', async (req, res) => {
  const checks = {
    timestamp: new Date().toISOString(),
    service: 'mitandrina-gateway',
    version: '1.0.0',
    status: 'healthy',
    checks: {}
  };
  
  try {
    // PostgreSQL
    await pgPool.query('SELECT 1');
    checks.checks.postgresql = { status: 'ok' };
  } catch (err) {
    checks.checks.postgresql = { status: 'error', message: err.message };
    checks.status = 'degraded';
  }
  
  try {
    // Redis
    await redis.ping();
    checks.checks.redis = { status: 'ok' };
  } catch (err) {
    checks.checks.redis = { status: 'error', message: err.message };
    checks.status = 'degraded';
  }
  
  const statusCode = checks.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(checks);
});

// GET /health/ready - Kubernetes readiness probe
router.get('/ready', async (req, res) => {
  try {
    await pgPool.query('SELECT 1');
    await redis.ping();
    res.json({ ready: true });
  } catch (err) {
    res.status(503).json({ ready: false, error: err.message });
  }
});

// GET /health/live - Kubernetes liveness probe
router.get('/live', (req, res) => {
  res.json({ alive: true });
});

module.exports = router;
