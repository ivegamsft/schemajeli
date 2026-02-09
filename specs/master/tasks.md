# Tasks: SchemaJeli Architecture Implementation

**Input**: Design documents from `/specs/master/` and `/specs/architecture/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/openapi.yaml ✅, quickstart.md ✅

**Tests**: Tests are NOT included in this implementation plan per TDD requirements from constitution. Tests should be written BEFORE implementation starts.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This project uses web app structure: `src/backend/` and `src/frontend/` directories.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create backend project structure with TypeScript, Express, and Prisma in src/backend/
- [ ] T002 Create frontend project structure with React 19, Vite, and TypeScript in src/frontend/
- [ ] T003 [P] Configure backend package.json with Express, Prisma, MSAL, Winston, Zod dependencies
- [ ] T004 [P] Configure frontend package.json with React 19, Vite, Zustand, Tailwind CSS v4, MSAL dependencies
- [ ] T005 [P] Setup backend TypeScript configuration (tsconfig.json) with strict mode enabled
- [ ] T006 [P] Setup frontend TypeScript configuration (tsconfig.json) with strict mode enabled
- [ ] T007 [P] Configure ESLint and Prettier for both backend and frontend
- [ ] T008 [P] Setup Vitest configuration for backend in src/backend/vitest.config.ts
- [ ] T009 [P] Setup Vitest configuration for frontend in src/frontend/vitest.config.ts
- [ ] T010 [P] Setup Playwright for E2E tests in src/frontend/playwright.config.ts
- [ ] T011 Create docker-compose.yml with PostgreSQL 15 service at repository root
- [ ] T012 [P] Create backend .env.example with all required environment variables
- [ ] T013 [P] Create frontend .env.example with Azure Entra ID configuration
- [ ] T014 Create .gitignore files for backend and frontend with proper Node.js exclusions

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T015 Create Prisma schema with all entities (User, Server, Database, Table, Element, Abbreviation, AuditLog) in src/backend/prisma/schema.prisma
- [ ] T016 Create initial Prisma migration for database schema in src/backend/prisma/migrations/
- [ ] T017 Implement Prisma soft delete middleware in src/backend/src/utils/prisma-soft-delete.middleware.ts
- [ ] T018 [P] Setup Winston structured logging configuration in src/backend/src/config/logger.ts
- [ ] T019 [P] Create Express app setup with middleware stack in src/backend/src/app.ts
- [ ] T020 [P] Implement centralized error handling middleware in src/backend/src/middleware/error.middleware.ts
- [ ] T021 [P] Implement request logging middleware with correlation IDs in src/backend/src/middleware/logging.middleware.ts
- [ ] T022 [P] Create standard response envelope utilities in src/backend/src/utils/response.utils.ts
- [ ] T023 [P] Implement rate limiting middleware (100 req/min) in src/backend/src/middleware/rate-limit.middleware.ts
- [ ] T024 [P] Setup Helmet security middleware in src/backend/src/middleware/security.middleware.ts
- [ ] T025 [P] Configure CORS middleware for frontend access in src/backend/src/middleware/cors.middleware.ts
- [ ] T026 Create base Prisma client instance with middleware in src/backend/src/config/prisma.ts
- [ ] T027 [P] Setup environment configuration loader with validation in src/backend/src/config/env.ts
- [ ] T028 [P] Create health check endpoint in src/backend/src/api/routes/health.routes.ts
- [ ] T029 [P] Setup Vite configuration with Tailwind CSS v4 in src/frontend/vite.config.ts
- [ ] T030 [P] Configure Tailwind CSS v4 in src/frontend/tailwind.config.js
- [ ] T031 [P] Create base React app structure with routing in src/frontend/src/App.tsx

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Secure Authentication via Azure Entra ID (Priority: P1) 🎯 MVP

**Goal**: Users authenticate via Azure Entra ID, receive JWT tokens, and can access protected routes

**Independent Test**: User clicks "Sign In", authenticates via Microsoft login, receives valid JWT, and can call protected API endpoint successfully

### Implementation for User Story 1

- [ ] T032 [P] [US1] Implement MSAL configuration service in src/backend/src/config/msal.config.ts
- [ ] T033 [P] [US1] Create JWT validation utilities in src/backend/src/utils/jwt.utils.ts
- [ ] T034 [P] [US1] Implement JWKS key caching in src/backend/src/utils/jwks-cache.ts
- [ ] T035 [US1] Implement authentication middleware with JWT validation in src/backend/src/middleware/auth.middleware.ts
- [ ] T036 [P] [US1] Create User service for auto-creating users from Entra ID in src/backend/src/services/user.service.ts
- [ ] T037 [P] [US1] Create User model methods in src/backend/src/models/user.model.ts
- [ ] T038 [P] [US1] Implement MSAL browser configuration in src/frontend/src/config/msal.config.ts
- [ ] T039 [P] [US1] Create MSAL authentication context provider in src/frontend/src/contexts/AuthContext.tsx
- [ ] T040 [P] [US1] Create sign-in component in src/frontend/src/components/SignIn.tsx
- [ ] T041 [P] [US1] Create authentication state management with Zustand in src/frontend/src/store/auth.store.ts
- [ ] T042 [P] [US1] Create protected route wrapper component in src/frontend/src/components/ProtectedRoute.tsx
- [ ] T043 [P] [US1] Create API client with MSAL token interceptor in src/frontend/src/services/api.client.ts
- [ ] T044 [US1] Create mock authentication middleware for local dev in src/backend/src/middleware/auth.mock.middleware.ts
- [ ] T045 [US1] Add authentication route fallback logic in src/backend/src/middleware/auth.middleware.ts

**Checkpoint**: At this point, User Story 1 should be fully functional - users can authenticate and receive valid tokens

---

## Phase 4: User Story 2 - Role-Based Access Control (Priority: P1)

**Goal**: Three distinct role levels (Admin, Maintainer, Viewer) enforced on every API endpoint

**Independent Test**: A Viewer user attempting a DELETE request receives 403; an Admin performing the same request succeeds

### Implementation for User Story 2

- [ ] T046 [P] [US2] Create RBAC utilities for role extraction from JWT in src/backend/src/utils/rbac.utils.ts
- [ ] T047 [P] [US2] Implement RBAC middleware with role checking in src/backend/src/middleware/rbac.middleware.ts
- [ ] T048 [P] [US2] Create role permission configuration in src/backend/src/config/permissions.ts
- [ ] T049 [P] [US2] Add role display in frontend header component in src/frontend/src/components/Header.tsx
- [ ] T050 [P] [US2] Create role-based UI component visibility helper in src/frontend/src/utils/permissions.utils.ts
- [ ] T051 [US2] Integrate RBAC middleware with authentication middleware in src/backend/src/middleware/auth.middleware.ts

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - authentication and authorization are complete

---

## Phase 5: User Story 3 - Schema Entity CRUD with Soft Deletes (Priority: P1)

**Goal**: Full CRUD operations on Server → Database → Table → Element hierarchy with soft deletes

**Independent Test**: Create a Server, add a Database to it, add Tables and Elements, soft-delete a Table, verify it's excluded from default queries but restorable

### Implementation for User Story 3

#### Server Entity
- [ ] T052 [P] [US3] Create Server validation schemas with Zod in src/backend/src/validators/server.validator.ts
- [ ] T053 [P] [US3] Implement Server service with CRUD operations in src/backend/src/services/server.service.ts
- [ ] T054 [P] [US3] Create Server controller in src/backend/src/api/controllers/server.controller.ts
- [ ] T055 [US3] Create Server routes with RBAC in src/backend/src/api/routes/server.routes.ts
- [ ] T056 [P] [US3] Create Server list page component in src/frontend/src/pages/Servers/ServerList.tsx
- [ ] T057 [P] [US3] Create Server detail page component in src/frontend/src/pages/Servers/ServerDetail.tsx
- [ ] T058 [P] [US3] Create Server form component in src/frontend/src/components/Servers/ServerForm.tsx
- [ ] T059 [P] [US3] Create Server API service in src/frontend/src/services/server.service.ts

#### Database Entity
- [ ] T060 [P] [US3] Create Database validation schemas with Zod in src/backend/src/validators/database.validator.ts
- [ ] T061 [P] [US3] Implement Database service with CRUD operations in src/backend/src/services/database.service.ts
- [ ] T062 [P] [US3] Create Database controller in src/backend/src/api/controllers/database.controller.ts
- [ ] T063 [US3] Create Database routes with RBAC in src/backend/src/api/routes/database.routes.ts
- [ ] T064 [P] [US3] Create Database list component in src/frontend/src/components/Databases/DatabaseList.tsx
- [ ] T065 [P] [US3] Create Database detail page component in src/frontend/src/pages/Databases/DatabaseDetail.tsx
- [ ] T066 [P] [US3] Create Database form component in src/frontend/src/components/Databases/DatabaseForm.tsx
- [ ] T067 [P] [US3] Create Database API service in src/frontend/src/services/database.service.ts

#### Table Entity
- [ ] T068 [P] [US3] Create Table validation schemas with Zod in src/backend/src/validators/table.validator.ts
- [ ] T069 [P] [US3] Implement Table service with CRUD operations in src/backend/src/services/table.service.ts
- [ ] T070 [P] [US3] Create Table controller in src/backend/src/api/controllers/table.controller.ts
- [ ] T071 [US3] Create Table routes with RBAC in src/backend/src/api/routes/table.routes.ts
- [ ] T072 [P] [US3] Create Table list component in src/frontend/src/components/Tables/TableList.tsx
- [ ] T073 [P] [US3] Create Table detail page component in src/frontend/src/pages/Tables/TableDetail.tsx
- [ ] T074 [P] [US3] Create Table form component in src/frontend/src/components/Tables/TableForm.tsx
- [ ] T075 [P] [US3] Create Table API service in src/frontend/src/services/table.service.ts

#### Element Entity
- [ ] T076 [P] [US3] Create Element validation schemas with Zod in src/backend/src/validators/element.validator.ts
- [ ] T077 [P] [US3] Implement Element service with CRUD operations in src/backend/src/services/element.service.ts
- [ ] T078 [P] [US3] Create Element controller in src/backend/src/api/controllers/element.controller.ts
- [ ] T079 [US3] Create Element routes with RBAC in src/backend/src/api/routes/element.routes.ts
- [ ] T080 [P] [US3] Create Element list component in src/frontend/src/components/Elements/ElementList.tsx
- [ ] T081 [P] [US3] Create Element detail component in src/frontend/src/components/Elements/ElementDetail.tsx
- [ ] T082 [P] [US3] Create Element form component in src/frontend/src/components/Elements/ElementForm.tsx
- [ ] T083 [P] [US3] Create Element API service in src/frontend/src/services/element.service.ts

#### Abbreviation Entity
- [ ] T084 [P] [US3] Create Abbreviation validation schemas with Zod in src/backend/src/validators/abbreviation.validator.ts
- [ ] T085 [P] [US3] Implement Abbreviation service with CRUD operations in src/backend/src/services/abbreviation.service.ts
- [ ] T086 [P] [US3] Create Abbreviation controller in src/backend/src/api/controllers/abbreviation.controller.ts
- [ ] T087 [US3] Create Abbreviation routes with RBAC in src/backend/src/api/routes/abbreviation.routes.ts
- [ ] T088 [P] [US3] Create Abbreviation list page component in src/frontend/src/pages/Abbreviations/AbbreviationList.tsx
- [ ] T089 [P] [US3] Create Abbreviation form component in src/frontend/src/components/Abbreviations/AbbreviationForm.tsx
- [ ] T090 [P] [US3] Create Abbreviation API service in src/frontend/src/services/abbreviation.service.ts

#### Audit Log
- [ ] T091 [P] [US3] Implement AuditLog service for recording changes in src/backend/src/services/audit-log.service.ts
- [ ] T092 [US3] Create audit middleware to auto-log all mutations in src/backend/src/middleware/audit.middleware.ts
- [ ] T093 [P] [US3] Create AuditLog viewer component (Admin only) in src/frontend/src/components/AuditLog/AuditLogViewer.tsx

#### Soft Delete Implementation
- [ ] T094 [US3] Implement cascade soft delete logic for Server → Database → Table → Element in src/backend/src/services/cascade-delete.service.ts
- [ ] T095 [US3] Add soft delete restore functionality in src/backend/src/services/server.service.ts
- [ ] T096 [P] [US3] Create soft delete indicator UI components in src/frontend/src/components/common/DeletedBadge.tsx

**Checkpoint**: All core CRUD operations with soft deletes should be fully functional and independently testable

---

## Phase 6: User Story 4 - API Infrastructure & Standards (Priority: P2)

**Goal**: Consistent REST API with versioned routes, standard response envelopes, pagination, and proper error handling

**Independent Test**: Call any list endpoint and verify the response envelope includes `{ status, data, total, page, limit, totalPages }`

### Implementation for User Story 4

- [ ] T097 [P] [US4] Create pagination utilities in src/backend/src/utils/pagination.utils.ts
- [ ] T098 [P] [US4] Create validation error formatter in src/backend/src/utils/validation-error.utils.ts
- [ ] T099 [P] [US4] Implement API versioning middleware in src/backend/src/middleware/versioning.middleware.ts
- [ ] T100 [US4] Apply pagination to all list endpoints in Server, Database, Table, Element services
- [ ] T101 [P] [US4] Create OpenAPI/Swagger documentation endpoint in src/backend/src/api/routes/docs.routes.ts
- [ ] T102 [P] [US4] Create pagination UI component in src/frontend/src/components/common/Pagination.tsx
- [ ] T103 [P] [US4] Create error boundary component in src/frontend/src/components/ErrorBoundary.tsx
- [ ] T104 [P] [US4] Create loading state component in src/frontend/src/components/common/LoadingSpinner.tsx
- [ ] T105 [P] [US4] Create API error toast notifications in src/frontend/src/components/common/Toast.tsx
- [ ] T106 [US4] Integrate pagination in all frontend list views

**Checkpoint**: API standards should be consistently applied across all endpoints with proper pagination and error handling

---

## Phase 7: User Story 5 - Azure Infrastructure via Terraform (Priority: P2)

**Goal**: Repeatable Azure infrastructure provisioned via Terraform for dev/staging/prod environments

**Independent Test**: Run `terraform plan` for dev environment and verify all resources are defined without errors

### Implementation for User Story 5

- [ ] T107 [P] [US5] Create main Terraform configuration in infrastructure/terraform/main.tf
- [ ] T108 [P] [US5] Define Terraform variables in infrastructure/terraform/variables.tf
- [ ] T109 [P] [US5] Define Terraform outputs in infrastructure/terraform/outputs.tf
- [ ] T110 [P] [US5] Create Azure Resource Group module in infrastructure/terraform/modules/resource-group/
- [ ] T111 [P] [US5] Create App Service Plan module in infrastructure/terraform/modules/app-service-plan/
- [ ] T112 [P] [US5] Create App Service (backend) module in infrastructure/terraform/modules/app-service/
- [ ] T113 [P] [US5] Create Static Web App (frontend) module in infrastructure/terraform/modules/static-web-app/
- [ ] T114 [P] [US5] Create PostgreSQL Flexible Server module in infrastructure/terraform/modules/postgresql/
- [ ] T115 [P] [US5] Create Key Vault module in infrastructure/terraform/modules/key-vault/
- [ ] T116 [P] [US5] Create Application Insights module in infrastructure/terraform/modules/application-insights/
- [ ] T117 [P] [US5] Create Storage Account module in infrastructure/terraform/modules/storage/
- [ ] T118 [P] [US5] Create environment-specific tfvars files (dev.tfvars, staging.tfvars, prod.tfvars) in infrastructure/terraform/
- [ ] T119 [P] [US5] Create Terraform backend configuration for state storage in infrastructure/terraform/backend.tf
- [ ] T120 [US5] Create deployment documentation in infrastructure/terraform/README.md

**Checkpoint**: Terraform configuration should be complete and executable for all environments

---

## Phase 8: User Story 6 - Monitoring & Observability (Priority: P3)

**Goal**: Structured logging and Application Insights integration for production monitoring

**Independent Test**: Trigger an API request and verify Winston logs include correlation ID and Application Insights receives telemetry

### Implementation for User Story 6

- [ ] T121 [P] [US6] Setup Application Insights client in src/backend/src/config/app-insights.ts
- [ ] T122 [P] [US6] Implement Application Insights middleware in src/backend/src/middleware/app-insights.middleware.ts
- [ ] T123 [P] [US6] Create custom telemetry helpers in src/backend/src/utils/telemetry.utils.ts
- [ ] T124 [P] [US6] Add exception tracking to error middleware in src/backend/src/middleware/error.middleware.ts
- [ ] T125 [P] [US6] Add dependency tracking for database calls in src/backend/src/config/prisma.ts
- [ ] T126 [P] [US6] Create performance monitoring utilities in src/backend/src/utils/performance.utils.ts
- [ ] T127 [P] [US6] Setup frontend Application Insights in src/frontend/src/config/app-insights.ts
- [ ] T128 [P] [US6] Add frontend error tracking in src/frontend/src/App.tsx
- [ ] T129 [P] [US6] Create monitoring dashboard documentation in docs/monitoring.md

**Checkpoint**: Full observability stack should be operational with logs and metrics flowing to Application Insights

---

## Phase 9: User Story 7 - Local Development Experience (Priority: P3)

**Goal**: Full stack runs locally via Docker Compose with mock authentication for development without Azure dependencies

**Independent Test**: Run `docker-compose up -d`, set `RBAC_MOCK_ROLES=Admin`, call API endpoint, and get successful response

### Implementation for User Story 7

- [ ] T130 [P] [US7] Enhance docker-compose.yml with backend service configuration
- [ ] T131 [P] [US7] Enhance docker-compose.yml with frontend service configuration
- [ ] T132 [P] [US7] Create backend Dockerfile with multi-stage build in src/backend/Dockerfile
- [ ] T133 [P] [US7] Create frontend Dockerfile with multi-stage build in src/frontend/Dockerfile
- [ ] T134 [P] [US7] Create database seed script in src/backend/prisma/seed.ts
- [ ] T135 [P] [US7] Create local development startup script in scripts/dev-start.sh
- [ ] T136 [P] [US7] Update quickstart.md with complete local setup instructions
- [ ] T137 [P] [US7] Create development troubleshooting guide in docs/troubleshooting.md
- [ ] T138 [US7] Add health check verification to docker-compose services

**Checkpoint**: Complete local development environment should start and run with single command

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final production readiness

- [ ] T139 [P] Create comprehensive API documentation from OpenAPI spec in docs/api.md
- [ ] T140 [P] Create architecture documentation in docs/architecture.md
- [ ] T141 [P] Create database schema documentation with ER diagrams in docs/database.md
- [ ] T142 [P] Update main README.md with project overview and quick links
- [ ] T143 [P] Create CONTRIBUTING.md with development guidelines
- [ ] T144 [P] Setup GitHub Actions CI workflow in .github/workflows/ci.yml
- [ ] T145 [P] Setup GitHub Actions CD workflow for backend in .github/workflows/deploy-backend.yml
- [ ] T146 [P] Setup GitHub Actions CD workflow for frontend in .github/workflows/deploy-frontend.yml
- [ ] T147 [P] Create security scanning workflow in .github/workflows/security-scan.yml
- [ ] T148 [P] Create database backup and restore scripts in scripts/db-backup.sh
- [ ] T149 [P] Create migration rollback documentation in docs/migrations.md
- [ ] T150 [P] Optimize frontend bundle size (code splitting, lazy loading)
- [ ] T151 [P] Add accessibility improvements (ARIA labels, keyboard navigation)
- [ ] T152 [P] Create user guide documentation in docs/user-guide.md
- [ ] T153 Run full E2E test suite via Playwright
- [ ] T154 Perform load testing with k6 for 100+ concurrent users
- [ ] T155 Security audit and penetration testing
- [ ] T156 Performance profiling and optimization
- [ ] T157 Run quickstart.md validation end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
- **User Story 2 (Phase 4)**: Depends on User Story 1 (requires authentication)
- **User Story 3 (Phase 5)**: Depends on User Stories 1 & 2 (requires auth + RBAC)
- **User Story 4 (Phase 6)**: Can start after Foundational, enhances User Story 3
- **User Story 5 (Phase 7)**: Independent, can start after Foundational
- **User Story 6 (Phase 8)**: Independent, can start after Foundational
- **User Story 7 (Phase 9)**: Independent, can start after Foundational
- **Polish (Phase 10)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (Auth)**: No dependencies on other stories - Can start after Foundational
- **User Story 2 (RBAC)**: Depends on User Story 1 - Requires auth tokens to check roles
- **User Story 3 (CRUD)**: Depends on User Stories 1 & 2 - All endpoints need auth + RBAC
- **User Story 4 (API Standards)**: Enhances User Story 3 - Can be integrated during or after US3
- **User Story 5 (Terraform)**: Independent - Can run in parallel with application development
- **User Story 6 (Monitoring)**: Independent - Can run in parallel with application development
- **User Story 7 (Local Dev)**: Independent - Can run in parallel with application development

### Within Each User Story

- Configuration and utilities before middleware
- Middleware before services
- Services before controllers
- Controllers before routes
- Backend routes before frontend components
- Core components before page components
- API services after backend routes are complete

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (different files)
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Within User Story 3: Server, Database, Table, Element, and Abbreviation entities can be developed in parallel
- User Story 5 (Terraform), 6 (Monitoring), and 7 (Local Dev) can all run in parallel
- All documentation tasks in Phase 10 can run in parallel

---

## Parallel Example: User Story 3 - CRUD Entities

```bash
# Server entity (Team Member A):
Task T052: Server validation schemas
Task T053: Server service
Task T054: Server controller
Task T055: Server routes
Task T056-059: Server frontend components

