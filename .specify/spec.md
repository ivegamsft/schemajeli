# SchemaJeli - Specification

## Overview & Context

**Project:** SchemaJeli Database Metadata Repository  
**Legacy System:** CompanyName Repository System (1999)  
**Current Tech Stack:** VBScript/ASP, Informix/DB2, IE 4.01+  
**Goal:** Modernize and rebrand from CompanyName to SchemaJeli with contemporary architecture

### Background
SchemaJeli is a legacy web-based metadata repository system originally developed for CompanyName in 1999. The system manages enterprise database schemas, metadata, and naming standards across multiple servers and databases. This project will rebrand the system, modernize the architecture, and prepare it for cloud-native deployment.

---

## Functional Requirements

### FR-1: User Authentication & Authorization
- **REQ-1.1** Users must authenticate with username/password
- **REQ-1.2** System shall support role-based access control (Admin, Maintainer, Viewer)
- **REQ-1.3** User sessions shall timeout after configurable period (default: 60 minutes)
- **REQ-1.4** Admin users can create, modify, and delete user accounts
- **REQ-1.5** User actions shall be logged for audit trail

### FR-2: Schema Object Management
- **REQ-2.1** Users can create, read, update, and delete server definitions
- **REQ-2.2** Users can create, read, update, and delete database definitions
- **REQ-2.3** Users can create, read, update, and delete table definitions
- **REQ-2.4** Users can create, read, update, and delete element (column) definitions
- **REQ-2.5** System enforces parent-child relationships (Server → Database → Table → Element)
- **REQ-2.6** Each object can be tagged with status: Production, Development, Testing, Approval

### FR-3: Search & Discovery
- **REQ-3.1** Users can search for servers by name or partial name
- **REQ-3.2** Users can search for databases by name or partial name
- **REQ-3.3** Users can search for tables by name with wildcard support
- **REQ-3.4** Users can search for elements (columns) with wildcard support
- **REQ-3.5** Users can search for elements by keywords
- **REQ-3.6** Search results display relevant metadata (status, location, version, owner)

### FR-4: Naming Standards Management
- **REQ-4.1** System maintains library of standard abbreviations
- **REQ-4.2** Users can view and search standard abbreviations
- **REQ-4.3** Authorized users can add/modify abbreviations
- **REQ-4.4** System validates element names against naming standards
- **REQ-4.5** System prevents forbidden characters in object names

### FR-5: Report Generation
- **REQ-5.1** Generate summary reports for servers
- **REQ-5.2** Generate summary, detail, and full reports for databases
- **REQ-5.3** Generate summary and detail reports for tables
- **REQ-5.4** Generate detail and full reports for elements
- **REQ-5.5** Generate DDL (Data Definition Language) scripts
- **REQ-5.6** Export reports in HTML, CSV, or PDF formats
- **REQ-5.7** Filter reports by status (Production, Development, Testing, Approval)

### FR-6: Data Dictionary & Documentation
- **REQ-6.1** System serves as enterprise data dictionary
- **REQ-6.2** Each object can have description and documentation
- **REQ-6.3** System tracks last modified date and user for audit
- **REQ-6.4** System tracks creation date and user for audit

### FR-7: Help System
- **REQ-7.1** Context-sensitive help available for all features
- **REQ-7.2** Comprehensive glossary of terms
- **REQ-7.3** How-to guides for common tasks
- **REQ-7.4** Help content searchable

---

## Non-Functional Requirements

### NFR-1: Performance
- **PERF-1.1** Search queries shall return results within 2 seconds
- **PERF-1.2** Report generation shall complete within 10 seconds for standard reports
- **PERF-1.3** System shall support concurrent users (minimum 100 concurrent sessions)
- **PERF-1.4** Database queries shall use appropriate indexing for optimization

### NFR-2: Scalability
- **SCALE-2.1** System architecture shall be horizontally scalable
- **SCALE-2.2** Database shall support millions of objects without performance degradation
- **SCALE-2.3** API-first design for future mobile/desktop client support

### NFR-3: Security
- **SEC-3.1** All passwords shall be hashed (bcrypt minimum)
- **SEC-3.2** HTTPS/TLS encryption for all data in transit
- **SEC-3.3** SQL injection prevention through parameterized queries
- **SEC-3.4** CSRF protection for all state-changing operations
- **SEC-3.5** Rate limiting on authentication endpoints
- **SEC-3.6** Audit logging of all data modifications

