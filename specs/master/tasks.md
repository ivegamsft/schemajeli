# Tasks: SchemaJeli System Architecture

**Input**: Design documents from `/specs/master/` and user stories from `/specs/architecture/spec.md`
**Prerequisites**: plan.md, data-model.md, contracts/openapi.yaml, research.md, quickstart.md

**Feature**: Complete SchemaJeli system architecture - cloud-native database metadata repository with Azure Entra ID authentication, RBAC, soft deletes, and full CRUD across the Server → Database → Table → Element hierarchy.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure per plan.md

**Duration Estimate**: 1-2 days

- [ ] T001 Verify repository structure matches plan.md (src/backend/, src/frontend/, infrastructure/, specs/)
- [ ] T002 Initialize backend project with Node.js 18+ and create package.json with Express, Prisma, MSAL dependencies
- [ ] T003 [P] Initialize frontend project with Vite, React 19, and create package.json with MSAL-browser, Zustand, Tailwind dependencies
- [ ] T004 [P] Configure TypeScript with strict mode in src/backend/tsconfig.json
- [ ] T005 [P] Configure TypeScript with strict mode in src/frontend/tsconfig.json
- [ ] T006 [P] Configure ESLint and Prettier in src/backend/.eslintrc.js
- [ ] T007 [P] Configure ESLint and Prettier in src/frontend/.eslintrc.js
- [ ] T008 [P] Create docker-compose.yml with PostgreSQL 15 service (port 5433 per quickstart.md)
- [ ] T009 [P] Create .env.example files for backend and frontend per quickstart.md specifications
- [ ] T010 [P] Setup Vitest configuration in src/backend/vitest.config.ts
- [ ] T011 [P] Setup Vitest configuration in src/frontend/vitest.config.ts
- [ ] T012 [P] Setup Playwright configuration in src/frontend/playwright.config.ts

**Checkpoint**: Foundation structure ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

**Duration Estimate**: 2-3 days

### Database & ORM Setup

- [ ] T013 Create Prisma schema file at src/backend/prisma/schema.prisma based on data-model.md
- [ ] T014 Define User model in src/backend/prisma/schema.prisma (id, email, name, role enum)
- [ ] T015 Define Server model with all fields and indexes in src/backend/prisma/schema.prisma
- [ ] T016 Define Database model with foreign key to Server in src/backend/prisma/schema.prisma
- [ ] T017 Define Table model with foreign key to Database in src/backend/prisma/schema.prisma
- [ ] T018 Define Element model with foreign key to Table in src/backend/prisma/schema.prisma
- [ ] T019 Define Abbreviation model in src/backend/prisma/schema.prisma
- [ ] T020 Define AuditLog model in src/backend/prisma/schema.prisma
- [ ] T021 Add soft delete fields (deletedAt) to all entity models per data-model.md
- [ ] T022 Add audit fields (createdAt, updatedAt, createdById, updatedById) to all entity models
- [ ] T023 Create initial Prisma migration with `npx prisma migrate dev --name init`
- [ ] T024 Create Prisma Client generation script in src/backend/package.json scripts

### Backend Core Infrastructure

- [ ] T025 Create Express app setup in src/backend/src/app.ts with middleware stack
- [ ] T026 [P] Create Winston logger configuration in src/backend/src/config/logger.ts with JSON format
- [ ] T027 [P] Create error handling middleware in src/backend/src/middleware/error-handler.ts
- [ ] T028 [P] Create correlation ID middleware in src/backend/src/middleware/correlation-id.ts
- [ ] T029 [P] Create request logging middleware in src/backend/src/middleware/request-logger.ts
- [ ] T030 [P] Create Prisma soft delete middleware in src/backend/src/utils/prisma-soft-delete.middleware.ts
- [ ] T031 Create Prisma client singleton in src/backend/src/config/database.ts with middleware registration
- [ ] T032 Create environment configuration loader in src/backend/src/config/env.ts
- [ ] T033 Create server entry point in src/backend/src/index.ts

### API Foundation

- [ ] T034 Create base API router structure in src/backend/src/api/v1/index.ts
- [ ] T035 [P] Create response envelope utility in src/backend/src/utils/response.ts (status, data, message)
- [ ] T036 [P] Create pagination utility in src/backend/src/utils/pagination.ts (page, limit, total, totalPages)
- [ ] T037 [P] Create validation utility with Zod in src/backend/src/utils/validation.ts
- [ ] T038 Create health check endpoint in src/backend/src/api/health.ts (database connection check)

### Frontend Foundation

- [ ] T039 Create Vite app entry point in src/frontend/src/main.tsx
- [ ] T040 Create React App component structure in src/frontend/src/App.tsx
- [ ] T041 [P] Setup Tailwind CSS v4 in src/frontend/tailwind.config.js
- [ ] T042 [P] Create Zustand auth store structure in src/frontend/src/store/authStore.ts
- [ ] T043 [P] Create API client base with axios in src/frontend/src/services/apiClient.ts

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Secure Authentication via Azure Entra ID (Priority: P1) 🎯 MVP

