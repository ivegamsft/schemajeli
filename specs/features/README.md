# Feature Specifications

Feature requirements, user stories, and functionality roadmap.

## Core Features

### 1. Server Management
Manage database server connections and metadata.

- Create, read, update, delete (CRUD) database servers
- Support multiple RDBMS types (PostgreSQL, MySQL, Oracle, DB2, Informix, SQL Server)
- Track server location and status
- View server details and associated databases

### 2. Database Management
Organize and document databases within servers.

- CRUD operations on databases
- Link databases to parent servers
- Track database purpose and status
- View database details and associated tables

### 3. Table Management
Browse and document database tables.

- CRUD operations on tables
- Support table types: TABLE, VIEW, MATERIALIZED_VIEW
- Track row count estimates
- View table elements (columns)
- Concurrent editing: Last-write-wins with conflict detection (HTTP 409 on timestamp mismatch)

### 4. Column/Element Management
Detailed column-level metadata.

- CRUD operations on table elements (columns)
- Track data types, lengths, precision, scale
- Track nullable, primary key, foreign key properties
- Column position tracking
- Default values and descriptions

### 5. Abbreviation Management
Maintain business term abbreviations and definitions.

- CRUD operations on abbreviations
- Track source terms and definitions
- Categorize abbreviations
- Prime class designation
- Full-text search support

### 6. Search Functionality
Cross-entity search across servers, databases, tables, elements, abbreviations.

- Full-text search
- Pagination of results (default 25, max 200 per page)
- Entity type filtering
- Result highlighting/context
- Empty result handling: Return empty array with clear "No results found" message
- Large result sets: Performance target <500ms p95 for searches across ~1M column metadata records

### 7. Report Generation
Export and document schema information.

- DDL (Data Definition Language) report generation
- Support multiple formats: SQL, JSON, TXT
- Database schema export
- Full or filtered exports
- Performance: DDL generation <2s for single database export
- Error recovery: Retry with exponential backoff (3 attempts); partial results with error notification if subset fails

### 8. Authentication & Authorization
Enterprise authentication with role-based access control.

- Azure Entra ID integration
- MSAL-based sign-in
- JWT token validation
- Role-based access control (Admin, Maintainer, Viewer)
- Permission-based UI/API enforcement

### 9. Audit & Monitoring
Track changes and system health.

- User action logging
- Change tracking (createdAt, updatedAt, createdBy)
- Application Insights monitoring
- Health checks
- Data retention: 7-year audit log retention per compliance requirements
- Soft delete visibility: Deleted entities hidden by default; Admin can query via `?status=deleted` filter

## User Stories

### As an Admin
- I want to manage user access and roles
- I want to audit all system changes
- I want to manage system configuration

### As a Maintainer
- I want to add/update database schema information
- I want to create and manage abbreviations
- I want to export schema documentation

### As a Viewer
- I want to browse database schemas
- I want to search for specific tables/columns
- I want to view abbreviations and definitions

## Roadmap

### Phase 1 ✅ (Complete)
- Basic CRUD for Servers, Databases, Tables, Elements
- User authentication
- Basic search

### Phase 2 ✅ (Complete)
- Abbreviation management
- Enhanced search
- Report generation (DDL)

### Phase 3 ✅ (Complete)
- Azure Entra ID integration
- RBAC implementation
- JWT authentication

### Phase 4 🚀 (Current)
- Frontend type fixes
- API permissions configuration
- Production hardening

### Phase 5 📋 (Planned)
- Change history/audit trail
- Data lineage tracking
- Advanced reporting
- API versioning

## Clarifications

### Session 2026-01-29

- Q: What is the expected data volume for the system at enterprise scale? → A: ~500 servers, ~2K databases, ~50K tables, ~1M columns (comprehensive enterprise metadata repository scale)
- Q: What are the performance targets for core operations? → A: Simple queries <100ms p95, complex searches <500ms p95, DDL generation <2s for single database
- Q: How should the system handle concurrent editing conflicts? → A: Last-write-wins with conflict detection: return HTTP 409 with current version if update timestamp mismatch detected
- Q: What are the data retention and soft delete visibility rules? → A: Soft-deleted entities hidden by default; Admin can query deleted entities via `?status=deleted` filter; 7-year audit retention per compliance
- Q: What error recovery mechanisms exist for failed DDL report generation? → A: Retry with exponential backoff (3 attempts); partial results with error notification if schema read fails for subset of tables
