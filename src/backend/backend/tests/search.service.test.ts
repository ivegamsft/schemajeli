import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { SearchService } from '../src/services/search.service';
import { ServerService } from '../src/services/server.service';
import { AbbreviationService } from '../src/services/abbreviation.service';
import prisma from '../src/config/database';
import bcrypt from 'bcrypt';

describe('SearchService', () => {
  let adminUserId: string;
  let testServerId: string;
  let testAbbreviationId: string;

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash('TestPassword123', 10);
    const admin = await prisma.user.create({
      data: {
        username: 'search_test_admin',
        email: 'search_admin@test.com',
        passwordHash,
        fullName: 'Search Test Admin',
        role: 'ADMIN',
        isActive: true,
      },
    });
    adminUserId = admin.id;

    const server = await ServerService.createServer(
      {
        name: 'SEARCH-TEST-SERVER',
        host: 'search.example.com',
        rdbmsType: 'POSTGRESQL',
        description: 'Server for search testing',
      },
      adminUserId
    );
    testServerId = server.id;

    const abbreviation = await AbbreviationService.createAbbreviation(
      {
        source: 'Search Test',
        abbreviation: 'SRCH',
        definition: 'Search functionality test',
        category: 'Testing',
      },
      adminUserId
    );
    testAbbreviationId = abbreviation.id;
  });

  afterAll(async () => {
    await prisma.auditLog.deleteMany({ where: { entityId: testServerId } });
    await prisma.server.delete({ where: { id: testServerId } });
    await prisma.auditLog.deleteMany({
      where: { entityId: testAbbreviationId },
    });
    await prisma.abbreviation.delete({ where: { id: testAbbreviationId } });
    await prisma.auditLog.deleteMany({ where: { userId: adminUserId } });
    await prisma.user.delete({ where: { id: adminUserId } });
    await prisma.$disconnect();
  });

  describe('searchAll', () => {
    it('should search across all entity types', async () => {
      const results = await SearchService.searchAll('SEARCH', 10);

      expect(results).toHaveProperty('servers');
      expect(results).toHaveProperty('databases');
      expect(results).toHaveProperty('tables');
      expect(results).toHaveProperty('elements');
      expect(results).toHaveProperty('abbreviations');
      expect(results).toHaveProperty('totalResults');
    });

    it('should find servers in search results', async () => {
      const results = await SearchService.searchAll('SEARCH-TEST', 10);

      expect(results.servers.length).toBeGreaterThan(0);
      expect(results.servers[0].name).toContain('SEARCH');
    });
  });

  describe('searchServers', () => {
    it('should search servers by query', async () => {
      const servers = await SearchService.searchServers('SEARCH', 10);

      expect(Array.isArray(servers)).toBe(true);
      expect(servers.length).toBeGreaterThan(0);
    });
  });

  describe('searchAbbreviations', () => {
    it('should search abbreviations by query', async () => {
      const abbreviations = await SearchService.searchAbbreviations('SRCH', 10);

      expect(Array.isArray(abbreviations)).toBe(true);
      expect(abbreviations.length).toBeGreaterThan(0);
      expect(abbreviations[0].abbreviation).toBe('SRCH');
    });
  });

  describe('advancedSearch', () => {
    it('should perform advanced search on servers', async () => {
      const results = await SearchService.advancedSearch(
        'server',
        'SEARCH',
        {},
        10
      );

      expect(Array.isArray(results)).toBe(true);
    });

    it('should apply filters in advanced search', async () => {
      const results = await SearchService.advancedSearch(
        'server',
        'SEARCH',
        { rdbmsType: 'POSTGRESQL' },
        10
      );

      expect(Array.isArray(results)).toBe(true);
    });
  });
});
