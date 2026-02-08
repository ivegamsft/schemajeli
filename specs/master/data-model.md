# Data Model: SchemaJeli

**Date**: 2026-01-29  
**Phase**: Phase 1 - Design & Contracts  
**Database**: PostgreSQL 15+  
**ORM**: Prisma

## Overview

SchemaJeli manages database metadata in a hierarchical structure with strict parent-child relationships:

```
Server → Database → Table → Element (Column)
```

All entities support:
- **Soft Deletes**: `deletedAt` timestamp (never physical deletion)
- **Audit Trail**: `createdAt`, `updatedAt`, `createdById`, `updatedById`
- **Foreign Key Constraints**: Enforced at database level
- **Cascade Behavior**: Soft delete propagates down hierarchy

## Entity Relationship Diagram

```
┌─────────────────┐
│      User       │  (Minimal record for Entra ID users)
│─────────────────│
│ id: UUID (PK)   │
│ email: string   │
│ name: string    │
│ role: enum      │
│ createdAt       │
│ updatedAt       │
│ deletedAt       │
└─────────────────┘
         │
         │ (createdBy/updatedBy FK)
         ▼
┌─────────────────┐
│     Server      │  (Database servers)
│─────────────────│
│ id: UUID (PK)   │
│ name: string    │
│ serverType: enum│  ← PostgreSQL, MySQL, Oracle, etc.
│ host: string    │
│ port: int       │
│ description     │
│ status: enum    │  ← ACTIVE, INACTIVE, MAINTENANCE
│ createdAt       │
│ updatedAt       │
│ deletedAt       │
│ createdById: FK │
│ updatedById: FK │
└─────────────────┘
         │
         │ (1:N)
         ▼
┌─────────────────┐
│    Database     │  (Databases within servers)
│─────────────────│
│ id: UUID (PK)   │
│ serverId: FK    │  ← Foreign key to Server
│ name: string    │
│ purpose: string │
│ status: enum    │
│ createdAt       │
│ updatedAt       │
│ deletedAt       │
│ createdById: FK │
│ updatedById: FK │
└─────────────────┘
         │
         │ (1:N)
         ▼
┌─────────────────┐
│      Table      │  (Tables/views within databases)
│─────────────────│
│ id: UUID (PK)   │
│ databaseId: FK  │  ← Foreign key to Database
│ name: string    │
│ tableType: enum │  ← TABLE, VIEW, MATERIALIZED_VIEW
│ rowCount: int   │
│ description     │
│ lastAnalyzed    │
│ createdAt       │
│ updatedAt       │
│ deletedAt       │
│ createdById: FK │
│ updatedById: FK │
└─────────────────┘
         │
         │ (1:N)
         ▼
┌─────────────────┐
│     Element     │  (Columns/fields within tables)
│─────────────────│
│ id: UUID (PK)   │
│ tableId: FK     │  ← Foreign key to Table
│ name: string    │
│ dataType: string│
│ length: int     │
│ precision: int  │
│ scale: int      │
│ isNullable: bool│
│ isPrimaryKey    │
│ isForeignKey    │
│ defaultValue    │
│ position: int   │
│ description     │
│ createdAt       │
│ updatedAt       │
│ deletedAt       │
│ createdById: FK │
│ updatedById: FK │
└─────────────────┘

┌─────────────────┐
│  Abbreviation   │  (Business term abbreviations - independent entity)
│─────────────────│
│ id: UUID (PK)   │
│ abbreviation    │
│ sourceTerm      │
│ definition      │
│ category        │
│ isPrimeClass    │
│ createdAt       │
│ updatedAt       │
│ deletedAt       │
│ createdById: FK │
│ updatedById: FK │
└─────────────────┘

┌─────────────────┐
│   AuditLog      │  (Audit trail for all modifications)
│─────────────────│
│ id: UUID (PK)   │
│ userId: FK      │
│ entityType      │
│ entityId: UUID  │
│ action: enum    │  ← CREATE, UPDATE, DELETE
│ beforeValue     │  ← JSON
│ afterValue      │  ← JSON
│ timestamp       │
│ ipAddress       │
└─────────────────┘
```

## Entity Definitions

### 1. User

**Purpose**: Minimal user record for foreign key references (audit trail). NOT used for authentication (Entra ID only).