**Goal**: Users can securely sign in to SchemaJeli using Azure Entra ID credentials and access protected API endpoints with valid JWT tokens.

**Independent Test**: User clicks "Sign In", authenticates via Microsoft login, receives a valid JWT, and can call the health endpoint successfully with Bearer token.

**Acceptance Criteria**:
1. MSAL frontend flow redirects to Microsoft login
2. Backend validates JWT via JWKS endpoint
3. Invalid/missing tokens return 401 Unauthorized
4. Local dev mode supports RBAC_MOCK_ROLES fallback

**Duration Estimate**: 3-4 days

### Backend Authentication Implementation

- [ ] T044 [P] [US1] Install @azure/msal-node and jsonwebtoken packages in src/backend/package.json
- [ ] T045 [US1] Create Azure Entra ID configuration in src/backend/src/config/azure-ad.ts (tenant, client ID, JWKS URI)
- [ ] T046 [US1] Create JWT validation middleware in src/backend/src/middleware/auth.ts (validate via JWKS)
- [ ] T047 [US1] Implement JWKS caching mechanism in src/backend/src/utils/jwks-cache.ts (TTL 24h)
- [ ] T048 [US1] Create user extraction logic from JWT claims in src/backend/src/utils/token-parser.ts
- [ ] T049 [US1] Implement user auto-creation service in src/backend/src/services/user.service.ts (upsert from token)
- [ ] T050 [US1] Add mock auth mode support in src/backend/src/middleware/auth.ts (RBAC_MOCK_ROLES check)
- [ ] T051 [US1] Apply authentication middleware to all API routes in src/backend/src/api/v1/index.ts
- [ ] T052 [US1] Create unit tests for JWT validation in src/backend/tests/unit/middleware/auth.test.ts
- [ ] T053 [US1] Create integration test for protected endpoint in src/backend/tests/integration/auth.test.ts

### Frontend Authentication Implementation

- [ ] T054 [P] [US1] Install @azure/msal-browser and @azure/msal-react packages in src/frontend/package.json
- [ ] T055 [US1] Create MSAL configuration in src/frontend/src/config/msalConfig.ts (tenant, client ID, redirect URI)
- [ ] T056 [US1] Initialize MSAL instance in src/frontend/src/services/authService.ts
- [ ] T057 [US1] Create MsalProvider wrapper in src/frontend/src/App.tsx
- [ ] T058 [US1] Implement token acquisition hook in src/frontend/src/hooks/useAuth.ts
- [ ] T059 [US1] Add axios interceptor for Bearer token injection in src/frontend/src/services/apiClient.ts
- [ ] T060 [US1] Create Sign In button component in src/frontend/src/components/Auth/SignInButton.tsx
- [ ] T061 [US1] Create Sign Out button component in src/frontend/src/components/Auth/SignOutButton.tsx
- [ ] T062 [US1] Create authentication callback handler in src/frontend/src/pages/AuthCallback.tsx
- [ ] T063 [US1] Update Zustand auth store with token management in src/frontend/src/store/authStore.ts
- [ ] T064 [US1] Create protected route wrapper component in src/frontend/src/components/Auth/ProtectedRoute.tsx
- [ ] T065 [US1] Create unit tests for authService in src/frontend/tests/unit/services/authService.test.ts
- [ ] T066 [US1] Create E2E test for sign-in flow in src/frontend/tests/e2e/auth.spec.ts

**Checkpoint**: Authentication fully functional - users can sign in and call protected endpoints

---

## Phase 4: User Story 2 - Role-Based Access Control (Priority: P1)

**Goal**: Three distinct role levels (Admin, Maintainer, Viewer) enforced on every API endpoint based on Azure Entra ID group membership.

**Independent Test**: A Viewer user attempting a DELETE request receives 403 Forbidden; an Admin performing the same request succeeds.

**Acceptance Criteria**:
1. Admin role has full CRUD access
2. Maintainer can create/update but cannot delete servers
3. Viewer has read-only access
4. Role derived from token groups claim matching RBAC_GROUP_* env vars

**Duration Estimate**: 2-3 days

### Backend RBAC Implementation

- [ ] T067 [P] [US2] Create role enum type in src/backend/src/types/roles.ts (ADMIN, MAINTAINER, VIEWER)
- [ ] T068 [US2] Create role extraction utility from token groups claim in src/backend/src/utils/role-mapper.ts
- [ ] T069 [US2] Implement RBAC middleware in src/backend/src/middleware/rbac.ts (check required roles)
- [ ] T070 [US2] Create role requirement decorator/wrapper in src/backend/src/utils/rbac-decorator.ts
- [ ] T071 [US2] Add rate limiting middleware in src/backend/src/middleware/rate-limiter.ts (100 req/min per user)
- [ ] T072 [US2] Create unit tests for role mapper in src/backend/tests/unit/utils/role-mapper.test.ts
- [ ] T073 [US2] Create unit tests for RBAC middleware in src/backend/tests/unit/middleware/rbac.test.ts
- [ ] T074 [US2] Create integration tests for role enforcement in src/backend/tests/integration/rbac.test.ts

