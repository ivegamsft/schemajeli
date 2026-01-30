# Database Migration Plan

**Project:** SchemaJeli Database Schema Implementation  
**Date:** January 30, 2026  
**Status:** Ready for Execution

## Overview

This document outlines the step-by-step process for creating and deploying the SchemaJeli database schema using Prisma ORM.

## Prerequisites

- [x] PostgreSQL 14+ server running
- [x] Prisma schema defined (`prisma/schema.prisma`)
- [ ] Database connection string configured
- [ ] Prisma CLI installed (`npm install -D prisma`)
- [ ] pg_trgm extension available (for full-text search)

## Migration Steps

### Step 1: Install Dependencies (5 minutes)

```bash
cd src/backend

# Install Prisma
npm install -D prisma @prisma/client

# Install additional dependencies
npm install bcrypt jsonwebtoken
npm install -D @types/bcrypt @types/jsonwebtoken
```

### Step 2: Configure Database Connection (10 minutes)

Create `.env` file in `src/backend/`:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/schemajeli?schema=public"

# JWT
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_EXPIRES_IN="24h"

# App
NODE_ENV="development"
PORT=3000
```

**Security Notes:**
- Never commit `.env` to version control
- Use different secrets for each environment
- Rotate JWT secrets regularly in production

### Step 3: Initialize Prisma (5 minutes)

```bash
# Generate Prisma Client
npx prisma generate

# Verify schema is valid
npx prisma validate
```

Expected output:
```
✔ Prisma schema loaded from prisma/schema.prisma
✔ Environment variables loaded from .env
✔ The schema is valid 🎉
```

### Step 4: Create Initial Migration (10 minutes)

```bash
# Create migration for initial schema
npx prisma migrate dev --name init

# This will:
# 1. Create SQL migration files
# 2. Apply migration to database
# 3. Generate Prisma Client
```

Expected files created:
```
prisma/migrations/
  └── 20260130_init/
      └── migration.sql
```

### Step 5: Enable PostgreSQL Extensions (5 minutes)

Run manually or add to migration:

```sql
-- Enable trigram extension for fuzzy search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

Update migration file if needed:
```bash
npx prisma migrate resolve --applied 20260130_init
```

### Step 6: Create Seed Data Script (30 minutes)

Create `prisma/seed.ts`:

```typescript
import { PrismaClient, UserRole } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // 1. Create admin user
  const adminPassword = await bcrypt.hash('Admin@123', 10);
  const admin = await prisma.user.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      email: 'admin@schemajeli.dev',
      passwordHash: adminPassword,
      fullName: 'System Administrator',
      role: UserRole.ADMIN,
      isActive: true,
    },
  });
  console.log('✓ Created admin user:', admin.username);

  // 2. Create sample abbreviations
  const abbreviations = [
    { source: 'Identifier', abbreviation: 'ID', isPrimeClass: true, category: 'Common' },
    { source: 'Number', abbreviation: 'NBR', isPrimeClass: true, category: 'Common' },
    { source: 'Name', abbreviation: 'NME', isPrimeClass: true, category: 'Common' },
    { source: 'Code', abbreviation: 'CD', isPrimeClass: true, category: 'Common' },
    { source: 'Date', abbreviation: 'DT', isPrimeClass: true, category: 'Common' },
    { source: 'Amount', abbreviation: 'AMT', isPrimeClass: false, category: 'Financial' },
    { source: 'Quantity', abbreviation: 'QTY', isPrimeClass: false, category: 'Inventory' },
    { source: 'Address', abbreviation: 'ADDR', isPrimeClass: false, category: 'Location' },
  ];

  for (const abbr of abbreviations) {
    await prisma.abbreviation.upsert({
      where: { abbreviation: abbr.abbreviation },
      update: {},
      create: {
        ...abbr,
        createdById: admin.id,
      },
    });
  }
  console.log(`✓ Created ${abbreviations.length} abbreviations`);

  // 3. Create sample server
  const server = await prisma.server.upsert({
    where: { name: 'DEV-DB-01' },
    update: {},
    create: {
      name: 'DEV-DB-01',
      description: 'Development PostgreSQL Server',
      host: 'localhost',
      port: 5432,
      rdbmsType: 'POSTGRESQL',
      location: 'Local Development',
      createdById: admin.id,
    },
  });
  console.log('✓ Created sample server:', server.name);

  // 4. Create sample database
  const database = await prisma.database.create({
    data: {
      name: 'sample_app',
      description: 'Sample Application Database',
      purpose: 'Development and testing',
      serverId: server.id,
      createdById: admin.id,
    },
  });
  console.log('✓ Created sample database:', database.name);

  // 5. Create sample table
  const table = await prisma.table.create({
    data: {
      name: 'users',
      description: 'Application users table',
      tableType: 'TABLE',
      rowCountEstimate: 1000,
      databaseId: database.id,
      createdById: admin.id,
    },
  });
  console.log('✓ Created sample table:', table.name);

  // 6. Create sample elements (columns)
  const elements = [
    { name: 'user_id', dataType: 'UUID', isPrimaryKey: true, position: 1 },
    { name: 'username', dataType: 'VARCHAR(100)', isNullable: false, position: 2 },
    { name: 'email', dataType: 'VARCHAR(255)', isNullable: false, position: 3 },
    { name: 'created_at', dataType: 'TIMESTAMP', isNullable: false, position: 4 },
  ];

  for (const elem of elements) {
    await prisma.element.create({
      data: {
        ...elem,
        tableId: table.id,
        createdById: admin.id,
      },
    });
  }
  console.log(`✓ Created ${elements.length} table columns`);

  console.log('✅ Database seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

Update `package.json`:
```json
{
  "prisma": {
    "seed": "ts-node prisma/seed.ts"
  }
}
```

Run seed:
```bash
npx prisma db seed
```

### Step 7: Verify Database Schema (10 minutes)

```bash
# Open Prisma Studio to browse data
npx prisma studio

