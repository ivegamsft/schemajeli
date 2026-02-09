# Research: Style Guide Management

**Feature**: Style Guide Management  
**Date**: 2026-02-08  
**Research Phase**: Phase 0

## Executive Summary

This document consolidates research findings for implementing style guide management functionality. All technical uncertainties have been resolved through analysis of best practices and existing SchemaJeli codebase patterns.

---

## 1. Naming Pattern Validation

### Decision: Zod + Cached RegExp Pattern Matching

**Rationale**: 
- Zod is already used in SchemaJeli frontend for form validation
- Backend uses Joi for API validation
- Regex patterns stored as plain text strings in PostgreSQL
- Compile and cache RegExp objects for performance with 1000+ rules

**Implementation Approach**:

```typescript
// Store patterns as text, compile on load
class PatternValidator {
  private cache = new Map<string, RegExp>();
  
  validate(name: string, pattern: string): boolean {
    if (!this.cache.has(pattern)) {
      this.cache.set(pattern, new RegExp(`^${pattern}$`));
    }
    return this.cache.get(pattern)!.test(name);
  }
}
```

**Case Convention Patterns**:
- PascalCase: `^[A-Z][a-zA-Z0-9]*$`
- camelCase: `^[a-z][a-zA-Z0-9]*$`
- UPPER_SNAKE_CASE: `^[A-Z][A-Z0-9_]*$`
- lower_snake_case: `^[a-z][a-z0-9_]*$`

**Performance Strategy**:
- Cache compiled RegExp objects in-memory (30-minute TTL)
- Batch validation for schema scans (validate 1000s of names in single pass)
- Pre-compile all active patterns on service startup

**Error Messages**:
- Include pattern description and examples
- Provide suggested corrections (e.g., "UserProfile" → "user_profile")
- Show before/after comparison in violation reports

**Alternatives Considered**:
- JSON Schema validation - Rejected: overkill for simple pattern matching
- Custom parser library - Rejected: regex sufficient for naming patterns

---

## 2. Version Control & History

### Decision: Semantic Versioning with Event Sourcing Pattern

**Rationale**:
- Semantic versioning (MAJOR.MINOR.PATCH) provides clear intent of changes
- Event sourcing stores immutable version snapshots for complete audit trail
- Separate tables for current state vs version history for query performance

**Versioning Logic**:
- **MAJOR** (breaking): Rule removed OR pattern changed
- **MINOR** (additive): New rule added
- **PATCH** (non-breaking): Description or example changes only

**Schema Design**:

```
StyleGuide (current state)
├── currentVersion: "2.1.3"
├── rules: NamingRule[] (current active rules)
│
StyleGuideVersion (immutable history)
├── version: "2.1.3"
├── ruleSnapshot: JSON (full rules array at this version)
├── changeType: MAJOR | MINOR | PATCH
├── changelog: "Added 3 new table naming rules"
│
RuleDiff (granular change tracking)
├── action: ADDED | MODIFIED | REMOVED
├── oldValue: JSON
├── newValue: JSON
```

**Key Features**:
- View any historical version (read from `ruleSnapshot` JSON)
- Compare versions with detailed diff (added/modified/removed rules)
- Rollback to previous version (create new version with old snapshot)
- Full audit trail (who changed what when)

**Alternatives Considered**:
- Sequential versioning - Rejected: no semantic meaning
- Timestamp-based - Rejected: harder to reference, no intent signal
- Delta-only storage - Rejected: complex reconstruction, prefer snapshots

---

## 3. Import/Export File Formats

### Decision: JSON Primary, YAML Optional

**Rationale**:
- JSON native to JavaScript/TypeScript, no parsing library needed
- Existing export functionality uses JSON (see `src/frontend/src/lib/export.ts`)
- YAML more human-readable but requires `js-yaml` library
- Style guides are structured data (better for JSON than YAML comments)

**File Format Schema**:

