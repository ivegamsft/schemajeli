---
description: "Task list for SchemaJeli System Architecture completion"
feature: "Architecture"
input_docs:
  - specs/architecture/README.md
  - specs/architecture/spec.md
  - specs/architecture/plan.md
  - ARCHITECTURE.md
---

# Tasks: System Architecture Completion

**Feature**: Core system architecture for SchemaJeli metadata repository

**Input Documents**:
- specs/architecture/README.md (Architecture overview)
- specs/architecture/spec.md (User stories US1–US7)
- specs/architecture/plan.md (Implementation plan with gap analysis)
- ARCHITECTURE.md (Project structure)

**Current State**: Architecture is ~85% implemented. Auth (JWT/JWKS), RBAC middleware, all CRUD routes, soft deletes, Winston logging, MSAL frontend config, 9 frontend pages, Docker Compose, and Terraform modules are all in place. This task list addresses the remaining **gaps**.

**Tech Stack** (verified from codebase):
- **Backend**: Node.js 18+ LTS, Express.js, TypeScript, Prisma ORM
- **Frontend**: React 19, Vite, MSAL, Zustand, Tailwind CSS v4
- **Database**: PostgreSQL 15+, Prisma Migrate
- **IaC**: Terraform (Azure-only)
- **Testing**: Vitest, React Testing Library, Playwright

**Organization**: Tasks grouped by user story for independent implementation and testing.

---

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (US1–US7)
- Paths use `src/backend/` or `src/frontend/` prefix

---

## Phase 1: Foundational Gaps (Blocking Prerequisites)

**Purpose**: Fill architectural gaps that block full compliance with the architecture spec

**⚠️ CRITICAL**: These tasks address missing infrastructure that multiple user stories depend on

