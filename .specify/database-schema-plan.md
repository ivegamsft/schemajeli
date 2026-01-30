# Database Schema Design Plan - P-1.2.1

**Task:** Create detailed database schema design  
**Phase:** 1.2 - Design & Specification  
**Duration:** 2.5 days  
**Assignee:** Backend Lead  
**Status:** In Progress

## Objectives

1. Design complete PostgreSQL schema for SchemaJeli
2. Define all tables, columns, relationships, and constraints
3. Create Entity-Relationship Diagram (ERD)
4. Plan indexes for performance optimization
5. Create Prisma schema definition
6. Generate migration scripts

## Database Tables

### Core Entity Tables

#### 1. **users** - User accounts and authentication
- `id` (UUID, PK)
- `username` (String, unique, indexed)
- `email` (String, unique, indexed)
- `password_hash` (String)
- `full_name` (String)
- `role` (Enum: ADMIN, EDITOR, VIEWER)
- `is_active` (Boolean, default: true)
- `last_login_at` (DateTime, nullable)
- `created_at` (DateTime, default: now)
- `updated_at` (DateTime, auto-update)

#### 2. **servers** - Database servers
- `id` (UUID, PK)
- `name` (String, unique, indexed)
- `description` (Text, nullable)
- `host` (String)
- `port` (Int, nullable)
- `rdbms_type` (Enum: POSTGRESQL, MYSQL, ORACLE, DB2, INFORMIX)
- `location` (String, nullable)
- `status` (Enum: ACTIVE, INACTIVE, ARCHIVED)
- `created_by_id` (UUID, FK → users)
- `created_at` (DateTime)
- `updated_at` (DateTime)
- `deleted_at` (DateTime, nullable) // Soft delete

#### 3. **databases** - Databases on servers
- `id` (UUID, PK)
- `server_id` (UUID, FK → servers)
- `name` (String, indexed)
- `description` (Text, nullable)
- `purpose` (String, nullable)
- `status` (Enum: ACTIVE, INACTIVE, ARCHIVED)
- `created_by_id` (UUID, FK → users)
- `created_at` (DateTime)
- `updated_at` (DateTime)
- `deleted_at` (DateTime, nullable)
- **Unique:** (server_id, name)

#### 4. **tables** - Tables in databases
- `id` (UUID, PK)
- `database_id` (UUID, FK → databases)
- `name` (String, indexed)
- `description` (Text, nullable)
- `table_type` (Enum: TABLE, VIEW, MATERIALIZED_VIEW)
- `row_count_estimate` (Int, nullable)
- `status` (Enum: ACTIVE, INACTIVE, ARCHIVED)
- `created_by_id` (UUID, FK → users)
- `created_at` (DateTime)
- `updated_at` (DateTime)
- `deleted_at` (DateTime, nullable)
- **Unique:** (database_id, name)

#### 5. **elements** - Columns/fields in tables
- `id` (UUID, PK)
- `table_id` (UUID, FK → tables)
- `name` (String, indexed)
- `description` (Text, nullable)
- `data_type` (String)
- `length` (Int, nullable)
- `precision` (Int, nullable)
- `scale` (Int, nullable)
- `is_nullable` (Boolean, default: true)
- `is_primary_key` (Boolean, default: false)
- `is_foreign_key` (Boolean, default: false)
- `default_value` (String, nullable)
- `position` (Int) // Column order in table
- `created_by_id` (UUID, FK → users)
- `created_at` (DateTime)
- `updated_at` (DateTime)
- `deleted_at` (DateTime, nullable)
- **Unique:** (table_id, name)

### Reference Data Tables

#### 6. **abbreviations** - Standard abbreviations
- `id` (UUID, PK)
- `source` (String, indexed) // Full word/phrase
- `abbreviation` (String, unique, indexed)
- `definition` (Text, nullable)
- `is_prime_class` (Boolean, default: false)
- `category` (String, nullable, indexed)
- `created_by_id` (UUID, FK → users)
- `created_at` (DateTime)
- `updated_at` (DateTime)

### Audit & Tracking Tables

#### 7. **audit_logs** - Change tracking for all entities
- `id` (UUID, PK)
- `entity_type` (Enum: SERVER, DATABASE, TABLE, ELEMENT, ABBREVIATION, USER)
- `entity_id` (UUID, indexed)
- `action` (Enum: CREATE, UPDATE, DELETE, RESTORE)
- `user_id` (UUID, FK → users)
- `changes` (JSON) // Old and new values
- `ip_address` (String, nullable)
- `user_agent` (String, nullable)
- `created_at` (DateTime, indexed)

### Search & Metadata Tables

#### 8. **search_index** - Full-text search optimization
- `id` (UUID, PK)
- `entity_type` (Enum)
- `entity_id` (UUID, indexed)
- `content` (Text) // Searchable content
- `metadata` (JSON) // Additional search metadata
- `created_at` (DateTime)
- `updated_at` (DateTime)

