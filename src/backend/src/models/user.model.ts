/**
 * User Model
 * 
 * Exports Prisma User type for use in services and controllers.
 * Uses Azure Entra ID for authentication (entraId field).
 */

import { User as PrismaUser, Role } from '@prisma/client';

// Re-export Prisma User type
export type User = PrismaUser;

// Re-export Role enum
export { Role };

// User without sensitive fields (for API responses)
export type PublicUser = Omit<PrismaUser, 'deletedAt'>;

// User creation input
export type CreateUserInput = {
  entraId: string;
  username: string;
  email: string;
  fullName: string;
  role?: Role;
  isActive?: boolean;
};

// User update input
export type UpdateUserInput = Partial<Pick<PrismaUser, 'username' | 'email' | 'fullName' | 'role' | 'isActive'>>;
