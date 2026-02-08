# Feature Specification: System Architecture

**Feature Branch**: `N/A - Core System Architecture`  
**Created**: 2026-02-08  
**Status**: Partially Implemented  
**Input**: User description: "Establish the core system architecture for SchemaJeli — a cloud-native database metadata repository with Azure Entra ID authentication, RBAC, soft deletes, and full CRUD across the Server → Database → Table → Element hierarchy."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secure Authentication via Azure Entra ID (Priority: P1)

As a database engineer, I need to securely sign in to SchemaJeli using my organization's Azure Entra ID credentials so that I can access metadata without maintaining separate credentials.

**Why this priority**: Authentication is the gateway to all functionality. Without it, nothing else is accessible.

**Independent Test**: User clicks "Sign In", authenticates via Microsoft login, receives a valid JWT, and can call a protected API endpoint successfully.

**Acceptance Scenarios**:

1. **Given** a user with valid Azure Entra ID credentials, **When** they sign in via the frontend MSAL flow, **Then** they receive an access token with roles/groups claims and can access protected routes.
2. **Given** an authenticated user with an expired token, **When** the frontend makes an API call, **Then** MSAL silently refreshes the token without requiring re-login.
3. **Given** a request with an invalid or missing JWT, **When** it hits a protected backend endpoint, **Then** the backend returns 401 Unauthorized.
4. **Given** a developer in local mode with `RBAC_MOCK_ROLES=Admin`, **When** they call a protected endpoint without a real JWT, **Then** mock roles are applied and the request succeeds.

---

### User Story 2 - Role-Based Access Control (Priority: P1)

As a system administrator, I need three distinct role levels (Admin, Maintainer, Viewer) enforced on every API endpoint so that users can only perform actions appropriate to their role.

**Why this priority**: Authorization is equally critical as authentication — it protects data integrity.

**Independent Test**: A Viewer user attempting a DELETE request receives 403; an Admin performing the same request succeeds.

**Acceptance Scenarios**:

1. **Given** a user with Admin role, **When** they perform any CRUD operation, **Then** all operations succeed.
2. **Given** a user with Maintainer role, **When** they create/update entities, **Then** operations succeed, but delete of servers returns 403.
3. **Given** a user with Viewer role, **When** they attempt any write operation, **Then** they receive 403 Forbidden.
4. **Given** roles derived from token `groups` claim, **When** the group ID matches `RBAC_GROUP_ADMIN`, **Then** the user is granted Admin role.

---

### User Story 3 - Schema Entity CRUD with Soft Deletes (Priority: P1)

As a database administrator, I need full CRUD operations on the Server → Database → Table → Element hierarchy with soft deletes so that metadata is never physically lost.

**Why this priority**: This is the core domain functionality of the application.

**Independent Test**: Create a Server, add a Database to it, add Tables and Elements, soft-delete a Table, verify it's excluded from default queries but restorable.

**Acceptance Scenarios**:

1. **Given** an authenticated Maintainer, **When** they create a Server with valid data, **Then** it is persisted and returned with `status: 'success'`.
2. **Given** a Server with child Databases, **When** a user attempts to delete the Server, **Then** the operation is blocked (`onDelete: Restrict`).
3. **Given** a soft-deleted Table, **When** a default list query runs, **Then** the deleted Table is excluded (`deletedAt IS NULL` filter).
4. **Given** any entity mutation, **When** it completes, **Then** an AuditLog entry is recorded with user, action, entity details, and timestamp.

---

### User Story 4 - API Infrastructure & Standards (Priority: P2)

As a frontend developer, I need a consistent REST API with versioned routes, standard response envelopes, pagination, and proper error handling so that I can build a reliable UI.

**Why this priority**: API consistency reduces frontend bugs and accelerates development.

**Independent Test**: Call any list endpoint and verify the response envelope includes `{ status, data, total, page, limit, totalPages }`.

**Acceptance Scenarios**:

1. **Given** a GET request to any list endpoint with `?page=2&limit=10`, **Then** the response includes correct pagination metadata.
2. **Given** a request that triggers a validation error, **Then** the response is `{ status: 'error', message: '...' }` with HTTP 400.
3. **Given** a request to a non-existent route, **Then** a 404 JSON response is returned (not HTML).
4. **Given** a user exceeding 100 requests/minute, **Then** they receive HTTP 429 with `Retry-After` header.

---

### User Story 5 - Azure Infrastructure via Terraform (Priority: P2)

As a DevOps engineer, I need repeatable Azure infrastructure provisioned via Terraform so that I can deploy dev/staging/prod environments consistently.

**Why this priority**: Infrastructure automation enables reliable deployments and environment parity.

**Independent Test**: Run `terraform plan` for the dev environment and verify all resources (App Service, PostgreSQL, Key Vault, Storage, Monitoring) are defined without errors.

**Acceptance Scenarios**:

