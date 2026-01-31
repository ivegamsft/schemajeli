import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { UserService } from '../src/services/user.service';
import prisma from '../src/config/database';
import bcrypt from 'bcrypt';

describe('UserService', () => {
  let adminUserId: string;
  let testUserId: string;

  beforeAll(async () => {
    // Create admin user for testing
    const passwordHash = await bcrypt.hash('AdminPassword123', 10);
    const admin = await prisma.user.create({
      data: {
        username: 'admin_test',
        email: 'admin_test@example.com',
        passwordHash,
        fullName: 'Admin Test User',
        role: 'ADMIN',
        isActive: true,
      },
    });
    adminUserId = admin.id;
  });

  afterAll(async () => {
    // Clean up test data
    if (testUserId) {
      await prisma.auditLog.deleteMany({
        where: { entityId: testUserId },
      });
      await prisma.user.deleteMany({
        where: { id: testUserId },
      });
    }
    await prisma.auditLog.deleteMany({
      where: { userId: adminUserId },
    });
    await prisma.user.delete({
      where: { id: adminUserId },
    });
    await prisma.$disconnect();
  });

  describe('createUser', () => {
    it('should create a new user successfully', async () => {
      const userData = {
        username: 'newuser',
        email: 'newuser@example.com',
        password: 'Password123',
        fullName: 'New User',
        role: 'VIEWER' as const,
      };

      const user = await UserService.createUser(userData, adminUserId);
      testUserId = user.id;

      expect(user.username).toBe('newuser');
      expect(user.email).toBe('newuser@example.com');
      expect(user.fullName).toBe('New User');
      expect(user.role).toBe('VIEWER');
      expect(user).not.toHaveProperty('passwordHash');
    });

    it('should throw error for duplicate username', async () => {
      const userData = {
        username: 'newuser',
        email: 'another@example.com',
        password: 'Password123',
        fullName: 'Another User',
      };

      await expect(
        UserService.createUser(userData, adminUserId)
      ).rejects.toThrow('already exists');
    });
  });

  describe('getAllUsers', () => {
    it('should return paginated users', async () => {
      const result = await UserService.getAllUsers(1, 10);

      expect(result).toHaveProperty('users');
      expect(result).toHaveProperty('pagination');
      expect(Array.isArray(result.users)).toBe(true);
      expect(result.pagination.page).toBe(1);
      expect(result.pagination.limit).toBe(10);
    });
  });

  describe('getUserById', () => {
    it('should return user by ID', async () => {
      const user = await UserService.getUserById(testUserId);

      expect(user.id).toBe(testUserId);
      expect(user.username).toBe('newuser');
    });

    it('should throw error for non-existent user', async () => {
      await expect(
        UserService.getUserById('00000000-0000-0000-0000-000000000000')
      ).rejects.toThrow('not found');
    });
  });

  describe('updateUser', () => {
    it('should update user successfully', async () => {
      const updatedUser = await UserService.updateUser(
        testUserId,
        { fullName: 'Updated Name' },
        adminUserId
      );

      expect(updatedUser.fullName).toBe('Updated Name');
    });
  });

  describe('deleteUser', () => {
    it('should deactivate user', async () => {
      const deletedUser = await UserService.deleteUser(
        testUserId,
        adminUserId
      );

      expect(deletedUser.isActive).toBe(false);
    });
  });
});