**Fields**:
- `id`: UUID (Primary Key)
- `email`: string (unique, not null) - from Entra ID token
- `name`: string (not null) - display name from Entra ID
- `role`: enum (ADMIN, MAINTAINER, VIEWER) - from Entra ID app roles
- `createdAt`: timestamp (auto-generated)
- `updatedAt`: timestamp (auto-updated)
- `deletedAt`: timestamp (nullable, soft delete)

**Validation Rules**:
- Email must match pattern: `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`
- Role must be one of: ADMIN, MAINTAINER, VIEWER
- Name minimum length: 1 character

**Indexes**:
- PRIMARY KEY on `id`
- UNIQUE INDEX on `email` WHERE `deletedAt IS NULL`

**State Transitions**: N/A (user lifecycle managed by Entra ID)

---

### 2. Server

**Purpose**: Represents a database server (PostgreSQL, MySQL, Oracle, SQL Server, Informix, DB2).

**Fields**:
- `id`: UUID (Primary Key)
- `name`: string (unique, not null) - server display name
- `serverType`: enum (POSTGRESQL, MYSQL, ORACLE, SQL_SERVER, INFORMIX, DB2)
- `host`: string (not null) - hostname or IP address
- `port`: integer (not null) - port number (e.g., 5432, 3306, 1521)
- `description`: text (nullable) - server purpose/notes
- `status`: enum (ACTIVE, INACTIVE, MAINTENANCE) - operational status
- `createdAt`: timestamp (auto-generated)
- `updatedAt`: timestamp (auto-updated)
- `deletedAt`: timestamp (nullable, soft delete)
- `createdById`: UUID (FK to User, not null)
- `updatedById`: UUID (FK to User, not null)

**Validation Rules**:
- Name: 1-100 characters, unique per serverType
- Host: valid hostname or IPv4/IPv6 address
- Port: 1-65535
- Status default: ACTIVE

**Relationships**:
- **1:N with Database**: One server has many databases
- **Cascade Soft Delete**: Deleting server soft-deletes all child databases

**Indexes**:
- PRIMARY KEY on `id`
- UNIQUE INDEX on `(name, serverType)` WHERE `deletedAt IS NULL`
- INDEX on `status` (for filtering active servers)
- INDEX on `deletedAt` (for soft delete queries)

**State Transitions**:
```
ACTIVE ←→ MAINTENANCE ←→ INACTIVE
```

---

### 3. Database

**Purpose**: Represents a database within a server.

**Fields**:
- `id`: UUID (Primary Key)
- `serverId`: UUID (FK to Server, not null)
- `name`: string (not null) - database name
- `purpose`: text (nullable) - database purpose/description
- `status`: enum (ACTIVE, INACTIVE) - operational status
- `createdAt`: timestamp (auto-generated)
- `updatedAt`: timestamp (auto-updated)
- `deletedAt`: timestamp (nullable, soft delete)
- `createdById`: UUID (FK to User, not null)
- `updatedById`: UUID (FK to User, not null)

**Validation Rules**:
- Name: 1-100 characters, unique within server
- ServerId must reference existing, non-deleted server

**Relationships**:
- **N:1 with Server**: Many databases belong to one server
- **1:N with Table**: One database has many tables
- **Cascade Soft Delete**: Deleting database soft-deletes all child tables

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `serverId` REFERENCES Server(id)
- UNIQUE INDEX on `(serverId, name)` WHERE `deletedAt IS NULL`
- INDEX on `status`
- INDEX on `deletedAt`

**State Transitions**:
```
ACTIVE ←→ INACTIVE
```

---

### 4. Table

**Purpose**: Represents a table, view, or materialized view within a database.

**Fields**:
- `id`: UUID (Primary Key)
- `databaseId`: UUID (FK to Database, not null)
- `name`: string (not null) - table/view name
- `tableType`: enum (TABLE, VIEW, MATERIALIZED_VIEW)
- `rowCount`: integer (nullable) - estimated row count
- `description`: text (nullable) - table purpose/notes
- `lastAnalyzed`: timestamp (nullable) - last time schema was analyzed
- `createdAt`: timestamp (auto-generated)
- `updatedAt`: timestamp (auto-updated)
- `deletedAt`: timestamp (nullable, soft delete)
- `createdById`: UUID (FK to User, not null)
- `updatedById`: UUID (FK to User, not null)

**Validation Rules**:
- Name: 1-100 characters, unique within database
- DatabaseId must reference existing, non-deleted database
- RowCount: ≥0 if provided
- TableType default: TABLE

