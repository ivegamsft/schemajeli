# API Specifications

REST API specification and documentation for SchemaJeli.

## 📋 Documentation Structure

- **[spec.md](./spec.md)** - Complete feature specification (98 functional requirements, 6 user stories, 25 success criteria)
- **[README.md](./README.md)** - This file: API overview and quick reference
- **[tasks.md](./tasks.md)** - Implementation tasks (104 tasks organized by user story)
- **[checklists/requirements.md](./checklists/requirements.md)** - Specification quality validation checklist

## 📊 Specification Summary

The SchemaJeli REST API specification defines a comprehensive metadata repository API with:

- **6 User Stories** prioritized P1 (MVP) and P2 (enhanced features)
- **98 Functional Requirements** covering authentication, CRUD operations, search, audit logging, and data governance
- **38 API Endpoints** across 8 categories (auth, servers, databases, tables, elements, abbreviations, search, system)
- **25 Success Criteria** with measurable outcomes (response times, accuracy, uptime)
- **21 Acceptance Scenarios** in Given-When-Then format for testing
- **10 Edge Cases** with specified handling approaches

### MVP Scope (Priority P1)

The API MVP includes these user stories:

1. **Database Administrator: Manage Database Infrastructure** - Register and manage servers and databases
2. **Developer: Search for Schema Metadata** - Global search across all entities
3. **Data Architect: Document Table Structures** - Complete table/column schema documentation
4. **Security Administrator: Manage User Access** - User management and RBAC

### Enhanced Features (Priority P2)

5. **Data Governance Officer: Enforce Naming Standards** - Abbreviation library and naming validation
6. **Data Analyst: Generate Schema Reports** - Reports and DDL script generation

## OpenAPI Reference

See [../openapi.yaml](../openapi.yaml) for the complete OpenAPI 3.0.3 specification.

### Core Endpoints

#### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh access token

#### Servers
- `GET /servers` - List all servers
- `POST /servers` - Create new server (Admin/Maintainer)
- `GET /servers/{id}` - Get server details
- `PUT /servers/{id}` - Update server (Admin/Maintainer)
- `DELETE /servers/{id}` - Soft delete server (Admin only)

#### Databases
- `GET /servers/{id}/databases` - List databases for server
- `POST /servers/{id}/databases` - Create database (Admin/Maintainer)
- `GET /databases/{id}` - Get database details
- `PUT /databases/{id}` - Update database (Admin/Maintainer)
- `DELETE /databases/{id}` - Soft delete database (Admin only)

#### Tables
- `GET /databases/{id}/tables` - List tables in database
- `POST /databases/{id}/tables` - Create table (Admin/Maintainer)
- `GET /tables/{id}` - Get table details
- `PUT /tables/{id}` - Update table (Admin/Maintainer)
- `DELETE /tables/{id}` - Soft delete table (Admin only)

#### Elements (Columns)
- `GET /tables/{id}/elements` - List columns in table
- `POST /tables/{id}/elements` - Create column (Admin/Maintainer)
- `GET /elements/{id}` - Get column details
- `PUT /elements/{id}` - Update column (Admin/Maintainer)
- `DELETE /elements/{id}` - Soft delete column (Admin only)

#### Abbreviations
- `GET /abbreviations` - List abbreviations
- `POST /abbreviations` - Create abbreviation (Admin/Maintainer)
- `GET /abbreviations/{id}` - Get abbreviation
- `PUT /abbreviations/{id}` - Update abbreviation (Admin/Maintainer)
- `DELETE /abbreviations/{id}` - Soft delete abbreviation (Admin only)

#### Search & Reports
- `GET /search` - Search across entities
- `GET /reports/ddl` - Generate DDL report

## Authentication

All endpoints require Bearer token authentication (JWT from Azure Entra ID).

```
Authorization: Bearer <access_token>
```

### Token Lifecycle
- **Access Token**: 1-hour expiry (short-lived for security)
- **Refresh Token**: 7-day expiry (balances security and UX)
- **Token Refresh**: Use `POST /auth/refresh` before access token expiry
- **Logout**: Invalidates refresh token server-side; access tokens expire naturally

