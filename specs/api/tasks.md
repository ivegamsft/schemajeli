---
description: "Task list for SchemaJeli REST API Implementation"
feature: "API"
input_docs: 
  - specs/api/README.md
  - .specify/openapi.yaml
  - .specify/spec.md
  - .specify/plan.md
  - ARCHITECTURE.md
---

# Tasks: SchemaJeli REST API Implementation

**Feature**: REST API for SchemaJeli metadata repository

**Input Documents**:
- specs/api/README.md (API endpoints overview)
- .specify/openapi.yaml (OpenAPI 3.0.3 specification)
- .specify/spec.md (User stories: US-1 through US-5)
- .specify/plan.md (Tech stack: Node.js 18+ with Express.js, TypeScript, Prisma)
- ARCHITECTURE.md (Project structure: src/backend/)

**Tech Stack** (from plan.md):
- **Runtime**: Node.js 18+ LTS
- **Framework**: Express.js with TypeScript
- **ORM**: Prisma
- **Validation**: Zod
- **Auth**: JWT (Azure Entra ID integration planned)
- **Testing**: Vitest, Supertest

**Tests**: Not explicitly requested in specs - tests are OPTIONAL per template guidance

**Organization**: Tasks organized by user story to enable independent implementation and testing

---

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (US1, US2, US3, US4, US5)
- Paths use src/backend/ prefix per ARCHITECTURE.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic API structure

- [ ] T001 Create backend project structure per ARCHITECTURE.md (src/backend/src/{api,models,services,middleware,config,utils})
- [ ] T002 Initialize Node.js project with Express.js, TypeScript, Prisma dependencies in src/backend/package.json
- [ ] T003 [P] Configure ESLint and Prettier for TypeScript in src/backend/
- [ ] T004 [P] Setup TypeScript configuration in src/backend/tsconfig.json
- [ ] T005 [P] Create environment configuration template in src/backend/.env.example
- [ ] T006 [P] Setup Vitest test configuration in src/backend/vitest.config.ts

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T007 Create Prisma schema with User, Server, Database, Table, Element, Abbreviation models in src/backend/prisma/schema.prisma
- [ ] T008 [P] Setup database migrations framework with Prisma Migrate
- [ ] T009 [P] Configure Express app with middleware (CORS, body-parser, helmet) in src/backend/src/app.ts
- [ ] T010 [P] Create API router structure with /api/v1 versioning in src/backend/src/api/routes/
- [ ] T011 [P] Implement JWT authentication middleware in src/backend/src/middleware/auth.ts
- [ ] T012 [P] Implement RBAC authorization middleware in src/backend/src/middleware/rbac.ts
- [ ] T013 [P] Setup Winston structured logging in src/backend/src/config/logger.ts
- [ ] T014 [P] Create global error handler middleware in src/backend/src/middleware/errorHandler.ts
- [ ] T015 [P] Create Zod validation schemas for all entities in src/backend/src/utils/validation/
- [ ] T016 Create base service class with common CRUD patterns in src/backend/src/services/baseService.ts
- [ ] T017 [P] Setup health check endpoint in src/backend/src/api/routes/health.ts
- [ ] T018 Run initial Prisma migration to create database schema

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Admin User Management (Priority: P1) 🎯 MVP

**Goal**: Admin users can create and manage user accounts with role-based access control (US-1)

**Independent Test**: Admin can create, view, update, and delete user accounts; changes are logged

### Implementation for User Story 1

- [ ] T019 [P] [US1] Create User Prisma model with username, email, password, role, isActive fields in src/backend/prisma/schema.prisma
- [ ] T020 [P] [US1] Create AuditLog Prisma model for tracking user actions in src/backend/prisma/schema.prisma
- [ ] T021 [US1] Implement UserService with CRUD operations in src/backend/src/services/userService.ts
- [ ] T022 [P] [US1] Implement AuthService with login, logout, token refresh in src/backend/src/services/authService.ts
- [ ] T023 [P] [US1] Create AuthController with POST /auth/login endpoint in src/backend/src/api/controllers/authController.ts
- [ ] T024 [P] [US1] Create auth routes for login, logout, refresh in src/backend/src/api/routes/auth.ts
- [ ] T025 [US1] Create UserController with CRUD endpoints in src/backend/src/api/controllers/userController.ts
- [ ] T026 [US1] Create user routes (GET /users, POST /users, GET /users/:id, PUT /users/:id, DELETE /users/:id) in src/backend/src/api/routes/users.ts
- [ ] T027 [US1] Add password hashing with bcrypt in src/backend/src/utils/password.ts
- [ ] T028 [US1] Add JWT token generation and validation in src/backend/src/utils/jwt.ts
- [ ] T029 [US1] Implement audit logging for user creation, updates, deletions in UserService
- [ ] T030 [US1] Add role validation (ADMIN, MAINTAINER, VIEWER) in RBAC middleware
- [ ] T031 [US1] Add request validation for user endpoints using Zod schemas

