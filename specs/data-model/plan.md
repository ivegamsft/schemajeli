# Implementation Plan: Data Model

**Branch**: `data-model` | **Date**: 2026-02-08 | **Spec**: [README.md](./README.md)
**Input**: Feature specification from `/specs/data-model/README.md`

**Note**: This plan documents the database schema and entity model design for SchemaJeli - a comprehensive enterprise metadata management system supporting ~500 servers, ~2K databases, ~50K tables, and ~1M column records.

## Summary

This plan establishes the core data model for SchemaJeli, defining the relational hierarchy (Server → Database → Table → Element) with comprehensive audit logging, full-text search capability, and Azure Entra ID authentication. The schema implements soft deletes, optimistic locking, role-based access control (ADMIN/MAINTAINER/VIEWER), and comprehensive indexing strategies for high-cardinality relationships. Migration tasks include: (1) Add `entraId` field to User model, (2) Remove legacy `passwordHash` field, (3) Rename `EDITOR` role to `MAINTAINER`, (4) Add `SQLSERVER` to RdbmsType enum, (5) Add `deletedAt` to User and Abbreviation models.

## Technical Context

**Language/Version**: TypeScript 5.x with Node.js 18+ LTS  
**Primary Dependencies**: Prisma ORM 5.20+, Express.js 4.x, @azure/msal-node 3.5+, bcrypt 5.x (for legacy migration)  
**Storage**: PostgreSQL 14+ with Prisma schema, connection pooling (minimum 20 connections)  
**Testing**: Vitest for unit/integration tests, 70% minimum coverage requirement  
**Target Platform**: Linux/Docker containers, Kubernetes (AKS) orchestration  
**Project Type**: Web application (backend/frontend separation with REST API)  
**Performance Goals**: Simple queries <100ms, complex searches <500ms p95, 100+ concurrent users  
**Constraints**: <500ms p95 API response times, stateless API design for horizontal scaling, HTTPS/TLS mandatory  
**Scale/Scope**: ~500 servers, ~2K databases, ~50K tables, ~1M elements (columns), multi-tenant ready with RBAC

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Security (NON-NEGOTIABLE) ✅
- ✅ Authentication/Authorization: Azure Entra ID integration, JWT tokens, role-based access control
- ✅ Password Security: Legacy passwordHash field to be removed (Entra ID only authentication)
- ✅ SQL Injection Prevention: Prisma ORM with parameterized queries
- ✅ Audit Trail: AuditLog model captures all data modifications with user, timestamp, before/after values
- ✅ Input Validation: Joi validation on API endpoints (enforced in middleware layer)

### Data Integrity ✅
- ✅ Relational Hierarchy: Foreign keys enforce Server → Database → Table → Element relationships
- ✅ Cascade Rules: `onDelete: Restrict` prevents orphaned records (parent cannot be deleted with active children)
- ✅ Soft Deletes: `deletedAt` field implemented on all entities (User, Server, Database, Table, Element, Abbreviation)
- ✅ Optimistic Locking: `updatedAt` timestamp used for concurrent update conflict detection

### Testing (MANDATORY) ⚠️ RESEARCH NEEDED
- ⚠️ Test Strategy: Unit/integration test coverage for Prisma models, migrations, and data validation to be defined in Phase 0
- ⚠️ Coverage Target: 70% minimum coverage - test patterns for ORM operations need research

### Observability ✅
- ✅ Audit Logging: Comprehensive AuditLog model (immutable, append-only, 7-year retention)
- ✅ Structured Logging: Winston integration for backend operations
- ✅ Performance Monitoring: Composite indexes on high-cardinality relationships (tableId + position, databaseId + name)

### Technology Standards ✅
- ✅ Backend: Node.js 18+ LTS with Express.js
- ✅ Database: PostgreSQL 14+ (primary)
- ✅ API Design: REST with OpenAPI 3.0 specification (to be generated in Phase 1)
- ✅ Authentication: Azure Entra ID with JWT (1-hour expiry per constitution)
- ✅ Container: Docker with multi-stage builds

### Quality Gates ⚠️ PHASE 1 REQUIRED
- ⚠️ API Documentation: OpenAPI contracts to be generated in Phase 1
- ⚠️ Migration Scripts: Prisma migration for schema updates (EDITOR → MAINTAINER, add entraId, remove passwordHash, add SQLSERVER, add deletedAt fields)

