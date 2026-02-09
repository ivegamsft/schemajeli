/**
 * Application Configuration
 * 
 * Centralizes all configuration settings from environment variables.
 */

import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../../.env');
dotenv.config({ path: envPath });

export const config = {
  // Server configuration
  server: {
    nodeEnv: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '3000', 10),
    apiPrefix: process.env.API_PREFIX || '/api/v1',
  },

  // Database configuration
  database: {
    url: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5433/schemajeli_dev',
    queryLog: process.env.PRISMA_QUERY_LOG === 'true',
  },

  // Azure Entra ID authentication
  auth: {
    tenantId: process.env.AZURE_TENANT_ID || '',
    clientId: process.env.AZURE_CLIENT_ID || '',
    clientSecret: process.env.AZURE_CLIENT_SECRET || '',
    audience: process.env.JWT_AUDIENCE || '',
    issuer: process.env.JWT_ISSUER || '',
    jwksUri: process.env.JWT_JWKS_URI || '',
  },

  // RBAC group mapping
  rbac: {
    groupAdmin: process.env.RBAC_GROUP_ADMIN || '',
    groupMaintainer: process.env.RBAC_GROUP_MAINTAINER || '',
    groupViewer: process.env.RBAC_GROUP_VIEWER || '',
    mockRoles: process.env.RBAC_MOCK_ROLES?.split(',') || [],
  },

  // CORS configuration
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  },

  // Rate limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },

  // Logging
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    filePath: process.env.LOG_FILE_PATH || 'logs/app.log',
  },

  // Azure Application Insights (optional)
  insights: {
    instrumentationKey: process.env.APPINSIGHTS_INSTRUMENTATION_KEY || '',
  },
};

// Validate required environment variables
const requiredEnvVars = ['DATABASE_URL'];

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    console.warn(`Warning: Required environment variable ${envVar} is not set`);
  }
}

export default config;