**Checkpoint**: User Story 1 complete - User authentication and management fully functional

---

## Phase 4: User Story 3 - Manage Database Schema (Priority: P1) 🎯 MVP

**Goal**: Database administrators can add and maintain database definitions with parent-child relationships (US-3)

**Independent Test**: DBA can create servers, add databases to servers, track status changes, verify audit logs

### Implementation for User Story 3

- [ ] T032 [P] [US3] Create Server Prisma model (name, host, port, rdbmsType, location, status) in src/backend/prisma/schema.prisma
- [ ] T033 [P] [US3] Create Database Prisma model (serverId FK, name, description, purpose, status) in src/backend/prisma/schema.prisma
- [ ] T034 [P] [US3] Create Table Prisma model (databaseId FK, name, tableType, rowCountEstimate, status) in src/backend/prisma/schema.prisma
- [ ] T035 [P] [US3] Create Element Prisma model (tableId FK, name, dataType, length, precision, isNullable, isPrimaryKey, isForeignKey, position) in src/backend/prisma/schema.prisma
- [ ] T036 [US3] Implement ServerService with CRUD operations in src/backend/src/services/serverService.ts
- [ ] T037 [P] [US3] Implement DatabaseService with CRUD operations in src/backend/src/services/databaseService.ts
- [ ] T038 [P] [US3] Implement TableService with CRUD operations in src/backend/src/services/tableService.ts
- [ ] T039 [P] [US3] Implement ElementService with CRUD operations in src/backend/src/services/elementService.ts
- [ ] T040 [US3] Create ServerController with CRUD endpoints in src/backend/src/api/controllers/serverController.ts
- [ ] T041 [P] [US3] Create DatabaseController with CRUD endpoints in src/backend/src/api/controllers/databaseController.ts
- [ ] T042 [P] [US3] Create TableController with CRUD endpoints in src/backend/src/api/controllers/tableController.ts
- [ ] T043 [P] [US3] Create ElementController with CRUD endpoints in src/backend/src/api/controllers/elementController.ts
- [ ] T044 [US3] Create server routes (GET /servers, POST /servers, GET /servers/:id, PUT /servers/:id, DELETE /servers/:id) in src/backend/src/api/routes/servers.ts
- [ ] T045 [US3] Create database routes (GET /servers/:id/databases, POST /servers/:id/databases, GET /databases/:id, PUT /databases/:id, DELETE /databases/:id) in src/backend/src/api/routes/databases.ts
- [ ] T046 [US3] Create table routes (GET /databases/:id/tables, POST /databases/:id/tables, GET /tables/:id, PUT /tables/:id, DELETE /tables/:id) in src/backend/src/api/routes/tables.ts
- [ ] T047 [US3] Create element routes (GET /tables/:id/elements, POST /tables/:id/elements, GET /elements/:id, PUT /elements/:id, DELETE /elements/:id) in src/backend/src/api/routes/elements.ts
- [ ] T048 [US3] Implement soft delete (deletedAt timestamp) for all entity models
- [ ] T049 [US3] Add parent-child relationship validation (prevent deleting server with active databases)
- [ ] T050 [US3] Add audit logging for all schema entity changes
- [ ] T051 [US3] Implement pagination for list endpoints (page, pageSize query params)
- [ ] T052 [US3] Add status filtering (ACTIVE, INACTIVE, ARCHIVED) for all entity endpoints

**Checkpoint**: User Story 3 complete - Full schema hierarchy management functional

---

## Phase 5: User Story 2 - Search Metadata (Priority: P2)

**Goal**: Developers can search for database tables and columns with wildcard support (US-2)

**Independent Test**: User can search by exact/partial name, get results under 2 seconds, see relevant metadata

### Implementation for User Story 2