## Relationships

```
users (1) ──< (many) servers [created_by]
users (1) ──< (many) databases [created_by]
users (1) ──< (many) tables [created_by]
users (1) ──< (many) elements [created_by]
users (1) ──< (many) abbreviations [created_by]
users (1) ──< (many) audit_logs [user]

servers (1) ──< (many) databases
databases (1) ──< (many) tables
tables (1) ──< (many) elements
```

## Indexes Strategy

### Primary Indexes (Automatic)
- All `id` fields (UUID primary keys)
- All unique constraints

### Search Performance Indexes
- `users.username` (unique)
- `users.email` (unique)
- `servers.name` (unique)
- `abbreviations.source` (B-tree)
- `abbreviations.abbreviation` (unique)
- `search_index.entity_id` (B-tree)

### Lookup Performance Indexes
- `databases.(server_id, name)` (composite unique)
- `tables.(database_id, name)` (composite unique)
- `elements.(table_id, name)` (composite unique)
- `audit_logs.entity_id` (B-tree)
- `audit_logs.created_at` (B-tree for time-range queries)

### Full-Text Search Indexes
- `search_index.content` (GIN index for PostgreSQL)
- `servers.description` (optional GIN/trgm)
- `databases.description` (optional GIN/trgm)
- `tables.description` (optional GIN/trgm)
- `elements.description` (optional GIN/trgm)

## Constraints & Validations

### Business Rules
1. **Soft Delete:** All core entities use `deleted_at` timestamp for soft deletion
2. **Hierarchical Integrity:** Cannot delete server/database/table if children exist
3. **Audit Trail:** All changes logged in `audit_logs` table
4. **Username Format:** Alphanumeric + underscore only
5. **Email Validation:** Standard RFC 5322 format
6. **Name Uniqueness:** Server, database, table, element names unique within parent

### Database Constraints
- Foreign key cascades: RESTRICT (prevent orphans)
- NOT NULL constraints on required fields
- CHECK constraints on enums
- Unique constraints on natural keys

## Migration Strategy

### Phase 1: Schema Creation
1. Create `users` table
2. Create `servers` table (depends on users)
3. Create `databases` table (depends on servers)
4. Create `tables` table (depends on databases)
5. Create `elements` table (depends on tables)
6. Create `abbreviations` table
7. Create `audit_logs` table
8. Create `search_index` table

### Phase 2: Indexes & Optimizations
1. Create all B-tree indexes
2. Create full-text search indexes
3. Analyze and vacuum tables

### Phase 3: Seed Data
1. Insert admin user
2. Insert sample abbreviations
3. Insert test data for development

## Data Migration from Legacy System

### Source: Informix/DB2 Legacy Database
- Legacy table names may differ (need mapping)
- Legacy user data (hash passwords)
- Legacy server/database/table metadata
- Legacy abbreviation dictionary

### Migration Scripts Required
1. Extract schema from legacy Informix database
2. Transform data to match new schema
3. Load data into PostgreSQL
4. Validate data integrity
5. Create search index entries

## Performance Considerations

### Expected Data Volumes
- Servers: ~50-100 entries
- Databases: ~500-1000 entries
- Tables: ~10,000-50,000 entries
- Elements: ~100,000-500,000 entries
- Abbreviations: ~5,000-10,000 entries
- Audit logs: Growing (partition by date)

### Optimization Strategies
1. **Partitioning:** `audit_logs` partitioned by month
2. **Archiving:** Soft-deleted records archived after 90 days
3. **Caching:** Redis cache for frequently accessed metadata
4. **Connection Pooling:** PgBouncer for connection management
5. **Read Replicas:** For reporting queries

## Deliverables

- [x] Database schema plan document (this file)
- [ ] Prisma schema file (`prisma/schema.prisma`)
- [ ] ERD diagram (Mermaid format)
- [ ] Migration scripts (Prisma migrations)
- [ ] Seed data scripts
- [ ] Data migration scripts (legacy → new)
- [ ] Index optimization documentation
- [ ] Performance testing plan

## Timeline

- **Day 1 Morning:** Prisma schema definition
- **Day 1 Afternoon:** ERD creation and review
- **Day 2 Morning:** Migration scripts and seed data
- **Day 2 Afternoon:** Index strategy and optimization
- **Day 3 Morning:** Data migration scripts (legacy)
- **Day 3 Afternoon:** Testing and validation

## Success Criteria

- ✅ All tables defined with proper relationships
- ✅ Prisma migrations generate without errors
- ✅ Foreign key constraints enforce data integrity
- ✅ Indexes improve query performance (verified by EXPLAIN)
- ✅ Seed data populates successfully
- ✅ Legacy data migration tested successfully
- ✅ Audit logging captures all entity changes
- ✅ Soft delete functionality works correctly