**Relationships**:
- **N:1 with Database**: Many tables belong to one database
- **1:N with Element**: One table has many elements (columns)
- **Cascade Soft Delete**: Deleting table soft-deletes all child elements

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `databaseId` REFERENCES Database(id)
- UNIQUE INDEX on `(databaseId, name)` WHERE `deletedAt IS NULL`
- INDEX on `tableType`
- INDEX on `deletedAt`
- GIN INDEX on `search_vector` (for full-text search)

**State Transitions**: N/A (operational status tracked at database level)

---

### 5. Element

**Purpose**: Represents a column/field within a table or view.

**Fields**:
- `id`: UUID (Primary Key)
- `tableId`: UUID (FK to Table, not null)
- `name`: string (not null) - column name
- `dataType`: string (not null) - data type (e.g., VARCHAR, INTEGER, TIMESTAMP)
- `length`: integer (nullable) - for character types (VARCHAR(100))
- `precision`: integer (nullable) - for numeric types (DECIMAL(10,2))
- `scale`: integer (nullable) - for numeric types (DECIMAL(10,2))
- `isNullable`: boolean (not null, default: true) - allows NULL values
- `isPrimaryKey`: boolean (not null, default: false)
- `isForeignKey`: boolean (not null, default: false)
- `defaultValue`: string (nullable) - default value expression
- `position`: integer (not null) - column ordinal position (1-based)
- `description`: text (nullable) - column purpose/notes
- `createdAt`: timestamp (auto-generated)
- `updatedAt`: timestamp (auto-updated)
- `deletedAt`: timestamp (nullable, soft delete)
- `createdById`: UUID (FK to User, not null)
- `updatedById`: UUID (FK to User, not null)

**Validation Rules**:
- Name: 1-100 characters, unique within table
- TableId must reference existing, non-deleted table
- DataType: not empty
- Length, precision, scale: ≥0 if provided
- Position: ≥1, unique within table

**Relationships**:
- **N:1 with Table**: Many elements belong to one table

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `tableId` REFERENCES Table(id)
- UNIQUE INDEX on `(tableId, name)` WHERE `deletedAt IS NULL`
- UNIQUE INDEX on `(tableId, position)` WHERE `deletedAt IS NULL`
- INDEX on `isPrimaryKey` (for quick PK lookups)
- INDEX on `isForeignKey` (for relationship queries)
- INDEX on `deletedAt`
- GIN INDEX on `search_vector` (for full-text search)

**State Transitions**: N/A

---

### 6. Abbreviation

**Purpose**: Business term abbreviations and definitions (independent entity, not part of server hierarchy).

**Fields**:
- `id`: UUID (Primary Key)
- `abbreviation`: string (unique, not null) - abbreviated term
- `sourceTerm`: string (not null) - full source term
- `definition`: text (not null) - detailed definition
- `category`: string (nullable) - categorization (e.g., "Technical", "Business")
- `isPrimeClass`: boolean (not null, default: false) - prime class designation
- `createdAt`: timestamp (auto-generated)
- `updatedAt`: timestamp (auto-updated)
- `deletedAt`: timestamp (nullable, soft delete)
- `createdById`: UUID (FK to User, not null)
- `updatedById`: UUID (FK to User, not null)

**Validation Rules**:
- Abbreviation: 1-50 characters, unique
- SourceTerm: 1-200 characters
- Definition: 1-2000 characters

**Relationships**: None (independent entity)

**Indexes**:
- PRIMARY KEY on `id`
- UNIQUE INDEX on `abbreviation` WHERE `deletedAt IS NULL`
- INDEX on `category`
- INDEX on `isPrimeClass`
- INDEX on `deletedAt`
- GIN INDEX on `search_vector` (for full-text search)

**State Transitions**: N/A

---

### 7. AuditLog

**Purpose**: Immutable audit trail for all entity modifications (create, update, delete).

**Fields**:
- `id`: UUID (Primary Key)
- `userId`: UUID (FK to User, not null) - who performed the action
- `entityType`: enum (SERVER, DATABASE, TABLE, ELEMENT, ABBREVIATION)
- `entityId`: UUID (not null) - which entity was modified
- `action`: enum (CREATE, UPDATE, DELETE)
- `beforeValue`: JSONB (nullable) - entity state before change
- `afterValue`: JSONB (not null) - entity state after change
- `timestamp`: timestamp (auto-generated, not null)
- `ipAddress`: string (nullable) - client IP address

