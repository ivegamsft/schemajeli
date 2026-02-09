/**
 * Server Model
 * 
 * Exports Prisma Server type for use in services and controllers.
 * Supports multiple RDBMS types including SQLSERVER.
 */

import { Server as PrismaServer, RdbmsType, EntityStatus } from '@prisma/client';

// Re-export Prisma Server type
export type Server = PrismaServer;

// Re-export enums
export { RdbmsType, EntityStatus };

// Server without soft-delete field (for public API)
export type PublicServer = Omit<PrismaServer, 'deletedAt'>;

// Server creation input
export type CreateServerInput = {
  name: string;
  description?: string;
  host: string;
  port?: number;
  rdbmsType: RdbmsType;
  location?: string;
  status?: EntityStatus;
  createdById: string;
};

// Server update input
export type UpdateServerInput = Partial<Omit<CreateServerInput, 'createdById'>>;