### Frontend RBAC Implementation

- [ ] T075 [P] [US2] Add user role to Zustand auth store in src/frontend/src/store/authStore.ts
- [ ] T076 [US2] Create role-based UI component wrapper in src/frontend/src/components/Auth/RoleGuard.tsx
- [ ] T077 [US2] Create hook for checking user permissions in src/frontend/src/hooks/usePermissions.ts
- [ ] T078 [US2] Update navigation to hide unauthorized actions in src/frontend/src/components/Layout/Navigation.tsx
- [ ] T079 [US2] Create unit tests for RoleGuard in src/frontend/tests/unit/components/Auth/RoleGuard.test.ts

**Checkpoint**: RBAC fully enforced - all endpoints respect role permissions

---

## Phase 5: User Story 3 - Schema Entity CRUD with Soft Deletes (Priority: P1)

**Goal**: Full CRUD operations on the Server → Database → Table → Element hierarchy with soft deletes ensuring metadata is never physically lost.

**Independent Test**: Create a Server, add a Database to it, add Tables and Elements, soft-delete a Table, verify it's excluded from default queries but present in admin deleted view.

**Acceptance Criteria**:
1. All entities support create, read, update, delete operations
2. Deletes are soft (set deletedAt timestamp)
3. Cascade soft deletes propagate down hierarchy
4. AuditLog captures all modifications
5. Foreign key constraints prevent orphan records

**Duration Estimate**: 5-7 days

### Server Entity Implementation

- [ ] T080 [P] [US3] Create Server validation schemas in src/backend/src/validators/server.validator.ts
- [ ] T081 [P] [US3] Create Server service in src/backend/src/services/server.service.ts (CRUD methods)
- [ ] T082 [US3] Implement getServers with pagination in src/backend/src/services/server.service.ts
- [ ] T083 [US3] Implement getServerById with include databases in src/backend/src/services/server.service.ts
- [ ] T084 [US3] Implement createServer with audit logging in src/backend/src/services/server.service.ts
- [ ] T085 [US3] Implement updateServer with optimistic locking in src/backend/src/services/server.service.ts
- [ ] T086 [US3] Implement softDeleteServer with cascade logic in src/backend/src/services/server.service.ts
- [ ] T087 [US3] Create Server controller in src/backend/src/api/v1/controllers/server.controller.ts
- [ ] T088 [US3] Create Server routes in src/backend/src/api/v1/routes/server.routes.ts with RBAC
- [ ] T089 [US3] Create unit tests for Server service in src/backend/tests/unit/services/server.service.test.ts
- [ ] T090 [US3] Create integration tests for Server endpoints in src/backend/tests/integration/api/servers.test.ts

### Database Entity Implementation

- [ ] T091 [P] [US3] Create Database validation schemas in src/backend/src/validators/database.validator.ts
- [ ] T092 [P] [US3] Create Database service in src/backend/src/services/database.service.ts (CRUD methods)
- [ ] T093 [US3] Implement getDatabases with server filter in src/backend/src/services/database.service.ts
- [ ] T094 [US3] Implement getDatabaseById with include tables in src/backend/src/services/database.service.ts
- [ ] T095 [US3] Implement createDatabase with parent validation in src/backend/src/services/database.service.ts
- [ ] T096 [US3] Implement updateDatabase with audit logging in src/backend/src/services/database.service.ts
- [ ] T097 [US3] Implement softDeleteDatabase with cascade to tables in src/backend/src/services/database.service.ts
- [ ] T098 [US3] Create Database controller in src/backend/src/api/v1/controllers/database.controller.ts
- [ ] T099 [US3] Create Database routes in src/backend/src/api/v1/routes/database.routes.ts with RBAC
- [ ] T100 [US3] Create unit tests for Database service in src/backend/tests/unit/services/database.service.test.ts
- [ ] T101 [US3] Create integration tests for Database endpoints in src/backend/tests/integration/api/databases.test.ts

### Table Entity Implementation