- [ ] T053 [P] [US2] Implement SearchService with full-text search capability in src/backend/src/services/searchService.ts
- [ ] T054 [P] [US2] Create SearchController with search endpoints in src/backend/src/api/controllers/searchController.ts
- [ ] T055 [US2] Create search routes (GET /search?q=query&type=server|database|table|element) in src/backend/src/api/routes/search.ts
- [ ] T056 [US2] Add Prisma full-text search queries for servers (name, description, location)
- [ ] T057 [US2] Add Prisma full-text search queries for databases (name, description, purpose)
- [ ] T058 [US2] Add Prisma full-text search queries for tables (name, description)
- [ ] T059 [US2] Add Prisma full-text search queries for elements (name, description, dataType)
- [ ] T060 [US2] Implement wildcard pattern matching (*, ?) for search queries
- [ ] T061 [US2] Add search result pagination and sorting (relevance, name, createdAt)
- [ ] T062 [US2] Add search performance optimization (database indexes on name columns)
- [ ] T063 [US2] Add search result metadata (status, location, owner, version)

**Checkpoint**: User Story 2 complete - Full search functionality operational

---

## Phase 6: User Story 5 - Enforce Naming Standards (Priority: P2)

**Goal**: Data governance officers can maintain and enforce naming standards via abbreviation library (US-5)

**Independent Test**: User can view abbreviations, admin can add/modify abbreviations, system validates names

### Implementation for User Story 5

- [ ] T064 [P] [US5] Create Abbreviation Prisma model (source, abbreviation, definition, isPrimeClass, category) in src/backend/prisma/schema.prisma
- [ ] T065 [P] [US5] Create ForbiddenChar Prisma model for character blacklist in src/backend/prisma/schema.prisma
- [ ] T066 [US5] Implement AbbreviationService with CRUD operations in src/backend/src/services/abbreviationService.ts
- [ ] T067 [P] [US5] Implement NamingValidationService with forbidden character checks in src/backend/src/services/namingValidationService.ts
- [ ] T068 [US5] Create AbbreviationController with CRUD endpoints in src/backend/src/api/controllers/abbreviationController.ts
- [ ] T069 [US5] Create abbreviation routes (GET /abbreviations, POST /abbreviations, GET /abbreviations/:id, PUT /abbreviations/:id, DELETE /abbreviations/:id) in src/backend/src/api/routes/abbreviations.ts
- [ ] T070 [US5] Implement naming validation middleware to check for forbidden characters
- [ ] T071 [US5] Add naming validation to Server, Database, Table, Element creation endpoints
- [ ] T072 [US5] Implement abbreviation search with category filtering
- [ ] T073 [US5] Add audit logging for abbreviation changes

**Checkpoint**: User Story 5 complete - Naming standards enforced across system

---

## Phase 7: User Story 4 - Generate Reports (Priority: P3)

**Goal**: Data architects can generate detailed schema reports in multiple formats (US-4)

**Independent Test**: User can select report type, filter by criteria, export in HTML/CSV/PDF, generate DDL scripts

### Implementation for User Story 4

- [ ] T074 [P] [US4] Implement ReportService with report generation logic in src/backend/src/services/reportService.ts
- [ ] T075 [P] [US4] Implement DDLGeneratorService for database-specific DDL in src/backend/src/services/ddlGeneratorService.ts
- [ ] T076 [US4] Create ReportController with report endpoints in src/backend/src/api/controllers/reportController.ts
- [ ] T077 [US4] Create report routes (GET /reports/server-summary, GET /reports/database-detail, GET /reports/table-detail) in src/backend/src/api/routes/reports.ts
- [ ] T078 [US4] Create DDL route (POST /reports/generate-ddl) in src/backend/src/api/routes/reports.ts
- [ ] T079 [US4] Implement server summary report (list of databases, counts, status)
- [ ] T080 [US4] Implement database detail report (tables, columns, metadata)
- [ ] T081 [US4] Implement table detail report (full column definitions, constraints)
- [ ] T082 [US4] Implement DDL script generation for PostgreSQL
- [ ] T083 [US4] Implement DDL script generation for SQL Server
- [ ] T084 [US4] Implement DDL script generation for MySQL
- [ ] T085 [US4] Add HTML export functionality using templating engine
- [ ] T086 [US4] Add CSV export functionality for tabular reports
- [ ] T087 [US4] Add PDF export functionality using PDF generation library
- [ ] T088 [US4] Add report filtering by status, server, database
- [ ] T089 [US4] Implement report streaming for large datasets

