# Data Model: Style Guide Management

**Feature**: Style Guide Management  
**Date**: 2026-02-08  
**Phase**: Phase 1 - Design

## Entity Relationship Diagram

```
User ──────┐
           │ creates
           ├──────────> StyleGuide
           │                │
           │                │ has many
           │                ├──────────> NamingRule
           │                │
           │                │ has many
           │                ├──────────> StyleGuideVersion
           │                │                │
           │                │                │ has many
           │                │                └──────────> RuleDiff
           │                │
           │                │ applied to
           │                └──────────> StyleGuideUsage ────> Database/Table
           │
           │ performs
           └──────────> StyleGuideAuditLog
```

---

## Core Entities

### 1. StyleGuide

**Purpose**: Represents a reusable set of naming conventions for database objects.

**Attributes**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | UUID | Yes | Primary key | Auto-generated |
| `name` | String(255) | Yes | Unique name | Unique, non-empty |
| `description` | Text | No | Purpose and scope | |
| `currentVersion` | String(20) | Yes | Current semantic version | Default: "1.0.0" |
| `isActive` | Boolean | Yes | Active status | Default: true |
| `source` | String(100) | Yes | Origin of guide | Enum: MANUAL, IMPORTED |
| `createdById` | UUID | Yes | Creator user ID | FK → User |
| `createdAt` | Timestamp | Yes | Creation timestamp | Auto |
| `updatedAt` | Timestamp | Yes | Last modification | Auto |
| `deletedAt` | Timestamp | No | Soft delete timestamp | NULL if active |

**Relationships**:
- **Owns**: Many `NamingRule` (cascade delete)
- **Has**: Many `StyleGuideVersion` (cascade delete)
- **Applied to**: Many `StyleGuideUsage` (restrict delete if in use)
- **Tracks**: Many `StyleGuideAuditLog` (cascade delete)
- **Created by**: One `User`

**Business Rules**:
- Name must be unique across all style guides
- Cannot delete if `StyleGuideUsage` exists (in-use protection)
- Soft delete sets `deletedAt` timestamp
- Version increments on every modification

**Indexes**:
- Primary: `id`
- Unique: `name`
- Filter: `isActive`, `deletedAt`

---

### 2. NamingRule

**Purpose**: Defines a single naming convention pattern within a style guide.

**Attributes**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | UUID | Yes | Primary key | Auto-generated |
| `styleGuideId` | UUID | Yes | Parent style guide | FK → StyleGuide |
| `name` | String(255) | Yes | Rule name | Unique within guide |
| `entityType` | String(50) | Yes | Target entity type | Enum: TABLE, COLUMN, INDEX, CONSTRAINT |
| `pattern` | Text | Yes | Regex pattern | Valid regex syntax |
| `caseConvention` | String(50) | Yes | Expected casing | Enum: PascalCase, camelCase, UPPER_SNAKE_CASE, lower_snake_case, kebab-case |
| `description` | Text | No | Explanation of rule | |
| `exampleValid` | String[] | No | Valid examples | JSON array |
| `exampleInvalid` | String[] | No | Invalid examples | JSON array |
| `isRequired` | Boolean | Yes | Mandatory rule | Default: false |
| `ruleOrder` | Int | Yes | Display/execution order | Default: 0 |
| `createdById` | UUID | Yes | Creator user ID | FK → User |
| `createdAt` | Timestamp | Yes | Creation timestamp | Auto |
| `updatedAt` | Timestamp | Yes | Last modification | Auto |

**Relationships**:
- **Belongs to**: One `StyleGuide` (cascade on parent delete)
- **Created by**: One `User`

**Business Rules**:
- Rule name must be unique within style guide
- Pattern must be valid regex (validated on save)
- EntityType must match predefined enum
- RuleOrder determines execution sequence during validation
- Examples stored as JSON arrays for flexibility

**Validation**:
```typescript
// Pattern syntax validation
const isValidRegex = (pattern: string): boolean => {
  try {
    new RegExp(pattern);
    return true;
  } catch {
    return false;
  }
};
```

**Indexes**:
- Primary: `id`
- Foreign: `styleGuideId`
- Unique: `(styleGuideId, name)`
- Filter: `entityType`

---

### 3. StyleGuideVersion

**Purpose**: Immutable snapshot of style guide state at a specific version (event sourcing pattern).

