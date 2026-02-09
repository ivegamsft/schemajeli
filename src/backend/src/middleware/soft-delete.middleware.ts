/**
 * Soft Delete Query Filter Middleware
 * 
 * Automatically filters out soft-deleted records (deletedAt IS NOT NULL)
 * unless explicitly requested via query parameter.
 */

/**
 * Prisma middleware to automatically filter soft-deleted records
 * Applies to findMany, findFirst, findUnique queries
 * 
 * Usage: Apply as Prisma middleware in prisma.client.ts
 */
export function softDeleteMiddleware() {
  return async (params: any, next: (params: any) => Promise<any>) => {
    // Check if query should include deleted records
    const includeDeleted = params.args?.includeDeleted === true;

    // Remove custom includeDeleted param before passing to Prisma
    if (params.args?.includeDeleted !== undefined) {
      delete params.args.includeDeleted;
    }

    // Models that support soft deletes
    const softDeleteModels = [
      'user',
      'server',
      'database',
      'table',
      'element',
      'abbreviation',
    ];

    // Check if current model supports soft deletes
    const isSoftDeleteModel = softDeleteModels.includes(params.model?.toLowerCase() || '');

    // Apply soft-delete filter if applicable
    if (isSoftDeleteModel && !includeDeleted) {
      // Handle different query types
      if (params.action === 'findUnique' || params.action === 'findFirst') {
        // Add deletedAt: null to where clause
        params.args.where = {
          ...params.args.where,
          deletedAt: null,
        };
      } else if (params.action === 'findMany') {
        // Add deletedAt: null to where clause
        params.args.where = {
          ...params.args.where,
          deletedAt: null,
        };
      } else if (params.action === 'count') {
        // Add deletedAt: null to where clause for count
        params.args.where = {
          ...params.args.where,
          deletedAt: null,
        };
      } else if (params.action === 'aggregate') {
        // Add deletedAt: null to where clause for aggregate
        params.args.where = {
          ...params.args.where,
          deletedAt: null,
        };
      }
    }

    return next(params);
  };
}

/**
 * Soft delete a record (set deletedAt to current timestamp)
 * 
 * @param model - Prisma model delegate
 * @param id - Record ID
 */
export async function softDelete<T extends { deletedAt: Date | null }>(
  model: any,
  id: string
): Promise<T> {
  return await model.update({
    where: { id },
    data: { deletedAt: new Date() },
  });
}

/**
 * Restore a soft-deleted record (set deletedAt to null)
 * 
 * @param model - Prisma model delegate
 * @param id - Record ID
 */
export async function restoreDeleted<T extends { deletedAt: Date | null }>(
  model: any,
  id: string
): Promise<T> {
  return await model.update({
    where: { id },
    data: { deletedAt: null },
  });
}

/**
 * Query options type for including deleted records
 */
export type QueryOptions = {
  includeDeleted?: boolean;
};

/**
 * Helper to add soft-delete filter to Prisma where clause
 */
export function applySoftDeleteFilter<T extends Record<string, any>>(
  where: T,
  includeDeleted: boolean = false
): T {
  if (includeDeleted) {
    return where;
  }

  return {
    ...where,
    deletedAt: null,
  } as T;
}