- [ ] T001 [P] [US4] Create global error handling middleware in `src/backend/src/middleware/errorHandler.ts` — catch unhandled errors, return standard `{ status: 'error', message }` envelope with appropriate HTTP status codes (400, 401, 403, 404, 500), log full stack trace via Winston, strip stack traces in production (`NODE_ENV=production`)
- [ ] T002 [P] [US4] Create pagination helper utility in `src/backend/src/utils/pagination.ts` — extract `page` and `limit` from query params (defaults: page=1, limit=25, max limit=100), compute `skip`/`take` for Prisma, return standardized `{ total, page, limit, totalPages }` metadata object
- [ ] T003 [P] [US4] Create rate limiting middleware in `src/backend/src/middleware/rateLimiter.ts` — 100 requests/minute per authenticated user (keyed by user ID from JWT), 20 req/min per IP for unauthenticated endpoints, return HTTP 429 with `Retry-After`, `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers, exempt `/api/v1/health` endpoint
- [ ] T004 [P] [US3] Create audit logging service in `src/backend/src/services/audit.service.ts` — accept `{ userId, action, entityType, entityId, changes?, ipAddress?, userAgent? }`, insert into AuditLog table via Prisma, support CREATE/UPDATE/DELETE actions, capture before/after state for updates as JSON

**Checkpoint**: Foundation gaps filled — audit logging, error handling, rate limiting, and pagination utilities ready for integration

---

## Phase 2: User Story 3 — Audit Logging Integration (Priority: P1) 🎯

**Goal**: All entity mutations are recorded in the AuditLog table (currently missing from CRUD routes in `src/backend/src/index.ts`)

**Independent Test**: Create a Server via POST, verify an AuditLog entry exists with action=CREATE, entityType=Server, userId, and timestamp

### Implementation for User Story 3

- [ ] T005 [US3] Integrate audit logging into Server CRUD routes in `src/backend/src/index.ts` — call `audit.service.ts` on POST (CREATE), PUT (UPDATE with before/after diff), DELETE (DELETE) for servers; extract userId from `req.user`, IP from `req.ip`
- [ ] T006 [P] [US3] Integrate audit logging into Database CRUD routes in `src/backend/src/index.ts` — same pattern as T005 for database create/update/delete
- [ ] T007 [P] [US3] Integrate audit logging into Table CRUD routes in `src/backend/src/index.ts` — same pattern as T005 for table create/update/delete
- [ ] T008 [P] [US3] Integrate audit logging into Element CRUD routes in `src/backend/src/index.ts` — same pattern as T005 for element create/update/delete
- [ ] T009 [P] [US3] Integrate audit logging into Abbreviation CRUD routes in `src/backend/src/index.ts` — same pattern as T005 for abbreviation create/update/delete
- [ ] T010 [US3] Add GET `/api/v1/audit-logs` endpoint in `src/backend/src/index.ts` — Admin-only, filterable by entityType, entityId, userId, date range (startDate/endDate query params), paginated using pagination helper from T002

**Checkpoint**: All data modifications are now audited — verify by checking AuditLog table after CRUD operations

---

## Phase 3: User Story 4 — API Infrastructure Hardening (Priority: P2)

**Goal**: Standard error handling, rate limiting, and pagination are applied across all routes

**Independent Test**: Send 101 requests in 1 minute and verify 429 response on the 101st; call a list endpoint with `?page=2&limit=5` and verify pagination metadata

### Implementation for User Story 4

- [ ] T011 [US4] Register global error handler middleware in `src/backend/src/index.ts` — add `app.use(errorHandler)` after all route definitions (must be last middleware); import from `middleware/errorHandler.ts`
- [ ] T012 [US4] Register rate limiter middleware in `src/backend/src/index.ts` — add `app.use(rateLimiter)` before route definitions; configure to exempt `/api/v1/health`
- [ ] T013 [US4] Refactor all list endpoints to use pagination helper — update GET `/api/v1/servers`, `/api/v1/databases`, `/api/v1/tables`, `/api/v1/elements`, `/api/v1/abbreviations` in `src/backend/src/index.ts` to use the pagination utility from T002 for consistent response format `{ status, data, total, page, limit, totalPages }`
- [ ] T014 [P] [US4] Add request validation middleware using Zod in `src/backend/src/middleware/validate.ts` — generic middleware that accepts a Zod schema and validates `req.body`, `req.params`, or `req.query`; returns 400 with field-level errors on validation failure
- [ ] T015 [P] [US4] Add CORS configuration review in `src/backend/src/index.ts` — ensure CORS allows frontend origin (localhost:5173 for dev, production Static Web App URL for prod), credentials: true for auth cookies

**Checkpoint**: API infrastructure hardened — error handling, rate limiting, pagination, and validation standardized

---

## Phase 4: User Story 6 — Monitoring & Observability (Priority: P3)

**Goal**: Application Insights integration and enhanced logging for production monitoring

**Independent Test**: Start the backend with `APPLICATIONINSIGHTS_CONNECTION_STRING` set, make an API request, verify telemetry appears in Application Insights

### Implementation for User Story 6

- [ ] T016 [P] [US6] Install and configure Application Insights SDK in `src/backend/src/config/appInsights.ts` — install `applicationinsights` package, initialize with connection string from env var `APPLICATIONINSIGHTS_CONNECTION_STRING`, enable auto-collection of requests, dependencies, exceptions; conditionally enable only when connection string is present
- [ ] T017 [P] [US6] Add request logging middleware in `src/backend/src/middleware/requestLogger.ts` — log method, path, status code, response time (ms), and correlation ID for every request via Winston; generate correlation ID via `crypto.randomUUID()` and attach to `req.headers['x-correlation-id']`
- [ ] T018 [US6] Register Application Insights and request logger in `src/backend/src/index.ts` — import and initialize Application Insights before Express app creation; add request logger middleware before route definitions
- [ ] T019 [P] [US6] Add health check enrichment to GET `/api/v1/health` endpoint in `src/backend/src/index.ts` — return database connectivity status (Prisma `$queryRaw`), uptime, version, and memory usage in health response

**Checkpoint**: Observability complete — Application Insights receiving telemetry, all requests logged with correlation IDs

---

## Phase 5: User Story 5 — Terraform Validation (Priority: P2)

**Goal**: Verify Terraform configurations are complete and consistent across environments

**Independent Test**: Run `terraform validate` and `terraform plan -var-file=dev.tfvars` successfully

### Implementation for User Story 5

- [ ] T020 [P] [US5] Review and validate Terraform module configurations in `infrastructure/terraform/modules/` — verify all modules (app-service, database, key-vault, networking, storage, app-configuration, monitoring) have proper variable definitions, outputs, and resource dependencies
- [ ] T021 [P] [US5] Verify environment-specific tfvars in `infrastructure/terraform/environments/` — ensure dev, staging, prod tfvars define correct SKUs, scaling settings, and network configurations; verify variable values match architecture spec (e.g., PostgreSQL Flexible Server, App Service, Static Web App)
- [ ] T022 [US5] Create Terraform deployment documentation in `infrastructure/terraform/README.md` — document prerequisites (Azure CLI, Terraform CLI, service principal), environment setup steps, `terraform init/plan/apply` workflow, state management (backend config), and module dependency order

**Checkpoint**: Infrastructure validated — Terraform configurations are consistent and documented

---

## Phase 6: Prisma Schema Migrations (Priority: P1)

**Goal**: Align Prisma schema with architecture spec (entraId field, MAINTAINER role, SQLSERVER enum)

**Independent Test**: Run `npx prisma migrate dev` and verify schema changes apply without errors

### Implementation for Prisma Migrations

- [ ] T023 [US1] Add `entraId` field to User model in `src/backend/prisma/schema.prisma` — String, unique, optional (nullable for migration), mapped to `entra_id` column; add unique index
- [ ] T024 [US2] Rename Role enum value `EDITOR` to `MAINTAINER` in `src/backend/prisma/schema.prisma` — update the Role enum; this requires a two-step Prisma migration: (1) add MAINTAINER, (2) migrate data from EDITOR to MAINTAINER, (3) remove EDITOR
- [ ] T025 [P] [US3] Add `SQLSERVER` to RdbmsType enum in `src/backend/prisma/schema.prisma` — add the new enum value for SQL Server support
- [ ] T026 [US1] Remove legacy `passwordHash` field from User model in `src/backend/prisma/schema.prisma` — drop the field since auth is Entra ID-only; ensure seed.ts no longer references it
- [ ] T027 Generate and test Prisma migration for T023–T026 changes — run `npx prisma migrate dev --name architecture-alignment`, verify migration SQL, update seed.ts to use entraId instead of passwordHash, run `npx prisma generate`

**Checkpoint**: Prisma schema aligned with architecture spec — all migrations applied successfully

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T028 [P] Add security headers middleware in `src/backend/src/middleware/securityHeaders.ts` — implement Content-Security-Policy (`default-src 'self'; script-src 'self'; connect-src 'self' https://login.microsoftonline.com https://*.azure.com; img-src 'self' data: https:`), X-Frame-Options, X-Content-Type-Options, Strict-Transport-Security headers
- [ ] T029 [P] Add API response time logging to identify slow queries — enhance Winston logging to warn on responses >100ms for simple queries and >500ms for complex queries (search, reports)
- [ ] T030 [P] Update `src/backend/src/middleware/auth.ts` to auto-create/update local User record on first Entra ID login — upsert User by entraId (oid claim), cache displayName and email from token claims
- [ ] T031 [P] Add OpenAPI/Swagger documentation setup — install `swagger-jsdoc` and `swagger-ui-express`, create `src/backend/src/config/swagger.ts`, serve at `/api-docs`, document all existing endpoints
- [ ] T032 Review and update `ARCHITECTURE.md` to reflect current implementation state — update component descriptions, remove references to "Editor" role, confirm all architecture decisions match codebase
- [ ] T033 Run backend test suite and fix any failures — execute `cd src/backend && npm test` and address test failures related to architecture changes (new middleware, audit service, schema migration)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Foundational Gaps)**: No dependencies — can start immediately
- **Phase 2 (Audit Integration)**: Depends on T004 (audit service) from Phase 1
- **Phase 3 (API Hardening)**: Depends on T001, T002, T003 from Phase 1
- **Phase 4 (Monitoring)**: No dependencies on other phases — can run in parallel with Phases 2–3
- **Phase 5 (Terraform)**: No dependencies on other phases — can run in parallel
- **Phase 6 (Prisma Migration)**: No dependencies on other phases — can run in parallel, but should be done before T030
- **Phase 7 (Polish)**: Depends on Phases 1–6 completion