# Or connect with psql
psql postgresql://username:password@localhost:5432/schemajeli

# Verify tables exist
\dt

# Check row counts
SELECT 'users' as table_name, count(*) FROM users
UNION ALL
SELECT 'servers', count(*) FROM servers
UNION ALL
SELECT 'databases', count(*) FROM databases
UNION ALL
SELECT 'tables', count(*) FROM tables
UNION ALL
SELECT 'elements', count(*) FROM elements
UNION ALL
SELECT 'abbreviations', count(*) FROM abbreviations;
```

Expected output:
```
 table_name   | count
--------------+-------
 users        |     1
 servers      |     1
 databases    |     1
 tables       |     1
 elements     |     4
 abbreviations|     8
```

### Step 8: Test Relationships (15 minutes)

Create `test-queries.ts`:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function testQueries() {
  // Test 1: Get server with all databases and tables
  const serverWithData = await prisma.server.findFirst({
    include: {
      databases: {
        include: {
          tables: {
            include: {
              elements: true,
            },
          },
        },
      },
    },
  });
  console.log('Server hierarchy:', JSON.stringify(serverWithData, null, 2));

  // Test 2: Search abbreviations
  const searchResults = await prisma.abbreviation.findMany({
    where: {
      OR: [
        { source: { contains: 'Name', mode: 'insensitive' } },
        { abbreviation: { contains: 'NME', mode: 'insensitive' } },
      ],
    },
  });
  console.log('Search results:', searchResults);

  // Test 3: Get audit trail
  const auditTrail = await prisma.auditLog.findMany({
    include: {
      user: {
        select: {
          username: true,
          fullName: true,
        },
      },
    },
    orderBy: {
      createdAt: 'desc',
    },
    take: 10,
  });
  console.log('Recent audit logs:', auditTrail);
}

testQueries()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

Run tests:
```bash
npx ts-node test-queries.ts
```

### Step 9: Performance Optimization (20 minutes)

```sql
-- Analyze tables for query optimization
ANALYZE users;
ANALYZE servers;
ANALYZE databases;
ANALYZE tables;
ANALYZE elements;
ANALYZE abbreviations;
ANALYZE audit_logs;

-- Create additional indexes if needed
CREATE INDEX CONCURRENTLY idx_elements_data_type ON elements(data_type);
CREATE INDEX CONCURRENTLY idx_audit_logs_entity_action ON audit_logs(entity_type, action);

-- Verify index usage
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

### Step 10: Create Migration Rollback Plan (15 minutes)

Document rollback procedure in `ROLLBACK.md`:

```markdown
# Rollback Procedure

## Emergency Rollback

If migration fails or causes issues:

1. Stop application
2. Restore from backup (if available)
3. Roll back migration:
   ```bash
   npx prisma migrate resolve --rolled-back 20260130_init
   ```

## Partial Rollback

To undo specific changes:
```sql
-- Drop tables in reverse order
DROP TABLE IF EXISTS search_index;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS abbreviations;
DROP TABLE IF EXISTS elements;
DROP TABLE IF EXISTS tables;
DROP TABLE IF EXISTS databases;
DROP TABLE IF EXISTS servers;
DROP TABLE IF EXISTS users;

-- Drop enums
DROP TYPE IF EXISTS entity_type;
DROP TYPE IF EXISTS audit_action;
DROP TYPE IF EXISTS table_type;
DROP TYPE IF EXISTS rdbms_type;
DROP TYPE IF EXISTS entity_status;
DROP TYPE IF EXISTS user_role;
```
```

## Timeline Summary

| Step | Task | Duration | Status |
|------|------|----------|--------|
| 1 | Install dependencies | 5 min | ⏳ Pending |
| 2 | Configure database | 10 min | ⏳ Pending |
| 3 | Initialize Prisma | 5 min | ⏳ Pending |
| 4 | Create migration | 10 min | ⏳ Pending |
| 5 | Enable extensions | 5 min | ⏳ Pending |
| 6 | Create seed data | 30 min | ⏳ Pending |
| 7 | Verify schema | 10 min | ⏳ Pending |
| 8 | Test relationships | 15 min | ⏳ Pending |
| 9 | Optimize performance | 20 min | ⏳ Pending |
| 10 | Document rollback | 15 min | ⏳ Pending |
| **Total** | | **2 hours 5 min** | |

## Next Steps After Migration

1. **Update Backend Code**
   - Integrate Prisma Client into Express routes
   - Add error handling for database operations
   - Implement audit logging middleware

2. **Create API Documentation**
   - Document database schema in OpenAPI spec
   - Add schema diagrams to API docs

3. **Setup Testing**
   - Create test database
   - Write integration tests
   - Setup CI/CD database migrations

4. **Production Preparation**
   - Plan production database provisioning
   - Setup database backups
   - Configure monitoring and alerts

## Success Criteria

- ✅ All migrations run successfully
- ✅ Seed data populates correctly
- ✅ Relationships work as expected
- ✅ Indexes improve query performance
- ✅ No foreign key violations
- ✅ Audit logging captures changes
- ✅ Prisma Studio shows all data correctly
- ✅ Rollback procedure documented and tested

## Troubleshooting

### Issue: Migration fails with constraint error
**Solution:** Check foreign key relationships and ensure parent records exist

### Issue: Seed data fails
**Solution:** Verify admin user is created first, then dependent records

### Issue: Slow queries
**Solution:** Run ANALYZE on tables, check EXPLAIN output, add indexes

### Issue: Connection timeout
**Solution:** Increase connection pool size in Prisma schema:
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  pool_timeout = 60
}
```
