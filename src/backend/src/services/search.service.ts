/**
 * Search Service
 *
 * Manages the full-text search index with async update support
 * and content aggregation across entities.
 */

import { db } from '../db/prisma.client.js';
import type {
  SearchIndex,
  CreateSearchIndexInput,
  UpdateSearchIndexInput,
} from '../models/search-index.model.js';
import { EntityType } from '../models/search-index.model.js';

/** Pagination options for search queries. */
interface SearchPaginationOptions {
  page?: number;
  limit?: number;
}

/** Paginated result set. */
interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/** A single search result with relevance metadata. */
interface SearchResult {
  entityType: EntityType;
  entityId: string;
  content: string;
  metadata: Record<string, unknown> | null;
  relevance: number;
}

export class SearchService {
  /**
   * Create a new search index entry.
   * @param input - Index creation data.
   * @returns The created index entry.
   */
  async createIndex(input: CreateSearchIndexInput): Promise<SearchIndex> {
    try {
      return await db.searchIndex.create({ data: input });
    } catch (error) {
      throw new Error(
        `Failed to create search index: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update an existing search index entry identified by entity type + id.
   * @param entityType - The entity type.
   * @param entityId - The entity ID.
   * @param input - Fields to update.
   * @returns The updated index entry.
   */
  async updateIndex(
    entityType: EntityType,
    entityId: string,
    input: UpdateSearchIndexInput
  ): Promise<SearchIndex> {
    try {
      const existing = await db.searchIndex.findFirst({
        where: { entityType, entityId },
      });

      if (!existing) {
        throw new Error('Search index entry not found');
      }

      return await db.searchIndex.update({
        where: { id: existing.id },
        data: input,
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to update search index: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Delete a search index entry for a given entity.
   * @param entityType - The entity type.
   * @param entityId - The entity ID.
   */
  async deleteIndex(entityType: EntityType, entityId: string): Promise<void> {
    try {
      await db.searchIndex.deleteMany({
        where: { entityType, entityId },
      });
    } catch (error) {
      throw new Error(
        `Failed to delete search index: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Create or update a search index entry asynchronously.
   * Fires-and-forgets so the caller is not blocked.
   * @param input - Index creation data.
   */
  async upsertIndexAsync(input: CreateSearchIndexInput): Promise<void> {
    // Fire-and-forget — errors are logged but not thrown to the caller
    void this.upsertIndex(input).catch((error) => {
      console.error('Async search index upsert failed:', error);
    });
  }

  /**
   * Aggregate entity fields into a single searchable content string
   * and upsert the index entry.
   * @param entityType - The type of entity.
   * @param entityId - The entity ID.
   * @returns The upserted index entry.
   */
  async indexEntity(
    entityType: EntityType,
    entityId: string
  ): Promise<SearchIndex> {
    try {
      const { content, metadata } = await this.aggregateContent(
        entityType,
        entityId
      );

      return await this.upsertIndex({
        entityType,
        entityId,
        content,
        metadata,
      });
    } catch (error) {
      throw new Error(
        `Failed to index entity: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Perform a full-text search across all indexed entities.
   * Uses case-insensitive substring matching.
   * @param query - The search query string.
   * @param options - Pagination options.
   */
  async search(
    query: string,
    options: SearchPaginationOptions = {}
  ): Promise<PaginatedResult<SearchResult>> {
    const { page = 1, limit = 20 } = options;
    const skip = (page - 1) * limit;

    try {
      const where = {
        content: { contains: query, mode: 'insensitive' as const },
      };

      const [entries, total] = await Promise.all([
        db.searchIndex.findMany({
          where,
          skip,
          take: limit,
          orderBy: { updatedAt: 'desc' },
        }),
        db.searchIndex.count({ where }),
      ]);

      const data: SearchResult[] = entries.map((entry) => ({
        entityType: entry.entityType,
        entityId: entry.entityId,
        content: entry.content,
        metadata: entry.metadata as Record<string, unknown> | null,
        relevance: this.calculateRelevance(entry.content, query),
      }));

      // Sort by relevance descending
      data.sort((a, b) => b.relevance - a.relevance);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Search failed: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  // -------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------

  /**
   * Upsert a search index entry (create if missing, update if present).
   */
  private async upsertIndex(
    input: CreateSearchIndexInput
  ): Promise<SearchIndex> {
    const existing = await db.searchIndex.findFirst({
      where: { entityType: input.entityType, entityId: input.entityId },
    });

    if (existing) {
      return await db.searchIndex.update({
        where: { id: existing.id },
        data: { content: input.content, metadata: input.metadata ?? undefined },
      });
    }

    return await db.searchIndex.create({ data: input });
  }

  /**
   * Aggregate an entity's fields into a single searchable string.
   */
  private async aggregateContent(
    entityType: EntityType,
    entityId: string
  ): Promise<{ content: string; metadata: Record<string, unknown> }> {
    switch (entityType) {
      case 'SERVER': {
        const server = await db.server.findUnique({ where: { id: entityId } });
        if (!server) throw new Error('Server not found');
        return {
          content: [server.name, server.description, server.host, server.rdbmsType, server.location]
            .filter(Boolean)
            .join(' '),
          metadata: { name: server.name, rdbmsType: server.rdbmsType },
        };
      }
      case 'DATABASE': {
        const database = await db.database.findUnique({ where: { id: entityId } });
        if (!database) throw new Error('Database not found');
        return {
          content: [database.name, database.description, database.purpose]
            .filter(Boolean)
            .join(' '),
          metadata: { name: database.name, serverId: database.serverId },
        };
      }
      case 'TABLE': {
        const table = await db.table.findUnique({ where: { id: entityId } });
        if (!table) throw new Error('Table not found');
        return {
          content: [table.name, table.description, table.tableType]
            .filter(Boolean)
            .join(' '),
          metadata: { name: table.name, databaseId: table.databaseId },
        };
      }
      case 'ELEMENT': {
        const element = await db.element.findUnique({ where: { id: entityId } });
        if (!element) throw new Error('Element not found');
        return {
          content: [element.name, element.description, element.dataType, element.defaultValue]
            .filter(Boolean)
            .join(' '),
          metadata: { name: element.name, tableId: element.tableId, dataType: element.dataType },
        };
      }
      case 'ABBREVIATION': {
        const abbreviation = await db.abbreviation.findUnique({ where: { id: entityId } });
        if (!abbreviation) throw new Error('Abbreviation not found');
        return {
          content: [abbreviation.source, abbreviation.abbreviation, abbreviation.definition, abbreviation.category]
            .filter(Boolean)
            .join(' '),
          metadata: { source: abbreviation.source, abbreviation: abbreviation.abbreviation },
        };
      }
      case 'USER': {
        const user = await db.user.findUnique({ where: { id: entityId } });
        if (!user) throw new Error('User not found');
        return {
          content: [user.username, user.fullName, user.email]
            .filter(Boolean)
            .join(' '),
          metadata: { username: user.username },
        };
      }
      default:
        throw new Error(`Unsupported entity type: ${entityType as string}`);
    }
  }

  /**
   * Calculate a simple relevance score based on match frequency.
   */
  private calculateRelevance(content: string, query: string): number {
    const lowerContent = content.toLowerCase();
    const lowerQuery = query.toLowerCase();
    let count = 0;
    let idx = 0;

    while ((idx = lowerContent.indexOf(lowerQuery, idx)) !== -1) {
      count++;
      idx += lowerQuery.length;
    }

    return count;
  }
}