```json
{
  "schemaVersion": "1.0",
  "name": "Corporate Naming Standards",
  "description": "Standard naming conventions for database objects",
  "version": "2.1.0",
  "rules": [
    {
      "name": "Table Names",
      "entityType": "TABLE",
      "pattern": "^[A-Z][a-zA-Z0-9]*$",
      "caseConvention": "PascalCase",
      "description": "Tables use PascalCase",
      "exampleValid": ["UserProfile", "OrderHistory"],
      "exampleInvalid": ["user_profile", "USERS"]
    }
  ],
  "metadata": {
    "created": "2026-02-08T10:00:00Z",
    "author": "admin@example.com",
    "source": "github.com/company/style-guides"
  }
}
```

**Validation Strategy**:
- Backend: Joi schema validation before import
- Frontend: Zod schema for file upload form
- Validate required fields, pattern syntax, and schema version compatibility

**Import Process**:
1. User uploads file → frontend validates size (<1MB) and extension (.json/.yaml)
2. Parse file and validate schema → show preview of rules
3. User confirms → POST to backend API
4. Backend validates, checks for duplicates, creates new style guide

**Export Format**:
- Leverage existing `exportToJSON` function from `src/frontend/src/lib/export.ts`
- Include metadata: version, export timestamp, current user
- Downloadable as `{styleguide-name}-v{version}.json`

**File Upload Implementation**:
- Use `multer` middleware for file upload in Express.js
- Limit file size to 1MB (reasonable for 1000+ rules)
- Accept `application/json` and `text/yaml` MIME types

**Alternatives Considered**:
- XML - Rejected: verbose, harder to parse
- TOML - Rejected: not common in web apps
- CSV - Rejected: poor fit for nested rule structures

---

## 4. Performance Optimization

### Decision: In-Memory Caching + Pagination + Batch Processing

**Performance Targets** (from spec):
- Validation of 1000-table schema: <5 seconds
- List view 50 guides: <1 second
- Import JSON file: <2 seconds

**Strategies**:

**1. Rule Caching**:
```typescript
class RuleCache {
  private patterns = new Map<string, RegExp>();
  private TTL = 1800000; // 30 minutes
  
  // Pre-compile all active patterns on startup
  async warmCache() {
    const rules = await prisma.namingRule.findMany({ 
      where: { isActive: true } 
    });
    rules.forEach(r => this.patterns.set(r.id, new RegExp(r.pattern)));
  }
}
```

**2. Batch Validation**:
```typescript
// Validate entire schema in single query
async validateSchema(schemaId: string, guideId: string) {
  const elements = await prisma.element.findMany({ 
    where: { table: { databaseId: schemaId } } 
  });
  const rules = this.ruleCache.getRules(guideId);
  
  // Parallel validation with Promise.all
  return Promise.all(
    elements.map(el => this.validateElement(el, rules))
  );
}
```

**3. Pagination**:
- List endpoint: 50 guides per page (configurable)
- Cursor-based pagination for version history
- Server-side filtering and sorting

**4. Database Indexing**:
```sql
-- Add indexes for common queries
CREATE INDEX idx_style_guides_name ON style_guides(name);
CREATE INDEX idx_naming_rules_style_guide_id ON naming_rules(style_guide_id);
CREATE INDEX idx_style_guide_versions_created_at ON style_guide_versions(created_at DESC);
```

---

## 5. Security & Access Control

### Decision: Admin-Only Operations with JWT + Audit Trail

**Access Control**:
- All style guide CRUD operations restricted to ADMIN role
- Use existing `roleCheck` middleware from `src/backend/src/middleware/roleCheck.ts`
- Read operations (view, list) available to EDITOR and VIEWER roles

**Authentication**:
- Azure Entra ID (MSAL) - already implemented in SchemaJeli
- JWT validation via JWKS endpoint
- No local password management

