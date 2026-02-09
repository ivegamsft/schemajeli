/**
 * Search Index Model
 * 
 * Exports Prisma SearchIndex type for use in services and controllers.
 * Supports full-text search across entities with async updates.
 */

import { SearchIndex as PrismaSearchIndex, EntityType } from '@prisma/client';

// Re-export Prisma SearchIndex type
export type SearchIndex = PrismaSearchIndex;

// Re-export EntityType enum
export { EntityType };

// Search index creation input
export type CreateSearchIndexInput = {
  entityType: EntityType;
  entityId: string;
  content: string;
  metadata?: Record<string, any>;
};

// Search index update input
export type UpdateSearchIndexInput = Partial<Omit<CreateSearchIndexInput, 'entityType' | 'entityId'>>;
