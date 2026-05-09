/**
 * 🌪️ MITANDRINA - API Gateway & WebSocket Server
 * 
 * Architecture:
 * - Express API Gateway (rate limiting, auth, proxy)
 * - Socket.io WebSocket Server (temps réel)
 * - Bull Queue Workers (notifications)
 * - PostgreSQL client
 */

require('dotenv').config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { Server } = require('socket.io');
const { createProxyMiddleware } = require('http-proxy-middleware');

const { redis, pgPool } = require('./config/database');
const logger = require('./utils/logger');
const authMiddleware = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');
const { setupWebSocketHandlers } = require('./websocket/handlers');
const { setupQueueWorkers } = require('./workers/queue');

// Routers
const authRouter = require('./routes/auth');
const usersRouter = require('./routes/users');
const alertsRouter = require('./routes/alerts');
const incidentsRouter = require('./routes/incidents');
const sheltersRouter = require('./routes/shelters');
const notificationsRouter = require('./routes/notifications');
const healthRouter = require('./routes/health');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true
  }
});

const PORT = process.env.PORT || 3001;
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

// ============================================
// MIDDLEWARES
// ============================================

// Sécurité
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
}));

// Logging
app.use(morgan('combined', { stream: { write: msg => logger.info(msg.trim()) } }));

// Compression
app.use(compression());

// Parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.ip
});
app.use('/api/', limiter);

// ============================================
// ROUTES
// ============================================

// Health check (sans auth)
app.use('/health', healthRouter);

// Auth
app.use('/api/v1/auth', authRouter);

// Routes protégées
app.use('/api/v1/users', authMiddleware, usersRouter);
app.use('/api/v1/alerts', authMiddleware, alertsRouter);
app.use('/api/v1/incidents', authMiddleware, incidentsRouter);
app.use('/api/v1/shelters', authMiddleware, sheltersRouter);
app.use('/api/v1/notifications', authMiddleware, notificationsRouter);

// Proxy vers FastAPI AI Services
app.use('/api/v1/ai', authMiddleware, createProxyMiddleware({
  target: AI_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/ai': '/api/v1'  // Réécrit /api/v1/ai/predictions -> /api/v1/predictions
  },
  onProxyReq: (proxyReq, req) => {
    logger.info(`Proxy AI: ${req.method} ${req.path}`);
  },
  onError: (err, req, res) => {
    logger.error('Proxy AI error:', err);
    res.status(503).json({ error: 'AI Service unavailable' });
  }
}));

// ============================================
// WEBSOCKET
// ============================================

// Middleware auth pour Socket.io
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication required'));
    }
    
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.userId;
    socket.userRole = decoded.role;
    next();
  } catch (err) {
    next(new Error('Invalid token'));
  }
});

// Setup handlers WebSocket
setupWebSocketHandlers(io, redis);

// ============================================
// ERROR HANDLING
// ============================================

app.use(errorHandler);

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'Not found', path: req.path });
});

// ============================================
// STARTUP
// ============================================

async function startServer() {
  try {
    // Test connections
    await redis.ping();
    logger.info('✅ Redis connected');
    
    await pgPool.query('SELECT NOW()');
    logger.info('✅ PostgreSQL connected');
    
    // Démarrer workers
    setupQueueWorkers();
    logger.info('✅ Queue workers started');
    
    // Démarrer serveur
    server.listen(PORT, () => {
      logger.info(`🚀 MITANDRINA Gateway running on port ${PORT}`);
      logger.info(`📚 API Docs: http://localhost:${PORT}/api/v1`);
      logger.info(`🔌 WebSocket: ws://localhost:${PORT}`);
    });
    
  } catch (err) {
    logger.error('Failed to start server:', err);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('HTTP server closed');
  });
  await redis.quit();
  await pgPool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close();
  await redis.quit();
  await pgPool.end();
  process.exit(0);
});

startServer();

module.exports = { app, io };
