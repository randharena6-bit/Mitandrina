/**
 * Configuration base de données - PostgreSQL et Redis
 */

const { Pool } = require('pg');
const Redis = require('ioredis');
const logger = require('../utils/logger');

// PostgreSQL Pool
const pgPool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: process.env.PGPORT || 5432,
  database: process.env.PGDATABASE || 'mitandrina',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pgPool.on('connect', () => {
  logger.info('New PostgreSQL client connected');
});

pgPool.on('error', (err) => {
  logger.error('PostgreSQL pool error:', err);
});

// Redis Client
const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  db: process.env.REDIS_DB || 0,
  retryDelayOnFailover: 100,
  maxRetriesPerRequest: 3,
});

redis.on('connect', () => {
  logger.info('Redis client connected');
});

redis.on('error', (err) => {
  logger.error('Redis error:', err);
});

// Queue Redis (DB séparée)
const queueRedis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  db: 1,  // Queue DB
});

module.exports = {
  pgPool,
  redis,
  queueRedis
};