- [ ] T102 [P] [US3] Create Table validation schemas in src/backend/src/validators/table.validator.ts
- [ ] T103 [P] [US3] Create Table service in src/backend/src/services/table.service.ts (CRUD methods)
- [ ] T104 [US3] Implement getTables with database filter in src/backend/src/services/table.service.ts
- [ ] T105 [US3] Implement getTableById with include elements in src/backend/src/services/table.service.ts
- [ ] T106 [US3] Implement createTable with parent validation in src/backend/src/services/table.service.ts
- [ ] T107 [US3] Implement updateTable with audit logging in src/backend/src/services/table.service.ts
- [ ] T108 [US3] Implement softDeleteTable with cascade to elements in src/backend/src/services/table.service.ts
- [ ] T109 [US3] Create Table controller in src/backend/src/api/v1/controllers/table.controller.ts
- [ ] T110 [US3] Create Table routes in src/backend/src/api/v1/routes/table.routes.ts with RBAC
- [ ] T111 [US3] Create unit tests for Table service in src/backend/tests/unit/services/table.service.test.ts
- [ ] T112 [US3] Create integration tests for Table endpoints in src/backend/tests/integration/api/tables.test.ts

### Element Entity Implementation

- [ ] T113 [P] [US3] Create Element validation schemas in src/backend/src/validators/element.validator.ts
- [ ] T114 [P] [US3] Create Element service in src/backend/src/services/element.service.ts (CRUD methods)
- [ ] T115 [US3] Implement getElements with table filter in src/backend/src/services/element.service.ts
- [ ] T116 [US3] Implement getElementById in src/backend/src/services/element.service.ts
- [ ] T117 [US3] Implement createElement with position validation in src/backend/src/services/element.service.ts
- [ ] T118 [US3] Implement updateElement with audit logging in src/backend/src/services/element.service.ts
- [ ] T119 [US3] Implement softDeleteElement in src/backend/src/services/element.service.ts
- [ ] T120 [US3] Create Element controller in src/backend/src/api/v1/controllers/element.controller.ts
- [ ] T121 [US3] Create Element routes in src/backend/src/api/v1/routes/element.routes.ts with RBAC
- [ ] T122 [US3] Create unit tests for Element service in src/backend/tests/unit/services/element.service.test.ts
- [ ] T123 [US3] Create integration tests for Element endpoints in src/backend/tests/integration/api/elements.test.ts

### Abbreviation Entity Implementation

- [ ] T124 [P] [US3] Create Abbreviation validation schemas in src/backend/src/validators/abbreviation.validator.ts
- [ ] T125 [P] [US3] Create Abbreviation service in src/backend/src/services/abbreviation.service.ts (CRUD methods)
- [ ] T126 [US3] Implement getAbbreviations with pagination in src/backend/src/services/abbreviation.service.ts
- [ ] T127 [US3] Implement getAbbreviationById in src/backend/src/services/abbreviation.service.ts
- [ ] T128 [US3] Implement createAbbreviation with uniqueness check in src/backend/src/services/abbreviation.service.ts
- [ ] T129 [US3] Implement updateAbbreviation with audit logging in src/backend/src/services/abbreviation.service.ts
- [ ] T130 [US3] Implement softDeleteAbbreviation in src/backend/src/services/abbreviation.service.ts
- [ ] T131 [US3] Create Abbreviation controller in src/backend/src/api/v1/controllers/abbreviation.controller.ts
- [ ] T132 [US3] Create Abbreviation routes in src/backend/src/api/v1/routes/abbreviation.routes.ts with RBAC
- [ ] T133 [US3] Create unit tests for Abbreviation service in src/backend/tests/unit/services/abbreviation.service.test.ts
- [ ] T134 [US3] Create integration tests for Abbreviation endpoints in src/backend/tests/integration/api/abbreviations.test.ts

### Audit Logging Implementation

- [ ] T135 [US3] Create audit middleware in src/backend/src/middleware/audit.ts (intercept mutations)
- [ ] T136 [US3] Implement AuditLog service in src/backend/src/services/audit-log.service.ts
- [ ] T137 [US3] Create audit log query endpoint in src/backend/src/api/v1/controllers/audit-log.controller.ts
- [ ] T138 [US3] Create unit tests for audit middleware in src/backend/tests/unit/middleware/audit.test.ts

### Frontend CRUD UI Implementation

