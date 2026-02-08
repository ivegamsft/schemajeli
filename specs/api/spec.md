# Feature Specification: SchemaJeli REST API

**Feature**: REST API for SchemaJeli Database Metadata Repository  
**Created**: 2025-01-29  
**Status**: Active  
**Version**: 1.0  

## Overview

SchemaJeli is a cloud-native database metadata repository that provides a RESTful API for documenting schemas across multiple RDBMS platforms (PostgreSQL, MySQL, Oracle, DB2, Informix). The API enables users to manage the complete hierarchy of database objects (Server → Database → Table → Element) with role-based access control, audit logging, and comprehensive search capabilities.

## User Scenarios & Testing

### User Story 1 - Database Administrator: Manage Database Infrastructure (Priority: P1)

A database administrator needs to register and manage database servers and their associated databases in the metadata repository to maintain an accurate inventory of organizational data assets.

**Why this priority**: Core functionality - without the ability to register servers and databases, no other features can provide value.

**Independent Test**: DBA can create a new server record, add multiple databases to that server, update server details, and verify all changes are logged in the audit trail.

**Acceptance Scenarios**:

1. **Given** a DBA with Maintainer role, **When** they create a new PostgreSQL server with name "prod-db-01" and host "db.company.com", **Then** the server appears in the server list and receives a unique UUID identifier
2. **Given** an existing server "prod-db-01", **When** the DBA adds a database named "customers_db" to that server, **Then** the database is created with the correct parent relationship and appears in the server's database list
3. **Given** a server with active databases, **When** the DBA attempts to delete the server, **Then** the system blocks the deletion with a CONFLICT error explaining parent-child constraints
4. **Given** any server modification, **When** changes are saved, **Then** an audit log entry captures the user, timestamp, and before/after values

---

### User Story 2 - Developer: Search for Schema Metadata (Priority: P1)

A developer needs to quickly find specific tables, columns, or databases across the entire metadata repository to understand data structures and locate relevant information for application development.

**Why this priority**: High-value feature that makes the repository immediately useful - developers can find what they need without knowing the exact location.

**Independent Test**: Developer can search for "customer" and receive results showing all servers, databases, tables, and elements containing that term, with results returned in under 2 seconds.

**Acceptance Scenarios**:

1. **Given** a metadata repository with multiple servers, **When** a developer searches for "customer", **Then** results include all matching servers, databases, tables, and elements with "customer" in their names or descriptions
2. **Given** a search query "email", **When** executed, **Then** results include all columns with data type email or name containing "email", sorted by relevance
3. **Given** a large dataset (1000+ tables), **When** search is performed, **Then** results are returned in under 2 seconds (p95)
4. **Given** search results spanning multiple entity types, **When** displayed, **Then** each result shows entity type, name, parent context (server/database), and relevant metadata

---

### User Story 3 - Data Architect: Document Table Structures (Priority: P1)

A data architect needs to document complete table schemas including columns, data types, constraints, and metadata to create a comprehensive data dictionary for the organization.

**Why this priority**: Core functionality that provides the detailed documentation value of the system.

**Independent Test**: Data architect can create a table "users" with 10 columns (id, username, email, etc.), specify data types and constraints for each, and verify the complete structure is accurately stored and retrievable.

**Acceptance Scenarios**:

1. **Given** an existing database "app_db", **When** the architect creates a table "orders" with columns (id INT PRIMARY KEY, customer_id INT FOREIGN KEY, order_date DATE, total DECIMAL(10,2)), **Then** all columns are created with correct data types and constraints
2. **Given** a table with 50 columns, **When** the architect retrieves the table details, **Then** columns are returned in the correct position order with complete metadata (data type, nullability, primary/foreign key flags)
3. **Given** a column "email_address", **When** the architect updates its description to "Customer primary email for communications", **Then** the change is saved and the audit log records who made the change and when
4. **Given** a table marked as VIEW type, **When** retrieved, **Then** the table type is correctly reflected and can be filtered separately from regular tables

---

### User Story 4 - Data Governance Officer: Enforce Naming Standards (Priority: P2)

A data governance officer needs to maintain an abbreviation library and enforce naming standards across the metadata repository to ensure consistency and prevent naming conflicts or ambiguity.

**Why this priority**: Important for data quality and standardization, but the system can function without it initially.

**Independent Test**: Governance officer can add abbreviations (e.g., "CUST" = "Customer"), view the complete library, and the system validates that new table/column names don't use forbidden characters or violate standards.

**Acceptance Scenarios**:

