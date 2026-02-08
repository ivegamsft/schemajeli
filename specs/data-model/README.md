# Data Model Specifications

Database schema design, entity relationships, and data dictionary.

## Entity Relationship Diagram

```
User (1) ──────── (N) Server
  │                   │
  │                   └─── (1) ──────── (N) Database
  │                                         │
  │                                         └─── (1) ──────── (N) Table
  │                                                               │
  │                                                               └─── (1) ──────── (N) Element
  │
  ├─── (1) ──────── (N) Abbreviation
  │
  └─── (1) ──────── (N) AuditLog
```

> **Clarifications encoded 2026-02-08** (from SpecKit clarify workflow):
>
> 1. **Roles**: Canonical roles are `ADMIN, MAINTAINER, VIEWER` (aligned with security spec and backend RBAC middleware). The legacy `EDITOR` role in the Prisma schema must be migrated to `MAINTAINER`.
> 2. **Authentication**: Users authenticate via Azure Entra ID only — no local passwords. The `passwordHash` field in the Prisma schema is legacy and must be removed. User records are synced from Entra ID token claims on first login.
> 3. **Soft deletes**: Per the constitution, all entities use soft deletes (`deletedAt` field). This applies to User and Abbreviation as well as the hierarchy entities.
> 4. **SQLSERVER**: `SQLSERVER` is a supported RDBMS type and must be added to the Prisma `RdbmsType` enum.
> 5. **AuditLog & SearchIndex**: Both are core entities required by the constitution and must be documented in this spec.

## Core Entities

**Scale:** System designed for comprehensive enterprise metadata management with ~500 servers, ~2K databases, ~50K tables, ~1M column records.

### User
System user profile synced from Azure Entra ID. Authentication is handled externally via Entra ID; no local credentials are stored.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| entraId | String | No | Azure Entra ID object identifier (`oid` claim) |
| username | String | No | Unique username (derived from Entra ID `preferred_username`) |
| email | String | No | User email (from Entra ID `email` claim) |
| fullName | String | No | User's display name (from Entra ID `name` claim) |
| role | Enum | No | ADMIN, MAINTAINER, VIEWER (default: VIEWER) |
| isActive | Boolean | No | Account active status (default: true) |
| lastLoginAt | DateTime | Yes | Last login timestamp |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |
| deletedAt | DateTime | Yes | Soft delete timestamp (null = active) |

### Server
Database server connection metadata.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| name | String | No | Server name (unique) |
| description | String | Yes | Server description |
| host | String | No | Hostname/IP address |
| port | Integer | Yes | Port number |
| rdbmsType | Enum | No | POSTGRESQL, MYSQL, ORACLE, DB2, INFORMIX, SQLSERVER |
| location | String | Yes | Physical/logical location |
| status | Enum | No | ACTIVE, INACTIVE, ARCHIVED (default: ACTIVE) |
| createdById | UUID | No | Creator user FK |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |
| deletedAt | DateTime | Yes | Soft delete timestamp (null = active) |

### Database
Logical database within a server.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| serverId | UUID | No | Parent server FK |
| name | String | No | Database name |
| description | String | Yes | Database description |
| purpose | String | Yes | Business purpose |
| status | Enum | No | ACTIVE, INACTIVE, ARCHIVED (default: ACTIVE) |
| createdById | UUID | No | Creator user FK |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |
| deletedAt | DateTime | Yes | Soft delete timestamp (null = active) |

### Table
Table/View within a database.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| databaseId | UUID | No | Parent database FK |
| name | String | No | Table name |
| description | String | Yes | Table description |
| tableType | Enum | No | TABLE, VIEW, MATERIALIZED_VIEW (default: TABLE) |
| rowCountEstimate | Integer | Yes | Estimated row count |
| status | Enum | No | ACTIVE, INACTIVE, ARCHIVED (default: ACTIVE) |
| createdById | UUID | No | Creator user FK |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |
| deletedAt | DateTime | Yes | Soft delete timestamp (null = active) |

### Element
Column/Field within a table.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| tableId | UUID | No | Parent table FK |
| name | String | No | Column name |
| description | String | Yes | Column description |
| dataType | String | No | SQL data type |
| length | Integer | Yes | Column length/size |
| precision | Integer | Yes | Numeric precision |
| scale | Integer | Yes | Numeric scale |
| isNullable | Boolean | No | Nullable flag (default: true) |
| isPrimaryKey | Boolean | No | Primary key flag (default: false) |
| isForeignKey | Boolean | No | Foreign key flag (default: false) |
| defaultValue | String | Yes | Default value expression |
| position | Integer | No | Column order position |
| createdById | UUID | No | Creator user FK |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |
| deletedAt | DateTime | Yes | Soft delete timestamp (null = active) |