**Pre-Phase 0 Status**: ✅ PASS with research requirements
**Violations**: None - all constitution requirements addressed or planned

## Project Structure

### Documentation (this feature)

```text
specs/data-model/
├── plan.md              # This file (implementation plan)
├── research.md          # Phase 0: Prisma migration patterns, test strategies, search indexing
├── data-model.md        # Phase 1: ERD diagrams, migration scripts, validation rules
├── quickstart.md        # Phase 1: Developer guide for Prisma schema, migrations, seeding
├── contracts/           # Phase 1: OpenAPI specs for entity CRUD endpoints
│   ├── users.yaml       # User management API
│   ├── servers.yaml     # Server management API
│   ├── databases.yaml   # Database management API
│   ├── tables.yaml      # Table management API
│   ├── elements.yaml    # Element/column management API
│   ├── abbreviations.yaml # Abbreviation dictionary API
│   └── audit.yaml       # Audit log query API
└── tasks.md             # Phase 2: Task breakdown (NOT created by this plan command)
```

### Source Code (repository root)

```text
src/
├── backend/
│   ├── prisma/
│   │   ├── schema.prisma           # Prisma schema (UPDATE: entraId, MAINTAINER role, SQLSERVER, deletedAt)
│   │   ├── migrations/             # Migration files (NEW: data-model-updates migration)
│   │   └── seed.ts                 # Database seeding script
│   ├── src/
│   │   ├── models/                 # Prisma client exports and type definitions
│   │   │   ├── user.model.ts
│   │   │   ├── server.model.ts
│   │   │   ├── database.model.ts
│   │   │   ├── table.model.ts
│   │   │   ├── element.model.ts
│   │   │   ├── abbreviation.model.ts
│   │   │   ├── audit-log.model.ts
│   │   │   └── search-index.model.ts
│   │   ├── services/               # Business logic layer
│   │   │   ├── user.service.ts     # User management + Entra ID sync
│   │   │   ├── server.service.ts
│   │   │   ├── database.service.ts
│   │   │   ├── table.service.ts
│   │   │   ├── element.service.ts
│   │   │   ├── abbreviation.service.ts
│   │   │   ├── audit.service.ts    # Audit logging interceptor
│   │   │   └── search.service.ts   # Search index management
│   │   ├── middleware/
│   │   │   ├── auth.middleware.ts  # Entra ID JWT validation
│   │   │   ├── rbac.middleware.ts  # Role-based authorization
│   │   │   └── soft-delete.middleware.ts # Query filter for deletedAt
│   │   └── db/
│   │       └── prisma.client.ts    # Prisma client singleton
│   └── tests/
│       ├── unit/                   # Prisma model tests, service logic tests
│       │   ├── models/
│       │   └── services/
│       └── integration/            # Database integration tests, migration tests
│           ├── schema.test.ts
│           ├── migrations.test.ts
│           └── soft-delete.test.ts
│
└── frontend/
    └── src/
        ├── services/
        │   └── api.service.ts      # API client (uses OpenAPI contracts)
        └── types/
            └── entities.ts         # TypeScript types from OpenAPI schemas
```

**Structure Decision**: Web application structure (Option 2) selected. Backend contains Prisma schema as single source of truth for data model. All entity models follow soft-delete pattern with `deletedAt` field. Frontend types generated from OpenAPI contracts for type safety. Testing structure separates unit tests (Prisma operations, service logic) from integration tests (database transactions, migrations).

## Complexity Tracking

> **No complexity violations** - all design decisions align with constitution requirements.

**Schema Design Notes:**
- Hierarchical entity model (Server → Database → Table → Element) is domain-appropriate for metadata repository
- Soft deletes with `deletedAt` field follow constitution requirement (no physical deletes)
- Prisma ORM chosen per constitution technology standards (Node.js/TypeScript ecosystem)
- Foreign key constraints with `onDelete: Restrict` prevent data integrity violations
- Optimistic locking via `updatedAt` timestamp is industry-standard pattern for concurrent updates
- Azure Entra ID integration is modern, security-first approach (removes password management burden)

