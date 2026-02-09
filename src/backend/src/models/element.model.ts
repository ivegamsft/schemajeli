/**
 * Element (Column) Model
 * 
 * Exports Prisma Element type for use in services and controllers.
 * Represents database columns/fields with detailed metadata.
 */

import { Element as PrismaElement } from '@prisma/client';

// Re-export Prisma Element type
export type Element = PrismaElement;

// Element without soft-delete field
export type PublicElement = Omit<PrismaElement, 'deletedAt'>;

// Element creation input
export type CreateElementInput = {
  tableId: string;
  name: string;
  description?: string;
  dataType: string;
  length?: number;
  precision?: number;
  scale?: number;
  isNullable?: boolean;
  isPrimaryKey?: boolean;
  isForeignKey?: boolean;
  defaultValue?: string;
  position: number;
  createdById: string;
};

// Element update input
export type UpdateElementInput = Partial<Omit<CreateElementInput, 'tableId' | 'createdById'>>;
