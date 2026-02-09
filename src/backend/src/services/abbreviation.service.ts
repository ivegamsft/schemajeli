/**
 * Abbreviation Service
 *
 * Handles CRUD operations for abbreviations with soft delete
 * and uniqueness validation.
 */

import { db } from '../db/prisma.client.js';
import type {
  Abbreviation,
  CreateAbbreviationInput,
  UpdateAbbreviationInput,
} from '../models/abbreviation.model.js';

/** Pagination options for list queries. */
interface PaginationOptions {
  page?: number;
  limit?: number;
  includeDeleted?: boolean;
  category?: string;
}

/** Paginated result set. */
interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export class AbbreviationService {
  /**
   * Create a new abbreviation after checking uniqueness.
   * @param input - Abbreviation creation data.
   * @returns The created abbreviation.
   */
  async create(input: CreateAbbreviationInput): Promise<Abbreviation> {
    try {
      // Uniqueness validation
      const existing = await db.abbreviation.findFirst({
        where: { abbreviation: input.abbreviation, deletedAt: null },
      });

      if (existing) {
        throw new Error(
          `Abbreviation '${input.abbreviation}' already exists`
        );
      }

      return await db.abbreviation.create({ data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('already exists')) {
        throw error;
      }
      throw new Error(
        `Failed to create abbreviation: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find an abbreviation by ID.
   * @param id - Abbreviation UUID.
   * @returns The abbreviation or null.
   */
  async findById(id: string): Promise<Abbreviation | null> {
    try {
      return await db.abbreviation.findFirst({
        where: { id, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find abbreviation: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Return a paginated list of abbreviations, optionally filtered by category.
   * @param options - Pagination and filter options.
   */
  async findAll(
    options: PaginationOptions = {}
  ): Promise<PaginatedResult<Abbreviation>> {
    const { page = 1, limit = 20, includeDeleted = false, category } = options;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = includeDeleted
      ? {}
      : { deletedAt: null };
    if (category) {
      where.category = category;
    }

    try {
      const [data, total] = await Promise.all([
        db.abbreviation.findMany({
          where,
          skip,
          take: limit,
          orderBy: { abbreviation: 'asc' },
        }),
        db.abbreviation.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to list abbreviations: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update an abbreviation with uniqueness validation.
   * @param id - Abbreviation UUID.
   * @param input - Fields to update.
   * @returns The updated abbreviation.
   */
  async update(
    id: string,
    input: UpdateAbbreviationInput
  ): Promise<Abbreviation> {
    try {
      const existing = await db.abbreviation.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Abbreviation not found');
      }

      // Uniqueness check if abbreviation text is being changed
      if (input.abbreviation && input.abbreviation !== existing.abbreviation) {
        const duplicate = await db.abbreviation.findFirst({
          where: { abbreviation: input.abbreviation, deletedAt: null },
        });

        if (duplicate) {
          throw new Error(
            `Abbreviation '${input.abbreviation}' already exists`
          );
        }
      }

      return await db.abbreviation.update({ where: { id }, data: input });
    } catch (error) {
      if (
        error instanceof Error &&
        (error.message.includes('not found') || error.message.includes('already exists'))
      ) {
        throw error;
      }
      throw new Error(
        `Failed to update abbreviation: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Soft-delete an abbreviation.
   * @param id - Abbreviation UUID.
   * @returns The soft-deleted abbreviation.
   */
  async softDelete(id: string): Promise<Abbreviation> {
    try {
      const existing = await db.abbreviation.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Abbreviation not found');
      }

      return await db.abbreviation.update({
        where: { id },
        data: { deletedAt: new Date() },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to delete abbreviation: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Restore a soft-deleted abbreviation.
   * @param id - Abbreviation UUID.
   * @returns The restored abbreviation.
   */
  async restore(id: string): Promise<Abbreviation> {
    try {
      const existing = await db.abbreviation.findFirst({
        where: { id, deletedAt: { not: null } },
      });

      if (!existing) {
        throw new Error('Abbreviation not found or not deleted');
      }

      return await db.abbreviation.update({
        where: { id },
        data: { deletedAt: null },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to restore abbreviation: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
}