### Authorization & RBAC

Role-based access control with hierarchical permissions (each role inherits permissions from lower roles):

- **Viewer**: Read-only access to all entities (GET operations)
- **Maintainer**: Viewer permissions + create/update operations (POST, PUT)
- **Admin**: Maintainer permissions + delete operations + user management (DELETE)

## Response Format

All responses follow a consistent JSON format:

```json
{
  "status": "success|error",
  "data": { },
  "pagination": {
    "page": 1,
    "pageSize": 25,
    "total": 100
  }
}
```

## Error Handling

Errors return appropriate HTTP status codes with error details:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Detailed error message",
  "details": { }
}
```

### Standard Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Request validation failed (missing/invalid fields) |
| `AUTHENTICATION_ERROR` | 401 | Missing or invalid authentication token |
| `AUTHORIZATION_ERROR` | 403 | Insufficient permissions for operation |
| `NOT_FOUND` | 404 | Requested resource does not exist |
| `CONFLICT` | 409 | Operation conflicts with existing state (duplicate, referential integrity) |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests (100 req/min per user limit) |
| `INTERNAL_ERROR` | 500 | Unexpected server error |
| `SERVICE_UNAVAILABLE` | 503 | Temporary service disruption (maintenance, dependency failure) |

## Pagination

List endpoints support pagination via query parameters:
- `page` (default: 1) - Page number
- `pageSize` (default: 25, max: 200) - Items per page

### Sorting

- **Default Sort**: `createdAt DESC` (most recently created first)
- **Optional Sort**: `sortBy=<field>&sortOrder=<asc|desc>`
  - Valid fields: `name`, `createdAt`, `updatedAt`
  - Example: `?sortBy=name&sortOrder=asc`

### Filtering

Basic filtering supported on key fields:
- `name=<search>` - Case-insensitive partial match on name field
- `status=<active|deleted>` - Filter by status (default: `active` only)
- `createdAfter=<ISO8601>` - Filter by creation date
- `updatedAfter=<ISO8601>` - Filter by last update date

Example: `GET /servers?name=prod&status=active&page=2&pageSize=50`

## Data Operations

### Delete Behavior

All DELETE operations implement **soft delete** (never physical deletion):
- Entity marked with `deletedAt` timestamp (ISO 8601 format)
- Deleted entities excluded from standard queries (filter: `deletedAt IS NULL`)
- Original data preserved for audit trail and potential recovery
- Parent-child relationships: Deleting parent entity does NOT cascade to children; operation blocked with `CONFLICT` error if active children exist
- Only Admin role can perform delete operations

### Audit Trail

All data modifications (create, update, delete) are logged with:
- User ID and role of actor
- Timestamp (ISO 8601)
- Operation type (CREATE, UPDATE, DELETE)
- Before/after values (for updates)
- Retention: 7 years minimum per constitution compliance

## Performance SLAs

API response time targets (measured at server, excluding network latency):

| Endpoint Type | P95 Target | Examples |
|---------------|------------|----------|
| Simple CRUD (single entity GET/PUT/DELETE) | < 100ms | `GET /servers/{id}`, `PUT /tables/{id}` |
| List with pagination | < 200ms | `GET /servers?page=1&pageSize=25` |
| Complex searches & reports | < 500ms | `GET /search`, `GET /reports/ddl` |

- Rate limit: 100 requests/minute per authenticated user (existing)
- Targets apply under normal load; no explicit concurrent user ceiling defined yet

## Data Validation Rules

All entity fields are validated at the API level before database operations:

| Field | Constraints |
|-------|-------------|
| `name` | Required, 1–255 characters, trimmed, HTML-sanitized |
| `description` | Optional, 0–2000 characters, trimmed, HTML-sanitized |
| `type` / `platform` | Required where applicable (e.g., server platform, element data type); validated against allowed enum values |

- All string inputs are trimmed of leading/trailing whitespace
- All string inputs are HTML-sanitized to prevent XSS
- Invalid or missing required fields return `VALIDATION_ERROR` (400) with field-level detail in `details`

## Observability

### Request Logging

- All requests logged via Winston with structured JSON format
- Each request assigned a unique **correlation ID** (`X-Correlation-ID` header); returned in responses
- Log fields: correlation ID, method, path, status code, response time (ms), user ID, role, timestamp
- Error responses include stack traces in logs (not in API responses)

### Health Check

- `GET /health` — returns service health status (no authentication required)
  - Response: `{ "status": "healthy|degraded|unhealthy", "version": "x.y.z", "uptime": <seconds> }`
  - Checks: database connectivity, memory usage

### Metrics (Future)

- APM integration (Azure Application Insights / OpenTelemetry) deferred to a later phase
- Health endpoint provides baseline for load balancer probes and uptime monitoring

## Concurrency Control

Optimistic concurrency via `updatedAt`-based ETags:

- **Reads**: `GET` responses include an `ETag` header derived from the entity's `updatedAt` timestamp
- **Writes**: `PUT` and `DELETE` requests should include `If-Match` header with the ETag value
  - If `If-Match` matches current `updatedAt` → operation proceeds
  - If `If-Match` is stale → returns `CONFLICT` (409) with error code `CONFLICT` and message indicating the entity was modified since last read
  - If `If-Match` is omitted → operation proceeds (backward-compatible; not enforced initially)
- No pessimistic locking; last-write-wins only when `If-Match` is not provided

## Entity Constraints

### Required Fields & Uniqueness

| Entity | Required Fields | Uniqueness Scope |
|--------|----------------|------------------|
| Server | `name`, `platform` | `name` unique globally (no two servers with same name) |
| Database | `name` | `name` unique per parent Server |
| Table | `name` | `name` unique per parent Database |
| Element | `name`, `dataType` | `name` unique per parent Table |
| Abbreviation | `abbreviation`, `definition` | `abbreviation` unique globally |

- Uniqueness is enforced among **active** (non-deleted) entities only; soft-deleted entities do not block new entities with the same name
- Violating uniqueness returns `CONFLICT` (409)

## Clarifications

### Session 2026-01-29

- Q: What is the token lifecycle for JWT access and refresh tokens? → A: Standard JWT pattern: 1-hour access tokens, 7-day refresh tokens (balanced security and UX)
- Q: How are RBAC role permissions structured for API operations? → A: Hierarchical permissions: Admin > Maintainer > Viewer (each inherits lower)
- Q: What error code taxonomy and HTTP status mapping should be used? → A: Domain-aligned error codes (VALIDATION_ERROR, AUTH_ERROR, etc.) with standard HTTP status codes
- Q: What delete operation strategy should be used for data entities? → A: Soft delete with audit trail for all entities (never physical deletion)
- Q: What sorting and filtering strategy should pagination support? → A: Default chronological sort (createdAt DESC), optional field-based sorting, basic filtering by key fields

### Session 2026-02-08

- Q: What are the target response time SLAs for API endpoints? → A: Simple CRUD P95 <100ms, list queries P95 <200ms, complex searches P95 <500ms (aligns with constitution)
- Q: What validation constraints should be enforced at the API level? → A: Name 1–255 chars required; description 0–2000 chars optional; all fields trimmed and HTML-sanitized; field-level errors in VALIDATION_ERROR details
- Q: What observability/monitoring should the API provide? → A: Winston structured JSON logging with correlation IDs on all requests; `GET /health` endpoint for service health; APM deferred to later phase
- Q: How should concurrent/conflicting updates be handled? → A: Optimistic concurrency via `updatedAt`-based ETags (`If-Match` header); returns 409 CONFLICT on stale writes; omitting `If-Match` is backward-compatible (last-write-wins)
- Q: What uniqueness and required field constraints apply to entities? → A: Name required and unique per parent scope (scoped uniqueness); soft-deleted entities don't block new names; violation returns 409 CONFLICT
