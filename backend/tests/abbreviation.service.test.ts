import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { AbbreviationService } from '../src/services/abbreviation.service';
import prisma from '../src/config/database';
import bcrypt from 'bcrypt';

describe('AbbreviationService', () => {
  let adminUserId: string;
  let testAbbreviationId: string;

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash('TestPassword123', 10);
    const admin = await prisma.user.create({
      data: {
        username: 'abbr_test_admin',
        email: 'abbr_admin@test.com',
        passwordHash,
        fullName: 'Abbreviation Test Admin',
        role: 'ADMIN',
        isActive: true,
      },
    });
    adminUserId = admin.id;
  });

  afterAll(async () => {
    if (testAbbreviationId) {
      await prisma.auditLog.deleteMany({
        where: { entityId: testAbbreviationId },
      });
      await prisma.abbreviation.deleteMany({
        where: { id: testAbbreviationId },
      });
    }
    await prisma.auditLog.deleteMany({ where: { userId: adminUserId } });
    await prisma.user.delete({ where: { id: adminUserId } });
    await prisma.$disconnect();
  });

  describe('createAbbreviation', () => {
    it('should create a new abbreviation successfully', async () => {
      const abbrData = {
        source: 'Test Source',
        abbreviation: 'TST',
        definition: 'Test abbreviation definition',
        isPrimeClass: true,
        category: 'Testing',
      };

      const abbreviation = await AbbreviationService.createAbbreviation(
        abbrData,
        adminUserId
      );
      testAbbreviationId = abbreviation.id;

      expect(abbreviation.source).toBe('Test Source');
      expect(abbreviation.abbreviation).toBe('TST');
      expect(abbreviation.isPrimeClass).toBe(true);
    });

    it('should throw error for duplicate abbreviation', async () => {
      const abbrData = {
        source: 'Another Source',
        abbreviation: 'TST',
        definition: 'Duplicate',
      };

      await expect(
        AbbreviationService.createAbbreviation(abbrData, adminUserId)
      ).rejects.toThrow('already exists');
    });
  });

  describe('getAllAbbreviations', () => {
    it('should return paginated abbreviations', async () => {
      const result = await AbbreviationService.getAllAbbreviations(1, 10);

      expect(result).toHaveProperty('abbreviations');
      expect(result).toHaveProperty('pagination');
      expect(Array.isArray(result.abbreviations)).toBe(true);
    });

    it('should filter by search query', async () => {
      const result = await AbbreviationService.getAllAbbreviations(1, 10, {
        search: 'TST',
      });

      expect(result.abbreviations.length).toBeGreaterThan(0);
    });
  });

  describe('searchByAbbreviation', () => {
    it('should find abbreviation by abbreviation string', async () => {
      const abbreviation =
        await AbbreviationService.searchByAbbreviation('TST');

      expect(abbreviation.abbreviation).toBe('TST');
      expect(abbreviation.source).toBe('Test Source');
    });
  });

  describe('updateAbbreviation', () => {
    it('should update abbreviation successfully', async () => {
      const updated = await AbbreviationService.updateAbbreviation(
        testAbbreviationId,
        { definition: 'Updated definition' },
        adminUserId
      );

      expect(updated.definition).toBe('Updated definition');
    });
  });

  describe('getAbbreviationStats', () => {
    it('should return abbreviation statistics', async () => {
      const stats = await AbbreviationService.getAbbreviationStats();

      expect(stats).toHaveProperty('total');
      expect(stats).toHaveProperty('primeClass');
      expect(stats).toHaveProperty('byCategory');
    });
  });
});
