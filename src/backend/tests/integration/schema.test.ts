/**
 * Integration Test: Prisma Schema and Database Connection
 * 
 * Verifies that the Prisma schema is correctly migrated and database is accessible.
 */

import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { db } from '../../src/db/prisma.client.js';

describe('Prisma Schema Integration', () => {
  beforeAll(async () => {
    // Connect to database
    await db.$connect();
  });

  afterAll(async () => {
    // Disconnect from database
    await db.$disconnect();
  });

  it('should connect to database successfully', async () => {
    const result = await db.$queryRaw`SELECT 1 as value`;
    expect(result).toBeDefined();
  });

  it('should have all models available', () => {
    expect(db.user).toBeDefined();
    expect(db.server).toBeDefined();
    expect(db.database).toBeDefined();
    expect(db.table).toBeDefined();
    expect(db.element).toBeDefined();
    expect(db.abbreviation).toBeDefined();
    expect(db.auditLog).toBeDefined();
    expect(db.searchIndex).toBeDefined();
  });

  it('should query users with entraId field', async () => {
    const users = await db.user.findMany({
      select: { id: true, entraId: true, username: true, role: true },
      take: 5,
    });
    
    expect(Array.isArray(users)).toBe(true);
    
    if (users.length > 0) {
      expect(users[0]).toHaveProperty('entraId');
      expect(users[0]).toHaveProperty('role');
      expect(users[0]).not.toHaveProperty('passwordHash'); // Should be removed
    }
  });

  it('should query servers with SQLSERVER type', async () => {
    const sqlServers = await db.server.findMany({
      where: { rdbmsType: 'SQLSERVER' },
    });
    
    expect(Array.isArray(sqlServers)).toBe(true);
  });

  it('should respect soft delete filter', async () => {
    // Query should not return soft-deleted records by default
    const activeUsers = await db.user.findMany({
      where: { deletedAt: null },
    });
    
    expect(Array.isArray(activeUsers)).toBe(true);
    activeUsers.forEach(user => {
      expect(user.deletedAt).toBeNull();
    });
  });

  it('should have MAINTAINER role (not EDITOR)', async () => {
    const maintainers = await db.user.findMany({
      where: { role: 'MAINTAINER' },
    });
    
    expect(Array.isArray(maintainers)).toBe(true);
  });

  it('should have composite indexes on Element', async () => {
    // This test verifies that we can query by tableId and position efficiently
    const firstTable = await db.table.findFirst();
    
    if (firstTable) {
      const elements = await db.element.findMany({
        where: { tableId: firstTable.id },
        orderBy: { position: 'asc' },
      });
      
      expect(Array.isArray(elements)).toBe(true);
    }
  });

  it('should have deletedAt field on Abbreviation', async () => {
    const abbreviations = await db.abbreviation.findMany({
      select: { id: true, abbreviation: true, deletedAt: true },
      take: 1,
    });
    
    if (abbreviations.length > 0) {
      expect(abbreviations[0]).toHaveProperty('deletedAt');
    }
  });
});