# Database entity (Team Member B):
Task T060: Database validation schemas
Task T061: Database service
Task T062: Database controller
Task T063: Database routes
Task T064-067: Database frontend components

# Table entity (Team Member C):
Task T068: Table validation schemas
Task T069: Table service
Task T070: Table controller
Task T071: Table routes
Task T072-075: Table frontend components

# Element entity (Team Member D):
Task T076: Element validation schemas
Task T077: Element service
Task T078: Element controller
Task T079: Element routes
Task T080-083: Element frontend components

# Abbreviation entity (Team Member E):
Task T084: Abbreviation validation schemas
Task T085: Abbreviation service
Task T086: Abbreviation controller
Task T087: Abbreviation routes
Task T088-090: Abbreviation frontend components
```

---

## Implementation Strategy

### MVP First (User Stories 1-3 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Authentication)
4. Complete Phase 4: User Story 2 (RBAC)
5. Complete Phase 5: User Story 3 (CRUD Operations)
6. **STOP and VALIDATE**: Test all three user stories independently
7. Deploy/demo if ready

**MVP Scope**: Users can authenticate via Azure Entra ID, roles are enforced, and full CRUD operations work on all entities with soft deletes. This represents a complete, functional system.

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 (Auth) → Test independently → Deploy/Demo
3. Add User Story 2 (RBAC) → Test independently → Deploy/Demo
4. Add User Story 3 (CRUD) → Test independently → Deploy/Demo (MVP!)
5. Add User Story 4 (API Standards) → Test independently → Deploy/Demo
6. Add User Story 5 (Terraform) → Infrastructure automation complete
7. Add User Story 6 (Monitoring) → Production observability ready
8. Add User Story 7 (Local Dev) → Developer experience optimized
9. Complete Phase 10 (Polish) → Production-ready system

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - **Team A**: User Story 1 (Authentication)
   - **Team B**: User Story 5 (Terraform - independent)
   - **Team C**: User Story 7 (Docker/Local Dev - independent)
3. After User Story 1:
   - **Team A**: User Story 2 (RBAC)
   - **Team B**: Continue User Story 5
   - **Team C**: Continue User Story 7
4. After User Stories 1 & 2:
   - **All Teams**: User Story 3 (CRUD) - split by entity (Server/Database/Table/Element/Abbreviation)
5. After User Story 3:
   - **Team A**: User Story 4 (API Standards)
   - **Team B**: User Story 6 (Monitoring)
   - **Team C**: Polish tasks
6. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Tests should be written BEFORE implementation per TDD mandate in constitution
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Backend tasks generally precede frontend tasks for each feature
- Soft deletes are implemented via Prisma middleware globally
- All API endpoints require authentication + RBAC enforcement
- Azure Entra ID is mandatory in production; mock auth available for local dev
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

---

## Task Count Summary

- **Total Tasks**: 157
- **Phase 1 (Setup)**: 14 tasks
- **Phase 2 (Foundational)**: 17 tasks
- **Phase 3 (US1 - Auth)**: 14 tasks
- **Phase 4 (US2 - RBAC)**: 6 tasks
- **Phase 5 (US3 - CRUD)**: 45 tasks
- **Phase 6 (US4 - API Standards)**: 10 tasks
- **Phase 7 (US5 - Terraform)**: 14 tasks
- **Phase 8 (US6 - Monitoring)**: 9 tasks
- **Phase 9 (US7 - Local Dev)**: 9 tasks
- **Phase 10 (Polish)**: 19 tasks

**Parallel Opportunities**: 95 tasks marked [P] (60% of total)

**MVP Scope**: Phases 1-5 (96 tasks) = Authentication + RBAC + Full CRUD

**Production Ready**: All phases (157 tasks) = Complete system with infrastructure, monitoring, and local dev