1. **Given** an empty abbreviation library, **When** the officer adds "CUST" → "Customer" as a prime class abbreviation, **Then** it appears in the library and is available for lookup
2. **Given** an abbreviation "ADDR" → "Address", **When** the officer updates it to add category "Location" and definition "Physical or mailing address", **Then** the enhanced metadata is saved
3. **Given** configured forbidden characters (e.g., spaces, special chars), **When** a user attempts to create a table named "my table!" with spaces and exclamation, **Then** the system rejects the name with a VALIDATION_ERROR listing the specific violations
4. **Given** a complete abbreviation library, **When** developers search for "customer", **Then** results include relevant abbreviations alongside tables and columns

---

### User Story 5 - Data Analyst: Generate Schema Reports (Priority: P2)

A data analyst needs to generate comprehensive schema reports and DDL scripts in multiple formats to document systems, support migrations, and share information with stakeholders.

**Why this priority**: Valuable feature for documentation and migration scenarios, but not essential for daily metadata management.

**Independent Test**: Analyst can select a server "prod-db-01", choose "Database Detail Report" format, export as PDF, and receive a complete report showing all databases, tables, and columns with metadata.

**Acceptance Scenarios**:

1. **Given** a server with 5 databases, **When** analyst generates a "Server Summary Report", **Then** the report shows server details, list of databases, table counts, and status summary in HTML format
2. **Given** a specific database "orders_db", **When** analyst requests a "Database Detail Report", **Then** the report includes all tables with complete column definitions, data types, and constraints
3. **Given** a table "customers", **When** analyst generates PostgreSQL DDL, **Then** the system produces syntactically correct CREATE TABLE statement with all columns, primary keys, and constraints
4. **Given** a large database with 100+ tables, **When** CSV export is requested, **Then** the system streams the output efficiently and completes in under 30 seconds

---

### User Story 6 - Security Administrator: Manage User Access (Priority: P1)

A security administrator needs to create user accounts, assign roles (Admin, Maintainer, Viewer), and control who can read vs. modify metadata to maintain security and compliance.

**Why this priority**: Essential for multi-user environments and production deployment - must have role-based access control from day one.

**Independent Test**: Admin can create a user account for "jane.doe@company.com" with Maintainer role, verify Jane can create/update but not delete entities, and confirm Jane cannot perform admin operations like user management.

**Acceptance Scenarios**:

1. **Given** an Admin user, **When** they create a new user with email "john@company.com" and role Viewer, **Then** the user account is created and John can authenticate and view metadata but cannot modify anything
2. **Given** a Maintainer role user, **When** they attempt to create a new server, **Then** the operation succeeds and audit log records their user ID
3. **Given** a Maintainer role user, **When** they attempt to delete a server (Admin-only operation), **Then** the system returns AUTHORIZATION_ERROR (403) with message explaining insufficient permissions
4. **Given** a user without a valid JWT token, **When** they attempt any API call, **Then** all requests return AUTHENTICATION_ERROR (401) and do not expose any data

---

### Edge Cases

- **Concurrent Updates**: What happens when two users update the same server simultaneously? → System uses optimistic locking with ETag-based concurrency control; second update receives CONFLICT (409) with message indicating the entity was modified
- **Circular Dependencies**: What happens if system allows foreign key relationships that create circular references? → Prevented at database constraint level; database schema validation blocks circular references in table relationships
- **Deleted Entity Queries**: What happens when a user requests a soft-deleted entity by ID? → API returns NOT_FOUND (404) as if entity doesn't exist; deleted entities only visible through explicit admin audit queries
- **Large Result Sets**: What happens when a search returns 10,000+ results? → Pagination is enforced (max 200 per page); client must use page parameter to retrieve subsequent pages
- **Special Characters in Names**: What happens when entity names contain Unicode, emojis, or SQL special characters? → Names are validated, trimmed, and HTML-sanitized; SQL injection prevented by Prisma's parameterized queries; forbidden characters rejected at validation layer
- **Token Expiration**: What happens when a user's JWT token expires mid-request? → Request fails with AUTHENTICATION_ERROR (401); client must refresh token using refresh endpoint before retrying
- **Duplicate Names**: What happens when creating a database with a name that already exists on the same server? → System returns CONFLICT (409) error with details about the constraint violation (uniqueness scope)
- **Parent Entity Deletion**: What happens when a user deletes a server that has databases? → System blocks deletion with CONFLICT (409) and message explaining active children prevent deletion
- **Invalid Foreign Keys**: What happens when creating a database with a non-existent serverId? → System returns VALIDATION_ERROR (400) explaining the referenced server does not exist
- **Empty Search**: What happens when search query is empty or only whitespace? → Returns empty results array with total=0; does not error