- [ ] T139 [P] [US3] Create Server list page in src/frontend/src/pages/Servers/ServerList.tsx
- [ ] T140 [P] [US3] Create Server detail page in src/frontend/src/pages/Servers/ServerDetail.tsx
- [ ] T141 [P] [US3] Create Server create/edit form in src/frontend/src/components/Servers/ServerForm.tsx
- [ ] T142 [P] [US3] Create Database list component in src/frontend/src/components/Databases/DatabaseList.tsx
- [ ] T143 [P] [US3] Create Database detail page in src/frontend/src/pages/Databases/DatabaseDetail.tsx
- [ ] T144 [P] [US3] Create Database create/edit form in src/frontend/src/components/Databases/DatabaseForm.tsx
- [ ] T145 [P] [US3] Create Table list component in src/frontend/src/components/Tables/TableList.tsx
- [ ] T146 [P] [US3] Create Table detail page in src/frontend/src/pages/Tables/TableDetail.tsx
- [ ] T147 [P] [US3] Create Table create/edit form in src/frontend/src/components/Tables/TableForm.tsx
- [ ] T148 [P] [US3] Create Element list component in src/frontend/src/components/Elements/ElementList.tsx
- [ ] T149 [P] [US3] Create Element create/edit form in src/frontend/src/components/Elements/ElementForm.tsx
- [ ] T150 [P] [US3] Create Abbreviation list page in src/frontend/src/pages/Abbreviations/AbbreviationList.tsx
- [ ] T151 [P] [US3] Create Abbreviation create/edit form in src/frontend/src/components/Abbreviations/AbbreviationForm.tsx
- [ ] T152 [US3] Create API service methods in src/frontend/src/services/api/ for all entities
- [ ] T153 [US3] Create Zustand stores for entity state management in src/frontend/src/store/
- [ ] T154 [US3] Create reusable DataTable component in src/frontend/src/components/common/DataTable.tsx
- [ ] T155 [US3] Create reusable ConfirmDialog component in src/frontend/src/components/common/ConfirmDialog.tsx
- [ ] T156 [US3] Wire up routing in src/frontend/src/App.tsx
- [ ] T157 [US3] Create E2E test for server CRUD flow in src/frontend/tests/e2e/server-crud.spec.ts
- [ ] T158 [US3] Create E2E test for soft delete behavior in src/frontend/tests/e2e/soft-delete.spec.ts

**Checkpoint**: Core CRUD functionality complete - all entities manageable with soft deletes and audit trail

---

## Phase 6: User Story 4 - API Infrastructure & Standards (Priority: P2)

**Goal**: Consistent REST API with versioned routes, standard response envelopes, pagination, proper error handling, and rate limiting for reliable frontend development.

**Independent Test**: Call any list endpoint with pagination parameters and verify response envelope includes `{ status, data, total, page, limit, totalPages }`.

**Acceptance Criteria**:
1. All list endpoints support pagination via query params
2. All responses use standard envelope format
3. Validation errors return 400 with clear messages
4. Rate limiting enforced at 100 req/min per user
5. 404 returns JSON (not HTML)

**Duration Estimate**: 2-3 days

### API Standards Implementation

- [ ] T159 [P] [US4] Create OpenAPI spec generator script in src/backend/scripts/generate-openapi.ts
- [ ] T160 [P] [US4] Create Swagger UI endpoint in src/backend/src/api/v1/docs.ts
- [ ] T161 [US4] Update all controllers to use standardized response envelope from T035
- [ ] T162 [US4] Update all list endpoints to use pagination utility from T036
- [ ] T163 [US4] Create input validation middleware for all endpoints in src/backend/src/middleware/validate-request.ts
- [ ] T164 [US4] Update 404 handler to return JSON in src/backend/src/middleware/error-handler.ts
- [ ] T165 [US4] Create API versioning middleware in src/backend/src/middleware/api-version.ts
- [ ] T166 [US4] Document all endpoints in src/backend/docs/api.md
- [ ] T167 [US4] Create integration test for pagination in src/backend/tests/integration/pagination.test.ts
- [ ] T168 [US4] Create integration test for error responses in src/backend/tests/integration/error-handling.test.ts
- [ ] T169 [US4] Create integration test for rate limiting in src/backend/tests/integration/rate-limiting.test.ts

**Checkpoint**: API standards fully implemented and documented

---

## Phase 7: User Story 5 - Azure Infrastructure via Terraform (Priority: P2)

**Goal**: Repeatable Azure infrastructure provisioned via Terraform for consistent dev/staging/prod environments.

**Independent Test**: Run `terraform plan` for dev environment and verify all resources are defined without errors.

**Acceptance Criteria**:
1. Terraform defines App Service, PostgreSQL, Key Vault, Storage, Monitoring
2. Dev, staging, and prod environments use different variable files
3. All secrets stored in Azure Key Vault
4. Terraform state managed remotely

**Duration Estimate**: 3-4 days

### Terraform Infrastructure Setup

- [ ] T170 [P] [US5] Create Terraform provider configuration in infrastructure/terraform/main.tf
- [ ] T171 [P] [US5] Create Terraform variables in infrastructure/terraform/variables.tf
- [ ] T172 [P] [US5] Create Terraform outputs in infrastructure/terraform/outputs.tf
- [ ] T173 [US5] Create resource group module in infrastructure/terraform/modules/resource-group/main.tf
- [ ] T174 [P] [US5] Create App Service module in infrastructure/terraform/modules/app-service/main.tf
- [ ] T175 [P] [US5] Create PostgreSQL Flexible Server module in infrastructure/terraform/modules/postgresql/main.tf
- [ ] T176 [P] [US5] Create Azure Key Vault module in infrastructure/terraform/modules/key-vault/main.tf
- [ ] T177 [P] [US5] Create Static Web App module in infrastructure/terraform/modules/static-web-app/main.tf
- [ ] T178 [P] [US5] Create Application Insights module in infrastructure/terraform/modules/app-insights/main.tf
- [ ] T179 [P] [US5] Create Storage Account module in infrastructure/terraform/modules/storage/main.tf
- [ ] T180 [US5] Wire up all modules in infrastructure/terraform/main.tf
- [ ] T181 [US5] Create dev environment variables in infrastructure/terraform/environments/dev.tfvars
- [ ] T182 [P] [US5] Create staging environment variables in infrastructure/terraform/environments/staging.tfvars
- [ ] T183 [P] [US5] Create prod environment variables in infrastructure/terraform/environments/prod.tfvars
- [ ] T184 [US5] Configure remote state backend in infrastructure/terraform/backend.tf
- [ ] T185 [US5] Create Terraform deployment guide in infrastructure/terraform/README.md
- [ ] T186 [US5] Test terraform plan for dev environment

