/**
 * Audit Log Model
 * 
 * Exports Prisma AuditLog type for use in services and controllers.
 * Immutable, append-only audit trail for all entity changes.
 */

import { AuditLog as PrismaAuditLog, AuditAction, EntityType } from '@prisma/client';

// Re-export Prisma AuditLog type
export type AuditLog = PrismaAuditLog;

// Re-export enums
export { AuditAction, EntityType };

// Audit log creation input (no updates allowed - append-only)
export type CreateAuditLogInput = {
  entityType: EntityType;
  entityId: string;
  action: AuditAction;
  userId: string;
  changes?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
};