## Requirements

### Functional Requirements

#### Authentication & Authorization

- **FR-001**: System MUST authenticate all API requests using JWT tokens issued by Azure Entra ID (MSAL)
- **FR-002**: System MUST validate JWT tokens using Microsoft's public key infrastructure (JWKS)
- **FR-003**: System MUST support three role levels with hierarchical permissions: Admin (full access), Maintainer (read + write), Viewer (read-only)
- **FR-004**: System MUST return AUTHENTICATION_ERROR (401) for requests without valid bearer tokens
- **FR-005**: System MUST return AUTHORIZATION_ERROR (403) for requests where user's role lacks required permissions
- **FR-006**: System MUST attach user context (id, name, email, roles) to all authenticated requests for audit logging

#### Server Management

- **FR-007**: System MUST allow Maintainer+ roles to create server records with required fields: name, host, rdbmsType (enum: POSTGRESQL, MYSQL, ORACLE, DB2, INFORMIX)
- **FR-008**: System MUST enforce unique server names globally across the repository
- **FR-009**: System MUST allow users to retrieve paginated server lists with filtering by rdbmsType and status
- **FR-010**: System MUST allow users to retrieve individual server details including list of associated databases
- **FR-011**: System MUST allow Maintainer+ roles to update server details (name, host, port, location, status)
- **FR-012**: System MUST allow Admin role to soft-delete servers (set deletedAt timestamp) only if no active databases exist
- **FR-013**: System MUST exclude soft-deleted servers from standard list and detail queries

#### Database Management

- **FR-014**: System MUST allow Maintainer+ roles to create database records with required fields: serverId (FK), name, description
- **FR-015**: System MUST enforce unique database names within each parent server (scoped uniqueness)
- **FR-016**: System MUST validate that serverId references an existing, non-deleted server
- **FR-017**: System MUST allow users to retrieve databases filtered by serverId
- **FR-018**: System MUST allow users to retrieve individual database details including list of associated tables
- **FR-019**: System MUST allow Maintainer+ roles to update database details (name, description, purpose, status)
- **FR-020**: System MUST allow Admin role to soft-delete databases only if no active tables exist
- **FR-021**: System MUST provide nested route /servers/:id/databases for contextual database listing

#### Table Management

- **FR-022**: System MUST allow Maintainer+ roles to create table records with required fields: databaseId (FK), name, tableType (enum: TABLE, VIEW, MATERIALIZED_VIEW)
- **FR-023**: System MUST enforce unique table names within each parent database (scoped uniqueness)
- **FR-024**: System MUST validate that databaseId references an existing, non-deleted database
- **FR-025**: System MUST allow users to retrieve tables filtered by databaseId
- **FR-026**: System MUST allow users to retrieve individual table details including list of associated elements/columns
- **FR-027**: System MUST allow Maintainer+ roles to update table details (name, description, tableType, rowCountEstimate, status)
- **FR-028**: System MUST allow Admin role to soft-delete tables only if no active elements exist
- **FR-029**: System MUST provide nested route /databases/:id/tables for contextual table listing
- **FR-030**: System MUST track table metadata: row count estimate, table type, status

#### Element (Column) Management

- **FR-031**: System MUST allow Maintainer+ roles to create element/column records with required fields: tableId (FK), name, dataType, position
- **FR-032**: System MUST enforce unique element names within each parent table (scoped uniqueness)
- **FR-033**: System MUST validate that tableId references an existing, non-deleted table
- **FR-034**: System MUST allow users to retrieve elements filtered by tableId, ordered by position
- **FR-035**: System MUST allow users to retrieve individual element details
- **FR-036**: System MUST allow Maintainer+ roles to update element details (name, description, dataType, length, precision, scale, isNullable, isPrimaryKey, isForeignKey, defaultValue, position)
- **FR-037**: System MUST allow Admin role to soft-delete elements
- **FR-038**: System MUST provide nested route /tables/:id/elements for contextual element listing
- **FR-039**: System MUST track element metadata: data type, length, precision, scale, nullability, primary/foreign key flags, default value, position

#### Abbreviation Management

- **FR-040**: System MUST allow Maintainer+ roles to create abbreviation records with required fields: abbreviation, source, definition
- **FR-041**: System MUST enforce unique abbreviation globally (one definition per abbreviation)
- **FR-042**: System MUST allow users to retrieve paginated abbreviation lists with filtering by category
- **FR-043**: System MUST allow users to search abbreviations by abbreviation text or source
- **FR-044**: System MUST allow Maintainer+ roles to update abbreviation details (source, definition, isPrimeClass, category)
- **FR-045**: System MUST allow Admin role to delete abbreviations (no soft delete for abbreviations)

