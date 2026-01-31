import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { AuthService } from '../src/services/auth.service';
import prisma from '../src/config/database';
import bcrypt from 'bcrypt';

describe('AuthService', () => {
  let testUserId: string;

  beforeAll(async () => {
    // Create a test user
    const passwordHash = await bcrypt.hash('TestPassword123', 10);
    const user = await prisma.user.create({
      data: {
        username: 'testuser',
        email: 'test@example.com',
        passwordHash,
        fullName: 'Test User',
        role: 'VIEWER',
        isActive: true,
      },
    });
    testUserId = user.id;
  });

  afterAll(async () => {
    // Clean up test data
    await prisma.auditLog.deleteMany({
      where: { userId: testUserId },
    });
    await prisma.user.delete({
      where: { id: testUserId },
    });
    await prisma.$disconnect();
  });

  describe('login', () => {
    it('should login successfully with valid credentials', async () => {
      const result = await AuthService.login('testuser', 'TestPassword123');

      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result.user.username).toBe('testuser');
      expect(result.user.email).toBe('test@example.com');
    });

    it('should login successfully with email', async () => {
      const result = await AuthService.login(
        'test@example.com',
        'TestPassword123'
      );

      expect(result).toHaveProperty('accessToken');
      expect(result.user.username).toBe('testuser');
    });

    it('should throw error with invalid password', async () => {
      await expect(
        AuthService.login('testuser', 'WrongPassword')
      ).rejects.toThrow('Invalid credentials');
    });

    it('should throw error with non-existent user', async () => {
      await expect(
        AuthService.login('nonexistent', 'password')
      ).rejects.toThrow('Invalid credentials');
    });
  });

  describe('refreshToken', () => {
    it('should generate new access token with valid refresh token', async () => {
      const loginResult = await AuthService.login(
        'testuser',
        'TestPassword123'
      );
      const result = await AuthService.refreshToken(loginResult.refreshToken);

      expect(result).toHaveProperty('accessToken');
      expect(typeof result.accessToken).toBe('string');
    });

    it('should throw error with invalid refresh token', async () => {
      await expect(
        AuthService.refreshToken('invalid-token')
      ).rejects.toThrow();
    });
  });

  describe('validateToken', () => {
    it('should validate a valid token', async () => {
      const loginResult = await AuthService.login(
        'testuser',
        'TestPassword123'
      );
      const payload = await AuthService.validateToken(
        loginResult.accessToken
      );

      expect(payload.userId).toBe(testUserId);
      expect(payload.username).toBe('testuser');
      expect(payload.role).toBe('VIEWER');
    });

    it('should throw error with invalid token', async () => {
      await expect(
        AuthService.validateToken('invalid-token')
      ).rejects.toThrow();
    });
  });
});
