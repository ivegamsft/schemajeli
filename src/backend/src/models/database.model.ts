/**
 * Database Model
 * 
 * Exports Prisma Database type for use in services and controllers.
 */

import { Database as PrismaDatabase, EntityStatus } from '@prisma/client';

// Re-export Prisma Database type
export type Database = PrismaDatabase;

// Re-export EntityStatus enum
export { EntityStatus };

// Database without soft-delete field
export type PublicDatabase = Omit<PrismaDatabase, 'deletedAt'>;

// Database creation input
export type CreateDatabaseInput = {
  serverId: string;
  name: string;
  description?: string;
  purpose?: string;
  status?: EntityStatus;
  createdById: string;
};

// Database update input
export type UpdateDatabaseInput = Partial<Omit<CreateDatabaseInput, 'serverId' | 'createdById'>>;