#### Search & Discovery

- **FR-046**: System MUST provide global search across all entity types (servers, databases, tables, elements, abbreviations)
- **FR-047**: System MUST support case-insensitive partial matching on name and description fields
- **FR-048**: System MUST return search results grouped by entity type with total count
- **FR-049**: System MUST exclude soft-deleted entities from search results
- **FR-050**: System MUST complete searches in under 2 seconds (p95) for typical datasets (1000+ entities)
- **FR-051**: System MUST return empty results (not error) for empty or whitespace-only search queries

#### Statistics & Dashboard

- **FR-052**: System MUST provide dashboard statistics endpoint returning counts of servers, databases, tables, elements
- **FR-053**: System MUST provide breakdown of servers by RDBMS type
- **FR-054**: System MUST exclude soft-deleted entities from statistics counts
- **FR-055**: System MUST complete statistics queries in under 500ms (p95)

#### Audit Logging

- **FR-056**: System MUST log all CREATE, UPDATE, DELETE operations to audit log table
- **FR-057**: System MUST capture audit log fields: entityType, entityId, action, userId, changes (before/after), timestamp, ipAddress, userAgent
- **FR-058**: System MUST store audit logs for minimum 7 years per compliance requirements
- **FR-059**: System MUST include user ID and role in all audit log entries
- **FR-060**: System MUST capture changes as JSON with before/after values for UPDATE operations

#### Soft Delete & Data Retention

- **FR-061**: System MUST implement soft delete (deletedAt timestamp) for all domain entities (servers, databases, tables, elements)
- **FR-062**: System MUST exclude soft-deleted entities from standard list and detail queries (filter: deletedAt IS NULL)
- **FR-063**: System MUST preserve soft-deleted data indefinitely for audit trail and potential recovery
- **FR-064**: System MUST block parent entity deletion if active (non-deleted) child entities exist (referential integrity)
- **FR-065**: System MUST allow uniqueness constraints to be satisfied by creating new entity with same name as soft-deleted entity

#### Response Format & Pagination

- **FR-066**: System MUST return all responses in standard JSON envelope: `{ status: 'success'|'error', data?, message?, total?, page?, limit?, totalPages? }`
- **FR-067**: System MUST support pagination via query parameters: page (default 1), limit (default 10, max 200)
- **FR-068**: System MUST return pagination metadata in list responses: total, page, limit, totalPages
- **FR-069**: System MUST return 201 status code for successful CREATE operations
- **FR-070**: System MUST return 200 status code for successful GET, PUT, DELETE operations

#### Error Handling

- **FR-071**: System MUST return appropriate HTTP status codes: 400 (validation), 401 (auth), 403 (authorization), 404 (not found), 409 (conflict), 429 (rate limit), 500 (internal), 503 (unavailable)
- **FR-072**: System MUST return error responses in format: `{ status: 'error', message: string }`
- **FR-073**: System MUST provide descriptive error messages explaining what went wrong and how to fix it
- **FR-074**: System MUST sanitize error messages to prevent information leakage (no stack traces, internal details, or SQL)
- **FR-075**: System MUST return VALIDATION_ERROR (400) for invalid request data with field-level details when possible

#### Validation

- **FR-076**: System MUST validate all string inputs: trim whitespace, sanitize HTML to prevent XSS
- **FR-077**: System MUST enforce name field constraints: required, 1-255 characters
- **FR-078**: System MUST enforce description field constraints: optional, 0-2000 characters
- **FR-079**: System MUST validate enum fields against allowed values (rdbmsType, tableType, status, role)
- **FR-080**: System MUST validate foreign key references exist and are not soft-deleted before allowing create/update
- **FR-081**: System MUST validate uniqueness constraints before allowing create/update operations
- **FR-082**: System MUST prevent SQL injection via Prisma's parameterized queries

#### Concurrency Control

- **FR-083**: System MUST implement optimistic locking using updatedAt-based ETags
- **FR-084**: System MUST return ETag header in GET responses derived from entity updatedAt timestamp
- **FR-085**: System MUST accept If-Match header in PUT/DELETE requests for concurrency control
- **FR-086**: System MUST return CONFLICT (409) if If-Match header value doesn't match current entity updatedAt
- **FR-087**: System MUST allow PUT/DELETE without If-Match header (backward compatible, last-write-wins)

#### Performance & Reliability

