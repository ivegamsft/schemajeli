---
description: "Task list for Data Model feature implementation"
---

# Tasks: Data Model

**Input**: Design documents from `/specs/data-model/`
**Prerequisites**: plan.md ✅, README.md ✅ (data model specification)

**Tests**: This feature includes test tasks as per the constitution requirement for 70% minimum coverage.

**Organization**: Tasks are grouped by logical phases to enable systematic implementation of the data model, migrations, and testing infrastructure.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions

- **Web app structure**: `src/backend/`, `src/frontend/` (per plan.md)
- **Prisma schema**: `src/backend/prisma/schema.prisma`
- **Backend source**: `src/backend/src/`
- **Frontend source**: `src/frontend/src/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prisma initialization and project structure setup

- [ ] T001 Verify Node.js 18+ LTS and npm are installed
- [ ] T002 Install Prisma CLI and dependencies (prisma@5.20+, @prisma/client, @azure/msal-node@3.5+)
- [ ] T003 [P] Configure PostgreSQL 14+ connection string in .env (minimum 20 connections in pool)
- [ ] T004 [P] Setup backend directory structure per plan.md (models/, services/, middleware/, db/)

**Checkpoint**: Project structure and Prisma tooling ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Prisma schema and migration infrastructure

**⚠️ CRITICAL**: No implementation work can begin until Prisma schema is migrated and client is generated

### Prisma Schema Updates

- [ ] T005 Update User model in src/backend/prisma/schema.prisma: Add entraId field (String @unique)
- [ ] T006 Update User model in src/backend/prisma/schema.prisma: Remove passwordHash field (legacy authentication)
- [ ] T007 Update User model in src/backend/prisma/schema.prisma: Add deletedAt field (DateTime? for soft deletes)
- [ ] T008 Update User.role enum in src/backend/prisma/schema.prisma: Rename EDITOR to MAINTAINER
- [ ] T009 Update Server.rdbmsType enum in src/backend/prisma/schema.prisma: Add SQLSERVER to enum values
- [ ] T010 Update Abbreviation model in src/backend/prisma/schema.prisma: Add deletedAt field (DateTime? for soft deletes)
- [ ] T011 Verify Server model in src/backend/prisma/schema.prisma has deletedAt field
- [ ] T012 Verify Database model in src/backend/prisma/schema.prisma has deletedAt field
- [ ] T013 Verify Table model in src/backend/prisma/schema.prisma has deletedAt field
- [ ] T014 Verify Element model in src/backend/prisma/schema.prisma has deletedAt field
- [ ] T015 Verify AuditLog model in src/backend/prisma/schema.prisma (immutable, append-only schema)
- [ ] T016 Verify SearchIndex model in src/backend/prisma/schema.prisma

### Indexes and Constraints

- [ ] T017 Add composite index (tableId, position) to Element model in src/backend/prisma/schema.prisma
- [ ] T018 Add composite index (databaseId, name) to Table model in src/backend/prisma/schema.prisma
- [ ] T019 Add unique constraints in src/backend/prisma/schema.prisma: user(entraId), user(username), user(email), server(name), abbreviation(abbreviation)
- [ ] T020 Add composite unique constraints in src/backend/prisma/schema.prisma: database(serverId, name), table(databaseId, name), element(tableId, name)
- [ ] T021 Add foreign key constraints with onDelete: Restrict in src/backend/prisma/schema.prisma for hierarchical relationships
- [ ] T022 Add indexes in src/backend/prisma/schema.prisma: users(role), servers(status), databases(status), tables(status)
- [ ] T023 Add indexes in src/backend/prisma/schema.prisma: elements(dataType), abbreviations(source, category)
- [ ] T024 Add indexes in src/backend/prisma/schema.prisma: auditLog(entityType, entityId), auditLog(userId), auditLog(createdAt)

### Migration and Database Setup

- [ ] T025 Create Prisma migration: npx prisma migrate dev --name data-model-updates
- [ ] T026 Generate Prisma Client: npx prisma generate
- [ ] T027 Create database seeding script in src/backend/prisma/seed.ts (admin user, sample servers, sample abbreviations)
- [ ] T028 Run seed script: npx prisma db seed

**Checkpoint**: Foundation ready - Prisma schema migrated, client generated, database seeded

---

## Phase 3: Core Models and Type Definitions

**Purpose**: TypeScript model exports and type definitions for all entities

**Independent Test**: Import models in a test file and verify types are correctly exported

### Model Files

- [ ] T029 [P] Create User model export in src/backend/src/models/user.model.ts (Prisma User type export)
- [ ] T030 [P] Create Server model export in src/backend/src/models/server.model.ts (Prisma Server type export)
- [ ] T031 [P] Create Database model export in src/backend/src/models/database.model.ts (Prisma Database type export)
- [ ] T032 [P] Create Table model export in src/backend/src/models/table.model.ts (Prisma Table type export)
- [ ] T033 [P] Create Element model export in src/backend/src/models/element.model.ts (Prisma Element type export)
- [ ] T034 [P] Create Abbreviation model export in src/backend/src/models/abbreviation.model.ts (Prisma Abbreviation type export)
- [ ] T035 [P] Create AuditLog model export in src/backend/src/models/audit-log.model.ts (Prisma AuditLog type export)
- [ ] T036 [P] Create SearchIndex model export in src/backend/src/models/search-index.model.ts (Prisma SearchIndex type export)

### Prisma Client Setup

- [ ] T037 Create Prisma client singleton in src/backend/src/db/prisma.client.ts (connection pooling, error handling)

**Checkpoint**: All models and types are available for service layer implementation

---

## Phase 4: Middleware Infrastructure

**Purpose**: Authentication, authorization, and soft-delete filtering

**Independent Test**: Call middleware functions with mock requests and verify correct behavior

### Middleware Files

- [ ] T038 [P] Implement Azure Entra ID JWT validation in src/backend/src/middleware/auth.middleware.ts (@azure/msal-node integration)
- [ ] T039 [P] Implement RBAC middleware in src/backend/src/middleware/rbac.middleware.ts (ADMIN/MAINTAINER/VIEWER role checks)
- [ ] T040 [P] Implement soft-delete query filter in src/backend/src/middleware/soft-delete.middleware.ts (deletedAt IS NULL filtering)

**Checkpoint**: Middleware ready for service layer integration

---

## Phase 5: Service Layer Implementation

**Purpose**: Business logic for all entity CRUD operations with audit logging

**Independent Test**: Call service methods directly and verify database operations work correctly

### Service Files

- [ ] T041 Implement UserService in src/backend/src/services/user.service.ts (CRUD, Entra ID sync, soft delete, optimistic locking)
- [ ] T042 Implement ServerService in src/backend/src/services/server.service.ts (CRUD, soft delete, restrict cascade validation)
- [ ] T043 Implement DatabaseService in src/backend/src/services/database.service.ts (CRUD, soft delete, serverId validation)
- [ ] T044 Implement TableService in src/backend/src/services/table.service.ts (CRUD, soft delete, databaseId validation)
- [ ] T045 Implement ElementService in src/backend/src/services/element.service.ts (CRUD, soft delete, position management, tableId validation)
- [ ] T046 Implement AbbreviationService in src/backend/src/services/abbreviation.service.ts (CRUD, soft delete, uniqueness validation)
- [ ] T047 Implement AuditService in src/backend/src/services/audit.service.ts (append-only logging, change tracking interceptor)
- [ ] T048 Implement SearchService in src/backend/src/services/search.service.ts (index management, async updates, content aggregation)

**Checkpoint**: All services implement business logic with audit logging and soft deletes

---

## Phase 6: Unit Tests for Models and Services

**Purpose**: Achieve 70% minimum test coverage per constitution requirement

**Independent Test**: Run test suite and verify coverage reports meet 70% threshold

### Model Tests

- [ ] T049 [P] Unit tests for User model in src/backend/tests/unit/models/user.model.test.ts (entraId validation, role enum, soft delete)
- [ ] T050 [P] Unit tests for Server model in src/backend/tests/unit/models/server.model.test.ts (rdbmsType enum including SQLSERVER, status enum)
- [ ] T051 [P] Unit tests for Database model in src/backend/tests/unit/models/database.model.test.ts (foreign key validation, unique constraint)
- [ ] T052 [P] Unit tests for Table model in src/backend/tests/unit/models/table.model.test.ts (tableType enum, composite index)
- [ ] T053 [P] Unit tests for Element model in src/backend/tests/unit/models/element.model.test.ts (position management, composite index)
- [ ] T054 [P] Unit tests for Abbreviation model in src/backend/tests/unit/models/abbreviation.model.test.ts (uniqueness, soft delete)
- [ ] T055 [P] Unit tests for AuditLog model in src/backend/tests/unit/models/audit-log.model.test.ts (append-only validation, immutability)

### Service Tests

- [ ] T056 [P] Unit tests for UserService in src/backend/tests/unit/services/user.service.test.ts (Entra ID sync, optimistic locking, soft delete)
- [ ] T057 [P] Unit tests for ServerService in src/backend/tests/unit/services/server.service.test.ts (CRUD operations, restrict cascade)
- [ ] T058 [P] Unit tests for DatabaseService in src/backend/tests/unit/services/database.service.test.ts (CRUD operations, parent validation)
- [ ] T059 [P] Unit tests for TableService in src/backend/tests/unit/services/table.service.test.ts (CRUD operations, parent validation)
- [ ] T060 [P] Unit tests for ElementService in src/backend/tests/unit/services/element.service.test.ts (CRUD operations, position management)
- [ ] T061 [P] Unit tests for AbbreviationService in src/backend/tests/unit/services/abbreviation.service.test.ts (CRUD operations, uniqueness)
- [ ] T062 [P] Unit tests for AuditService in src/backend/tests/unit/services/audit.service.test.ts (change tracking, append-only enforcement)
- [ ] T063 [P] Unit tests for SearchService in src/backend/tests/unit/services/search.service.test.ts (index updates, async operations)

**Checkpoint**: Unit test coverage meets 70% minimum requirement

---

## Phase 7: Integration Tests

**Purpose**: Validate database operations, migrations, and cross-entity relationships

**Independent Test**: Run integration test suite against test database and verify all scenarios pass

### Integration Test Files

- [ ] T064 [P] Schema integration test in src/backend/tests/integration/schema.test.ts (verify all models, constraints, indexes)
- [ ] T065 [P] Migration integration test in src/backend/tests/integration/migrations.test.ts (verify migration applies cleanly, data integrity)
- [ ] T066 [P] Soft delete integration test in src/backend/tests/integration/soft-delete.test.ts (verify filtering, cascade behavior)
- [ ] T067 [P] Audit logging integration test in src/backend/tests/integration/audit-log.test.ts (verify all CRUD operations log correctly)
- [ ] T068 [P] Optimistic locking integration test in src/backend/tests/integration/optimistic-locking.test.ts (verify conflict detection)
- [ ] T069 [P] Hierarchical cascade integration test in src/backend/tests/integration/cascade.test.ts (verify onDelete: Restrict enforcement)
- [ ] T070 [P] Search index integration test in src/backend/tests/integration/search-index.test.ts (verify async updates, content aggregation)

**Checkpoint**: All integration tests pass, database operations validated

---

## Phase 8: Frontend Type Generation

**Purpose**: Generate TypeScript types from Prisma schema for frontend use

**Independent Test**: Import types in frontend code and verify TypeScript compilation succeeds

- [ ] T071 Install @prisma/generator-helper in src/frontend (for type generation)
- [ ] T072 Generate TypeScript entity types from Prisma schema in src/frontend/src/types/entities.ts
- [ ] T073 Create API service client in src/frontend/src/services/api.service.ts (typed fetch wrapper with entity types)

**Checkpoint**: Frontend has type-safe access to all entity definitions

---

## Phase 9: Documentation and Developer Guide

**Purpose**: Create developer documentation for schema usage, migrations, and testing

**Independent Test**: Follow quickstart guide as a new developer and verify all steps work

- [ ] T074 Create research.md in specs/data-model/: Document Prisma migration patterns, test strategies for ORM operations
- [ ] T075 Create quickstart.md in specs/data-model/: Developer guide for Prisma schema, running migrations, database seeding
- [ ] T076 [P] Document soft delete pattern in quickstart.md (query filtering, restore operations)
- [ ] T077 [P] Document optimistic locking pattern in quickstart.md (updatedAt timestamp comparison)
- [ ] T078 [P] Document audit logging integration in quickstart.md (automatic change tracking)

**Checkpoint**: Documentation complete, developers can onboard using quickstart guide

---

## Phase 10: OpenAPI Contract Generation (Optional)

**Purpose**: Generate OpenAPI specifications for entity CRUD endpoints

**Independent Test**: Import OpenAPI specs into Postman/Swagger and verify all endpoints are documented

- [ ] T079 [P] Generate OpenAPI spec for Users API in specs/data-model/contracts/users.yaml
- [ ] T080 [P] Generate OpenAPI spec for Servers API in specs/data-model/contracts/servers.yaml
- [ ] T081 [P] Generate OpenAPI spec for Databases API in specs/data-model/contracts/databases.yaml
- [ ] T082 [P] Generate OpenAPI spec for Tables API in specs/data-model/contracts/tables.yaml
- [ ] T083 [P] Generate OpenAPI spec for Elements API in specs/data-model/contracts/elements.yaml
- [ ] T084 [P] Generate OpenAPI spec for Abbreviations API in specs/data-model/contracts/abbreviations.yaml
- [ ] T085 [P] Generate OpenAPI spec for Audit Logs API in specs/data-model/contracts/audit.yaml

**Checkpoint**: All API contracts documented and ready for endpoint implementation

---

## Phase 11: Polish & Validation

**Purpose**: Final validation, code cleanup, and performance verification

- [ ] T086 Run Prisma Studio to visually inspect database schema and data
- [ ] T087 Run full test suite (unit + integration) and verify 70%+ coverage
- [ ] T088 Verify all soft delete queries filter by deletedAt IS NULL
- [ ] T089 Verify onDelete: Restrict prevents parent deletion with active children
- [ ] T090 Verify optimistic locking throws conflict errors on concurrent updates
- [ ] T091 [P] Verify composite indexes perform efficiently (tableId + position, databaseId + name)
- [ ] T092 [P] Code cleanup: Remove console.logs, add JSDoc comments to service methods
- [ ] T093 Run linter and fix any issues
- [ ] T094 Update main README.md with data model feature completion status

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies - can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 completion - BLOCKS all other phases
- **Phase 3 (Models)**: Depends on Phase 2 (Prisma client must be generated)
- **Phase 4 (Middleware)**: Depends on Phase 2 (Prisma client must be available)
- **Phase 5 (Services)**: Depends on Phase 3 (models) AND Phase 4 (middleware)
- **Phase 6 (Unit Tests)**: Depends on Phase 3 (models) AND Phase 5 (services)
- **Phase 7 (Integration Tests)**: Depends on Phase 2 (schema) AND Phase 5 (services)
- **Phase 8 (Frontend Types)**: Depends on Phase 2 (Prisma schema complete)
- **Phase 9 (Documentation)**: Can start after Phase 2; benefits from Phase 6 & 7 completion
- **Phase 10 (OpenAPI)**: Optional; can run in parallel with Phase 6-9
- **Phase 11 (Polish)**: Depends on all previous phases

### Critical Path

1. Phase 1 (Setup) → Phase 2 (Foundational) → **BLOCKING CHECKPOINT**
2. After Phase 2: Phases 3, 4, 8 can run in parallel
3. After Phases 3 & 4: Phase 5 (Services)
4. After Phase 5: Phases 6, 7, 9, 10 can run in parallel
5. After all phases: Phase 11 (Polish)

### Parallel Opportunities

- **Phase 1**: T003, T004 can run in parallel
- **Phase 2**: Schema update tasks (T005-T016) can run in parallel, index tasks (T017-T024) can run in parallel
- **Phase 3**: All model files (T029-T036) can run in parallel
- **Phase 4**: All middleware files (T038-T040) can run in parallel
- **Phase 5**: Service files are sequential (depend on each other for audit integration)
- **Phase 6**: All model tests can run in parallel, all service tests can run in parallel
- **Phase 7**: All integration tests can run in parallel
- **Phase 8**: Tasks T071-T073 are sequential
- **Phase 9**: Documentation tasks T076-T078 can run in parallel
- **Phase 10**: All OpenAPI generation tasks (T079-T085) can run in parallel
- **Phase 11**: T091, T092 can run in parallel

---

## Parallel Example: Phase 3 (Models)

```bash
# Launch all model files together:
Task: "Create User model export in src/backend/src/models/user.model.ts"
Task: "Create Server model export in src/backend/src/models/server.model.ts"
Task: "Create Database model export in src/backend/src/models/database.model.ts"
Task: "Create Table model export in src/backend/src/models/table.model.ts"
Task: "Create Element model export in src/backend/src/models/element.model.ts"
Task: "Create Abbreviation model export in src/backend/src/models/abbreviation.model.ts"
Task: "Create AuditLog model export in src/backend/src/models/audit-log.model.ts"
Task: "Create SearchIndex model export in src/backend/src/models/search-index.model.ts"
```

---

## Implementation Strategy

### Waterfall Approach (Recommended for Data Model)

1. Complete Phase 1: Setup → Basic project structure ready
2. Complete Phase 2: Foundational → **CRITICAL BLOCKER** - Prisma schema migrated
3. Complete Phase 3: Models → Type definitions available
4. Complete Phase 4: Middleware → Security infrastructure ready
5. Complete Phase 5: Services → Business logic complete
6. Complete Phase 6-7: Tests → Validation and coverage
7. Complete Phase 8-10: Types & Docs → Developer experience
8. Complete Phase 11: Polish → Production ready

**Rationale**: Data model is foundational infrastructure. Schema must be stable before building services. Testing validates correctness before exposing via APIs.

### Minimum Viable Schema (MVS)

If needing faster iteration:

1. Complete Phase 1 + Phase 2 → Schema migrated
2. Complete Phase 3 + Phase 5 (User + Server entities only) → Basic CRUD
3. Add Phase 6 tests for User + Server → Validate core patterns
4. **STOP and VALIDATE**: Test basic user and server management
5. Expand to remaining entities (Database, Table, Element, etc.)

### Parallel Team Strategy

With multiple developers:

1. Team completes Phase 1 + Phase 2 together (schema is shared)
2. Once Phase 2 done:
   - Developer A: Phase 3 (Models) + Phase 4 (Middleware)
   - Developer B: Phase 8 (Frontend Types) + Phase 9 (Documentation)
   - Developer C: Research Phase 10 (OpenAPI generation tooling)
3. After Phase 3 + 4 complete:
   - Developer A: Phase 5 (Services)
   - Developer B: Phase 6 (Unit Tests)
   - Developer C: Phase 7 (Integration Tests)

---

## Notes

- **Migration First**: Prisma schema changes (Phase 2) MUST be complete before any service implementation
- **Soft Delete Pattern**: ALL list/get queries must filter `deletedAt IS NULL` unless explicitly querying deleted records
- **Audit Logging**: ALL CRUD operations (except AuditLog itself) must trigger audit log entries
- **Optimistic Locking**: Use `updatedAt` timestamp comparison on all update operations
- **Test Coverage**: Maintain 70% minimum coverage per constitution requirement
- **Foreign Key Constraints**: `onDelete: Restrict` prevents orphaned records - validate parent existence before creating children
- **SQLSERVER Support**: New RDBMS type added - ensure all rdbmsType references include it
- **MAINTAINER Role**: Replaces legacy EDITOR role - update all role-based logic accordingly
- **Entra ID Only**: No local authentication - entraId is the canonical user identifier
- **Search Index**: Async updates acceptable with <5 second lag per design decision
- Each checkpoint is a commit point - verify functionality before proceeding
- [P] tasks = different files, no dependencies within that phase
- Stop at any checkpoint to validate before moving forward