### Abbreviation
Business term abbreviation dictionary.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| source | String | No | Source term |
| abbreviation | String | No | Abbreviated term (unique) |
| definition | String | Yes | Definition/meaning |
| isPrimeClass | Boolean | No | Prime class flag (default: false) |
| category | String | Yes | Category classification |
| createdById | UUID | No | Creator user FK |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |
| deletedAt | DateTime | Yes | Soft delete timestamp (null = active) |

### AuditLog
Immutable audit trail for all data modifications (required by constitution).

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| entityType | Enum | No | SERVER, DATABASE, TABLE, ELEMENT, ABBREVIATION, USER |
| entityId | String | No | ID of the affected entity |
| action | Enum | No | CREATE, UPDATE, DELETE, RESTORE |
| userId | String | No | User who performed the action (FK) |
| changes | JSON | Yes | Before/after values for the modification |
| ipAddress | String | Yes | Client IP address |
| userAgent | String | Yes | Client user-agent string |
| createdAt | DateTime | No | Timestamp of the action |

> AuditLog records are **append-only** — they must never be updated or deleted. Retention policy: 7 years.

### SearchIndex
Full-text search index for cross-entity search functionality.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| id | UUID | No | Primary key |
| entityType | Enum | No | SERVER, DATABASE, TABLE, ELEMENT, ABBREVIATION, USER |
| entityId | String | No | ID of the indexed entity |
| content | Text | No | Searchable text content (aggregated from entity fields) |
| metadata | JSON | Yes | Additional metadata for search ranking/filtering |
| createdAt | DateTime | No | Creation timestamp |
| updatedAt | DateTime | No | Last update timestamp |

## Key Constraints

- **Foreign Keys**: Enforce referential integrity with `onDelete: Restrict` (parent cannot be deleted while children exist)
- **Unique Constraints**:
  - `user(entraId)`, `user(username)`, `user(email)`
  - `server(name)`
  - `database(serverId, name)`
  - `table(databaseId, name)`
  - `element(tableId, name)`
  - `abbreviation(abbreviation)`
- **Check Constraints**: Valid RDBMS types, status values, table types
- **Not Null**: All required fields enforced at database level
- **Soft Delete Filtering**: All list/get queries must filter by `deletedAt IS NULL` unless explicitly requesting deleted records

## Indexes

- **Users**: (entraId), (email), (role)
- **Servers**: (name), (status)
- **Databases**: (serverId), (name), (status)
- **Tables**: (databaseId), (name), (status)
- **Elements**: (tableId), (name), (dataType)
- **Abbreviations**: (source), (abbreviation), (category)
- **AuditLog**: (entityType, entityId), (userId), (createdAt)
- **SearchIndex**: (entityType, entityId)

## Data Dictionary

### RDBMS Types
- POSTGRESQL — PostgreSQL
- MYSQL — MySQL
- ORACLE — Oracle Database
- DB2 — IBM DB2
- INFORMIX — IBM Informix
- SQLSERVER — Microsoft SQL Server

### Entity Status
- ACTIVE — Currently active and in use
- INACTIVE — Inactive but retained
- ARCHIVED — Archived for historical reference

### Table Types
- TABLE — Regular database table
- VIEW — Database view
- MATERIALIZED_VIEW — Materialized/snapshot view

### User Roles
- ADMIN — Full system access, user management, all CRUD operations
- MAINTAINER — Schema editing, database management, abbreviation management
- VIEWER — Read-only access to all entities

### Audit Actions
- CREATE — New entity created
- UPDATE — Entity modified
- DELETE — Entity soft-deleted
- RESTORE — Soft-deleted entity restored

### Entity Types (for AuditLog and SearchIndex)
- SERVER
- DATABASE
- TABLE
- ELEMENT
- ABBREVIATION
- USER

## Clarifications

### Session 2026-01-29

- Q: What are the performance index requirements for high-cardinality entity relationships? → A: Composite index (tableId, position) on Elements optimized for ~1M records; (databaseId, name) on Tables for 50K records
- Q: How should concurrent update conflicts be detected? → A: Use `updatedAt` timestamp for optimistic locking; compare timestamp on update and fail with conflict error if mismatch
- Q: What is the retention and archival policy for audit logs? → A: 7-year retention (already documented); append-only (already documented); no archival to external storage required initially
- Q: What are the cascading delete rules for hierarchical entities? → A: Soft delete only; `onDelete: Restrict` prevents parent deletion if active children exist (already documented)
- Q: What search index update strategy should be used? → A: Asynchronous update: database write commits first, then search index updated in background job; temporary inconsistency acceptable (<5 second lag)