**Validation Rules**:
- All fields immutable after creation (INSERT only, no UPDATE/DELETE)
- BeforeValue: null for CREATE actions
- AfterValue: required for all actions

**Relationships**:
- **N:1 with User**: Many audit logs per user

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `userId` REFERENCES User(id)
- INDEX on `(entityType, entityId)` (for entity history queries)
- INDEX on `timestamp` (for temporal queries)
- INDEX on `userId` (for user activity queries)

**Retention**: 7 years per compliance requirements

---

## Prisma Schema

```prisma
// This is a reference schema. Actual implementation in src/backend/prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum Role {
  ADMIN
  MAINTAINER
  VIEWER
}

enum ServerType {
  POSTGRESQL
  MYSQL
  ORACLE
  SQL_SERVER
  INFORMIX
  DB2
}

enum ServerStatus {
  ACTIVE
  INACTIVE
  MAINTENANCE
}

enum DatabaseStatus {
  ACTIVE
  INACTIVE
}

enum TableType {
  TABLE
  VIEW
  MATERIALIZED_VIEW
}

enum AuditAction {
  CREATE
  UPDATE
  DELETE
}

enum AuditEntityType {
  SERVER
  DATABASE
  TABLE
  ELEMENT
  ABBREVIATION
}

model User {
  id        String    @id @default(uuid())
  email     String    @unique
  name      String
  role      Role
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  deletedAt DateTime?

  // Relations
  createdServers      Server[]      @relation("ServerCreatedBy")
  updatedServers      Server[]      @relation("ServerUpdatedBy")
  createdDatabases    Database[]    @relation("DatabaseCreatedBy")
  updatedDatabases    Database[]    @relation("DatabaseUpdatedBy")
  createdTables       Table[]       @relation("TableCreatedBy")
  updatedTables       Table[]       @relation("TableUpdatedBy")
  createdElements     Element[]     @relation("ElementCreatedBy")
  updatedElements     Element[]     @relation("ElementUpdatedBy")
  createdAbbreviations Abbreviation[] @relation("AbbreviationCreatedBy")
  updatedAbbreviations Abbreviation[] @relation("AbbreviationUpdatedBy")
  auditLogs           AuditLog[]

  @@index([email])
  @@index([deletedAt])
}

model Server {
  id          String       @id @default(uuid())
  name        String
  serverType  ServerType
  host        String
  port        Int
  description String?
  status      ServerStatus @default(ACTIVE)
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt
  deletedAt   DateTime?
  createdById String
  updatedById String

  // Relations
  createdBy User       @relation("ServerCreatedBy", fields: [createdById], references: [id])
  updatedBy User       @relation("ServerUpdatedBy", fields: [updatedById], references: [id])
  databases Database[]

  @@unique([name, serverType])
  @@index([status])
  @@index([deletedAt])
}

model Database {
  id          String         @id @default(uuid())
  serverId    String
  name        String
  purpose     String?
  status      DatabaseStatus @default(ACTIVE)
  createdAt   DateTime       @default(now())
  updatedAt   DateTime       @updatedAt
  deletedAt   DateTime?
  createdById String
  updatedById String

  // Relations
  server    Server  @relation(fields: [serverId], references: [id])
  createdBy User    @relation("DatabaseCreatedBy", fields: [createdById], references: [id])
  updatedBy User    @relation("DatabaseUpdatedBy", fields: [updatedById], references: [id])
  tables    Table[]

  @@unique([serverId, name])
  @@index([status])
  @@index([deletedAt])
}

model Table {
  id           String     @id @default(uuid())
  databaseId   String
  name         String
  tableType    TableType  @default(TABLE)
  rowCount     Int?
  description  String?
  lastAnalyzed DateTime?
  createdAt    DateTime   @default(now())
  updatedAt    DateTime   @updatedAt
  deletedAt    DateTime?
  createdById  String
  updatedById  String

  // Relations
  database  Database  @relation(fields: [databaseId], references: [id])
  createdBy User      @relation("TableCreatedBy", fields: [createdById], references: [id])
  updatedBy User      @relation("TableUpdatedBy", fields: [updatedById], references: [id])
  elements  Element[]

  @@unique([databaseId, name])
  @@index([tableType])
  @@index([deletedAt])
}

model Element {
  id           String    @id @default(uuid())
  tableId      String
  name         String
  dataType     String
  length       Int?
  precision    Int?
  scale        Int?
  isNullable   Boolean   @default(true)
  isPrimaryKey Boolean   @default(false)
  isForeignKey Boolean   @default(false)
  defaultValue String?
  position     Int
  description  String?
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  deletedAt    DateTime?
  createdById  String
  updatedById  String

  // Relations
  table     Table @relation(fields: [tableId], references: [id])
  createdBy User  @relation("ElementCreatedBy", fields: [createdById], references: [id])
  updatedBy User  @relation("ElementUpdatedBy", fields: [updatedById], references: [id])

  @@unique([tableId, name])
  @@unique([tableId, position])
  @@index([isPrimaryKey])
  @@index([isForeignKey])
  @@index([deletedAt])
}

model Abbreviation {
  id           String    @id @default(uuid())
  abbreviation String    @unique
  sourceTerm   String
  definition   String
  category     String?
  isPrimeClass Boolean   @default(false)
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  deletedAt    DateTime?
  createdById  String
  updatedById  String

  // Relations
  createdBy User @relation("AbbreviationCreatedBy", fields: [createdById], references: [id])
  updatedBy User @relation("AbbreviationUpdatedBy", fields: [updatedById], references: [id])

  @@index([category])
  @@index([isPrimeClass])
  @@index([deletedAt])
}

model AuditLog {
  id          String            @id @default(uuid())
  userId      String
  entityType  AuditEntityType
  entityId    String
  action      AuditAction
  beforeValue Json?
  afterValue  Json
  timestamp   DateTime          @default(now())
  ipAddress   String?

  // Relations
  user User @relation(fields: [userId], references: [id])

  @@index([entityType, entityId])
  @@index([timestamp])
  @@index([userId])
}
```