**Checkpoint**: Infrastructure as Code complete and validated

---

## Phase 8: User Story 6 - Monitoring & Observability (Priority: P3)

**Goal**: Structured logging and Application Insights integration for monitoring application health and diagnosing production issues.

**Independent Test**: Trigger an API request and verify Winston logs include correlation ID and Application Insights receives telemetry.

**Acceptance Criteria**:
1. Winston logs include method, path, status, duration, correlation ID
2. Unhandled exceptions logged with full stack trace
3. Application Insights receives requests, dependencies, and exceptions
4. Log levels configurable via environment variable

**Duration Estimate**: 2-3 days

### Monitoring Implementation

- [ ] T187 [P] [US6] Install @azure/monitor-opentelemetry and applicationinsights packages
- [ ] T188 [US6] Configure Application Insights in src/backend/src/config/app-insights.ts
- [ ] T189 [US6] Initialize Application Insights in src/backend/src/index.ts
- [ ] T190 [US6] Add custom event tracking utility in src/backend/src/utils/telemetry.ts
- [ ] T191 [US6] Create performance tracking middleware in src/backend/src/middleware/performance.ts
- [ ] T192 [US6] Update error handler to report to App Insights in src/backend/src/middleware/error-handler.ts
- [ ] T193 [US6] Add dependency tracking for Prisma queries in src/backend/src/config/database.ts
- [ ] T194 [US6] Create custom metrics for CRUD operations in src/backend/src/services/
- [ ] T195 [US6] Create monitoring dashboard queries in infrastructure/monitoring/queries.kusto
- [ ] T196 [US6] Create unit tests for telemetry utility in src/backend/tests/unit/utils/telemetry.test.ts

### Frontend Monitoring

- [ ] T197 [P] [US6] Install @microsoft/applicationinsights-web package
- [ ] T198 [US6] Configure Application Insights React plugin in src/frontend/src/config/appInsights.ts
- [ ] T199 [US6] Add error boundary with telemetry in src/frontend/src/components/ErrorBoundary.tsx
- [ ] T200 [US6] Track user interactions in src/frontend/src/utils/analytics.ts

**Checkpoint**: Full observability in place for production readiness

---

## Phase 9: User Story 7 - Local Development Experience (Priority: P3)

**Goal**: Developers can run the full stack locally via Docker Compose with mock authentication for development without Azure dependencies.

**Independent Test**: Run `docker-compose up -d`, set `RBAC_MOCK_ROLES=Admin`, call health endpoint, and get successful response.

**Acceptance Criteria**:
1. Docker Compose starts PostgreSQL, backend, and frontend
2. Backend supports RBAC_MOCK_ROLES for local development
3. Hot reload works for both backend and frontend
4. Seed data script available for local testing

**Duration Estimate**: 2-3 days

### Docker & Local Development

- [ ] T201 [P] [US7] Create backend Dockerfile in src/backend/Dockerfile (multi-stage build)
- [ ] T202 [P] [US7] Create frontend Dockerfile in src/frontend/Dockerfile (nginx serving)
- [ ] T203 [US7] Update docker-compose.yml with backend and frontend services
- [ ] T204 [US7] Add health check endpoints to docker-compose.yml
- [ ] T205 [US7] Create database seed script in src/backend/prisma/seed.ts
- [ ] T206 [US7] Add seed script to package.json in src/backend/package.json
- [ ] T207 [US7] Create local development guide in docs/LOCAL_DEVELOPMENT.md
- [ ] T208 [US7] Create VSCode debug configurations in .vscode/launch.json
- [ ] T209 [US7] Create .dockerignore files for backend and frontend
- [ ] T210 [US7] Test full stack startup with docker-compose up

**Checkpoint**: Local development environment fully functional

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final production readiness

**Duration Estimate**: 2-3 days

### Documentation

- [ ] T211 [P] Update README.md with project overview and quick start
- [ ] T212 [P] Update ARCHITECTURE.md with final architecture diagrams
- [ ] T213 [P] Create API usage examples in docs/API_EXAMPLES.md
- [ ] T214 [P] Create troubleshooting guide in docs/TROUBLESHOOTING.md
- [ ] T215 [P] Update CONTRIBUTING.md with development workflow

