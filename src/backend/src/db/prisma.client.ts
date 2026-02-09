/**
 * Prisma Client Singleton
 * 
 * Provides a single instance of PrismaClient for the entire application.
 * Implements connection pooling and proper error handling.
 */

import { PrismaClient } from '@prisma/client';
import { config } from '../config/index.js';

// PrismaClient options with connection pooling
const logLevels = config.database.queryLog 
  ? ['query', 'error', 'warn'] as ('query' | 'error' | 'warn')[]
  : ['error', 'warn'] as ('error' | 'warn')[];

const prismaOptions = {
  datasources: {
    db: {
      url: config.database.url,
    },
  },
  log: logLevels,
};

// Singleton instance
let prisma: PrismaClient;

/**
 * Get the Prisma Client instance
 * Creates a new instance if one doesn't exist (singleton pattern)
 */
export function getPrismaClient(): PrismaClient {
  if (!prisma) {
    prisma = new PrismaClient(prismaOptions);

    // Handle connection errors
    prisma.$connect().catch((error) => {
      console.error('Failed to connect to database:', error);
      process.exit(1);
    });

    // Graceful shutdown
    process.on('beforeExit', async () => {
      await prisma.$disconnect();
    });
  }

  return prisma;
}

// Export default instance
export const db = getPrismaClient();