**Checkpoint**: User Story 4 complete - Full reporting and DDL generation functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T090 [P] Setup Swagger UI for API documentation in src/backend/src/api/swagger.ts
- [ ] T091 [P] Add API rate limiting middleware (100 req/min per user) in src/backend/src/middleware/rateLimiter.ts
- [ ] T092 [P] Implement request correlation IDs for distributed tracing in src/backend/src/middleware/correlationId.ts
- [ ] T093 [P] Add comprehensive API error responses with correlation IDs
- [ ] T094 [P] Implement optimistic locking for concurrent updates using Prisma version fields
- [ ] T095 [P] Add database query performance monitoring with Prisma query events
- [ ] T096 [P] Implement CSRF protection for state-changing endpoints
- [ ] T097 [P] Add SQL injection prevention validation (Prisma handles this, add docs)
- [ ] T098 [P] Setup Application Insights instrumentation for Azure monitoring
- [ ] T099 [P] Create API usage examples and Postman collection in docs/api-examples/
- [ ] T100 [P] Add comprehensive API documentation comments for OpenAPI generation
- [ ] T101 Code review and refactoring pass across all services
- [ ] T102 Security audit: OWASP Top 10 checklist verification
- [ ] T103 Performance optimization: Add database indexes per query patterns
- [ ] T104 [P] Create API deployment guide in docs/deployment/api-deployment.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion - MVP starts here
- **User Story 3 (Phase 4)**: Depends on Foundational phase completion - MVP core functionality
- **User Story 2 (Phase 5)**: Depends on Foundational + US3 completion (needs entities to search)
- **User Story 5 (Phase 6)**: Depends on Foundational + US3 completion (validates entity names)
- **User Story 4 (Phase 7)**: Depends on Foundational + US3 completion (reports on entities)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (US-1 - Admin User Management)**: Can start after Foundational (Phase 2) - No story dependencies
- **User Story 3 (US-3 - Manage Database Schema)**: Can start after Foundational (Phase 2) - No story dependencies
- **User Story 2 (US-2 - Search Metadata)**: Requires US-3 complete (needs schema entities to search)
- **User Story 5 (US-5 - Enforce Naming Standards)**: Requires US-3 complete (validates entity names)
- **User Story 4 (US-4 - Generate Reports)**: Requires US-3 complete (reports on schema entities)

### Within Each User Story

- Prisma models must be created before services
- Services must be created before controllers
- Controllers must be created before routes
- Routes integrated into Express app last
- Validation and middleware applied after core implementation
- Audit logging added after basic functionality works

### Parallel Opportunities

**Setup Phase (Phase 1)**:
- All tasks T001-T006 can run in parallel

**Foundational Phase (Phase 2)**:
- T007-T008 (Database setup) must complete first
- T009-T017 (Middleware and utilities) can run in parallel after database setup
- T018 (Migration) must run last

**User Story 1 (Phase 3)**:
- T019-T020 (Models) can run in parallel
- T021-T022 (Services) can run in parallel after models
- T023-T024 (Auth endpoints) and T025-T026 (User endpoints) can run in parallel after services
- T027-T031 (Utilities and enhancements) can run in parallel

**User Story 3 (Phase 4)**:
- T032-T035 (All Prisma models) can run in parallel
- T036-T039 (All services) can run in parallel after models
- T040-T043 (All controllers) can run in parallel after services
- T044-T047 (All routes) can run in parallel after controllers
- T048-T052 (Cross-cutting enhancements) can run in parallel

**User Story 2 (Phase 5)**:
- T053-T054 can run in parallel
- T056-T059 (Search queries) can run in parallel after T053
- T060-T063 (Enhancements) can run in parallel

**User Story 5 (Phase 6)**:
- T064-T065 (Models) can run in parallel
- T066-T067 (Services) can run in parallel after models
- T070-T073 (Implementation) can run in parallel

**User Story 4 (Phase 7)**:
- T074-T075 can run in parallel
- T079-T084 (Report implementations) can run in parallel after T074-T075
- T085-T089 (Export formats) can run in parallel

**Polish Phase (Phase 8)**:
- Most tasks T090-T104 can run in parallel except T101-T104 which should be sequential

---

## Parallel Example: User Story 3