## Soft Delete Implementation

### Prisma Middleware (Global Soft Delete)

```typescript
// src/backend/src/utils/prisma-soft-delete.middleware.ts
import { Prisma } from '@prisma/client';

export function softDeleteMiddleware(): Prisma.Middleware {
  return async (params, next) => {
    // Intercept delete operations
    if (params.action === 'delete') {
      params.action = 'update';
      params.args['data'] = { deletedAt: new Date() };
    }

    // Intercept deleteMany operations
    if (params.action === 'deleteMany') {
      params.action = 'updateMany';
      if (params.args.data !== undefined) {
        params.args.data['deletedAt'] = new Date();
      } else {
        params.args['data'] = { deletedAt: new Date() };
      }
    }

    // Filter out soft-deleted records in queries
    if (params.action === 'findUnique' || params.action === 'findFirst') {
      params.args.where = { ...params.args.where, deletedAt: null };
    }

    if (params.action === 'findMany') {
      if (params.args.where !== undefined) {
        if (params.args.where.deletedAt === undefined) {
          params.args.where['deletedAt'] = null;
        }
      } else {
        params.args['where'] = { deletedAt: null };
      }
    }

    return next(params);
  };
}
```

## Cascade Soft Delete Behavior

### Server Deletion
When a server is soft-deleted:
1. Set `server.deletedAt = now()`
2. For each child database: Set `database.deletedAt = now()`
3. For each child table: Set `table.deletedAt = now()`
4. For each child element: Set `element.deletedAt = now()`
5. Create AuditLog entry for each entity

### Database Deletion
When a database is soft-deleted:
1. Set `database.deletedAt = now()`
2. For each child table: Set `table.deletedAt = now()`
3. For each child element: Set `element.deletedAt = now()`
4. Create AuditLog entry for each entity

### Table Deletion
When a table is soft-deleted:
1. Set `table.deletedAt = now()`
2. For each child element: Set `element.deletedAt = now()`
3. Create AuditLog entry for each entity

### Element Deletion
When an element is soft-deleted:
1. Set `element.deletedAt = now()`
2. Create AuditLog entry

## Full-Text Search Configuration

### Search Vector Fields

Add `search_vector` column to searchable entities:

