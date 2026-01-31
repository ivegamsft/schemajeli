import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { ServerService } from '../src/services/server.service';
import prisma from '../src/config/database';
import bcrypt from 'bcrypt';

describe('ServerService', () => {
  let adminUserId: string;
  let testServerId: string;

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash('TestPassword123', 10);
    const admin = await prisma.user.create({
      data: {
        username: 'server_test_admin',
        email: 'server_admin@test.com',
        passwordHash,
        fullName: 'Server Test Admin',
        role: 'ADMIN',
        isActive: true,
      },
    });
    adminUserId = admin.id;
  });

  afterAll(async () => {
    if (testServerId) {
      await prisma.auditLog.deleteMany({ where: { entityId: testServerId } });
      await prisma.server.deleteMany({ where: { id: testServerId } });
    }
    await prisma.auditLog.deleteMany({ where: { userId: adminUserId } });
    await prisma.user.delete({ where: { id: adminUserId } });
    await prisma.$disconnect();
  });

  describe('createServer', () => {
    it('should create a new server successfully', async () => {
      const serverData = {
        name: 'TEST-SERVER-01',
        description: 'Test PostgreSQL Server',
        host: 'test-db.example.com',
        port: 5432,
        rdbmsType: 'POSTGRESQL' as const,
        location: 'US-TEST',
      };

      const server = await ServerService.createServer(serverData, adminUserId);
      testServerId = server.id;

      expect(server.name).toBe('TEST-SERVER-01');
      expect(server.host).toBe('test-db.example.com');
      expect(server.rdbmsType).toBe('POSTGRESQL');
      expect(server.port).toBe(5432);
    });

    it('should throw error for duplicate server name', async () => {
      const serverData = {
        name: 'TEST-SERVER-01',
        description: 'Duplicate server',
        host: 'another.example.com',
        rdbmsType: 'MYSQL' as const,
      };

      await expect(
        ServerService.createServer(serverData, adminUserId)
      ).rejects.toThrow('already exists');
    });
  });

  describe('getAllServers', () => {
    it('should return paginated servers', async () => {
      const result = await ServerService.getAllServers(1, 10);

      expect(result).toHaveProperty('servers');
      expect(result).toHaveProperty('pagination');
      expect(Array.isArray(result.servers)).toBe(true);
    });

    it('should filter servers by search query', async () => {
      const result = await ServerService.getAllServers(1, 10, {
        search: 'TEST-SERVER',
      });

      expect(result.servers.length).toBeGreaterThan(0);
      expect(result.servers[0].name).toContain('TEST-SERVER');
    });
  });

  describe('getServerById', () => {
    it('should return server by ID', async () => {
      const server = await ServerService.getServerById(testServerId);

      expect(server.id).toBe(testServerId);
      expect(server.name).toBe('TEST-SERVER-01');
    });

    it('should throw error for non-existent server', async () => {
      await expect(
        ServerService.getServerById('00000000-0000-0000-0000-000000000000')
      ).rejects.toThrow('not found');
    });
  });

  describe('updateServer', () => {
    it('should update server successfully', async () => {
      const updated = await ServerService.updateServer(
        testServerId,
        { description: 'Updated Description' },
        adminUserId
      );

      expect(updated.description).toBe('Updated Description');
    });
  });

  describe('getServerStats', () => {
    it('should return server statistics', async () => {
      const stats = await ServerService.getServerStats();

      expect(stats).toHaveProperty('total');
      expect(stats).toHaveProperty('byRdbmsType');
      expect(stats).toHaveProperty('byStatus');
    });
  });
});
