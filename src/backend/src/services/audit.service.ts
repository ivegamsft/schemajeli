/**
 * Audit Service
 *
 * Append-only audit log service for tracking entity changes.
 * Supports creation and querying — no updates or deletes.
 */

import { db } from '../db/prisma.client.js';
import type {
  AuditLog,
  CreateAuditLogInput,
} from '../models/audit-log.model.js';
import { AuditAction, EntityType } from '../models/audit-log.model.js';

/** Pagination options for audit queries. */
interface AuditPaginationOptions {
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

export class AuditService {
  /**
   * Create an audit log entry. This is the only write operation — audit
   * logs are immutable once created.
   * @param input - Audit log creation data.
   * @returns The created audit log entry.
   */
  async create(input: CreateAuditLogInput): Promise<AuditLog> {
    try {
      return await db.auditLog.create({ data: input });
    } catch (error) {
      throw new Error(
        `Failed to create audit log: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Log a change for a given entity. Convenience wrapper around create.
   * @param entityType - The type of entity that changed.
   * @param entityId - The ID of the changed entity.
   * @param action - The action performed.
   * @param userId - The user who performed the action.
   * @param changes - Optional diff / snapshot of changes.
   * @param ipAddress - Optional client IP address.
   * @param userAgent - Optional client user-agent string.
   * @returns The created audit log entry.
   */
  async logChange(
    entityType: EntityType,
    entityId: string,
    action: AuditAction,
    userId: string,
    changes?: Record<string, unknown>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<AuditLog> {
    return this.create({
      entityType,
      entityId,
      action,
      userId,
      changes,
      ipAddress,
      userAgent,
    });
  }

  /**
   * Find audit logs for a specific entity.
   * @param entityType - The type of entity.
   * @param entityId - The entity ID.
   * @param options - Pagination options.
   */
  async findByEntity(
    entityType: EntityType,
    entityId: string,
    options: AuditPaginationOptions = {}
  ): Promise<PaginatedResult<AuditLog>> {
    const { page = 1, limit = 20 } = options;
    const skip = (page - 1) * limit;
    const where = { entityType, entityId };

    try {
      const [data, total] = await Promise.all([
        db.auditLog.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: 'desc' },
        }),
        db.auditLog.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to query audit logs by entity: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find audit logs for a specific user.
   * @param userId - The user ID.
   * @param options - Pagination options.
   */
  async findByUser(
    userId: string,
    options: AuditPaginationOptions = {}
  ): Promise<PaginatedResult<AuditLog>> {
    const { page = 1, limit = 20 } = options;
    const skip = (page - 1) * limit;
    const where = { userId };

    try {
      const [data, total] = await Promise.all([
        db.auditLog.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: 'desc' },
        }),
        db.auditLog.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to query audit logs by user: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Find audit logs within a date range.
   * @param startDate - Range start (inclusive).
   * @param endDate - Range end (inclusive).
   * @param options - Pagination options.
   */
  async findByDateRange(
    startDate: Date,
    endDate: Date,
    options: AuditPaginationOptions = {}
  ): Promise<PaginatedResult<AuditLog>> {
    const { page = 1, limit = 20 } = options;
    const skip = (page - 1) * limit;
    const where = { createdAt: { gte: startDate, lte: endDate } };

    try {
      const [data, total] = await Promise.all([
        db.auditLog.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: 'desc' },
        }),
        db.auditLog.count({ where }),
      ]);

      return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
    } catch (error) {
      throw new Error(
        `Failed to query audit logs by date range: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
}