```sql
-- Add search vector columns
ALTER TABLE "Server" ADD COLUMN search_vector tsvector;
ALTER TABLE "Database" ADD COLUMN search_vector tsvector;
ALTER TABLE "Table" ADD COLUMN search_vector tsvector;
ALTER TABLE "Element" ADD COLUMN search_vector tsvector;
ALTER TABLE "Abbreviation" ADD COLUMN search_vector tsvector;

-- Create GIN indexes for fast search
CREATE INDEX server_search_idx ON "Server" USING GIN (search_vector);
CREATE INDEX database_search_idx ON "Database" USING GIN (search_vector);
CREATE INDEX table_search_idx ON "Table" USING GIN (search_vector);
CREATE INDEX element_search_idx ON "Element" USING GIN (search_vector);
CREATE INDEX abbreviation_search_idx ON "Abbreviation" USING GIN (search_vector);

-- Trigger to update search vectors on insert/update
CREATE TRIGGER server_search_vector_update
BEFORE INSERT OR UPDATE ON "Server"
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', name, description);

CREATE TRIGGER database_search_vector_update
BEFORE INSERT OR UPDATE ON "Database"
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', name, purpose);

CREATE TRIGGER table_search_vector_update
BEFORE INSERT OR UPDATE ON "Table"
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', name, description);

CREATE TRIGGER element_search_vector_update
BEFORE INSERT OR UPDATE ON "Element"
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', name, description);

CREATE TRIGGER abbreviation_search_vector_update
BEFORE INSERT OR UPDATE ON "Abbreviation"
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', abbreviation, sourceTerm, definition);
```

## Migration Strategy

### From Legacy Informix to PostgreSQL

1. **User Migration**: Create minimal user records from legacy user table
2. **Server Migration**: Map Informix server metadata to Server table
3. **Database Migration**: Map database metadata to Database table
4. **Table Migration**: Map table metadata to Table table (handle VIEWs, MATERIALIZED_VIEWs)
5. **Element Migration**: Map column metadata to Element table (data type mapping required)
6. **Abbreviation Migration**: Direct copy from legacy abbreviation table

**Data Type Mapping** (Informix → PostgreSQL):
- `SERIAL` → `INTEGER`
- `CHAR(n)` → `VARCHAR(n)`
- `VARCHAR(n,m)` → `VARCHAR(n)`
- `DATETIME YEAR TO SECOND` → `TIMESTAMP`
- `MONEY` → `DECIMAL(19,2)`
- `BYTE` → `BYTEA`

## Performance Optimizations

### Indexes
- All foreign keys have indexes (automatic in PostgreSQL)
- Composite unique indexes for uniqueness constraints
- GIN indexes for full-text search
- Partial indexes on `deletedAt IS NULL` for soft delete queries

### Query Patterns
- Use `include` for eager loading related entities (avoid N+1)
- Paginate large result sets (limit 25-200 per page)
- Use `select` to fetch only required fields (reduce payload size)
- Cache frequently accessed reference data (server types, roles)

### Database Configuration
- Connection pool size: 20-50 connections
- Statement timeout: 30 seconds
- Idle transaction timeout: 5 minutes
- Max locks per transaction: 10000

## Data Integrity Constraints

### Foreign Key Constraints
All foreign keys enforce referential integrity:
- `ON DELETE RESTRICT` (soft delete via middleware, not cascade)
- `ON UPDATE CASCADE` (propagate ID changes if UUID ever changes)

### Check Constraints
- Port number: 1-65535
- Row count: ≥0
- Position: ≥1
- Length, precision, scale: ≥0

### Unique Constraints
- User email (where deletedAt IS NULL)
- Server (name, serverType) (where deletedAt IS NULL)
- Database (serverId, name) (where deletedAt IS NULL)
- Table (databaseId, name) (where deletedAt IS NULL)
- Element (tableId, name) (where deletedAt IS NULL)
- Element (tableId, position) (where deletedAt IS NULL)
- Abbreviation (abbreviation) (where deletedAt IS NULL)

## Audit Trail Details

### Captured Information
- **Who**: userId (from JWT token)
- **What**: entityType + entityId
- **When**: timestamp (auto-generated)
- **Where**: ipAddress (from request)
- **Before**: beforeValue (JSON snapshot before change)
- **After**: afterValue (JSON snapshot after change)

### Privacy Considerations
- No passwords stored (Entra ID only)
- IP addresses logged for security (GDPR compliant with legitimate interest)
- Audit logs immutable (insert-only, no updates/deletes)
- Retention: 7 years per compliance requirements

## Phase 1 Data Model Conclusion

**Status**: ✅ **COMPLETE**

Data model defines all entities, relationships, validation rules, and indexes. Prisma schema is production-ready with soft delete middleware, audit trail, and full-text search configuration.

**Next Steps**: Generate API contracts (OpenAPI specification) from data model.
