/**
 * Table Model
 * 
 * Exports Prisma Table type for use in services and controllers.
 * Supports TABLE, VIEW, and MATERIALIZED_VIEW types.
 */

import { Table as PrismaTable, TableType, EntityStatus } from '@prisma/client';

// Re-export Prisma Table type
export type Table = PrismaTable;

// Re-export enums
export { TableType, EntityStatus };

// Table without soft-delete field
export type PublicTable = Omit<PrismaTable, 'deletedAt'>;

// Table creation input
export type CreateTableInput = {
  databaseId: string;
  name: string;
  description?: string;
  tableType?: TableType;
  rowCountEstimate?: number;
  status?: EntityStatus;
  createdById: string;
};

// Table update input
export type UpdateTableInput = Partial<Omit<CreateTableInput, 'databaseId' | 'createdById'>>;
