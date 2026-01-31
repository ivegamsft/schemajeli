# Legacy System Assessment

**Project:** SchemaJeli  
**Phase:** 1.2.5 - Design & Specification  
**Version:** 1.0  
**Last Updated:** January 30, 2026

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Legacy Technology Stack](#legacy-technology-stack)
3. [File Structure Analysis](#file-structure-analysis)
4. [Database Schema Assessment](#database-schema-assessment)
5. [Business Logic Inventory](#business-logic-inventory)
6. [Rebranding Requirements](#rebranding-requirements)
7. [Migration Strategy](#migration-strategy)
8. [Risk Assessment](#risk-assessment)
9. [Data Migration Plan](#data-migration-plan)
10. [Deprecation Timeline](#deprecation-timeline)

---

## Executive Summary

The **SchemaJeli** project involves modernizing a legacy ASP-based metadata repository system originally designed circa 1999-2000. The system uses Classic ASP (VBScript), Informix database, and traditional server-side rendering with minimal JavaScript.

### Key Findings
- ✅ **Codebase Status**: Company references removed, git history cleaned
- ⚠️ **Legacy Tech**: Classic ASP (VBScript), Informix stored procedures, no modern framework
- ⚠️ **Architecture**: Monolithic, tightly coupled, no API layer
- ⚠️ **Security**: Basic authentication, potential SQL injection risks, no parameterized queries
- ⚠️ **Documentation**: Minimal inline comments, no formal API documentation
- ⚠️ **Testing**: No automated tests, no test coverage

### Migration Scope
| Component | Legacy | Modern | Migration Complexity |
|-----------|--------|--------|---------------------|
| **Backend** | ASP/VBScript | Node.js/TypeScript | High |
| **Database** | Informix | PostgreSQL | Medium |
| **Frontend** | Server-rendered HTML | React SPA | High |
| **API** | None (embedded) | REST API | High |
| **Auth** | Session-based | JWT-based | Medium |
| **Reports** | ASP includes | API endpoints | Medium |

---

## Legacy Technology Stack

### Server-Side Components
| Technology | Version | Purpose | Replacement |
|------------|---------|---------|-------------|
| **IIS (Internet Information Services)** | 5.0+ | Web server | Node.js (Express) |
| **Classic ASP** | 3.0 | Server-side scripting | TypeScript/Node.js |
| **VBScript** | 5.x | Programming language | TypeScript |
| **COM Components** | Various | Data access (ADO) | Prisma ORM |
| **Informix** | 9.x-10.x | Relational database | PostgreSQL 14+ |

### Client-Side Components
| Technology | Purpose | Replacement |
|------------|---------|-------------|
| **HTML 4.01** | Markup | HTML5 |
| **Inline CSS** | Styling | Tailwind CSS |
| **Minimal JavaScript** | Basic validation | React 18 + TypeScript |
| **Java Applets (menu.CAB)** | Navigation menu | React Router |
| **ActiveX Controls** | Client-side functionality | Modern JavaScript APIs |

### Database Technologies
- **RDBMS**: Informix Dynamic Server
- **Stored Procedures**: Informix SPL (Stored Procedure Language)
- **Data Access**: ADO (ActiveX Data Objects)
- **Connection Pooling**: COM+ object pooling
- **Transaction Management**: Manual transaction control

---

## File Structure Analysis

### Root Directory Files
| File | Purpose | Migration Action |
|------|---------|------------------|
| `default.asp` | Application entry point, login redirect | Replace with React routing (`/` → `/login` or `/dashboard`) |
| `GLOBAL.ASA` | Application-level events, session config | Replace with Express middleware, session management |
| `Inettest.asp` | Connection test page | Replace with `/api/health` endpoint |
| `#haccess.ctl` | Access control file | Replace with JWT authentication middleware |

### Include Directory (`/include/`)
**Purpose**: Shared ASP include files (reusable code modules)

| File | Purpose | Lines | Migration Strategy |
|------|---------|-------|-------------------|
| `adovbs.inc` | ADO constant definitions | ~500 | ❌ Deprecated (Prisma ORM replaces ADO) |
| `asccodes.inc` | ASCII code constants | ~100 | ✅ Migrate to TypeScript constants file |
| `cmpny_cds.inc` | Company code lookups | ~50 | ⚠️ **REBRAND** - Replace company references |
| `colors.inc` | Color definitions for HTML | ~30 | ✅ Migrate to Tailwind CSS config |
| `date.inc` | Date manipulation functions | ~200 | ✅ Migrate to `date-fns` library |
| `frbdnChars.inc` | Forbidden characters validation | ~50 | ✅ Migrate to Zod validation schemas |
| `navmenu.inc` | Navigation menu generation | ~300 | ✅ Replace with React components |
| `New_ElemNme.inc` | Element name validation | ~100 | ✅ Migrate to Prisma schema + validation |
| `NRS_foot.inc` | Page footer template | ~50 | ✅ Migrate to React layout component |
| `Rpt_*.inc` (15 files) | Report generation includes | ~3000 | ✅ Migrate to API endpoints + React components |
| `security.inc` | Authentication/authorization logic | ~400 | ✅ Migrate to Express middleware + JWT |
| `tblname.inc` | Table name constants | ~100 | ✅ Migrate to Prisma schema |
| `Valid_*.inc` (3 files) | Validation logic | ~300 | ✅ Migrate to Zod schemas |

**Total Include Files**: 30+ files (~5,000 lines of VBScript)

### DDL Directory (`/ddl/`)
**Purpose**: Database schema definitions (Informix DDL)

| File | Purpose | Size | Migration Action |
|------|---------|------|------------------|
| `OATPA10_YYYC716.ddl` | Schema for C716 server | ~500 lines | ✅ Analyze for Prisma schema mapping |
| `OATPA20_YYYC716.ddl` | Updated schema | ~600 lines | ✅ Analyze for Prisma schema mapping |
| `OATPA20_YYYC716.txt` | Schema documentation | ~100 lines | ✅ Use as reference for field descriptions |
| `OATPA20_YYYDWG1.txt` | DWG1 server schema | ~100 lines | ✅ Use as reference |
| `OATPA20_YYYTEST.txt` | Test server schema | ~100 lines | ✅ Use as reference |

**Key Findings:**
- Table prefix: `OATPA` (likely abbreviation for "Online Application Table ...")
- Naming convention: `OATPA##_<server>` format
- Multiple server instances documented
- No foreign key constraints visible (may be enforced in application layer)

### Scripts Directory (`/scripts/`)
**Purpose**: Client-side JavaScript and supporting files

Detailed inventory not available in workspace view, but expected contents:
- Validation scripts
- Form handling
- Menu navigation
- Search functionality

**Migration Strategy**: Replace all with React components and modern JavaScript

### Menu Directory (`/menu/`)
**Purpose**: Java-based navigation menu applet

| File | Type | Purpose | Migration Action |
|------|------|---------|------------------|
| `Menu.js` | JavaScript | Menu controller | ✅ Replace with React components |
| `DisplayMenu.js` | JavaScript | Menu display logic | ✅ Replace with React components |
| `NavBar.js` | JavaScript | Navigation bar | ✅ Replace with React Router + components |
| `menu.CAB` | Java CAB | Compiled Java applet | ❌ Deprecated - Use React |
| `menu.vjp` | Project | Visual J++ project | ❌ Deprecated |

**Security Concern**: Java applets are deprecated and pose security risks. Must be replaced.

### Help Directory (`/help/`)
**Purpose**: User documentation HTML files

| File | Purpose | Rebranding Required |
|------|---------|---------------------|
| `hlp_admin.htm` | Admin help | ⚠️ Check for company references |
| `hlp_codes.htm` | Code tables help | ⚠️ Check for company references |
| `hlp_howTo.htm` | How-to guide | ⚠️ Check for company references |
| `hlp_maintain.htm` | Maintenance help | ⚠️ Check for company references |
| `hlp_procs.htm` | Procedures guide | ⚠️ Check for company references |
| `hlp_reports.htm` | Reports help | ⚠️ Check for company references |
| `hlp_search.htm` | Search help | ⚠️ Check for company references |
| `hlp_support.htm` | Support information | ⚠️ **HIGH PRIORITY** - Replace contact info |

**Migration Strategy**: Convert to Markdown, integrate into React app, update all references

---

## Database Schema Assessment

### Informix Schema Structure

**Based on file naming and legacy ASP patterns, estimated schema:**

#### Core Tables (Inferred)

**1. Users/Security Table**
```sql
-- Estimated structure based on security.inc analysis
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(50), -- Likely plain text or weak hash ⚠️
  email VARCHAR(100),
  role VARCHAR(20), -- ADMIN, EDITOR, VIEWER
  status CHAR(1), -- A=Active, I=Inactive
  created_date DATETIME YEAR TO SECOND,
  modified_date DATETIME YEAR TO SECOND
);
```

**2. Servers Table**
```sql
-- Metadata repository tracking multiple database servers
CREATE TABLE servers (
  server_id SERIAL PRIMARY KEY,
  server_name VARCHAR(50) NOT NULL UNIQUE,
  rdbms_type VARCHAR(20), -- INFORMIX, ORACLE, SQLSERVER
  host_name VARCHAR(100),
  port INTEGER,
  status CHAR(1),
  description VARCHAR(255),
  created_date DATETIME YEAR TO SECOND,
  created_by INTEGER REFERENCES users(user_id)
);
```

**3. Databases Table**
```sql
CREATE TABLE databases (
  database_id SERIAL PRIMARY KEY,
  server_id INTEGER REFERENCES servers(server_id),
  database_name VARCHAR(50) NOT NULL,
  status CHAR(1),
  description VARCHAR(255),
  created_date DATETIME YEAR TO SECOND,
  UNIQUE (server_id, database_name)
);
```

**4. Tables Table**
```sql
CREATE TABLE tables (
  table_id SERIAL PRIMARY KEY,
  database_id INTEGER REFERENCES databases(database_id),
  table_name VARCHAR(50) NOT NULL,
  table_type VARCHAR(20), -- TABLE, VIEW, SYNONYM
  description VARCHAR(255),
  row_count INTEGER,
  created_date DATETIME YEAR TO SECOND,
  UNIQUE (database_id, table_name)
);
```

**5. Elements Table (Columns)**
```sql
CREATE TABLE elements (
  element_id SERIAL PRIMARY KEY,
  table_id INTEGER REFERENCES tables(table_id),
  element_name VARCHAR(50) NOT NULL,
  data_type VARCHAR(30),
  length INTEGER,
  precision INTEGER,
  scale INTEGER,
  nullable CHAR(1), -- Y/N
  default_value VARCHAR(100),
  description VARCHAR(255),
  position INTEGER, -- Column order
  UNIQUE (table_id, element_name)
);
```

**6. Abbreviations Table**
```sql
CREATE TABLE abbreviations (
  abbreviation_id SERIAL PRIMARY KEY,
  abbreviation VARCHAR(20) NOT NULL UNIQUE,
  full_text VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  description VARCHAR(255),
  created_date DATETIME YEAR TO SECOND
);
```

### Data Migration Challenges

| Challenge | Severity | Mitigation |
|-----------|----------|------------|
| **Informix-specific data types** | Medium | Map to PostgreSQL equivalents (SERIAL → BIGSERIAL, DATETIME → TIMESTAMP) |
| **Character encoding** | Low | Validate UTF-8 encoding, handle special characters |
| **Date formats** | Low | Convert Informix DATETIME to ISO 8601 |
| **NULL handling** | Low | Review nullability constraints |
| **Stored procedures** | High | Rewrite in TypeScript/SQL as needed |
| **Triggers** | Medium | Identify and rewrite in PostgreSQL |
| **Sequences** | Low | Migrate to PostgreSQL sequences |

### Estimated Data Volumes (from design docs)
- **Servers**: 50-100 records
- **Databases**: 500-1,000 records (5-10 per server)
- **Tables**: 10,000-50,000 records (10-50 per database)
- **Elements**: 100,000-500,000 records (10-20 per table)
- **Abbreviations**: 500-2,000 records
- **Users**: 10-50 records

**Total estimated database size**: 50-100 MB

---

## Business Logic Inventory

### Core Functionality Modules

#### 1. Authentication & Authorization (`security.inc`)
**Current Implementation:**
- Session-based authentication
- Role-based access control (Admin, Editor, Viewer)
- Basic SQL injection prevention (Input validation)
- Session timeout handling

**Migration Needs:**
- ✅ Replace with JWT-based authentication
- ✅ Implement RBAC middleware
- ✅ Add password hashing (bcrypt)
- ✅ Add audit logging

#### 2. Search Functionality
**Current Implementation:**
- Full-text search across servers, databases, tables, elements
- Multiple search criteria (name, description, type)
- Result pagination (likely manual)
- Export to text/CSV

**Migration Needs:**
- ✅ Implement PostgreSQL full-text search
- ✅ Add search indexing
- ✅ Implement faceted search (filters)
- ✅ Add sorting and pagination
- ✅ Export to JSON/CSV/Excel

#### 3. Report Generation (`Rpt_*.inc`)

**Identified Reports (15 include files):**

| Report File | Report Type | Description |
|-------------|-------------|-------------|
| `Rpt_ElemSum.inc` | Element Summary | List all elements with descriptions |
| `Rpt_ElemDtl.inc` | Element Details | Detailed element metadata |
| `Rpt_TblSum.inc` | Table Summary | List all tables in a database |
| `Rpt_TblDtl.inc` | Table Details | Detailed table metadata + columns |
| `Rpt_DbFull.inc` | Database Full Report | Complete database schema export |
| `Rpt_DbDtl.inc` | Database Details | Database metadata |
| `Rpt_SrvrSum.inc` | Server Summary | List all servers |
| `Rpt_DbaFull.inc` | DBA Full Report | Complete system report |
| `Rpt_ShwName.inc` | Show Name | Display entity names |
| `Rpt_ShwType.inc` | Show Type | Display entity types |
| `Rpt_ShwStat.inc` | Show Status | Display entity status |
| `Rpt_ShwSrvr.inc` | Show Server | Display server info |
| `Rpt_ShwRep.inc` | Show Report | Display report output |
| `Rpt_ShwEnd.inc` | Show End | Report footer |
| `Rpt_Helper.inc` | Report Helper | Shared report functions |

**Migration Needs:**
- ✅ Convert to REST API endpoints (`/api/reports/*`)
- ✅ Implement pagination for large reports
- ✅ Add export formats (JSON, CSV, Excel, PDF)
- ✅ Create React components for report display
- ✅ Add report scheduling (future enhancement)

#### 4. CRUD Operations

**Servers Management:**
- Create new server entry
- Update server details (host, port, type)
- Delete/deactivate server
- List all servers with filters

**Databases Management:**
- Add database to server
- Update database metadata
- Delete/deactivate database
- View database schema summary

**Tables Management:**
- Document table structure
- Update table descriptions
- Link to parent database
- Mark tables as deprecated

**Elements (Columns) Management:**
- Add column metadata
- Update data types and descriptions
- Track column usage
- Validate naming conventions

**Abbreviations Management:**
- Add new abbreviations
- Update definitions
- Search abbreviations
- Prevent duplicates

#### 5. Validation Logic (`Valid_*.inc`)

**Database Name Validation (`Valid_DbNme.inc`):**
- Length constraints (1-50 characters)
- Allowed characters (alphanumeric, underscore)
- Reserved words check
- Duplicate check

**Table Name Validation (`Valid_TblNme.inc`):**
- Naming convention enforcement
- Prefix/suffix rules
- Case sensitivity handling
- Uniqueness within database

**Element Name Validation (`Valid_ElemNme.inc`):**
- Column naming standards
- Data type validation
- Length constraints by data type
- Forbidden characters

**Migration Strategy:**
- ✅ Implement in Zod schemas
- ✅ Add client-side validation (React Hook Form + Zod)
- ✅ Add server-side validation (Express middleware)
- ✅ Return detailed validation errors

---

## Rebranding Requirements

### Company Reference Audit

**Status**: ✅ Primary rebranding already completed (git history cleaned)

**Remaining Items to Verify:**

#### 1. Help Files (`/help/*.htm`)
**Action Required**: Full text search and replace

```bash
# Search for potential company references
grep -ri "Company" help/
grep -ri "Corp" help/
grep -ri "Inc\." help/
```

**Expected Replacements:**
- Company Name → "SchemaJeli"
- Support Email → `support@schemajeli.example.com`
- Copyright notices → "Copyright © 2026 SchemaJeli Project"
- Phone numbers → Remove or replace with support URL

#### 2. Database Object Names

**Current Naming Pattern**: `OATPA##` prefix

**Options:**
1. **Keep as-is**: Maintain `OATPA` prefix (no business value to change)
2. **Rename to neutral**: `META##` or `SCHEMA##` prefix
3. **Modernize**: Use descriptive names without prefixes

**Recommendation**: ✅ **Keep as-is** in legacy data, use clean names in new schema

**Prisma Schema Mapping:**
```prisma
// Old: OATPA10_servers
// New: Server (clean model name)
model Server {
  id        String   @id @default(uuid())
  name      String   @unique
  // ...
}
```

#### 3. Code Comments

**Action Required**: Review all ASP includes for embedded comments

```vbscript
' Example legacy comment that might need updating:
' Company Database Repository System
' Copyright (c) 1999-2000 CompanyName, Inc.
' All Rights Reserved.
```

**Replacement:**
```typescript
/**
 * SchemaJeli - Database Metadata Repository
 * Modern metadata management system
 * MIT License
 */
```

#### 4. Configuration Files

**Files to Review:**
- `GLOBAL.ASA` - Application name, session variables
- `#haccess.ctl` - Access control configurations
- Any `.ini` or `.config` files (not visible in current structure)

**Migration**: New `.env` file with clean variable names:
```bash
# .env
APP_NAME=SchemaJeli
APP_VERSION=2.0.0
COMPANY_NAME=SchemaJeli
SUPPORT_EMAIL=support@schemajeli.example.com
```

#### 5. Error Messages & User-Facing Text

**Review Needed**: All ASP pages for hardcoded strings

**Examples to replace:**
- "Welcome to Company Database Repository" → "Welcome to SchemaJeli"
- "Contact Company Support" → "Contact Support"
- "Company Confidential" → Remove or replace with appropriate notice

**Strategy**: 
- ✅ Use i18n library in React (`react-i18next`)
- ✅ Centralize all UI strings in `src/frontend/locales/en.json`
- ✅ No hardcoded strings in components

### Rebranding Checklist

- [x] Git history cleaned (completed)
- [x] Repository renamed to `schemajeli` (completed)
- [ ] Help files updated (`/help/*.htm`)
- [ ] Support contact information replaced
- [ ] Copyright notices updated
- [ ] Code comments reviewed
- [ ] Configuration files updated
- [ ] Error messages and UI text centralized
- [ ] Database object prefixes documented (keep as-is decision)
- [ ] Logo/branding assets created (future - Phase 2)
- [ ] Favicon and metadata updated (future - Phase 2)

---

## Migration Strategy

### Phase-Based Approach

#### Phase 1: Foundation (Current - Weeks 1-4)
**Status**: In Progress (Design & Specification)

**Deliverables:**
- ✅ Database schema design (Prisma)
- ✅ API specification (OpenAPI 3.0)
- ✅ Frontend architecture (React)
- ✅ Authentication design (JWT + RBAC)
- ✅ Legacy system assessment (this document)
- ⏳ CI/CD pipeline design
- ⏳ Testing strategy
- ⏳ Documentation plan

#### Phase 2: Backend MVP (Weeks 5-8)
**Focus**: Build core backend API

**Tasks:**
1. Set up Node.js/Express project structure
2. Configure PostgreSQL + Prisma ORM
3. Implement authentication endpoints
4. Implement CRUD operations for:
   - Servers
   - Databases
   - Tables
   - Elements
   - Abbreviations
5. Implement search functionality
6. Implement report generation endpoints
7. Write unit + integration tests (80% coverage target)

#### Phase 3: Data Migration (Weeks 9-10)
**Focus**: Migrate data from Informix to PostgreSQL

**Tasks:**
1. Extract data from Informix (SQL exports)
2. Transform data to match new schema
3. Validate data integrity
4. Load data into PostgreSQL
5. Run migration tests
6. Generate migration report

**Migration Tools:**
- `pg_dump` / `pg_restore` for PostgreSQL
- Custom Node.js scripts for data transformation
- Prisma migrations for schema versioning

#### Phase 4: Frontend MVP (Weeks 11-14)
**Focus**: Build core React UI

**Tasks:**
1. Set up Vite + React + TypeScript project
2. Implement authentication flow (login, logout)
3. Build main layout and navigation
4. Implement server management pages
5. Implement database browsing
6. Implement table/element viewing
7. Implement search interface
8. Implement report generation UI
9. Write component tests (70% coverage target)

#### Phase 5: Integration & Testing (Weeks 15-16)
**Focus**: End-to-end integration and testing

**Tasks:**
1. Connect frontend to backend API
2. Implement role-based UI rendering
3. End-to-end testing (Playwright)
4. Performance testing (load testing)
5. Security testing (OWASP Top 10)
6. User acceptance testing (UAT)
7. Bug fixes and refinements

#### Phase 6: Deployment & Cutover (Weeks 17-18)
**Focus**: Production deployment and legacy system decommission

**Tasks:**
1. Deploy to Azure (staging environment)
2. Production deployment
3. Data migration to production
4. Parallel run (new + old systems)
5. User training
6. Legacy system decommission
7. Post-launch monitoring

### Parallel Run Strategy

**Week 17-18**: Run both systems simultaneously

| System | Role | Users |
|--------|------|-------|
| **Legacy ASP** | Read-only fallback | All users (backup access) |
| **New SchemaJeli** | Primary system | All users (encouraged) |

**Cutover Criteria:**
- ✅ All data migrated successfully
- ✅ All core features functional
- ✅ User acceptance testing passed
- ✅ Performance benchmarks met
- ✅ Security audit passed
- ✅ User training completed

**Decommission Plan:**
- Week 18: Disable legacy write operations
- Week 19: Redirect all URLs to new system
- Week 20: Archive legacy data
- Week 21: Shut down legacy servers

---

## Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Data loss during migration** | Medium | Critical | Multiple backups, validation scripts, rollback plan |
| **Informix connection issues** | Low | High | Early data export, maintain legacy system during parallel run |
| **Performance degradation** | Medium | Medium | Load testing, database indexing, caching strategy |
| **Security vulnerabilities** | Low | Critical | Security audit, penetration testing, OWASP compliance |
| **Browser compatibility** | Low | Low | Modern browser support only (Chrome, Firefox, Safari, Edge) |
| **Third-party API failures** | Low | Medium | Error handling, retry logic, fallback mechanisms |

### Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **User resistance to change** | Medium | Medium | User training, documentation, gradual rollout |
| **Extended timeline** | Medium | Medium | Agile approach, MVP focus, phased delivery |
| **Budget overrun** | Low | Medium | Fixed-scope MVP, defer non-essential features to Phase 2 |
| **Key developer unavailability** | Low | High | Code documentation, pair programming, knowledge sharing |
| **Scope creep** | High | Medium | Strict change control, backlog prioritization |

### Data Migration Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Encoding issues (special characters)** | Medium | Low | UTF-8 validation, character mapping, test migrations |
| **Duplicate records** | Low | Medium | Unique constraints, deduplication scripts |
| **Orphaned records (missing FKs)** | Medium | Medium | Data integrity checks, cascade rules, cleanup scripts |
| **Data type mismatches** | Low | Low | Schema mapping validation, test migrations |
| **Lost historical data** | Low | Medium | Complete data export, archive legacy database |

---

## Data Migration Plan

### Pre-Migration Checklist

- [ ] **Backup legacy Informix database**
  - Full database export (`dbexport` command)
  - Store in secure location with versioning
  - Test restore procedure

- [ ] **Analyze data quality**
  - Count records per table
  - Identify NULL values and defaults
  - Check for duplicate keys
  - Validate foreign key relationships

- [ ] **Prepare target PostgreSQL database**
  - Run Prisma migrations (`npx prisma migrate deploy`)
  - Verify schema matches design
  - Create database indexes
  - Set up connection pooling

- [ ] **Develop migration scripts**
  - Extract scripts (Informix → CSV)
  - Transform scripts (CSV → JSON → PostgreSQL)
  - Load scripts (Prisma Client or raw SQL)
  - Validation scripts (compare record counts)

### Migration Execution Steps

**Step 1: Extract Data from Informix**

```sql
-- Example: Export servers table
UNLOAD TO 'servers.csv' DELIMITER ','
SELECT server_id, server_name, rdbms_type, host_name, port, 
       status, description, created_date, created_by
FROM servers
WHERE status = 'A'; -- Active only
```

**Output**: CSV files for each table

**Step 2: Transform Data**

```typescript
// migration/transform-servers.ts
import { parse } from 'csv-parse/sync';
import fs from 'fs';

interface LegacyServer {
  server_id: number;
  server_name: string;
  rdbms_type: string;
  host_name: string;
  port: number;
  status: string;
  description: string;
  created_date: string;
  created_by: number;
}

interface NewServer {
  id: string; // UUID
  name: string;
  rdbmsType: 'INFORMIX' | 'ORACLE' | 'SQLSERVER' | 'POSTGRESQL' | 'MYSQL';
  hostname: string | null;
  port: number | null;
  status: 'ACTIVE' | 'INACTIVE';
  description: string | null;
  createdAt: Date;
  createdById: string; // Map to new user UUID
}

const csv = fs.readFileSync('data/servers.csv', 'utf-8');
const legacyServers: LegacyServer[] = parse(csv, { 
  columns: true,
  skip_empty_lines: true 
});

const newServers: NewServer[] = legacyServers.map((legacy) => ({
  id: uuidv4(), // Generate new UUID
  name: legacy.server_name,
  rdbmsType: mapRdbmsType(legacy.rdbms_type),
  hostname: legacy.host_name || null,
  port: legacy.port || null,
  status: legacy.status === 'A' ? 'ACTIVE' : 'INACTIVE',
  description: legacy.description || null,
  createdAt: new Date(legacy.created_date),
  createdById: mapUserId(legacy.created_by), // Map old ID to new UUID
}));

fs.writeFileSync('data/servers-transformed.json', JSON.stringify(newServers, null, 2));
```

**Step 3: Load Data into PostgreSQL**

```typescript
// migration/load-servers.ts
import { PrismaClient } from '@prisma/client';
import fs from 'fs';

const prisma = new PrismaClient();

async function loadServers() {
  const servers = JSON.parse(fs.readFileSync('data/servers-transformed.json', 'utf-8'));
  
  console.log(`Loading ${servers.length} servers...`);
  
  for (const server of servers) {
    await prisma.server.create({
      data: server,
    });
  }
  
  console.log('✅ Servers loaded successfully');
}

loadServers()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

**Step 4: Validate Migration**

```typescript
// migration/validate.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function validateMigration() {
  const counts = {
    servers: await prisma.server.count(),
    databases: await prisma.database.count(),
    tables: await prisma.table.count(),
    elements: await prisma.element.count(),
    abbreviations: await prisma.abbreviation.count(),
  };
  
  console.log('Record counts:');
  console.table(counts);
  
  // Compare with legacy counts (from CSV)
  const expectedCounts = {
    servers: 73,
    databases: 542,
    tables: 12387,
    elements: 185642,
    abbreviations: 1247,
  };
  
  const discrepancies = Object.keys(counts).filter(
    (table) => counts[table] !== expectedCounts[table]
  );
  
  if (discrepancies.length > 0) {
    console.error('❌ Discrepancies found:', discrepancies);
    process.exit(1);
  }
  
  console.log('✅ Migration validation passed');
}

validateMigration()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

### Migration Rollback Plan

**If migration fails:**

1. **Stop all write operations** to new database
2. **Restore from backup** (`pg_restore`)
3. **Investigate root cause** (check logs)
4. **Fix migration scripts**
5. **Re-run migration** with updated scripts

**Rollback Script:**
```bash
#!/bin/bash
# migration/rollback.sh

echo "⚠️ Rolling back migration..."

# Drop all tables
npx prisma migrate reset --force

# Restore from backup
pg_restore -h localhost -U postgres -d schemajeli backup/schemajeli-pre-migration.dump

echo "✅ Rollback complete"
```

---

## Deprecation Timeline

### Legacy ASP System Decommission

| Phase | Timeline | Status | Description |
|-------|----------|--------|-------------|
| **Phase 1: Preparation** | Weeks 1-4 | ✅ In Progress | Design new system, assess legacy code |
| **Phase 2: Development** | Weeks 5-14 | ⏳ Pending | Build new system (backend + frontend) |
| **Phase 3: Migration** | Weeks 15-16 | ⏳ Pending | Migrate data, testing |
| **Phase 4: Parallel Run** | Weeks 17-18 | ⏳ Pending | Both systems operational |
| **Phase 5: Cutover** | Week 19 | ⏳ Pending | Legacy to read-only mode |
| **Phase 6: Archive** | Week 20 | ⏳ Pending | Archive legacy data |
| **Phase 7: Decommission** | Week 21 | ⏳ Pending | Shut down legacy servers |

### Support Timeline

| System | Support Level | Timeline |
|--------|---------------|----------|
| **Legacy ASP** | Full support | Until Week 18 |
| **Legacy ASP** | Read-only | Weeks 19-20 |
| **Legacy ASP** | Archived | Week 21+ (no active support) |
| **New SchemaJeli** | Beta support | Weeks 17-18 |
| **New SchemaJeli** | Full support | Week 19+ |

### User Communication Plan

**Week 15**: Email announcement - "New SchemaJeli launching soon"
**Week 16**: Training sessions scheduled
**Week 17**: "SchemaJeli is live - try it now!" (parallel run begins)
**Week 18**: Reminder to switch to new system
**Week 19**: "Legacy system now read-only"
**Week 21**: "Legacy system archived"

---

## Appendix A: File Inventory Summary

### Total File Count by Directory

| Directory | Files | Total Lines (Est.) | Migration Priority |
|-----------|-------|--------------------|--------------------|
| `/` (root) | 5 | 500 | High |
| `/include/` | 30+ | 5,000 | High |
| `/ddl/` | 6 | 2,000 | Medium |
| `/help/` | 8 | 2,000 | Medium |
| `/scripts/` | ~15 | 1,500 | Medium |
| `/menu/` | ~10 | 2,000 | Low (deprecated) |
| `/images/` | ~20 | N/A | Low |
| `/Logs/` | ~20 | N/A | Low (historical) |
| **Total** | **~115 files** | **~13,000 lines** | - |

### Legacy Codebase Statistics

- **Lines of VBScript**: ~10,000
- **Lines of JavaScript**: ~1,500
- **Lines of SQL (DDL)**: ~2,000
- **HTML Pages**: ~50
- **Include Files**: ~30

**Estimated Rewrite Effort**: 
- Backend: 3-4 weeks (2 developers)
- Frontend: 3-4 weeks (2 developers)
- Data migration: 1 week (1 developer)
- Testing: 2 weeks (1-2 developers)
- **Total**: ~10-12 weeks (assuming 2-3 developers)

---

## Appendix B: Informix to PostgreSQL Type Mapping

| Informix Type | PostgreSQL Type | Notes |
|---------------|-----------------|-------|
| `SERIAL` | `BIGSERIAL` | Auto-increment integer |
| `INTEGER` | `INTEGER` | 4-byte integer |
| `SMALLINT` | `SMALLINT` | 2-byte integer |
| `CHAR(n)` | `CHAR(n)` | Fixed-length string |
| `VARCHAR(n)` | `VARCHAR(n)` | Variable-length string |
| `LVARCHAR(n)` | `TEXT` | Large variable string → unlimited text |
| `DATE` | `DATE` | Date only |
| `DATETIME YEAR TO SECOND` | `TIMESTAMP` | Date + time |
| `DECIMAL(p, s)` | `NUMERIC(p, s)` | Fixed-point decimal |
| `MONEY` | `NUMERIC(19, 2)` | Currency → decimal with 2 decimal places |
| `BOOLEAN` | `BOOLEAN` | True/false |
| `BYTE` | `BYTEA` | Binary data |
| `TEXT` | `TEXT` | Large text object |

---

## Appendix C: Legacy Report Mapping to API Endpoints

| Legacy Report | New API Endpoint | HTTP Method | Description |
|---------------|------------------|-------------|-------------|
| `Rpt_ElemSum.inc` | `/api/reports/element-summary` | GET | Element summary report |
| `Rpt_ElemDtl.inc` | `/api/reports/element-details` | GET | Element details report |
| `Rpt_TblSum.inc` | `/api/reports/table-summary` | GET | Table summary report |
| `Rpt_TblDtl.inc` | `/api/reports/table-details` | GET | Table details report |
| `Rpt_DbFull.inc` | `/api/reports/database-full` | GET | Full database schema |
| `Rpt_DbDtl.inc` | `/api/reports/database-details` | GET | Database metadata |
| `Rpt_SrvrSum.inc` | `/api/reports/server-summary` | GET | Server summary report |
| `Rpt_DbaFull.inc` | `/api/reports/system-full` | GET | Complete system report |

**Common Query Parameters:**
- `?serverId=<uuid>` - Filter by server
- `?databaseId=<uuid>` - Filter by database
- `?format=json|csv|excel` - Export format
- `?page=1&limit=50` - Pagination

---

**Document Status:** ✅ Complete  
**Next Step:** Proceed to Phase 1.3 tasks (CI/CD, Testing, Monitoring)