**Performance Considerations:**
- Composite indexes `(tableId, position)` and `(databaseId, name)` optimize high-cardinality queries
- Search index in separate table allows asynchronous updates (acceptable <5s lag per spec clarifications)
- Connection pooling (20+ connections) supports 100+ concurrent users per constitution scalability requirements

## Phase 0: Research & Technology Decisions

**Objective**: Resolve all NEEDS CLARIFICATION items from Technical Context and Constitution Check.

### Research Tasks

1. **Prisma Migration Patterns**
   - Decision criteria: Safe migration strategy for production data
   - Questions:
     - How to safely rename enum value (`EDITOR` → `MAINTAINER`) with existing data?
     - How to add non-nullable field (`entraId`) to existing User records?
     - How to remove field (`passwordHash`) with data preservation for audit?
   - Output: Migration script patterns, rollback strategies

2. **Prisma Testing Best Practices**
   - Decision criteria: Achieve 70% coverage for ORM operations
   - Questions:
     - Unit test patterns for Prisma models (mocking vs. real database)?
     - Integration test setup for migrations and schema validation?
     - Test data factory patterns for hierarchical entities?
   - Output: Test architecture, example tests for each entity type

3. **Search Index Update Strategy**
   - Decision criteria: <5s lag acceptable, asynchronous updates
   - Questions:
     - Event-driven updates (triggers, change data capture) vs. background jobs?
     - How to handle search index failures without blocking entity updates?
     - Full-text search implementation in PostgreSQL (tsvector) vs. external service?
   - Output: Architecture decision, implementation pattern

4. **Azure Entra ID User Sync**
   - Decision criteria: Sync user profiles on first login
   - Questions:
     - Token claims mapping (`oid` → `entraId`, `preferred_username` → `username`)?
     - Handling missing email/name claims from Entra ID tokens?
     - Default role assignment strategy (all new users = VIEWER)?
   - Output: Token parsing logic, user upsert pattern

5. **Soft Delete Query Patterns**
   - Decision criteria: All queries filter `deletedAt IS NULL` by default
   - Questions:
     - Prisma middleware approach for automatic soft-delete filtering?
     - Admin endpoints to list deleted entities (bypass filter)?
     - Restore operation implementation (set `deletedAt` to null)?
   - Output: Middleware implementation, API endpoint patterns

**Output Artifact**: `research.md` with decisions, rationale, and code examples for each topic.

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete with all migration patterns, test strategies, and sync logic defined.

### 1. Data Model Documentation (`data-model.md`)

**Inputs**: 
- Existing Prisma schema (`src/backend/prisma/schema.prisma`)
- Feature spec entity definitions (`specs/data-model/README.md`)
- Research decisions on migrations and soft deletes

**Outputs**:
- **ERD Diagram**: Visual representation of entity relationships (Server ↔ Database ↔ Table ↔ Element hierarchy)
- **Migration Scripts**:
  ```sql
  -- Add entraId field to User (non-nullable, unique)
  ALTER TABLE users ADD COLUMN entra_id VARCHAR(255);
  CREATE UNIQUE INDEX users_entra_id_idx ON users(entra_id);
  
  -- Remove passwordHash field (preserve data in audit log first)
  ALTER TABLE users DROP COLUMN password_hash;
  
  -- Update Role enum: EDITOR → MAINTAINER
  UPDATE users SET role = 'MAINTAINER' WHERE role = 'EDITOR';
  ALTER TYPE Role RENAME VALUE 'EDITOR' TO 'MAINTAINER';
  
  -- Add SQLSERVER to RdbmsType enum
  ALTER TYPE RdbmsType ADD VALUE 'SQLSERVER';
  
  -- Add deletedAt to User and Abbreviation
  ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;
  ALTER TABLE abbreviations ADD COLUMN deleted_at TIMESTAMP;
  ```
- **Validation Rules**: Joi schemas for each entity (extracted from spec constraints)
- **Index Strategy**: Document all indexes with cardinality estimates