**Audit Requirements**:
- Log all operations: CREATE, UPDATE, DELETE, APPLY
- Capture: userId, timestamp, action, before/after values
- Store in `AuditLog` table (existing) and `StyleGuideAuditLog` (new)

**Input Validation**:
- Backend: Joi validation on all API endpoints
- Frontend: Zod validation on forms
- Sanitize regex patterns to prevent ReDoS attacks
- Limit file upload size to 1MB
- Validate file MIME types

**SQL Injection Prevention**:
- Use Prisma ORM exclusively (parameterized queries)
- Never concatenate user input into raw SQL

---

## 6. UI/UX Patterns

### Decision: Multi-Step Forms + Preview + Inline Validation

**Create/Edit Style Guide**:
- Multi-step form: (1) Basic info → (2) Add rules → (3) Review → (4) Confirm
- Rule builder with pattern preview and live validation
- Show example matches/non-matches as user types pattern

**Import Flow**:
```
[Upload File] → [Parse & Validate] → [Preview Rules] → [Confirm Import]
                       ↓ error
                [Show Validation Errors]
```

**Validation Report**:
- Summary: X violations found, Y tables affected
- Filterable list of violations by severity
- For each violation:
  - Element name
  - Current pattern
  - Expected pattern
  - Suggested fix (before → after)
- Bulk accept/reject actions

**Version History**:
- Timeline view with version badges (MAJOR in red, MINOR in yellow)
- Click to view diff: Added (green), Modified (orange), Removed (red)
- Restore previous version button (ADMIN only)

**Components** (React):
- `StyleGuideForm.tsx` - Create/edit with Zod validation
- `NamingRuleBuilder.tsx` - Regex pattern builder with live preview
- `ImportDialog.tsx` - File upload with drag-drop
- `ValidationReport.tsx` - Violation list with suggestions
- `VersionTimeline.tsx` - Version history with diffs

---

## 7. Testing Strategy

### Decision: TDD with 70% Coverage Minimum

**Unit Tests** (Vitest):
- `styleGuideService.test.ts`: CRUD operations, version logic
- `validationService.test.ts`: Pattern matching, batch validation
- `versioningService.test.ts`: Version increment, diff calculation

**Integration Tests** (Vitest + Supertest):
- `styleGuides.test.ts`: API endpoints, auth middleware
- Test all user scenarios from spec (create, import, modify, validate, export)

**Contract Tests**:
- OpenAPI schema validation
- Request/response schema compliance

**E2E Tests** (Playwright):
- `styleGuides.spec.ts`: Complete user workflows
- Test: Create guide → Add rules → Apply to database → Validate → View report

**Performance Tests**:
- Validate 1000-table schema (must complete <5 seconds)
- Load 50 guides with pagination (must complete <1 second)

**Coverage Targets**:
- Overall: 70% minimum (constitutional requirement)
- Critical paths: 90% (validation logic, versioning)

---

## 8. API Design

### Decision: RESTful API with OpenAPI 3.0 Specification

**Endpoints**:

```
# Style Guides
POST   /api/style-guides              Create new style guide
GET    /api/style-guides              List all style guides (paginated)
GET    /api/style-guides/:id          Get style guide details
PUT    /api/style-guides/:id          Update style guide (creates new version)
DELETE /api/style-guides/:id          Soft delete style guide
POST   /api/style-guides/import       Import from file
GET    /api/style-guides/:id/export   Export to JSON/YAML

# Versions
GET    /api/style-guides/:id/versions              List version history
GET    /api/style-guides/:id/versions/:version     Get specific version
GET    /api/style-guides/:id/versions/:v1/diff/:v2 Compare versions
POST   /api/style-guides/:id/versions/:v/restore   Rollback to version

# Validation
POST   /api/style-guides/:id/validate  Validate schema against guide
GET    /api/style-guides/:id/usage     Get resources using guide

# Naming Rules (nested under style guide)
POST   /api/style-guides/:id/rules     Add naming rule
PUT    /api/style-guides/:id/rules/:ruleId  Update naming rule
DELETE /api/style-guides/:id/rules/:ruleId  Remove naming rule
```

