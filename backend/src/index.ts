import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import 'express-async-errors';
import { config } from './config/config.js';
import { logger } from './utils/logger.js';
import { errorHandler } from './middleware/errorHandler.js';
import { requestLogger } from './middleware/requestLogger.js';
import { rateLimiter } from './middleware/rateLimiter.js';
import authRoutes from './routes/auth.routes.js';
import userRoutes from './routes/user.routes.js';
import serverRoutes from './routes/server.routes.js';
import databaseRoutes from './routes/database.routes.js';
import tableRoutes from './routes/table.routes.js';
import elementRoutes from './routes/element.routes.js';
import abbreviationRoutes from './routes/abbreviation.routes.js';
import searchRoutes from './routes/search.routes.js';

const app: Application = express();

// Security middleware
app.use(helmet());
app.use(
  cors({
    origin: config.cors.origin,
    credentials: true,
  })
);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use(requestLogger);

// Rate limiting
app.use(rateLimiter);

// Health check endpoint
app.get('/health', (_req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API routes
const apiPrefix = config.api.prefix;
app.use(`${apiPrefix}/auth`, authRoutes);
app.use(`${apiPrefix}/users`, userRoutes);
app.use(`${apiPrefix}/servers`, serverRoutes);
app.use(`${apiPrefix}/databases`, databaseRoutes);
app.use(`${apiPrefix}/tables`, tableRoutes);
app.use(`${apiPrefix}/elements`, elementRoutes);
app.use(`${apiPrefix}/abbreviations`, abbreviationRoutes);
app.use(`${apiPrefix}/search`, searchRoutes);

// Error handling (must be last)
app.use(errorHandler);

// Start server
const PORT = config.server.port;
app.listen(PORT, () => {
  logger.info(`🚀 SchemaJeli API server running on port ${PORT}`);
  logger.info(`📍 Environment: ${config.server.env}`);
  logger.info(`🔗 API prefix: ${apiPrefix}`);
});

export default app;
