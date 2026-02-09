/**
 * Database Service
 *
 * Handles CRUD operations for databases with soft delete,
 * server-id validation, and restrict-cascade checks.
 */

import { db } from '../db/prisma.client.js';
import type {
  Database,
  CreateDatabaseInput,
  UpdateDatabaseInput,
} from '../models/database.model.js';

/** Pagination options for list queries. */
interface PaginationOptions {
  page?: number;
  limit?: number;
  includeDeleted?: boolean;
  serverId?: string;
}

/** Paginated result set. */
interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export class DatabaseService {
  /**
   * Create a new database after validating the parent server exists.
   * @param input - Database creation data.
   * @returns The created database.
   */
  async create(input: CreateDatabaseInput): Promise<Database> {
    try {
      const server = await db.server.findFirst({
        where: { id: input.serverId, deletedAt: null },
      });

      if (!server) {
        throw new Error('Server not found');
      }

      return await db.database.create({ data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to create database: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find a database by ID.
   * @param id - Database UUID.
   * @returns The database or null.
   */
  async findById(id: string): Promise<Database | null> {
    try {
      return await db.database.findFirst({
        where: { id, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find database: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Return a paginated list of databases, optionally filtered by server.
   * @param options - Pagination and filter options.
   */
  async findAll(
    options: PaginationOptions = {}
  ): Promise<PaginatedResult<Database>> {
    const { page = 1, limit = 20, includeDeleted = false, serverId } = options;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = includeDeleted
      ? {}
      : { deletedAt: null };
    if (serverId) {
      where.serverId = serverId;
    }

    try {
      const [data, total] = await Promise.all([
        db.database.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
        db.database.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to list databases: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update a database.
   * @param id - Database UUID.
   * @param input - Fields to update.
   * @returns The updated database.
   */
  async update(id: string, input: UpdateDatabaseInput): Promise<Database> {
    try {
      const existing = await db.database.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Database not found');
      }

      return await db.database.update({ where: { id }, data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to update database: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Soft-delete a database after ensuring no active tables reference it.
   * @param id - Database UUID.
   * @returns The soft-deleted database.
   */
  async softDelete(id: string): Promise<Database> {
    try {
      const existing = await db.database.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Database not found');
      }

      // Restrict cascade: check for active child tables
      const activeTables = await db.table.count({
        where: { databaseId: id, deletedAt: null },
      });

      if (activeTables > 0) {
        throw new Error(
          `Cannot delete database: ${activeTables} active table(s) still reference it`
        );
      }

      return await db.database.update({
        where: { id },
        data: { deletedAt: new Date(), status: 'INACTIVE' },
      });
    } catch (error) {
      if (
        error instanceof Error &&
        (error.message.includes('not found') || error.message.includes('Cannot delete'))
      ) {
        throw error;
      }
      throw new Error(
        `Failed to delete database: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Restore a soft-deleted database.
   * @param id - Database UUID.
   * @returns The restored database.
   */
  async restore(id: string): Promise<Database> {
    try {
      const existing = await db.database.findFirst({
        where: { id, deletedAt: { not: null } },
      });

      if (!existing) {
        throw new Error('Database not found or not deleted');
      }

      return await db.database.update({
        where: { id },
        data: { deletedAt: null, status: 'ACTIVE' },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to restore database: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
}