**Response Formats**:
- Success: `{ data: {...}, message: "Success" }`
- Error: `{ error: "ERROR_CODE", message: "Human-readable", details: {...} }`
- List: `{ data: [...], pagination: { page, totalPages, totalCount } }`

**OpenAPI Specification**:
- Generate from Joi schemas using `joi-to-swagger`
- Serve at `/api/docs` (Swagger UI)
- Include examples and descriptions

---

## 9. Database Schema Extensions

### Required Prisma Schema Additions:

```prisma
model StyleGuide {
  id              String    @id @default(uuid())
  name            String    @unique @db.VarChar(255)
  description     String?   @db.Text
  currentVersion  String    @db.VarChar(20) @default("1.0.0")
  isActive        Boolean   @default(true)
  source          String    @db.VarChar(100) @default("MANUAL") // MANUAL | IMPORTED
  createdById     String    @map("created_by_id")
  createdAt       DateTime  @default(now()) @map("created_at")
  updatedAt       DateTime  @updatedAt @map("updated_at")
  deletedAt       DateTime? @map("deleted_at")

  createdBy       User      @relation("StyleGuideCreator", fields: [createdById], references: [id])
  rules           NamingRule[]
  versions        StyleGuideVersion[]
  usage           StyleGuideUsage[]
  auditLog        StyleGuideAuditLog[]

  @@index([name])
  @@index([isActive])
  @@map("style_guides")
}

model NamingRule {
  id              String    @id @default(uuid())
  styleGuideId    String    @map("style_guide_id")
  name            String    @db.VarChar(255)
  entityType      String    @db.VarChar(50) // TABLE, COLUMN, INDEX, CONSTRAINT
  pattern         String    @db.Text // Regex pattern
  caseConvention  String    @db.VarChar(50) // PascalCase, camelCase, etc.
  description     String?   @db.Text
  exampleValid    String[]  @default([])
  exampleInvalid  String[]  @default([])
  isRequired      Boolean   @default(false)
  ruleOrder       Int       @default(0)
  createdById     String    @map("created_by_id")
  createdAt       DateTime  @default(now()) @map("created_at")
  updatedAt       DateTime  @updatedAt @map("updated_at")

  styleGuide      StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Cascade)
  createdBy       User       @relation("NamingRuleCreator", fields: [createdById], references: [id])

  @@unique([styleGuideId, name])
  @@index([styleGuideId])
  @@index([entityType])
  @@map("naming_rules")
}

model StyleGuideVersion {
  id              String    @id @default(uuid())
  styleGuideId    String    @map("style_guide_id")
  version         String    @db.VarChar(20)
  changeType      String    @db.VarChar(20) // MAJOR, MINOR, PATCH
  changelog       String?   @db.Text
  ruleSnapshot    Json      // Complete rules array at this version
  createdById     String    @map("created_by_id")
  createdAt       DateTime  @default(now()) @map("created_at")

  styleGuide      StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Cascade)
  createdBy       User       @relation("StyleGuideVersionCreator", fields: [createdById], references: [id])
  ruleDiffs       RuleDiff[]

  @@unique([styleGuideId, version])
  @@index([styleGuideId, createdAt])
  @@map("style_guide_versions")
}

model RuleDiff {
  id              String    @id @default(uuid())
  versionId       String    @map("version_id")
  ruleId          String    @map("rule_id")
  action          String    @db.VarChar(20) // ADDED, MODIFIED, REMOVED
  oldValue        Json?
  newValue        Json?
  fieldChanged    String?   @db.VarChar(100)

  version         StyleGuideVersion @relation(fields: [versionId], references: [id], onDelete: Cascade)

  @@index([versionId])
  @@index([ruleId])
  @@map("rule_diffs")
}

model StyleGuideUsage {
  id              String    @id @default(uuid())
  styleGuideId    String    @map("style_guide_id")
  resourceType    String    @db.VarChar(50) // DATABASE, TABLE
  resourceId      String    @map("resource_id")
  appliedById     String    @map("applied_by_id")
  appliedAt       DateTime  @default(now()) @map("applied_at")
  violationCount  Int       @default(0)

  styleGuide      StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Restrict)
  appliedBy       User       @relation("StyleGuideUsageCreator", fields: [appliedById], references: [id])

  @@unique([styleGuideId, resourceType, resourceId])
  @@index([styleGuideId])
  @@index([resourceId])
  @@map("style_guide_usage")
}

model StyleGuideAuditLog {
  id                String    @id @default(uuid())
  styleGuideId      String    @map("style_guide_id")
  action            String    @db.VarChar(50) // CREATE, UPDATE, DELETE, APPLY
  versionBefore     String?   @db.VarChar(20)
  versionAfter      String?   @db.VarChar(20)
  changeDescription String?   @db.Text
  userId            String    @map("user_id")
  createdAt         DateTime  @default(now()) @map("created_at")

  styleGuide        StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Cascade)
  user              User       @relation("StyleGuideAuditUser", fields: [userId], references: [id])

  @@index([styleGuideId])
  @@index([userId])
  @@index([createdAt])
  @@map("style_guide_audit_logs")
}

// Extend User model with relations
model User {
  // ... existing fields ...
  
  styleGuidesCreated       StyleGuide[] @relation("StyleGuideCreator")
  namingRulesCreated       NamingRule[] @relation("NamingRuleCreator")
  styleGuideVersionsCreated StyleGuideVersion[] @relation("StyleGuideVersionCreator")
  styleGuideUsageCreated   StyleGuideUsage[] @relation("StyleGuideUsageCreator")
  styleGuideAudits         StyleGuideAuditLog[] @relation("StyleGuideAuditUser")
}
```

