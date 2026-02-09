/**
 * Table Service
 *
 * Handles CRUD operations for tables with soft delete,
 * database-id validation, and restrict-cascade checks.
 */

import { db } from '../db/prisma.client.js';
import type {
  Table,
  CreateTableInput,
  UpdateTableInput,
} from '../models/table.model.js';

/** Pagination options for list queries. */
interface PaginationOptions {
  page?: number;
  limit?: number;
  includeDeleted?: boolean;
  databaseId?: string;
}

/** Paginated result set. */
interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export class TableService {
  /**
   * Create a new table after validating the parent database exists.
   * @param input - Table creation data.
   * @returns The created table.
   */
  async create(input: CreateTableInput): Promise<Table> {
    try {
      const database = await db.database.findFirst({
        where: { id: input.databaseId, deletedAt: null },
      });

      if (!database) {
        throw new Error('Database not found');
      }

      return await db.table.create({ data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to create table: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find a table by ID.
   * @param id - Table UUID.
   * @returns The table or null.
   */
  async findById(id: string): Promise<Table | null> {
    try {
      return await db.table.findFirst({
        where: { id, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find table: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Return a paginated list of tables, optionally filtered by database.
   * @param options - Pagination and filter options.
   */
  async findAll(
    options: PaginationOptions = {}
  ): Promise<PaginatedResult<Table>> {
    const { page = 1, limit = 20, includeDeleted = false, databaseId } = options;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = includeDeleted
      ? {}
      : { deletedAt: null };
    if (databaseId) {
      where.databaseId = databaseId;
    }

    try {
      const [data, total] = await Promise.all([
        db.table.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
        db.table.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to list tables: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update a table.
   * @param id - Table UUID.
   * @param input - Fields to update.
   * @returns The updated table.
   */
  async update(id: string, input: UpdateTableInput): Promise<Table> {
    try {
      const existing = await db.table.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Table not found');
      }

      return await db.table.update({ where: { id }, data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to update table: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Soft-delete a table after ensuring no active elements reference it.
   * @param id - Table UUID.
   * @returns The soft-deleted table.
   */
  async softDelete(id: string): Promise<Table> {
    try {
      const existing = await db.table.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Table not found');
      }

      // Restrict cascade: check for active child elements
      const activeElements = await db.element.count({
        where: { tableId: id, deletedAt: null },
      });

      if (activeElements > 0) {
        throw new Error(
          `Cannot delete table: ${activeElements} active element(s) still reference it`
        );
      }

      return await db.table.update({
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
        `Failed to delete table: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Restore a soft-deleted table.
   * @param id - Table UUID.
   * @returns The restored table.
   */
  async restore(id: string): Promise<Table> {
    try {
      const existing = await db.table.findFirst({
        where: { id, deletedAt: { not: null } },
      });

      if (!existing) {
        throw new Error('Table not found or not deleted');
      }

      return await db.table.update({
        where: { id },
        data: { deletedAt: null, status: 'ACTIVE' },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to restore table: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
}