1. **Given** the Terraform configuration, **When** `terraform plan -var-file=dev.tfvars` is run, **Then** it shows all required Azure resources with no errors.
2. **Given** a production deployment, **When** Terraform applies, **Then** App Service, Static Web App, PostgreSQL Flexible Server, Key Vault, Storage, App Configuration, and Application Insights are all provisioned.
3. **Given** a staging environment, **When** it is provisioned, **Then** it mirrors production topology but uses smaller SKUs.

---

### User Story 6 - Monitoring & Observability (Priority: P3)

As an operations engineer, I need structured logging and Application Insights integration so that I can monitor application health and diagnose issues in production.

**Why this priority**: Observability is important for production reliability but not blocking for core functionality.

**Independent Test**: Trigger an API request and verify Winston logs the request with correlation ID, and Application Insights receives the telemetry.

**Acceptance Scenarios**:

1. **Given** any API request, **When** it completes, **Then** Winston logs include method, path, status code, duration, and correlation ID.
2. **Given** an unhandled exception, **When** it occurs, **Then** it is logged with full stack trace and reported to Application Insights.
3. **Given** Application Insights is configured, **When** the backend starts, **Then** it begins sending telemetry (requests, dependencies, exceptions).

---

### User Story 7 - Local Development Experience (Priority: P3)

As a developer, I need to run the full stack locally via Docker Compose with mock authentication so that I can develop without Azure dependencies.

**Why this priority**: Developer productivity is important but not blocking for production deployment.

**Independent Test**: Run `docker-compose up -d`, set `RBAC_MOCK_ROLES=Admin`, call an API endpoint, and get a successful response.

**Acceptance Scenarios**:

1. **Given** `docker-compose up -d`, **When** all containers start, **Then** PostgreSQL (5433), backend (8080), and frontend (8081) are all healthy.
2. **Given** `RBAC_MOCK_ROLES=Admin` in the backend environment, **When** a developer calls a protected endpoint, **Then** it succeeds without real Azure tokens.
3. **Given** `npm run dev` in the backend directory, **When** a code change is saved, **Then** the server reloads automatically via tsx watch.

---

### Edge Cases

- What happens when Azure Entra ID is unreachable? **Answer**: Backend fails to validate JWKS keys; returns 503 Service Unavailable. Frontend shows "Authentication service unavailable" message.
- What if a JWT has no `roles` or `groups` claims? **Answer**: User defaults to no roles; all protected endpoints return 403.
- What if two users update the same entity concurrently? **Answer**: `updatedAt` field enables optimistic locking; second update gets a conflict error.
- What if a Prisma migration fails mid-way? **Answer**: Prisma wraps migrations in transactions; partial migrations are rolled back.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST authenticate users exclusively via Azure Entra ID (MSAL) — no local passwords.
- **FR-002**: System MUST validate JWT tokens on every API request via Microsoft JWKS endpoint.
- **FR-003**: System MUST enforce three RBAC roles: Admin (full), Maintainer (CRUD except delete servers), Viewer (read-only).
- **FR-004**: System MUST implement soft deletes (`deletedAt` field) on all entities — no physical deletion.
- **FR-005**: System MUST use Prisma ORM with parameterized queries for all database operations.
- **FR-006**: System MUST log all data modifications to AuditLog table with user, action, entity, and timestamp.
- **FR-007**: System MUST return standard response envelope: `{ status: 'success'|'error', data?, message? }`.
- **FR-008**: System MUST support pagination via `page` + `limit` query params with metadata in response.
- **FR-009**: System MUST provision Azure infrastructure via Terraform only (no Kubernetes).
- **FR-010**: System MUST implement rate limiting: 100 req/min per authenticated user.
- **FR-011**: System MUST use Winston for structured logging with Application Insights integration.
- **FR-012**: System MUST support local development via Docker Compose with `RBAC_MOCK_ROLES` fallback.

### Key Entities

- **User**: Minimal local record auto-created from Entra ID login (entraId, displayName, email, preferences). FK target for audit fields.
- **Server**: Top-level entity (name, host, port, rdbmsType, location, status, description).
- **Database**: Child of Server (name, description, purpose, status).
- **Table**: Child of Database (name, tableType, description, status).
- **Element**: Child of Table (name, dataType, length, precision, isNullable, isPrimaryKey, isForeignKey, position, description).
- **AuditLog**: Immutable record of all data modifications.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users authenticate via Entra ID and access protected resources in under 5 seconds.
- **SC-002**: JWT validation completes in under 10ms per request with cached JWKS keys.
- **SC-003**: RBAC checks complete in under 5ms per request.
- **SC-004**: Simple CRUD queries respond in under 100ms; complex searches under 500ms p95.
- **SC-005**: All entities use soft deletes — zero physical deletions.
- **SC-006**: 100% of data modifications captured in AuditLog.
- **SC-007**: Terraform provisions all Azure resources in dev/staging/prod without manual steps.
- **SC-008**: Docker Compose starts full stack locally in under 60 seconds.
- **SC-009**: Rate limiting blocks excessive requests with 100% accuracy.