### CI/CD Pipeline

- [ ] T216 [P] Create backend CI workflow in .github/workflows/backend-ci.yml (lint, test, build)
- [ ] T217 [P] Create frontend CI workflow in .github/workflows/frontend-ci.yml (lint, test, build)
- [ ] T218 [US5] Create Azure deployment workflow in .github/workflows/deploy.yml (Terraform apply)
- [ ] T219 [P] Add code coverage reporting to CI workflows
- [ ] T220 [P] Add security scanning with Snyk in .github/workflows/security.yml

### Performance & Security

- [ ] T221 [P] Add database connection pooling configuration optimization
- [ ] T222 [P] Implement query result caching for frequently accessed data
- [ ] T223 [P] Add Helmet.js security headers middleware
- [ ] T224 [P] Configure CORS properly for production
- [ ] T225 [P] Add input sanitization for all user inputs
- [ ] T226 [P] Create performance test suite with k6 in tests/performance/

### Testing & Quality

- [ ] T227 Create seed data for E2E tests in src/backend/prisma/seed-test.ts
- [ ] T228 Run full E2E test suite and fix any failures
- [ ] T229 Verify test coverage meets requirements (Backend ≥80%, Frontend ≥70%)
- [ ] T230 Run security audit with npm audit and fix vulnerabilities
- [ ] T231 Perform load testing with 100 concurrent users
- [ ] T232 Validate all quickstart.md steps work from clean state

### Final Validation

- [ ] T233 Deploy to dev environment and smoke test all features
- [ ] T234 Deploy to staging and run full regression test suite
- [ ] T235 Review and update all environment variable documentation
- [ ] T236 Create production deployment checklist
- [ ] T237 Final security review and penetration testing

**Checkpoint**: System production-ready

---

## Dependencies & Execution Order

### Phase Dependencies

1. **Phase 1 (Setup)**: No dependencies - can start immediately
2. **Phase 2 (Foundational)**: Depends on Phase 1 completion - BLOCKS all user stories
3. **Phase 3 (US1 - Auth)**: Depends on Phase 2 completion - Can proceed in parallel with US2
4. **Phase 4 (US2 - RBAC)**: Depends on Phase 2 completion and Phase 3 (auth) - Required for US3
5. **Phase 5 (US3 - CRUD)**: Depends on Phase 2, Phase 3, and Phase 4 completion
6. **Phase 6 (US4 - API Standards)**: Can run in parallel with Phase 5 or after
7. **Phase 7 (US5 - Terraform)**: Can run in parallel with Phase 3-6
8. **Phase 8 (US6 - Monitoring)**: Can run in parallel with Phase 3-7
9. **Phase 9 (US7 - Local Dev)**: Can run in parallel with Phase 3-8
10. **Phase 10 (Polish)**: Depends on all desired user stories being complete

### User Story Dependencies

```
Phase 2 (Foundation) ← BLOCKS ALL STORIES
     ↓
Phase 3 (US1: Auth) ← MVP Core
     ↓
Phase 4 (US2: RBAC) ← MVP Core
     ↓
Phase 5 (US3: CRUD) ← MVP Core
     ↓
Phase 6 (US4: API Standards) ← Enhancement
Phase 7 (US5: Terraform) ← Infrastructure (can be parallel)
Phase 8 (US6: Monitoring) ← Observability (can be parallel)
Phase 9 (US7: Local Dev) ← Developer Experience (can be parallel)
```

### Parallel Opportunities Within Phases

**Phase 1 (Setup)**: Tasks T003-T012 can run in parallel (different projects/configs)

**Phase 2 (Foundational)**:
- T026-T030 (middleware) can run in parallel
- T034-T038 (API utilities) can run in parallel
- T039-T043 (frontend foundation) can run in parallel

**Phase 3 (US1 - Auth)**:
- T044 (install packages) must complete first
- T052-T053 (backend tests) can run in parallel after implementation
- T054 (install packages) must complete first
- Frontend tasks T055-T066 can proceed in parallel with backend

**Phase 5 (US3 - CRUD)**:
- All validation schemas (T080, T091, T102, T113, T124) can be created in parallel
- All service files can be started in parallel (T081, T092, T103, T114, T125)
- Frontend components (T139-T151) can be created in parallel
- Tests can run in parallel with other entity implementations

**Phase 7 (US5 - Terraform)**:
- All module creations (T174-T179) can run in parallel
- Environment variable files (T182-T183) can be created in parallel

---

## Parallel Example: Phase 5 User Story 3