```bash
# Launch all Prisma models together:
Task T032: "Create Server Prisma model in src/backend/prisma/schema.prisma"
Task T033: "Create Database Prisma model in src/backend/prisma/schema.prisma"
Task T034: "Create Table Prisma model in src/backend/prisma/schema.prisma"
Task T035: "Create Element Prisma model in src/backend/prisma/schema.prisma"

# Then launch all services together:
Task T036: "Implement ServerService in src/backend/src/services/serverService.ts"
Task T037: "Implement DatabaseService in src/backend/src/services/databaseService.ts"
Task T038: "Implement TableService in src/backend/src/services/tableService.ts"
Task T039: "Implement ElementService in src/backend/src/services/elementService.ts"

# Then launch all controllers together:
Task T040: "Create ServerController in src/backend/src/api/controllers/serverController.ts"
Task T041: "Create DatabaseController in src/backend/src/api/controllers/databaseController.ts"
Task T042: "Create TableController in src/backend/src/api/controllers/tableController.ts"
Task T043: "Create ElementController in src/backend/src/api/controllers/elementController.ts"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 3)

1. Complete Phase 1: Setup (T001-T006)
2. Complete Phase 2: Foundational (T007-T018) - CRITICAL BLOCKER
3. Complete Phase 3: User Story 1 (T019-T031) - Authentication and user management
4. Complete Phase 4: User Story 3 (T032-T052) - Core schema management
5. **STOP and VALIDATE**: Test US-1 and US-3 independently
6. Deploy/demo if ready - MVP is user management + schema CRUD

### Incremental Delivery

1. **Foundation** (Phases 1-2): T001-T018 → Backend infrastructure ready
2. **MVP** (Phases 3-4): T019-T052 → User management + Schema CRUD → Deploy/Demo
3. **Enhanced MVP** (Phase 5): T053-T063 → Add search → Deploy/Demo
4. **Governance** (Phase 6): T064-T073 → Add naming standards → Deploy/Demo
5. **Complete** (Phase 7): T074-T089 → Add reporting → Deploy/Demo
6. **Production Ready** (Phase 8): T090-T104 → Polish and harden → Production deployment

### Parallel Team Strategy

With multiple backend developers:

1. **Together**: Complete Setup (Phase 1) and Foundational (Phase 2)
2. **Once Foundational is done**:
   - Developer A: User Story 1 (Auth & User Management)
   - Developer B: User Story 3 (Schema Management) 
3. **After US-1 and US-3**:
   - Developer A: User Story 2 (Search)
   - Developer B: User Story 5 (Naming Standards)
   - Developer C: User Story 4 (Reports)
4. **Finally**: All developers collaborate on Phase 8 (Polish)

---

## Task Summary

| Phase | Task Range | Count | Purpose |
|-------|-----------|-------|---------|
| Phase 1: Setup | T001-T006 | 6 | Project initialization |
| Phase 2: Foundational | T007-T018 | 12 | Core infrastructure (BLOCKS all stories) |
| Phase 3: User Story 1 | T019-T031 | 13 | Admin user management (MVP) |
| Phase 4: User Story 3 | T032-T052 | 21 | Schema hierarchy management (MVP) |
| Phase 5: User Story 2 | T053-T063 | 11 | Search metadata |
| Phase 6: User Story 5 | T064-T073 | 10 | Naming standards enforcement |
| Phase 7: User Story 4 | T074-T089 | 16 | Report generation and DDL |
| Phase 8: Polish | T090-T104 | 15 | Cross-cutting concerns |
| **TOTAL** | T001-T104 | **104** | **Complete REST API** |

### Task Distribution by User Story

- **US-1**: 13 tasks (Admin User Management)
- **US-2**: 11 tasks (Search Metadata)
- **US-3**: 21 tasks (Manage Database Schema) - Largest story, core functionality
- **US-4**: 16 tasks (Generate Reports)
- **US-5**: 10 tasks (Enforce Naming Standards)
- **Setup & Foundation**: 18 tasks (Enables all stories)
- **Polish**: 15 tasks (Quality and production readiness)

### Parallel Opportunities

- **Setup**: 5 parallel tasks (T003-T006)
- **Foundational**: 9 parallel tasks (T009-T017)
- **User Story 1**: 11 parallel opportunities
- **User Story 3**: 20 parallel opportunities (largest)
- **User Story 2**: 7 parallel opportunities
- **User Story 5**: 6 parallel opportunities
- **User Story 4**: 13 parallel opportunities
- **Polish**: 13 parallel opportunities

**Estimated parallel efficiency**: With 3 developers, project can complete ~40% faster than sequential execution

---

## MVP Scope (Recommended First Release)

**MVP = User Story 1 + User Story 3** (T001-T052)

**Included in MVP**:
- ✅ User authentication (JWT-based login/logout)
- ✅ User management (CRUD operations, role-based access)
- ✅ Server management (CRUD with RDBMS type tracking)
- ✅ Database management (CRUD with server relationships)
- ✅ Table management (CRUD with database relationships)
- ✅ Element/Column management (CRUD with data type tracking)
- ✅ Audit logging for all changes
- ✅ Soft deletes (no data loss)
- ✅ Parent-child relationship enforcement
- ✅ Pagination and filtering
- ✅ RBAC authorization
- ✅ API documentation (Swagger)

**Total MVP Tasks**: 52 tasks
**Estimated MVP Effort**: 6-8 weeks with 2-3 backend developers

**Excluded from MVP** (add incrementally):
- 🔜 Search functionality (US-2) - Add next
- 🔜 Naming standards enforcement (US-5)
- 🔜 Report generation and DDL scripts (US-4)
- 🔜 Advanced polish features (Phase 8)

---

## Notes

- **Path Convention**: All paths use `src/backend/` prefix per ARCHITECTURE.md
- **[P] Marker**: Tasks marked [P] can run in parallel with others in same phase
- **[Story] Label**: Maps task to specific user story for traceability
- **Tests Optional**: No test tasks included per template guidance (not explicitly requested)
- **Prisma First**: All data models defined in Prisma schema before implementation
- **Service Layer**: All business logic in services, controllers are thin
- **Validation**: Zod schemas for all request validation
- **Audit Trail**: All data changes logged to AuditLog table
- **Soft Deletes**: deletedAt timestamp, no physical deletion
- **Independent Stories**: Each user story independently completable after Foundational phase
- **Commit Frequency**: Commit after each task or logical group of related tasks
- **Checkpoints**: Use checkpoints to validate story independently before proceeding

---

## Success Criteria

### Per User Story

- **US-1**: Admin can create users, assign roles, changes are audited ✅
- **US-2**: Developers can search metadata in under 2 seconds with wildcard support ✅
- **US-3**: DBAs can manage full schema hierarchy (Server → Database → Table → Element) ✅
- **US-4**: Data architects can generate reports in multiple formats and DDL scripts ✅
- **US-5**: System enforces naming standards, abbreviation library maintained ✅

### Overall API Success Criteria

- ✅ All OpenAPI 3.0.3 endpoints implemented per .specify/openapi.yaml
- ✅ JWT authentication working with role-based authorization (ADMIN, MAINTAINER, VIEWER)
- ✅ All entities support CRUD operations with pagination
- ✅ Audit logging captures all data modifications
- ✅ Soft deletes implemented (no data loss)
- ✅ Parent-child relationships enforced (referential integrity)
- ✅ API response time < 500ms p95 (per ARCHITECTURE.md targets)
- ✅ Swagger UI documentation available at /api-docs
- ✅ Health check endpoint operational
- ✅ All endpoints return consistent JSON response format
- ✅ Error handling with appropriate HTTP status codes
- ✅ Rate limiting: 100 req/min per user (per specs/api/README.md)

---

## Next Steps

1. **Review this tasks.md** with team for completeness and feasibility
2. **Set up tracking**: Import tasks into project management tool (Jira, GitHub Issues, etc.)
3. **Staff the team**: Assign 2-3 backend developers
4. **Start Phase 1**: Complete setup tasks (T001-T006)
5. **Execute Phase 2**: Complete foundational infrastructure (T007-T018) - BLOCKER
6. **Implement MVP**: Execute Phases 3-4 (User Stories 1 & 3)
7. **Validate MVP**: Test independently, deploy to staging
8. **Incremental delivery**: Add User Stories 2, 5, 4 in priority order
9. **Polish**: Complete Phase 8 for production readiness
10. **Deploy to production**: Follow deployment guide from PHASE-4-PLAN.md

---

**Generated**: 2025-01-29
**Format Validation**: ✅ All tasks follow strict checklist format: `- [ ] [ID] [P?] [Story?] Description with file path`
**User Story Mapping**: ✅ All tasks mapped to user stories from .specify/spec.md
**Dependency Order**: ✅ Tasks ordered by dependencies, parallel opportunities marked
**Independent Testing**: ✅ Each user story can be tested independently after Foundational phase
**MVP Defined**: ✅ MVP scope = US-1 + US-3 (52 tasks, 6-8 weeks)