- **FR-088**: System MUST meet response time SLAs: simple CRUD <100ms (p95), list queries <200ms (p95), complex searches <500ms (p95)
- **FR-089**: System MUST enforce rate limiting: 100 requests per minute per authenticated user
- **FR-090**: System MUST return RATE_LIMIT_EXCEEDED (429) when user exceeds rate limit
- **FR-091**: System MUST provide health check endpoint /health (no authentication required) returning service status
- **FR-092**: System MUST use connection pooling for database connections
- **FR-093**: System MUST use database indexes on frequently queried fields (name, status, foreign keys)

#### Observability

- **FR-094**: System MUST log all API requests with structured JSON format (method, path, status, duration, userId, timestamp)
- **FR-095**: System MUST assign unique correlation ID to each request and return in X-Correlation-ID header
- **FR-096**: System MUST include correlation ID in all log entries for request tracing
- **FR-097**: System MUST log errors with stack traces (in logs only, not in API responses)
- **FR-098**: System MUST use Winston logger with JSON formatting for production environments

### Key Entities

- **User**: Represents authenticated users with fields: id (UUID), username, email, passwordHash, fullName, role (enum: ADMIN/EDITOR/VIEWER), isActive (boolean), lastLoginAt, createdAt, updatedAt

- **Server**: Represents database servers with fields: id (UUID), name (unique), description, host, port, rdbmsType (enum: POSTGRESQL/MYSQL/ORACLE/DB2/INFORMIX), location, status (enum: ACTIVE/INACTIVE/ARCHIVED), createdById (FK to User), createdAt, updatedAt, deletedAt

- **Database**: Represents databases on servers with fields: id (UUID), serverId (FK to Server), name (unique per server), description, purpose, status, createdById (FK to User), createdAt, updatedAt, deletedAt. Relationship: belongs to Server, has many Tables

- **Table**: Represents tables/views in databases with fields: id (UUID), databaseId (FK to Database), name (unique per database), description, tableType (enum: TABLE/VIEW/MATERIALIZED_VIEW), rowCountEstimate, status, createdById (FK to User), createdAt, updatedAt, deletedAt. Relationship: belongs to Database, has many Elements

- **Element**: Represents columns in tables with fields: id (UUID), tableId (FK to Table), name (unique per table), description, dataType, length, precision, scale, isNullable, isPrimaryKey, isForeignKey, defaultValue, position (order in table), createdById (FK to User), createdAt, updatedAt, deletedAt. Relationship: belongs to Table

- **Abbreviation**: Represents standard abbreviations with fields: id (UUID), source (full word/phrase), abbreviation (unique), definition, isPrimeClass (boolean), category, createdById (FK to User), createdAt, updatedAt. No soft delete (hard delete allowed)

- **AuditLog**: Represents audit trail with fields: id (UUID), entityType (enum), entityId, action (enum: CREATE/UPDATE/DELETE/RESTORE), userId (FK to User), changes (JSON), ipAddress, userAgent, createdAt. Immutable records, never deleted

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can complete full CRUD operations (create server → add database → add table → add columns) in under 5 minutes through the API
- **SC-002**: API responds to simple GET requests (single entity by ID) in under 100ms at p95
- **SC-003**: API responds to paginated list requests in under 200ms at p95
- **SC-004**: API responds to complex search queries in under 500ms at p95
- **SC-005**: System supports 100 concurrent users without response time degradation
- **SC-006**: Search returns relevant results in under 2 seconds for datasets with 1000+ entities
- **SC-007**: API enforces role-based access control with 100% accuracy (no unauthorized operations succeed)
- **SC-008**: All data modifications (create/update/delete) are captured in audit log with 100% fidelity
- **SC-009**: Soft delete prevents data loss - 100% of deleted entities are recoverable via audit trail
- **SC-010**: API achieves 99.9% uptime in production (measured monthly)
- **SC-011**: Zero SQL injection vulnerabilities (validated by security audit)
- **SC-012**: Zero XSS vulnerabilities in API responses (validated by security audit)
- **SC-013**: API documentation (OpenAPI/Swagger) is 100% accurate and up-to-date with implementation
- **SC-014**: Rate limiting prevents abuse - no user can exceed 100 requests/minute
- **SC-015**: Health check endpoint responds in under 50ms and accurately reflects database connectivity

### Quality Criteria

- **QC-001**: All API endpoints follow consistent response format envelope
- **QC-002**: All error responses provide actionable error messages
- **QC-003**: All API endpoints require authentication (except /health)
- **QC-004**: All validation errors include field-level details when applicable
- **QC-005**: All entity names and descriptions are sanitized against XSS attacks
- **QC-006**: All foreign key constraints are validated before entity creation
- **QC-007**: All uniqueness constraints are enforced at database and API level
- **QC-008**: All timestamps use ISO 8601 format with UTC timezone
- **QC-009**: All pagination responses include complete metadata (total, page, limit, totalPages)
- **QC-010**: All log entries include correlation ID for request tracing