**Attributes**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | UUID | Yes | Primary key | Auto-generated |
| `styleGuideId` | UUID | Yes | Parent style guide | FK → StyleGuide |
| `version` | String(20) | Yes | Semantic version | Format: X.Y.Z |
| `changeType` | String(20) | Yes | Type of change | Enum: MAJOR, MINOR, PATCH |
| `changelog` | Text | No | Summary of changes | Human-readable |
| `ruleSnapshot` | JSON | Yes | Complete rules array | Serialized NamingRule[] |
| `createdById` | UUID | Yes | User who created version | FK → User |
| `createdAt` | Timestamp | Yes | Version timestamp | Auto |

**Relationships**:
- **Belongs to**: One `StyleGuide` (cascade on parent delete)
- **Contains**: Many `RuleDiff` (cascade delete)
- **Created by**: One `User`

**Business Rules**:
- Version must be unique within style guide
- `ruleSnapshot` stores complete rules state (not delta)
- Immutable after creation (no updates allowed)
- Ordered by `createdAt` for timeline view

**Version Increment Logic**:
```typescript
function incrementVersion(current: string, type: ChangeType): string {
  const [major, minor, patch] = current.split('.').map(Number);
  switch (type) {
    case 'MAJOR': return `${major + 1}.0.0`;
    case 'MINOR': return `${major}.${minor + 1}.0`;
    case 'PATCH': return `${major}.${minor}.${patch + 1}`;
  }
}
```

**Indexes**:
- Primary: `id`
- Unique: `(styleGuideId, version)`
- Sort: `(styleGuideId, createdAt DESC)`

---

### 4. RuleDiff

**Purpose**: Tracks granular changes to individual naming rules within a version (for detailed diff view).

**Attributes**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | UUID | Yes | Primary key | Auto-generated |
| `versionId` | UUID | Yes | Parent version | FK → StyleGuideVersion |
| `ruleId` | String | Yes | Rule identifier | May be "new" for additions |
| `action` | String(20) | Yes | Change action | Enum: ADDED, MODIFIED, REMOVED |
| `oldValue` | JSON | No | Before state | NULL if ADDED |
| `newValue` | JSON | No | After state | NULL if REMOVED |
| `fieldChanged` | String(100) | No | Specific field | e.g., "pattern", "description" |

**Relationships**:
- **Belongs to**: One `StyleGuideVersion` (cascade on parent delete)

**Business Rules**:
- ADDED: `oldValue` is NULL, `newValue` contains new rule
- MODIFIED: Both `oldValue` and `newValue` populated
- REMOVED: `newValue` is NULL, `oldValue` contains deleted rule
- `fieldChanged` specifies which field was modified (for MODIFIED action)

**Diff Calculation**:
```typescript
interface DiffResult {
  added: NamingRule[];
  modified: Array<{ ruleId: string; changes: Record<string, { old: any; new: any }> }>;
  removed: NamingRule[];
}
```

**Indexes**:
- Primary: `id`
- Foreign: `versionId`
- Lookup: `ruleId`

---

### 5. StyleGuideUsage

**Purpose**: Tracks which databases/tables are using which style guides (for in-use protection and impact analysis).

**Attributes**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | UUID | Yes | Primary key | Auto-generated |
| `styleGuideId` | UUID | Yes | Applied style guide | FK → StyleGuide (RESTRICT) |
| `resourceType` | String(50) | Yes | Type of resource | Enum: DATABASE, TABLE |
| `resourceId` | UUID | Yes | Resource identifier | FK → Database or Table |
| `appliedById` | UUID | Yes | User who applied | FK → User |
| `appliedAt` | Timestamp | Yes | Application timestamp | Auto |
| `violationCount` | Int | Yes | Current violations | Default: 0, updated after validation |

**Relationships**:
- **References**: One `StyleGuide` (RESTRICT delete)
- **Applied to**: One `Database` or `Table` (polymorphic)
- **Applied by**: One `User`

**Business Rules**:
- Unique constraint: `(styleGuideId, resourceType, resourceId)` - one guide per resource
- Cannot delete `StyleGuide` if usage records exist (referential integrity)
- `violationCount` updated after each validation run
- Used for "Show Usage" and "Impact Analysis" features

**Impact Query**:
```typescript
// Find all resources using a style guide
async function getUsage(styleGuideId: string) {
  return await prisma.styleGuideUsage.findMany({
    where: { styleGuideId },
    include: {
      // Dynamically include database or table based on resourceType
    }
  });
}
```

**Indexes**:
- Primary: `id`
- Unique: `(styleGuideId, resourceType, resourceId)`
- Lookup: `styleGuideId`, `resourceId`

---

### 6. StyleGuideAuditLog

**Purpose**: Complete audit trail of all style guide operations (constitutional requirement).

