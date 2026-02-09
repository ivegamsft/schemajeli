/**
 * User Service
 *
 * Handles CRUD operations for users with Azure Entra ID integration,
 * optimistic locking, and soft delete support.
 */

import { db } from '../db/prisma.client.js';
import type {
  User,
  CreateUserInput,
  UpdateUserInput,
} from '../models/user.model.js';
import { Role } from '../models/user.model.js';

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

/** Token payload used during Entra ID sync. */
interface EntraIdTokenPayload {
  oid: string;
  preferred_username: string;
  email: string;
  name: string;
  roles?: string[];
}

export class UserService {
  /**
   * Create a new user.
   * @param input - User creation data.
   * @returns The created user.
   */
  async create(input: CreateUserInput): Promise<User> {
    try {
      return await db.user.create({ data: input });
    } catch (error) {
      throw new Error(
        `Failed to create user: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find a user by internal ID.
   * @param id - The user UUID.
   * @returns The user or null if not found.
   */
  async findById(id: string): Promise<User | null> {
    try {
      return await db.user.findFirst({
        where: { id, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find user: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find a user by Azure Entra ID.
   * @param entraId - The Entra object ID.
   * @returns The user or null if not found.
   */
  async findByEntraId(entraId: string): Promise<User | null> {
    try {
      return await db.user.findFirst({
        where: { entraId, deletedAt: null },
      });
    } catch (error) {
      throw new Error(
        `Failed to find user by Entra ID: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Return a paginated list of users.
   * @param options - Pagination and filter options.
   */
  async findAll(
    options: PaginationOptions = {}
  ): Promise<PaginatedResult<User>> {
    const { page = 1, limit = 20, includeDeleted = false } = options;
    const skip = (page - 1) * limit;
    const where = includeDeleted ? {} : { deletedAt: null };

    try {
      const [data, total] = await Promise.all([
        db.user.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
        db.user.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to list users: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Update a user with optimistic locking.
   * @param id - User UUID.
   * @param input - Fields to update.
   * @param expectedUpdatedAt - Timestamp for optimistic concurrency check.
   * @returns The updated user.
   */
  async update(
    id: string,
    input: UpdateUserInput,
    expectedUpdatedAt: Date
  ): Promise<User> {
    try {
      const existing = await db.user.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('User not found');
      }

      if (existing.updatedAt.getTime() !== expectedUpdatedAt.getTime()) {
        throw new Error(
          'Conflict: the user has been modified by another request'
        );
      }

      return await db.user.update({ where: { id }, data: input });
    } catch (error) {
      if (error instanceof Error && (error.message.includes('not found') || error.message.includes('Conflict'))) {
        throw error;
      }
      throw new Error(
        `Failed to update user: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Soft-delete a user by setting deletedAt.
   * @param id - User UUID.
   * @returns The soft-deleted user.
   */
  async softDelete(id: string): Promise<User> {
    try {
      const existing = await db.user.findFirst({
        where: { id, deletedAt: null },
      });

      if (!existing) {
        throw new Error('User not found');
      }

      return await db.user.update({
        where: { id },
        data: { deletedAt: new Date(), isActive: false },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to delete user: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Restore a soft-deleted user.
   * @param id - User UUID.
   * @returns The restored user.
   */
  async restore(id: string): Promise<User> {
    try {
      const existing = await db.user.findFirst({
        where: { id, deletedAt: { not: null } },
      });

      if (!existing) {
        throw new Error('User not found or not deleted');
      }

      return await db.user.update({
        where: { id },
        data: { deletedAt: null, isActive: true },
      });
    } catch (error) {
      if (error instanceof Error && error.message.includes('not found')) {
        throw error;
      }
      throw new Error(
        `Failed to restore user: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Create or update a user from an Azure Entra ID token.
   * Updates lastLoginAt on every call.
   * @param token - Decoded Entra ID token payload.
   * @returns The upserted user.
   */
  async upsertFromEntraId(token: EntraIdTokenPayload): Promise<User> {
    try {
      const role = this.mapTokenRole(token.roles);

      return await db.user.upsert({
        where: { entraId: token.oid },
        create: {
          entraId: token.oid,
          username: token.preferred_username,
          email: token.email,
          fullName: token.name,
          role,
          isActive: true,
          lastLoginAt: new Date(),
        },
        update: {
          email: token.email,
          fullName: token.name,
          role,
          lastLoginAt: new Date(),
        },
      });
    } catch (error) {
      throw new Error(
        `Failed to upsert user from Entra ID: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Map Entra ID token roles to the application Role enum.
   * Falls back to VIEWER when no recognised role is present.
   */
  private mapTokenRole(roles?: string[]): Role {
    if (!roles || roles.length === 0) return Role.VIEWER;
    if (roles.includes('Admin')) return Role.ADMIN;
    if (roles.includes('Maintainer')) return Role.MAINTAINER;
    return Role.VIEWER;
  }
}