### NFR-4: Availability & Reliability
- **REL-4.1** System shall achieve 99.5% uptime
- **REL-4.2** Database backups daily with 30-day retention
- **REL-4.3** Graceful error handling with user-friendly messages
- **REL-4.4** Connection retry logic for database failures

### NFR-5: Usability
- **USE-5.1** Responsive web UI supporting desktop and tablet
- **USE-5.2** Intuitive navigation with consistent menu structure
- **USE-5.3** Accessible design following WCAG 2.1 AA standards
- **USE-5.4** Browser compatibility: Chrome, Firefox, Safari, Edge (latest 2 versions)

### NFR-6: Maintainability
- **MAINT-6.1** Code organized into distinct layers (API, Business Logic, Data)
- **MAINT-6.2** Comprehensive API documentation (OpenAPI/Swagger)
- **MAINT-6.3** Minimum 70% test coverage
- **MAINT-6.4** All components containerized with Docker
- **MAINT-6.5** Infrastructure as Code (Terraform/Bicep for Azure)

### NFR-7: Data Management
- **DATA-7.1** Support for PostgreSQL, MySQL, SQL Server, and Informix databases
- **DATA-7.2** Data export in CSV, JSON, and SQL formats
- **DATA-7.3** Data import validation and conflict detection

---

## User Stories

### Story US-1: Admin User Management
**As an** administrator  
**I want to** create and manage user accounts  
**So that** I can control access to the metadata repository

**Acceptance Criteria:**
- Can create new users with assigned roles
- Can modify user roles and permissions
- Can disable/delete users
- Changes are logged for audit trail

### Story US-2: Search Metadata
**As a** developer  
**I want to** search for database tables and columns  
**So that** I can find the metadata I need for my application

**Acceptance Criteria:**
- Can search by exact or partial name
- Results show relevant metadata (status, location, owner)
- Search completes in under 2 seconds
- Wildcard support for element searches

### Story US-3: Manage Database Schema
**As a** database administrator  
**I want to** add and maintain database definitions  
**So that** our enterprise metadata is current and accurate

**Acceptance Criteria:**
- Can create new database entries with required metadata
- Can link databases to servers
- Can update database status (Production, Development, etc.)
- Changes trigger audit log entries

### Story US-4: Generate Reports
**As a** data architect  
**I want to** generate detailed schema reports  
**So that** I can document and analyze database structures

**Acceptance Criteria:**
- Can select report type (Summary, Detail, Full)
- Can filter by status, server, or database
- Reports available in HTML, CSV, PDF
- DDL scripts can be generated for deployment

### Story US-5: Enforce Naming Standards
**As a** data governance officer  
**I want to** maintain and enforce naming standards  
**So that** the organization maintains consistent naming conventions

**Acceptance Criteria:**
- Abbreviation library is maintained and searchable
- System prevents object names with forbidden characters
- Naming validation is applied on object creation
- Standards are documented and accessible to users

---

## Edge Cases & Constraints

### EC-1: Legacy Data Migration
- Some objects may lack parent references (migrated from old MSP system)
- System shall display "N/A" for missing parent objects gracefully
- New objects MUST have valid parent-child relationships

### EC-2: Multi-RDBMS Support
- Must support Informix, DB2, SQL Server, PostgreSQL
- Database version tracking required
- Platform-specific DDL generation

### EC-3: Large Result Sets
- Search results with 10,000+ rows must be paginated
- Reports for large schemas must support streaming/chunking
- Export functionality must handle memory efficiently

### EC-4: Concurrent Modifications
- Conflict detection if two users edit same object simultaneously
- Last-write-wins strategy with change notifications
- Optimistic locking for concurrent updates

### EC-5: Browser Compatibility
- Modern browsers only (IE support removed)
- Responsive design for mobile viewing
- Progressive enhancement for JavaScript-disabled scenarios

---

## Success Criteria

1. **Rebranding:** All references to "CompanyName" replaced with "SchemaJeli"
2. **Architecture:** Modern 3-tier architecture (Frontend, API, Database)
3. **Technology Stack:** Node.js/Python backend, React/Vue frontend, PostgreSQL database
4. **Testing:** Minimum 70% code coverage with unit and integration tests
5. **Documentation:** Complete API docs, user guide, and deployment guide
6. **Performance:** All operations meet response time targets
7. **Security:** Passes OWASP Top 10 security review
8. **Cloud Ready:** Deployable to Azure, AWS, or on-premises Kubernetes