**Attributes**:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | UUID | Yes | Primary key | Auto-generated |
| `styleGuideId` | UUID | Yes | Target style guide | FK → StyleGuide |
| `action` | String(50) | Yes | Operation performed | Enum: CREATE, UPDATE, DELETE, APPLY, IMPORT, EXPORT |
| `versionBefore` | String(20) | No | Version before change | NULL on CREATE |
| `versionAfter` | String(20) | No | Version after change | NULL on DELETE |
| `changeDescription` | Text | No | Summary of change | Human-readable |
| `userId` | UUID | Yes | User who performed action | FK → User |
| `createdAt` | Timestamp | Yes | Action timestamp | Auto |

**Relationships**:
- **References**: One `StyleGuide` (cascade on parent delete)
- **Performed by**: One `User`

**Business Rules**:
- Immutable records (no updates after creation)
- Captures all CRUD operations for compliance
- Stores before/after versions for rollback context
- Ordered by `createdAt` for timeline view

**Audit Actions**:
- `CREATE`: New style guide created
- `UPDATE`: Style guide modified (version incremented)
- `DELETE`: Style guide soft-deleted
- `APPLY`: Style guide applied to resource
- `IMPORT`: Style guide imported from file
- `EXPORT`: Style guide exported to file

**Indexes**:
- Primary: `id`
- Foreign: `styleGuideId`, `userId`
- Sort: `createdAt DESC`

---

## Validation Entities (Transient)

These entities are **not persisted** but used for validation operations:

### ValidationResult (Runtime DTO)

```typescript
interface ValidationResult {
  styleGuideId: string;
  resourceId: string;
  resourceType: 'DATABASE' | 'TABLE';
  totalElements: number;
  totalViolations: number;
  violations: Violation[];
  summary: {
    byRule: Map<string, number>;
    bySeverity: Map<string, number>;
  };
}

interface Violation {
  elementId: string;
  elementName: string;
  elementType: string; // TABLE, COLUMN, etc.
  ruleId: string;
  ruleName: string;
  expected: string; // Expected pattern
  actual: string; // Current name
  suggestion: string; // Corrected name
  severity: 'ERROR' | 'WARNING';
}
```

---

## Data Flow Diagrams

### Create Style Guide Flow

```
User → Frontend Form
         ↓ (validate with Zod)
       Backend API (POST /api/style-guides)
         ↓ (validate with Joi)
       StyleGuideService.create()
         ↓ (transaction)
       ┌─────────────────────────────┐
       │ 1. Create StyleGuide        │
       │ 2. Create NamingRules       │
       │ 3. Create StyleGuideVersion │ (v1.0.0)
       │ 4. Create AuditLog          │
       └─────────────────────────────┘
         ↓
       Return StyleGuide with Rules
```

### Modify Style Guide Flow

```
User → Frontend Edit Form
         ↓ (modified rules)
       Backend API (PUT /api/style-guides/:id)
         ↓
       VersioningService.createVersion()
         ↓ (calculate diff)
       ┌─────────────────────────────┐
       │ 1. Determine change type    │ (MAJOR/MINOR/PATCH)
       │ 2. Increment version        │ (e.g., 1.0.0 → 1.1.0)
       │ 3. Create StyleGuideVersion │
       │ 4. Create RuleDiffs         │
       │ 5. Update NamingRules       │ (replace all)
       │ 6. Update currentVersion    │
       │ 7. Create AuditLog          │
       └─────────────────────────────┘
         ↓
       Return updated StyleGuide
```

### Validate Schema Flow

```
User → Frontend "Validate" Button
         ↓ (styleGuideId, databaseId)
       Backend API (POST /api/style-guides/:id/validate)
         ↓
       ValidationService.validateSchema()
         ↓
       ┌─────────────────────────────┐
       │ 1. Load all tables/elements │
       │ 2. Load style guide rules   │
       │ 3. Batch validate names     │
       │ 4. Generate violations list │
       │ 5. Calculate suggestions    │
       │ 6. Update violationCount    │
       └─────────────────────────────┘
         ↓
       Return ValidationResult
         ↓
       Frontend displays report
```

---

## Database Indexes Summary

For optimal query performance:

