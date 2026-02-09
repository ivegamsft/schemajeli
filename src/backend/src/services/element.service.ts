/**
 * Element (Column) Service
 *
 * Handles CRUD operations for table elements with soft delete,
 * table-id validation, and automatic position management.
 */

import { db } from '../db/prisma.client.js';
import type {
  Element,
  CreateElementInput,
  UpdateElementInput,
} from '../models/element.model.js';

/** Pagination options for list queries. */
interface PaginationOptions {
  page?: number;
  limit?: number;
  includeDeleted?: boolean;
  tableId?: string;
}

/** Paginated result set. */
interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export class ElementService {
  /**
   * Create a new element after validating the parent table exists.
   * Auto-increments position when not explicitly provided.
   * @param input - Element creation data.
   * @returns The created element.
   */
  async create(input: CreateElementInput): Promise<Element> {
    try {
      const table = await db.table.findFirst({
        where: { id: input.tableId, deletedAt: null },
      });

      if (!table) {
        throw new Error('Table not found');
      }

      // Auto-increment position if not explicitly set or set to 0
      if (!input.position) {
        const maxPosition = await db.element.aggregate({
          where: { tableId: input.tableId, deletedAt: null },
          _max: { position: true },
        });
        input = { ...input, position: (maxPosition._max.position ?? 0) + 1 };
      }

      return await db.element.create({ data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to create element: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find an element by ID.
   * @param id - Element UUID.
   * @returns The element or null.
   */
  async findById(id: string): Promise<Element | null> {
    try {
      return await db.element.findFirst({
        where: { id, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find element: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Return a paginated list of elements, optionally filtered by table.
   * Results are ordered by position within a table.
   * @param options - Pagination and filter options.
   */
  async findAll(
    options: PaginationOptions = {}
  ): Promise<PaginatedResult<Element>> {
    const { page = 1, limit = 20, includeDeleted = false, tableId } = options;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = includeDeleted
      ? {}
      : { deletedAt: null };
    if (tableId) {
      where.tableId = tableId;
    }

    try {
      const [data, total] = await Promise.all([
        db.element.findMany({
          where,
          skip,
          take: limit,
          orderBy: { position: 'asc' },
        }),
        db.element.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to list elements: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update an element.
   * @param id - Element UUID.
   * @param input - Fields to update.
   * @returns The updated element.
   */
  async update(id: string, input: UpdateElementInput): Promise<Element> {
    try {
      const existing = await db.element.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Element not found');
      }

      return await db.element.update({ where: { id }, data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to update element: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Soft-delete an element and reorder remaining elements in the table.
   * @param id - Element UUID.
   * @returns The soft-deleted element.
   */
  async softDelete(id: string): Promise<Element> {
    try {
      const existing = await db.element.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Element not found');
      }

      const deleted = await db.element.update({
        where: { id },
        data: { deletedAt: new Date() },
      });

      // Reorder remaining elements to close the gap
      await db.element.updateMany({
        where: {
          tableId: existing.tableId,
          deletedAt: null,
          position: { gt: existing.position },
        },
        data: { position: { decrement: 1 } },
      });

      return deleted;
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to delete element: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Restore a soft-deleted element, appending it to the end of the position list.
   * @param id - Element UUID.
   * @returns The restored element.
   */
  async restore(id: string): Promise<Element> {
    try {
      const existing = await db.element.findFirst({
        where: { id, deletedAt: { not: null } },
      });

      if (!existing) {
        throw new Error('Element not found or not deleted');
      }

      // Place at end of current element list
      const maxPosition = await db.element.aggregate({
        where: { tableId: existing.tableId, deletedAt: null },
        _max: { position: true },
      });
      const newPosition = (maxPosition._max.position ?? 0) + 1;

      return await db.element.update({
        where: { id },
        data: { deletedAt: null, position: newPosition },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to restore element: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
}