## API Endpoint Catalog

### Authentication Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| POST | /api/v1/auth/login | No | - | Initiate Azure Entra ID authentication flow |
| POST | /api/v1/auth/logout | Yes | All | Logout user (informational - tokens expire naturally) |
| POST | /api/v1/auth/refresh | No | - | Refresh JWT access token |
| GET | /api/v1/auth/verify | Yes | All | Verify current JWT token validity and return user info |
| GET | /api/v1/auth/me | Yes | All | Get current authenticated user details |

### Server Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /api/v1/servers | Yes | All | List servers with pagination and filtering |
| POST | /api/v1/servers | Yes | Maintainer, Admin | Create new server |
| GET | /api/v1/servers/:id | Yes | All | Get server details with databases |
| PUT | /api/v1/servers/:id | Yes | Maintainer, Admin | Update server details |
| DELETE | /api/v1/servers/:id | Yes | Admin | Soft delete server (if no active databases) |
| GET | /api/v1/servers/:id/databases | Yes | All | List databases for specific server |

### Database Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /api/v1/databases | Yes | All | List databases with pagination and optional serverId filter |
| POST | /api/v1/databases | Yes | Maintainer, Admin | Create new database |
| GET | /api/v1/databases/:id | Yes | All | Get database details with tables |
| PUT | /api/v1/databases/:id | Yes | Maintainer, Admin | Update database details |
| DELETE | /api/v1/databases/:id | Yes | Admin | Soft delete database (if no active tables) |
| GET | /api/v1/databases/:id/tables | Yes | All | List tables for specific database |

### Table Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /api/v1/tables | Yes | All | List tables with pagination and optional databaseId filter |
| POST | /api/v1/tables | Yes | Maintainer, Admin | Create new table |
| GET | /api/v1/tables/:id | Yes | All | Get table details with elements/columns |
| PUT | /api/v1/tables/:id | Yes | Maintainer, Admin | Update table details |
| DELETE | /api/v1/tables/:id | Yes | Admin | Soft delete table (if no active elements) |
| GET | /api/v1/tables/:id/elements | Yes | All | List elements/columns for specific table |

### Element (Column) Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /api/v1/elements | Yes | All | List elements with pagination and optional tableId filter |
| POST | /api/v1/elements | Yes | Maintainer, Admin | Create new element/column |
| GET | /api/v1/elements/:id | Yes | All | Get element details |
| PUT | /api/v1/elements/:id | Yes | Maintainer, Admin | Update element details |
| DELETE | /api/v1/elements/:id | Yes | Admin | Soft delete element |

### Abbreviation Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /api/v1/abbreviations | Yes | All | List abbreviations with pagination |
| POST | /api/v1/abbreviations | Yes | Maintainer, Admin | Create new abbreviation |
| GET | /api/v1/abbreviations/:id | Yes | All | Get abbreviation details |
| PUT | /api/v1/abbreviations/:id | Yes | Maintainer, Admin | Update abbreviation |
| DELETE | /api/v1/abbreviations/:id | Yes | Admin | Hard delete abbreviation |

### Search & Statistics Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /api/v1/search?query={term} | Yes | All | Global search across all entities |
| GET | /api/v1/statistics/dashboard | Yes | All | Get dashboard statistics (entity counts, server breakdown) |

### System Endpoints

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| GET | /health | No | - | Health check (database connectivity, service status) |
| GET | /api/v1 | No | - | API version info |

## Request/Response Examples

### Create Server

**Request:**
```http
POST /api/v1/servers
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "prod-postgres-01",
  "host": "db.company.com",
  "port": 5432,
  "rdbmsType": "POSTGRESQL",
  "location": "AWS US-East-1",
  "description": "Production PostgreSQL server for customer data",
  "status": "ACTIVE",
  "createdById": "user-uuid-here"
}
```

**Response (201 Created):**
```json
{
  "status": "success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "prod-postgres-01",
    "host": "db.company.com",
    "port": 5432,
    "rdbmsType": "POSTGRESQL",
    "location": "AWS US-East-1",
    "description": "Production PostgreSQL server for customer data",
    "status": "ACTIVE",
    "createdById": "user-uuid-here",
    "createdAt": "2025-01-29T10:00:00.000Z",
    "updatedAt": "2025-01-29T10:00:00.000Z",
    "deletedAt": null
  }
}
```

