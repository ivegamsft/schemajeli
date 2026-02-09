/**
 * Abbreviation Model
 * 
 * Exports Prisma Abbreviation type for use in services and controllers.
 * Manages standard abbreviations and naming conventions.
 */

import { Abbreviation as PrismaAbbreviation } from '@prisma/client';

// Re-export Prisma Abbreviation type
export type Abbreviation = PrismaAbbreviation;

// Abbreviation without soft-delete field
export type PublicAbbreviation = Omit<PrismaAbbreviation, 'deletedAt'>;

// Abbreviation creation input
export type CreateAbbreviationInput = {
  source: string;
  abbreviation: string;
  definition?: string;
  isPrimeClass?: boolean;
  category?: string;
  createdById: string;
};

// Abbreviation update input
export type UpdateAbbreviationInput = Partial<Omit<CreateAbbreviationInput, 'createdById'>>;