### Within Each Phase

- Utilities/services before middleware registration
- Middleware creation before registration in index.ts
- Schema changes before migration generation
- All changes before test suite run (T033)

### Parallel Opportunities

**Phase 1**: All tasks T001–T004 can run in parallel (different files)
**Phase 2**: T006–T009 can run in parallel after T005 establishes the pattern
**Phase 3**: T014–T015 can run in parallel with T011–T013
**Phase 4**: T016–T017, T019 can run in parallel
**Phase 5**: T020–T021 can run in parallel
**Phase 6**: T025 can run in parallel with T023–T024
**Phase 7**: T028–T032 can run in parallel; T033 must be last

---

## Implementation Strategy

### Priority Order (Recommended)

1. **Phase 6: Prisma Migrations** (T023–T027) — Align data model first
2. **Phase 1: Foundational Gaps** (T001–T004) — Create missing utilities/services
3. **Phase 2: Audit Integration** (T005–T010) — Wire audit logging into routes
4. **Phase 3: API Hardening** (T011–T015) — Register middleware, standardize responses
5. **Phase 4: Monitoring** (T016–T019) — Add Application Insights
6. **Phase 5: Terraform** (T020–T022) — Validate infrastructure
7. **Phase 7: Polish** (T028–T033) — Security headers, Swagger, tests