---

## 10. Migration & Rollout Strategy

### Decision: Feature Flag + Phased Rollout

**Phase 1** (P1 features):
- Create style guides (UI + API)
- List and view style guides
- Apply guide to database

**Phase 2** (P2 features):
- Import from JSON
- Modify style guides (with versioning)
- Version history view

**Phase 3** (P3 features):
- Validate schema against guide
- Validation report with suggestions
- Export to JSON

**Database Migration**:
```bash
# Create Prisma migration
npx prisma migrate dev --name add-style-guides

# Run migration in staging
npm run prisma:migrate

# Seed with sample style guide
npm run prisma:seed
```

**Feature Flag**:
```typescript
// feature-flags.ts
export const FEATURES = {
  STYLE_GUIDES: process.env.ENABLE_STYLE_GUIDES === 'true',
  STYLE_GUIDE_IMPORT: process.env.ENABLE_STYLE_GUIDE_IMPORT === 'true',
  STYLE_GUIDE_VALIDATION: process.env.ENABLE_VALIDATION === 'true',
};
```

**Rollback Plan**:
- Keep feature behind flag (can disable without code deployment)
- Database migrations are additive (no destructive changes)
- If critical bug: disable feature flag and deploy hotfix

---

## Summary of Key Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| **Validation** | Zod + cached RegExp | Already in stack, performant |
| **Versioning** | Semantic + event sourcing | Audit trail, clear intent |
| **File Format** | JSON primary, YAML optional | Native to JS, existing patterns |
| **Performance** | Cache + batch + pagination | Meet <5s validation target |
| **Security** | Admin-only + JWT + audit | Constitution compliance |
| **API Design** | RESTful + OpenAPI 3.0 | Consistent with existing APIs |
| **Testing** | TDD + 70% coverage | Constitutional requirement |
| **Rollout** | Feature flag + phased | Safe, reversible |

**All NEEDS CLARIFICATION items have been resolved. Proceeding to Phase 1 design.**