**Entity Extraction**:
- User: 8 core fields + entraId (NEW), remove passwordHash, add deletedAt
- Server: 9 fields (existing, add SQLSERVER support)
- Database: 7 fields (existing)
- Table: 8 fields (existing)
- Element: 14 fields (existing, optimize composite index)
- Abbreviation: 7 fields (existing, add deletedAt)
- AuditLog: 8 fields (immutable, append-only)
- SearchIndex: 5 fields (asynchronous updates)

### 2. API Contracts (`contracts/*.yaml`)

**Inputs**:
- Entity definitions from data-model.md
- CRUD operation requirements from feature spec
- RBAC rules (ADMIN/MAINTAINER/VIEWER) from spec

**Outputs**: OpenAPI 3.0 YAML files for each resource:

**users.yaml**:
```yaml
paths:
  /users:
    get:      # List users (ADMIN only, includes soft-deleted with ?includeDeleted=true)
    post:     # Create user (ADMIN only - manual user creation, not Entra sync)
  /users/{id}:
    get:      # Get user by ID (All roles - own profile or ADMIN)
    patch:    # Update user (ADMIN only for role changes, users can update own profile)
    delete:   # Soft delete user (ADMIN only)
  /users/{id}/restore:
    post:     # Restore soft-deleted user (ADMIN only)
```

**servers.yaml**, **databases.yaml**, **tables.yaml**, **elements.yaml**: Standard CRUD with RBAC
- GET list/detail: All roles (filtered by deletedAt IS NULL)
- POST create: MAINTAINER, ADMIN
- PATCH update: MAINTAINER, ADMIN (with optimistic locking via updatedAt)
- DELETE soft-delete: MAINTAINER, ADMIN
- POST restore: ADMIN only

**abbreviations.yaml**: Similar CRUD with category filtering
**audit.yaml**: Read-only queries (no create/update/delete endpoints)
- GET /audit-logs: Query by entityType, entityId, userId, date range (ADMIN only)

**Schema Definitions**: Each contract includes JSON Schema definitions derived from Prisma models.

### 3. Developer Quickstart (`quickstart.md`)

**Inputs**:
- Prisma schema and migration scripts
- Research decisions on testing and development setup

**Outputs**:
```markdown
# Data Model Developer Guide

## Setup
1. Install dependencies: `npm install`
2. Configure DATABASE_URL in .env
3. Run migrations: `npm run prisma:migrate`
4. Seed database: `npm run prisma:seed`

## Prisma Workflow
- Generate client: `npm run prisma:generate`
- Create migration: `npm run prisma:migrate`
- View database: `npm run prisma:studio`

## Entity CRUD Examples
[Code examples for each entity with soft-delete filtering]

## Testing
- Run unit tests: `npm test -- tests/unit`
- Run integration tests: `npm test -- tests/integration`
- Coverage report: `npm run test:coverage`

## Soft Delete Pattern
[Middleware implementation and query examples]

## Entra ID User Sync
[Token parsing and user upsert logic]
```

### 4. Agent Context Update

**Action**: Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`

**Purpose**: Update AI agent context with new data model artifacts (schema changes, API contracts).

**Expected Changes**:
- Add Prisma schema location and entity list
- Add OpenAPI contract file paths
- Add testing strategy and coverage requirements
- Preserve existing manual context between markers

## Phase 2: Task Generation (NOT EXECUTED BY THIS PLAN)

Phase 2 task generation will be handled by the `/speckit.tasks` command, which will produce `tasks.md` with dependency-ordered implementation tasks based on artifacts from Phase 0 and Phase 1.

**Expected Task Categories**:
1. **Schema Migration Tasks**: Update Prisma schema, generate/test migrations, deploy to staging
2. **Model Layer Tasks**: Update model files, add type definitions, implement soft-delete middleware
3. **Service Layer Tasks**: Update services with new validation rules, Entra ID sync, audit logging
4. **API Layer Tasks**: Generate OpenAPI contracts, update route handlers, add RBAC middleware
5. **Testing Tasks**: Write unit tests for models, integration tests for migrations, E2E tests for CRUD operations
6. **Documentation Tasks**: Update API docs, create migration guide, update developer onboarding

**Dependencies**: Phase 2 tasks blocked until Phase 0 research and Phase 1 design artifacts are complete and validated.

---

**Plan Status**: Phase 1 design artifacts ready for generation. Phase 0 research required for migration patterns and testing strategies.
