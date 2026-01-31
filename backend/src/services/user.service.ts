import bcrypt from 'bcrypt';
import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';
import { Role } from '@prisma/client';

export interface CreateUserDto {
  username: string;
  email: string;
  password: string;
  fullName: string;
  role?: Role;
}

export interface UpdateUserDto {
  email?: string;
  fullName?: string;
  role?: Role;
  isActive?: boolean;
}

export class UserService {
  /**
   * Create a new user
   */
  static async createUser(data: CreateUserDto, createdById: string) {
    // Check if username already exists
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ username: data.username }, { email: data.email }],
      },
    });

    if (existingUser) {
      throw new AppError(
        409,
        'User with this username or email already exists'
      );
    }

    // Hash password
    const passwordHash = await bcrypt.hash(data.password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        username: data.username,
        email: data.email,
        passwordHash,
        fullName: data.fullName,
        role: data.role || Role.VIEWER,
        isActive: true,
      },
      select: {
        id: true,
        username: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'USER',
        entityId: user.id,
        action: 'CREATE',
        userId: createdById,
        changes: { created: user },
      },
    });

    return user;
  }

  /**
   * Get all users with pagination
   */
  static async getAllUsers(page = 1, limit = 10) {
    const skip = (page - 1) * limit;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        skip,
        take: limit,
        select: {
          id: true,
          username: true,
          email: true,
          fullName: true,
          role: true,
          isActive: true,
          lastLoginAt: true,
          createdAt: true,
          updatedAt: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count(),
    ]);

    return {
      users,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get user by ID
   */
  static async getUserById(id: string) {
    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        username: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    return user;
  }

  /**
   * Update user
   */
  static async updateUser(
    id: string,
    data: UpdateUserDto,
    updatedById: string
  ) {
    const existingUser = await prisma.user.findUnique({ where: { id } });
    if (!existingUser) {
      throw new AppError(404, 'User not found');
    }

    // Check email uniqueness if updating email
    if (data.email && data.email !== existingUser.email) {
      const emailExists = await prisma.user.findUnique({
        where: { email: data.email },
      });
      if (emailExists) {
        throw new AppError(409, 'Email already in use');
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id },
      data,
      select: {
        id: true,
        username: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        lastLoginAt: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'USER',
        entityId: id,
        action: 'UPDATE',
        userId: updatedById,
        changes: {
          before: existingUser,
          after: updatedUser,
        },
      },
    });

    return updatedUser;
  }

  /**
   * Delete user (soft delete by deactivating)
   */
  static async deleteUser(id: string, deletedById: string) {
    const existingUser = await prisma.user.findUnique({ where: { id } });
    if (!existingUser) {
      throw new AppError(404, 'User not found');
    }

    // Deactivate instead of hard delete
    const deletedUser = await prisma.user.update({
      where: { id },
      data: { isActive: false },
      select: {
        id: true,
        username: true,
        isActive: true,
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'USER',
        entityId: id,
        action: 'DELETE',
        userId: deletedById,
        changes: { deactivated: true },
      },
    });

    return deletedUser;
  }

  /**
   * Change user password
   */
  static async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string
  ) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new AppError(404, 'User not found');
    }

    // Verify old password
    const isPasswordValid = await bcrypt.compare(oldPassword, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError(401, 'Current password is incorrect');
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    // Update password
    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newPasswordHash },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'USER',
        entityId: userId,
        action: 'UPDATE',
        userId,
        changes: { action: 'password_changed' },
      },
    });

    return { message: 'Password changed successfully' };
  }
}
