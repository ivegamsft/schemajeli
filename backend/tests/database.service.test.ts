import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { DatabaseService } from '../src/services/database.service';
import { ServerService } from '../src/services/server.service';
import prisma from '../src/config/database';
import bcrypt from 'bcrypt';

describe('DatabaseService', () => {
  let adminUserId: string;
  let testServerId: string;
  let testDatabaseId: string;

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash('TestPassword123', 10);
    const admin = await prisma.user.create({
      data: {
        username: 'db_test_admin',
        email: 'db_admin@test.com',
        passwordHash,
        fullName: 'Database Test Admin',
        role: 'ADMIN',
        isActive: true,
      },
    });
    adminUserId = admin.id;

    const server = await ServerService.createServer(
      {
        name: 'DB-TEST-SERVER',
        host: 'dbtest.example.com',
        rdbmsType: 'POSTGRESQL',
      },
      adminUserId
    );
    testServerId = server.id;
  });

  afterAll(async () => {
    if (testDatabaseId) {
      await prisma.auditLog.deleteMany({ where: { entityId: testDatabaseId } });
      await prisma.database.deleteMany({ where: { id: testDatabaseId } });
    }
    await prisma.auditLog.deleteMany({ where: { entityId: testServerId } });
    await prisma.server.delete({ where: { id: testServerId } });
    await prisma.auditLog.deleteMany({ where: { userId: adminUserId } });
    await prisma.user.delete({ where: { id: adminUserId } });
    await prisma.$disconnect();
  });

  describe('createDatabase', () => {
    it('should create a new database successfully', async () => {
      const databaseData = {
        serverId: testServerId,
        name: 'test_database',
        description: 'Test database for unit tests',
        purpose: 'Testing',
      };

      const database = await DatabaseService.createDatabase(
        databaseData,
        adminUserId
      );
      testDatabaseId = database.id;

      expect(database.name).toBe('test_database');
      expect(database.serverId).toBe(testServerId);
      expect(database.description).toBe('Test database for unit tests');
    });

    it('should throw error for duplicate database name on same server', async () => {
      const databaseData = {
        serverId: testServerId,
        name: 'test_database',
        description: 'Duplicate database',
      };

      await expect(
        DatabaseService.createDatabase(databaseData, adminUserId)
      ).rejects.toThrow('already exists');
    });
  });

  describe('getAllDatabases', () => {
    it('should return paginated databases', async () => {
      const result = await DatabaseService.getAllDatabases(1, 10);

      expect(result).toHaveProperty('databases');
      expect(result).toHaveProperty('pagination');
      expect(Array.isArray(result.databases)).toBe(true);
    });
  });

  describe('getDatabaseById', () => {
    it('should return database by ID', async () => {
      const database = await DatabaseService.getDatabaseById(testDatabaseId);

      expect(database.id).toBe(testDatabaseId);
      expect(database.name).toBe('test_database');
    });
  });

  describe('updateDatabase', () => {
    it('should update database successfully', async () => {
      const updated = await DatabaseService.updateDatabase(
        testDatabaseId,
        { purpose: 'Updated testing purpose' },
        adminUserId
      );

      expect(updated.purpose).toBe('Updated testing purpose');
    });
  });
});