### MVP (Minimum to close architecture gaps)

**MVP = Phase 1 + Phase 2 + Phase 6** (T001–T010, T023–T027) = **17 tasks**

This delivers: audit logging integration, error handling, rate limiting, pagination, and schema alignment.

---

## Task Summary

| Phase | Task Range | Count | Purpose |
|-------|-----------|-------|---------|
| Phase 1: Foundational Gaps | T001–T004 | 4 | Error handling, pagination, rate limiting, audit service |
| Phase 2: Audit Integration | T005–T010 | 6 | Wire audit logging into all CRUD routes |
| Phase 3: API Hardening | T011–T015 | 5 | Register middleware, standardize responses |
| Phase 4: Monitoring | T016–T019 | 4 | Application Insights, request logging |
| Phase 5: Terraform | T020–T022 | 3 | Validate and document IaC |
| Phase 6: Prisma Migration | T023–T027 | 5 | Schema alignment (entraId, MAINTAINER, SQLSERVER) |
| Phase 7: Polish | T028–T033 | 6 | Security headers, Swagger, tests, docs |
| **TOTAL** | T001–T033 | **33** | **Complete architecture gaps** |

---

## Notes

- **[P] Marker**: Tasks marked [P] can run in parallel with others in the same phase
- **[Story] Label**: Maps task to user story from spec.md for traceability
- **Existing Code**: ~85% of architecture is already implemented; these 33 tasks close the remaining gaps
- **Soft Deletes**: Already implemented in Prisma schema — no additional work needed
- **RBAC**: Already implemented in auth.ts middleware — no additional work needed
- **JWT/JWKS**: Already implemented — no additional work needed
- **Docker Compose**: Already working — no additional work needed
- **Commit Frequency**: Commit after each task or logical group
- **Test Last**: T033 runs the full test suite after all other tasks complete

---

**Generated**: 2026-02-08
**Format Validation**: ✅ All tasks follow strict checklist format
**User Story Mapping**: ✅ All tasks mapped to user stories from spec.md
**Dependency Order**: ✅ Tasks ordered by dependencies, parallel opportunities marked
**Gap Analysis**: ✅ Tasks derived from plan.md gap analysis (85% → 100% completion)
