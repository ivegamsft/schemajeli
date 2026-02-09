/**
 * Server Service
 *
 * Handles CRUD operations for database servers with soft delete
 * and restrict-cascade validation.
 */

import { db } from '../db/prisma.client.js';
import type {
  Server,
  CreateServerInput,
  UpdateServerInput,
} from '../models/server.model.js';

/** Pagination options for list queries. */
interface PaginationOptions {
  page?: number;
  limit?: number;
  includeDeleted?: boolean;
}

/** Paginated result set. */
interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export class ServerService {
  /**
   * Create a new server.
   * @param input - Server creation data.
   * @returns The created server.
   */
  async create(input: CreateServerInput): Promise<Server> {
    try {
      return await db.server.create({ data: input });
    } catch (error) {
      throw new Error(
        `Failed to create server: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find a server by ID.
   * @param id - Server UUID.
   * @returns The server or null.
   */
  async findById(id: string): Promise<Server | null> {
    try {
      return await db.server.findFirst({
        where: { id, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find server: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Return a paginated list of servers.
   * @param options - Pagination and filter options.
   */
  async findAll(
    options: PaginationOptions = {}
  ): Promise<PaginatedResult<Server>> {
    const { page = 1, limit = 20, includeDeleted = false } = options;
    const skip = (page - 1) * limit;
    const where = includeDeleted ? {} : { deletedAt: null };

    try {
      const [data, total] = await Promise.all([
        db.server.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
        db.server.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to list servers: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update a server.
   * @param id - Server UUID.
   * @param input - Fields to update.
   * @returns The updated server.
   */
  async update(id: string, input: UpdateServerInput): Promise<Server> {
    try {
      const existing = await db.server.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Server not found');
      }

      return await db.server.update({ where: { id }, data: input });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to update server: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Soft-delete a server after ensuring no active databases reference it.
   * @param id - Server UUID.
   * @returns The soft-deleted server.
   */
  async softDelete(id: string): Promise<Server> {
    try {
      const existing = await db.server.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('Server not found');
      }

      // Restrict cascade: check for active child databases
      const activeDatabases = await db.database.count({
        where: { serverId: id, deletedAt: null },
      });

      if (activeDatabases > 0) {
        throw new Error(
          `Cannot delete server: ${activeDatabases} active database(s) still reference it`
        );
      }

      return await db.server.update({
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
        `Failed to delete server: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Restore a soft-deleted server.
   * @param id - Server UUID.
   * @returns The restored server.
   */
  async restore(id: string): Promise<Server> {
    try {
      const existing = await db.server.findFirst({
        where: { id, deletedAt: { not: null } },
      });

      if (!existing) {
        throw new Error('Server not found or not deleted');
      }

      return await db.server.update({
        where: { id },
        data: { deletedAt: null, status: 'ACTIVE' },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to restore server: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
}