```sql
-- StyleGuide
CREATE INDEX idx_style_guides_name ON style_guides(name);
CREATE INDEX idx_style_guides_active ON style_guides(is_active) WHERE deleted_at IS NULL;

-- NamingRule
CREATE INDEX idx_naming_rules_style_guide ON naming_rules(style_guide_id);
CREATE INDEX idx_naming_rules_entity_type ON naming_rules(entity_type);
CREATE UNIQUE INDEX idx_naming_rules_unique_name ON naming_rules(style_guide_id, name);

-- StyleGuideVersion
CREATE INDEX idx_versions_style_guide_time ON style_guide_versions(style_guide_id, created_at DESC);
CREATE UNIQUE INDEX idx_versions_unique ON style_guide_versions(style_guide_id, version);

-- RuleDiff
CREATE INDEX idx_rule_diffs_version ON rule_diffs(version_id);
CREATE INDEX idx_rule_diffs_rule ON rule_diffs(rule_id);

-- StyleGuideUsage
CREATE UNIQUE INDEX idx_usage_unique ON style_guide_usage(style_guide_id, resource_type, resource_id);
CREATE INDEX idx_usage_style_guide ON style_guide_usage(style_guide_id);
CREATE INDEX idx_usage_resource ON style_guide_usage(resource_id);

-- StyleGuideAuditLog
CREATE INDEX idx_audit_style_guide ON style_guide_audit_logs(style_guide_id);
CREATE INDEX idx_audit_user ON style_guide_audit_logs(user_id);
CREATE INDEX idx_audit_time ON style_guide_audit_logs(created_at DESC);
```

---

## Data Validation Rules

### StyleGuide
- ✅ Name: 1-255 characters, alphanumeric + spaces/hyphens
- ✅ Name unique across all guides
- ✅ CurrentVersion: semantic version format (X.Y.Z)
- ✅ Cannot delete if StyleGuideUsage exists

### NamingRule
- ✅ Pattern: valid regex syntax
- ✅ EntityType: one of [TABLE, COLUMN, INDEX, CONSTRAINT]
- ✅ CaseConvention: one of [PascalCase, camelCase, UPPER_SNAKE_CASE, lower_snake_case, kebab-case]
- ✅ Name unique within style guide
- ✅ ExampleValid/ExampleInvalid: valid JSON arrays

### StyleGuideVersion
- ✅ Version: semantic version format (X.Y.Z)
- ✅ Version unique within style guide
- ✅ ChangeType: one of [MAJOR, MINOR, PATCH]
- ✅ RuleSnapshot: valid JSON array of rules

### StyleGuideUsage
- ✅ ResourceType: one of [DATABASE, TABLE]
- ✅ ResourceId: must exist in corresponding table
- ✅ Unique: (styleGuideId, resourceType, resourceId)

---

## Migration Considerations

### Initial Migration

```bash
# Generate Prisma migration
npx prisma migrate dev --name add-style-guides

# Apply to staging database
npx prisma migrate deploy

# Seed with sample data
npx prisma db seed
```

### Rollback Strategy

All migrations are **additive only** (no destructive changes):
- New tables created
- No existing tables modified
- No data deleted
- Safe to roll back by disabling feature flag

### Sample Seed Data

```typescript
// prisma/seed-style-guides.ts
const sampleGuide = await prisma.styleGuide.create({
  data: {
    name: "Corporate Naming Standards",
    description: "Standard naming conventions for all databases",
    currentVersion: "1.0.0",
    source: "MANUAL",
    createdById: adminUser.id,
    rules: {
      create: [
        {
          name: "Table Names",
          entityType: "TABLE",
          pattern: "^[A-Z][a-zA-Z0-9]*$",
          caseConvention: "PascalCase",
          description: "Tables must use PascalCase",
          exampleValid: ["UserProfile", "OrderHistory"],
          exampleInvalid: ["user_profile", "USERS"],
          ruleOrder: 1,
          createdById: adminUser.id,
        },
        {
          name: "Column Names",
          entityType: "COLUMN",
          pattern: "^[a-z][a-zA-Z0-9]*$",
          caseConvention: "camelCase",
          description: "Columns must use camelCase",
          exampleValid: ["userId", "createdAt"],
          exampleInvalid: ["user_id", "UserID"],
          ruleOrder: 2,
          createdById: adminUser.id,
        },
      ],
    },
  },
});
```

---

## Summary

This data model provides:

✅ **Complete audit trail** (constitutional compliance)  
✅ **Referential integrity** (foreign keys with cascade/restrict)  
✅ **Version history** (event sourcing pattern)  
✅ **In-use protection** (cannot delete applied guides)  
✅ **Granular change tracking** (rule-level diffs)  
✅ **Performance optimization** (strategic indexes)  
✅ **Soft deletes** (constitutional requirement)  
✅ **Extensibility** (JSON fields for metadata)

**Next Step**: Generate API contracts from this data model (Phase 1 continued).