### List Servers with Pagination

**Request:**
```http
GET /api/v1/servers?page=1&limit=25&rdbmsType=POSTGRESQL
Authorization: Bearer <jwt_token>
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "prod-postgres-01",
      "host": "db.company.com",
      "port": 5432,
      "rdbmsType": "POSTGRESQL",
      "location": "AWS US-East-1",
      "status": "ACTIVE",
      "createdAt": "2025-01-29T10:00:00.000Z",
      "updatedAt": "2025-01-29T10:00:00.000Z"
    }
  ],
  "total": 47,
  "page": 1,
  "limit": 25,
  "totalPages": 2
}
```

### Search Across Entities

**Request:**
```http
GET /api/v1/search?query=customer
Authorization: Bearer <jwt_token>
```

**Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "servers": [],
    "databases": [
      {
        "id": "db-uuid",
        "name": "customer_data",
        "serverId": "server-uuid",
        "description": "Customer information database"
      }
    ],
    "tables": [
      {
        "id": "table-uuid",
        "name": "customers",
        "databaseId": "db-uuid",
        "description": "Customer master table"
      }
    ],
    "elements": [
      {
        "id": "element-uuid",
        "name": "customer_id",
        "tableId": "table-uuid",
        "dataType": "INT",
        "isPrimaryKey": true
      },
      {
        "id": "element-uuid-2",
        "name": "customer_email",
        "tableId": "table-uuid",
        "dataType": "VARCHAR(255)",
        "isPrimaryKey": false
      }
    ],
    "abbreviations": [
      {
        "id": "abbr-uuid",
        "source": "Customer",
        "abbreviation": "CUST",
        "definition": "Customer entity"
      }
    ],
    "total": 4
  }
}
```

### Error Response - Validation Error

**Request:**
```http
POST /api/v1/servers
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "",
  "host": "db.company.com"
}
```

**Response (400 Bad Request):**
```json
{
  "status": "error",
  "message": "Validation failed",
  "details": {
    "name": "Name is required and must be 1-255 characters",
    "rdbmsType": "RDBMS type is required and must be one of: POSTGRESQL, MYSQL, ORACLE, DB2, INFORMIX"
  }
}
```

### Error Response - Authorization Error

**Request:**
```http
DELETE /api/v1/servers/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <jwt_token_for_maintainer_user>
```

**Response (403 Forbidden):**
```json
{
  "status": "error",
  "message": "Insufficient permissions",
  "required": ["Admin"],
  "current": ["Maintainer"]
}
```

### Error Response - Conflict (Parent Has Children)

**Request:**
```http
DELETE /api/v1/servers/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <jwt_token_for_admin>
```

**Response (409 Conflict):**
```json
{
  "status": "error",
  "message": "Cannot delete server with active databases. Please delete or move all databases first.",
  "details": {
    "activeDatabases": 3,
    "databaseIds": ["db-uuid-1", "db-uuid-2", "db-uuid-3"]
  }
}
```

## Technical Context

### Technology Stack

- **Runtime**: Node.js 18+ LTS
- **Framework**: Express.js 4.x with TypeScript 5.x
- **ORM**: Prisma 5.x for type-safe database access
- **Database**: PostgreSQL 14+ (for metadata storage)
- **Authentication**: Azure Entra ID (MSAL) with JWT tokens
- **Validation**: Zod for request schema validation
- **Logging**: Winston with structured JSON logging
- **Testing**: Vitest for unit/integration tests, Playwright for E2E

### Architecture Patterns

- **Layered Architecture**: API routes → Controllers → Services → Prisma (data access)
- **Standard Response Envelope**: All responses follow `{ status, data?, message? }` format
- **Soft Delete Pattern**: deletedAt timestamp for all domain entities (Server, Database, Table, Element)
- **Audit Trail**: All CREATE/UPDATE/DELETE operations logged to AuditLog table
- **Optimistic Locking**: ETag-based concurrency control using updatedAt timestamps
- **Hierarchical RBAC**: Admin > Maintainer > Viewer with inherited permissions

### Security Controls

- **Authentication**: Azure Entra ID JWT tokens validated with Microsoft public keys
- **Authorization**: Role-based middleware checks (requireRole) on protected endpoints
- **Input Validation**: All inputs trimmed, HTML-sanitized, validated against schemas
- **SQL Injection Prevention**: Prisma's parameterized queries prevent SQL injection
- **XSS Prevention**: HTML sanitization on all string inputs
- **Rate Limiting**: 100 requests/minute per user
- **CORS**: Configured to allow frontend origin only
- **Audit Logging**: All data modifications logged with user, timestamp, before/after values

### Performance Targets

| Operation Type | P95 Target | Examples |
|---------------|------------|----------|
| Simple CRUD | < 100ms | GET /servers/:id, PUT /tables/:id |
| List queries | < 200ms | GET /servers?page=1&limit=25 |
| Complex searches | < 500ms | GET /search?query=customer |
| Statistics | < 500ms | GET /statistics/dashboard |

### Data Validation Rules

| Field | Validation Rules |
|-------|-----------------|
| name | Required, 1-255 characters, trimmed, HTML-sanitized, unique per scope |
| description | Optional, 0-2000 characters, trimmed, HTML-sanitized |
| email | Optional, valid email format, 255 characters max |
| rdbmsType | Required for servers, enum: POSTGRESQL/MYSQL/ORACLE/DB2/INFORMIX |
| tableType | Required for tables, enum: TABLE/VIEW/MATERIALIZED_VIEW |
| status | Optional, enum: ACTIVE/INACTIVE/ARCHIVED, default ACTIVE |
| role | Required for users, enum: ADMIN/EDITOR/VIEWER, default VIEWER |

## Assumptions

1. **Authentication**: Assumes Azure Entra ID is configured and accessible; JWT tokens are obtained by frontend before API calls
2. **Database**: Assumes PostgreSQL 14+ database is provisioned and accessible at DATABASE_URL
3. **Frontend**: Assumes separate React frontend will consume this API; no server-side rendering
4. **Network**: Assumes API is deployed behind load balancer with HTTPS termination
5. **Scalability**: Initial deployment assumes single API server; horizontal scaling may require session store for rate limiting
6. **Timezone**: All timestamps stored in UTC; timezone conversion is frontend responsibility
7. **Locale**: API responses are English-only; internationalization is frontend responsibility
8. **File Storage**: No file upload/download in initial version; future DDL/report generation may require object storage
9. **Email Notifications**: No email notifications in initial version; audit logs provide change history
10. **User Registration**: User accounts created by Admin; no self-service registration
11. **Password Management**: Passwords managed by Azure Entra ID; API does not handle password storage/reset
12. **Token Refresh**: Frontend responsible for proactive token refresh before expiration
13. **Data Retention**: Soft-deleted entities retained indefinitely; no automated purging in initial version
14. **Concurrency**: Optimistic locking is optional (backward compatible); last-write-wins if If-Match header omitted
15. **Search**: Basic case-insensitive partial match in initial version; full-text search with ranking is future enhancement

## Dependencies

### External Dependencies

- **Azure Entra ID**: Required for JWT token issuance and validation
- **PostgreSQL Database**: Required for metadata persistence
- **Microsoft JWKS Endpoint**: Required for JWT public key retrieval

### Internal Dependencies

- This API specification depends on completion of database schema design (see `specs/data-model/`)
- Frontend application depends on this API specification for data access
- Report generation feature depends on completion of core CRUD operations

### Future Dependencies

- PDF report generation may require puppeteer or similar library
- DDL script generation may require database-specific template libraries
- Advanced search may require full-text search engine (PostgreSQL full-text or Elasticsearch)

## Open Questions

None - all critical questions have been clarified in previous specification sessions (see specs/api/README.md "Clarifications" section for historical context).

## Acceptance Criteria Checklist

- [ ] All API endpoints documented in this spec are implemented
- [ ] All endpoints require authentication (except /health and /api/v1)
- [ ] Role-based authorization enforced on all protected endpoints
- [ ] All CREATE/UPDATE/DELETE operations logged to AuditLog
- [ ] Soft delete implemented for Server, Database, Table, Element
- [ ] Parent-child relationship constraints enforced (prevent delete with active children)
- [ ] Pagination implemented on all list endpoints
- [ ] Search endpoint returns results across all entity types
- [ ] Standard response envelope used for all responses
- [ ] Appropriate HTTP status codes returned for all scenarios
- [ ] Validation errors include field-level details
- [ ] All inputs trimmed and HTML-sanitized
- [ ] Optimistic locking (ETag) implemented and tested
- [ ] Rate limiting enforced (100 req/min per user)
- [ ] Health check endpoint operational
- [ ] Response time SLAs met (100ms simple, 200ms list, 500ms complex)
- [ ] OpenAPI/Swagger documentation generated and accessible
- [ ] Security audit passed (no SQL injection, XSS, auth bypass)
- [ ] All user stories independently testable and verified
- [ ] Integration tests cover happy paths and error scenarios
- [ ] API deployed to staging environment and smoke tested

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-29  
**Next Review**: After implementation planning phase