```bash
# Launch all validation schemas in parallel (different files):
Task T080: "Create Server validation schemas in src/backend/src/validators/server.validator.ts"
Task T091: "Create Database validation schemas in src/backend/src/validators/database.validator.ts"
Task T102: "Create Table validation schemas in src/backend/src/validators/table.validator.ts"
Task T113: "Create Element validation schemas in src/backend/src/validators/element.validator.ts"
Task T124: "Create Abbreviation validation schemas in src/backend/src/validators/abbreviation.validator.ts"

# Launch all service file creations in parallel:
Task T081: "Create Server service in src/backend/src/services/server.service.ts"
Task T092: "Create Database service in src/backend/src/services/database.service.ts"
Task T103: "Create Table service in src/backend/src/services/table.service.ts"
Task T114: "Create Element service in src/backend/src/services/element.service.ts"
Task T125: "Create Abbreviation service in src/backend/src/services/abbreviation.service.ts"
```

---

## Implementation Strategy

### MVP First (Phases 1-5 Only)

**Minimum Viable Product includes**:
1. ✅ Phase 1: Setup (project structure)
2. ✅ Phase 2: Foundational (core infrastructure)
3. ✅ Phase 3: User Story 1 (Authentication via Azure Entra ID)
4. ✅ Phase 4: User Story 2 (RBAC)
5. ✅ Phase 5: User Story 3 (CRUD with soft deletes)

**STOP and VALIDATE**: Test all user stories independently, deploy to dev, get stakeholder feedback.

**Total MVP Duration**: ~15-21 days

### Incremental Delivery After MVP

After MVP validation:
6. Add Phase 6 (US4: API Standards) → Better API consistency
7. Add Phase 7 (US5: Terraform) → Automated infrastructure
8. Add Phase 8 (US6: Monitoring) → Production observability
9. Add Phase 9 (US7: Local Dev) → Better developer experience
10. Complete Phase 10 (Polish) → Production ready

### Parallel Team Strategy

With 3 developers after Phase 2 completion:

- **Developer A**: Phase 3 (US1: Authentication) → Phase 6 (US4: API Standards)
- **Developer B**: Phase 4 (US2: RBAC) → Phase 5 (US3: CRUD backend)
- **Developer C**: Phase 5 (US3: CRUD frontend) → Phase 8 (US6: Monitoring)
- **DevOps Engineer**: Phase 7 (US5: Terraform) + Phase 9 (US7: Docker)

---

## Task Summary

**Total Tasks**: 237
- Phase 1 (Setup): 12 tasks
- Phase 2 (Foundational): 31 tasks
- Phase 3 (US1 - Auth): 23 tasks
- Phase 4 (US2 - RBAC): 13 tasks
- Phase 5 (US3 - CRUD): 79 tasks
- Phase 6 (US4 - API Standards): 11 tasks
- Phase 7 (US5 - Terraform): 17 tasks
- Phase 8 (US6 - Monitoring): 14 tasks
- Phase 9 (US7 - Local Dev): 10 tasks
- Phase 10 (Polish): 27 tasks

**Parallelizable Tasks**: 97 tasks marked [P]

**Estimated Duration**:
- MVP (Phases 1-5): 15-21 days (1 developer) or 8-12 days (3 developers)
- Full Feature (All Phases): 24-33 days (1 developer) or 12-18 days (3 developers)

---

## Success Criteria Validation

After implementation, verify these measurable outcomes:

- [ ] **SC-001**: Users authenticate via Entra ID and access protected resources in under 5 seconds
- [ ] **SC-002**: JWT validation completes in under 10ms per request with cached JWKS keys
- [ ] **SC-003**: RBAC checks complete in under 5ms per request
- [ ] **SC-004**: Simple CRUD queries respond in under 100ms; complex searches under 500ms p95
- [ ] **SC-005**: All entities use soft deletes — zero physical deletions
- [ ] **SC-006**: 100% of data modifications captured in AuditLog
- [ ] **SC-007**: Terraform provisions all Azure resources in dev/staging/prod without manual steps
- [ ] **SC-008**: Docker Compose starts full stack locally in under 60 seconds
- [ ] **SC-009**: Rate limiting blocks excessive requests with 100% accuracy
- [ ] **SC-010**: Test coverage meets targets: Backend ≥80%, Frontend ≥70%, Integration ≥60%

---

## Notes

- **[P] Tasks**: Different files, no dependencies - safe to parallelize
- **[Story] Labels**: Map tasks to user stories for independent testing and delivery
- **Soft Deletes**: All delete operations must use soft delete (set deletedAt, never physical delete)
- **Audit Trail**: All mutations must create AuditLog entries automatically via middleware
- **Type Safety**: All code must pass TypeScript strict mode compilation
- **Tests**: Write tests as you go, not at the end
- **Commits**: Commit after each task or logical group of related tasks
- **Checkpoints**: Stop at each checkpoint to validate story independence before proceeding

---

**Generated**: 2026-02-08
**Based On**: specs/architecture/spec.md (user stories), specs/master/plan.md, specs/master/data-model.md, specs/master/contracts/openapi.yaml
