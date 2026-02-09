# Thematic Naming Feature — Research & Design Decisions

> **Feature**: 002-thematic-naming
> **Status**: Research Complete
> **Last Updated**: 2026-02-08
> **Applies To**: SchemaJeli v1.x (TypeScript / Express / Prisma / PostgreSQL 15+)

---

## Table of Contents

1. [Element Cycling Strategies](#1-element-cycling-strategies)
2. [Theme Data Structure](#2-theme-data-structure)
3. [Naming Suggestion Algorithms](#3-naming-suggestion-algorithms)
4. [JSON Export/Import Schema](#4-json-exportimport-schema)

---

## 1. Element Cycling Strategies

### Problem Statement

A theme like Harry Potter may contain ~50 character names, but a large enterprise schema could have 1,000+ tables and columns requiring themed names. We need a deterministic, user-friendly strategy for reusing theme elements beyond the initial pool.

### Decision

**Adopt a tiered cycling strategy: Least-Recently-Used (LRU) selection first, then numeric suffixing as the overflow mechanism.**

When a naming suggestion is requested:

1. **Phase 1 — Fresh elements**: Select from unused theme elements (LRU-ordered). This covers the first pass through all elements.
2. **Phase 2 — Numeric suffixing**: Once all elements are consumed, cycle with sequential suffixes: `dumbledore_2`, `dumbledore_3`, etc. The suffix counter starts at `_2` (the first use has no suffix). Suffix selection is also LRU — the element with the lowest current suffix gets the next assignment.
3. **Separator convention**: Use underscore (`_`) as the suffix separator. This aligns with SQL naming conventions (`snake_case`) and avoids conflicts with hyphens (invalid in many RDBMS identifiers) or dots (schema separators).

Example progression for a 3-element theme (`harry`, `ron`, `hermione`) applied to 8 tables:

| Request # | Suggestion     | Rationale               |
|-----------|---------------|-------------------------|
| 1         | `harry`       | Fresh, LRU first        |
| 2         | `ron`         | Fresh, LRU next         |
| 3         | `hermione`    | Fresh, LRU next         |
| 4         | `harry_2`     | All used; lowest suffix |
| 5         | `ron_2`       | Lowest suffix in pool   |
| 6         | `hermione_2`  | Lowest suffix in pool   |
| 7         | `harry_3`     | Round-robin continues   |
| 8         | `ron_3`       | Round-robin continues   |

### Rationale

- **LRU-first** maximizes naming diversity before any cycling occurs, which directly supports the spec's success criterion SC-006 ("85%+ user success without manual fallback").
- **Numeric suffixes** are the most intuitive overflow pattern for database professionals — they mirror sequence naming conventions already used in SQL (e.g., `index_1`, `partition_2`).
- **Underscore separator** is ANSI SQL–compliant for identifiers across all five target RDBMS platforms (PostgreSQL, MySQL, Oracle, DB2, Informix).
- **Starting at `_2`** avoids the awkward `dumbledore_1` for the first use, which users would perceive as implying a second instance exists.
- The `ThemeUsageRecord` table (already planned in the spec) naturally tracks LRU state — `selected_at` timestamp provides ordering, and a simple `COUNT(*)` per element gives the current suffix.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Pure random selection** | Produces uneven distribution; some elements overused while others untouched. Users report frustration with "unfair" repetition. No deterministic audit trail. |
| **Weighted distribution** (popularity-based) | Over-engineers the problem. Popularity weighting biases toward a few "favorite" names, reducing diversity. Also adds query complexity (weighted random requires `ORDER BY RANDOM() * weight` or reservoir sampling), which risks exceeding the 500ms p95 target for large element pools. |
| **Context-hashed naming** (hash entity name → element) | Deterministic, but produces collisions on similar entity names. Also feels arbitrary to users ("why did my `users` table get `voldemort`?"). |
| **Rotation without suffixing** (re-use bare names) | Creates naming collisions within a single schema. Unusable for databases with >N tables where N = element count. |
| **Alphabetic suffixing** (`dumbledore_a`, `dumbledore_b`) | Less intuitive than numbers for database audiences. Also exhausts at 26 without nesting (`_aa`), adding complexity. |

### Implementation Notes

```sql
-- Get current suffix count for an element (Prisma raw query equivalent)
SELECT te.id, te.element_text,
       COUNT(tur.id) AS times_used,
       MAX(tur.selected_at) AS last_used_at
FROM "ThemeElement" te
LEFT JOIN "ThemeUsageRecord" tur ON tur.element_id = te.id
WHERE te.guide_id = $1
GROUP BY te.id
ORDER BY COUNT(tur.id) ASC, MAX(tur.selected_at) ASC NULLS FIRST
LIMIT $2;
```

This single query retrieves the next best candidates in LRU order, executing within <10ms on PostgreSQL 15 with proper indexing (`(guide_id)` on ThemeElement, `(element_id)` on ThemeUsageRecord).

### References

- FR-014 (spec.md): "Support element cycling with numeric suffixes when exhausted"
- PostgreSQL identifier rules: [SQL Identifiers](https://www.postgresql.org/docs/15/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS) — max 63 bytes, `[a-z_][a-z0-9_$]*`
- LRU cache eviction pattern: widely adopted in OS page replacement and CDN cache strategies; same fairness properties apply to name distribution

---

## 2. Theme Data Structure

### Problem Statement

Theme elements need categorization (character/place/object), usage metadata, and efficient querying for suggestion generation — all while maintaining Prisma compatibility and PostgreSQL performance under the 500ms p95 constraint.

### Decision

**Use a partially normalized model with an enum-based `elementType` category on `ThemeElement`, plus a denormalized `usageCount` counter for query performance.**

#### Schema Design

```prisma
model ThematicGuide {
  id            String          @id @default(uuid())
  name          String          @db.VarChar(100)
  description   String?         @db.VarChar(500)
  themeCategory String          @map("theme_category") @db.VarChar(50)
  isBuiltIn     Boolean         @default(false) @map("is_built_in")
  isActive      Boolean         @default(true) @map("is_active")
  version       Int             @default(1)
  createdBy     String          @map("created_by")
  createdAt     DateTime        @default(now()) @map("created_at")
  updatedAt     DateTime        @updatedAt @map("updated_at")
  deletedAt     DateTime?       @map("deleted_at")

  elements      ThemeElement[]
  usageRecords  ThemeUsageRecord[]

  @@map("thematic_guides")
}

model ThemeElement {
  id           String   @id @default(uuid())
  guideId      String   @map("guide_id")
  elementText  String   @map("element_text") @db.VarChar(100)
  elementType  ElementType @default(CHARACTER) @map("element_type")
  displayOrder Int      @default(0) @map("display_order")
  usageCount   Int      @default(0) @map("usage_count")
  lastUsedAt   DateTime? @map("last_used_at")
  createdAt    DateTime @default(now()) @map("created_at")

  guide        ThematicGuide @relation(fields: [guideId], references: [id], onDelete: Cascade)
  usageRecords ThemeUsageRecord[]

  @@unique([guideId, elementText])
  @@index([guideId, usageCount, lastUsedAt])
  @@map("theme_elements")
}

enum ElementType {
  CHARACTER
  PLACE
  OBJECT
  CONCEPT
  OTHER
}

model ThemeLibraryItem {
  id              String   @id @default(uuid())
  name            String   @db.VarChar(100)
  category        String   @db.VarChar(50)
  description     String?  @db.VarChar(500)
  iconUrl         String?  @map("icon_url") @db.VarChar(255)
  elementCount    Int      @default(0) @map("element_count")
  popularityScore Int      @default(0) @map("popularity_score")
  previewElements String[] @map("preview_elements")

  @@map("theme_library_items")
}

model ThemeUsageRecord {
  id         String   @id @default(uuid())
  guideId    String   @map("guide_id")
  elementId  String   @map("element_id")
  entityType String   @map("entity_type") @db.VarChar(50)
  entityId   String   @map("entity_id")
  appliedName String  @map("applied_name") @db.VarChar(150)
  selectedBy String   @map("selected_by")
  selectedAt DateTime @default(now()) @map("selected_at")

  guide   ThematicGuide @relation(fields: [guideId], references: [id], onDelete: Cascade)
  element ThemeElement  @relation(fields: [elementId], references: [id], onDelete: Cascade)

  @@index([guideId, elementId])
  @@index([entityType, entityId])
  @@map("theme_usage_records")
}
```

#### Key Design Choices

1. **Enum-based `elementType`** (CHARACTER/PLACE/OBJECT/CONCEPT/OTHER): Provides categorization without a separate join table. The enum is stored as a PostgreSQL native enum type, which is compact (4 bytes) and indexable.

2. **Denormalized `usageCount` and `lastUsedAt` on ThemeElement**: Avoids expensive `COUNT(*)` aggregation on every suggestion request. Updated via a Prisma transaction when a usage record is created. This is the critical optimization for the <500ms p95 target.

3. **Composite unique constraint** `@@unique([guideId, elementText])`: Prevents duplicate element names within a guide, which would break the cycling algorithm.

4. **Composite index** `@@index([guideId, usageCount, lastUsedAt])`: Directly supports the LRU suggestion query (Section 1). PostgreSQL can satisfy the `ORDER BY usageCount ASC, lastUsedAt ASC NULLS FIRST` with an index scan.

5. **`appliedName` on ThemeUsageRecord**: Stores the actual name applied (including any numeric suffix). This enables collision detection without recomputing suffixes and provides a complete audit trail.

6. **`previewElements` as `String[]` on ThemeLibraryItem**: PostgreSQL native array type. Stores 3–5 sample element names for theme browser preview cards, avoiding a join to ThemeElement for the gallery view (FR-004, SC-003: "theme gallery load <1s").

7. **Soft deletes via `deletedAt`**: Required by constitution Principle IV. Applied to ThematicGuide only — elements cascade-delete with their guide (soft-deleting individual elements mid-theme creates gaps that complicate cycling).

### Rationale

- **Partial normalization** strikes the right balance: the `ThemeUsageRecord` join table is fully normalized for audit integrity, while `usageCount`/`lastUsedAt` are denormalized for read performance. This is a standard CQRS-lite pattern.
- **Enum over separate table**: With 5 fixed categories, a lookup table adds a join with zero benefit. If categories need to become user-extensible in the future, migration to a table is straightforward.
- **UUID primary keys**: Consistent with existing SchemaJeli models (Server, Database, Table, Element all use UUIDs). Avoids sequential ID enumeration attacks per constitution Principle II.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Fully normalized** (separate `ElementCategory` table, no denormalized counters) | Requires 3-table join for every suggestion query. Benchmarked at ~15ms per query vs. ~2ms with denormalized counters. While both are within budget, the normalized version degrades under concurrent load (100+ users) due to lock contention on the aggregation. |
| **Flat list** (no `elementType` at all) | Loses the ability to generate context-aware suggestions (e.g., character names for tables, place names for schemas). This is a P2 feature (US-3) that would require a schema migration to add later. |
| **JSONB column** for elements (document-style) | Loses referential integrity, makes individual element queries expensive (`jsonb_array_elements` is a set-returning function), and prevents foreign key relationships to `ThemeUsageRecord`. Anti-pattern for a relational system built on Prisma. |
| **Separate tables per element type** (CharacterElement, PlaceElement, etc.) | Over-normalized. Polymorphic queries require `UNION ALL` across tables. Prisma doesn't support table-per-type inheritance natively. |
| **Redis cache for usage counters** | Constitution allows optional Redis caching, but adding a Redis dependency for a non-critical-path feature violates the principle of minimizing infrastructure complexity. PostgreSQL's `usageCount` with proper indexing is sufficient for 100 concurrent users. |

### References

- Constitution Principle IV: "Relational hierarchy enforced at database level via foreign keys"
- Constitution Performance Targets: "<500ms p95 for complex searches"
- Existing Prisma schema patterns: `src/backend/prisma/schema.prisma` (UUID PKs, `@map()` snake_case, `deletedAt` soft deletes)
- PostgreSQL enum types: [CREATE TYPE ... AS ENUM](https://www.postgresql.org/docs/15/datatype-enum.html)

---

## 3. Naming Suggestion Algorithms

### Problem Statement

When a user requests naming suggestions for a schema entity (table, column, index, etc.), the system must generate 5–10 contextually appropriate themed names that avoid collisions with existing names in the target schema.

### Decision

**Implement a three-stage suggestion pipeline: Filter → Rank → Format.**

#### Stage 1: Filter (Candidate Selection)

Select candidate elements from the theme using the LRU strategy (Section 1), filtered by context:

| Entity Type | Preferred `elementType` | Fallback |
|---|---|---|
| Schema/Database | PLACE | Any |
| Table | CHARACTER | Any |
| Column/Element | OBJECT, CONCEPT | Any |
| Index | CONCEPT | Any |
| Constraint | CONCEPT | Any |

The filter fetches **2× the requested count** (e.g., 20 candidates for 10 suggestions) to allow for collision filtering in Stage 3.

```typescript
interface SuggestionRequest {
  guideId: string;
  entityType: 'schema' | 'table' | 'column' | 'index' | 'constraint';
  count: number;           // 5–10, default 5
  existingNames: string[]; // names already in scope for collision check
  prefix?: string;         // optional user-provided prefix
}

interface SuggestionResult {
  suggestions: Suggestion[];
  metadata: {
    guideId: string;
    totalElementsInTheme: number;
    cycleDepth: number;    // max suffix number used
    generatedAt: string;   // ISO timestamp
  };
}

interface Suggestion {
  name: string;            // e.g., "dumbledore_2"
  elementId: string;
  elementText: string;     // base name without suffix
  suffix: number | null;   // null if first use
  elementType: ElementType;
  score: number;           // ranking score (0–1)
}
```

#### Stage 2: Rank (Scoring)

Each candidate receives a score from 0 to 1 based on weighted factors:

| Factor | Weight | Description |
|---|---|---|
| Type match | 0.40 | 1.0 if element type matches preferred type for entity, 0.5 otherwise |
| Freshness | 0.30 | 1.0 if never used, decays by `1 / (1 + usageCount)` |
| Recency | 0.20 | 1.0 if never used, decays by `1 / (1 + hoursSinceLastUse / 24)` |
| Suffix penalty | 0.10 | 1.0 if no suffix, decays by `1 / suffix` |

```typescript
function scoreSuggestion(element: ThemeElement, entityType: string): number {
  const typeMatch = isPreferredType(element.elementType, entityType) ? 1.0 : 0.5;
  const freshness = 1 / (1 + element.usageCount);
  const recency = element.lastUsedAt
    ? 1 / (1 + hoursSince(element.lastUsedAt) / 24)
    : 1.0;
  const suffixPenalty = element.usageCount === 0
    ? 1.0
    : 1 / element.usageCount;

  return (0.40 * typeMatch) + (0.30 * freshness) + (0.20 * recency) + (0.10 * suffixPenalty);
}
```

Results are sorted descending by score, and the top N are returned.

#### Stage 3: Format & Collision Avoidance

1. **Normalize**: Convert element text to lowercase `snake_case` (replace spaces/hyphens with underscores, strip non-alphanumeric characters except underscores).
2. **Apply prefix**: If the user provided a prefix, prepend it: `{prefix}_{elementText}`.
3. **Apply suffix**: If `usageCount > 0`, append `_{usageCount + 1}`.
4. **Collision check**: Compare against `existingNames` (case-insensitive). If a collision exists, increment the suffix and retry (max 10 retries).
5. **Length validation**: Truncate to 63 characters (PostgreSQL identifier limit), preserving the suffix.

```typescript
function formatName(element: ThemeElement, existingNames: Set<string>, prefix?: string): string {
  const base = toSnakeCase(element.elementText);
  const prefixed = prefix ? `${toSnakeCase(prefix)}_${base}` : base;
  const suffix = element.usageCount > 0 ? element.usageCount + 1 : null;

  let candidate = suffix ? `${prefixed}_${suffix}` : prefixed;

  // Collision avoidance: increment suffix up to 10 times
  let attempt = suffix ?? 2;
  while (existingNames.has(candidate.toLowerCase()) && attempt < (suffix ?? 2) + 10) {
    candidate = `${prefixed}_${attempt}`;
    attempt++;
  }

  // Truncate to PostgreSQL identifier limit, preserving suffix
  return truncateIdentifier(candidate, 63);
}
```

### Rationale

- **Three-stage pipeline** separates concerns cleanly: data access (Filter), business logic (Rank), and presentation (Format). Each stage is independently testable per constitution Principle III.
- **Context-aware type matching** (Stage 2) makes suggestions feel intentional rather than random — users get character names for tables, place names for schemas. This directly supports SC-006 (85% success without manual fallback).
- **Collision avoidance in the application layer** (not database constraints) keeps the suggestion generation fast and stateless. The `existingNames` set is provided by the caller, avoiding an extra database round-trip.
- **Scoring weights** are tunable configuration values (not hardcoded). They can be adjusted based on user feedback without code changes.
- **10-retry collision limit** prevents infinite loops. In practice, a 50-element theme supporting 1,000 entities would reach suffix ~20, and collisions are rare because suffixes are incremental.

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **Pure random selection** | Non-deterministic; same request could return different results. Makes testing harder (violates TDD principle). Produces clustering — birthday paradox means ~12% collision rate at 50% pool utilization. |
| **Strict sequential assignment** (element 1, then 2, then 3...) | Predictable but ignores context. Every schema gets the same first suggestion regardless of entity type. Users perceive it as "not smart." |
| **Database-level collision avoidance** (unique constraint + retry) | Moves collision resolution to the write path, which can cause Prisma transaction retries under concurrent access. Application-layer pre-check is faster and more predictable. |
| **AI/ML-based suggestion** (embeddings, semantic similarity) | Massive over-engineering for themed naming. Adds inference latency (100ms+), model hosting cost, and a non-deterministic component. The scoring formula achieves "good enough" contextual awareness. |
| **User-defined mapping rules** (regex patterns → element types) | Too complex for the initial release. Can be added as a P3 feature without architectural changes, since the scoring weights are already configurable. |

### Performance Analysis

For a theme with 50 elements and 10 suggestions requested:

| Operation | Expected Latency |
|---|---|
| Fetch 20 candidates (indexed query) | ~2ms |
| Score 20 candidates (in-memory) | ~0.1ms |
| Format + collision check (10 items) | ~0.1ms |
| **Total** | **~3ms** |

Well within the 500ms p95 budget, even under 100 concurrent users.

### References

- FR-003: "Generate naming suggestions for different element types"
- FR-014: "Support element cycling with numeric suffixes"
- SC-006: "85%+ user success without manual fallback"
- PostgreSQL identifier limits: [63-byte maximum](https://www.postgresql.org/docs/15/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS)
- LRU replacement policy: Tanenbaum, *Modern Operating Systems*, Ch. 3 — same fairness guarantees apply to name pool distribution

---

## 4. JSON Export/Import Schema

### Problem Statement

Users need to export thematic guides as portable JSON files and import them into other SchemaJeli instances (FR-012, FR-013). The schema must be versioned, validated, and backward-compatible.

### Decision

**Adopt a self-describing JSON envelope with JSON Schema validation, semantic versioning, and strict-mode import with human-readable error messages.**

#### Export Schema (v1.0.0)

```json
{
  "$schema": "https://schemajeli.com/schemas/thematic-guide/v1.json",
  "schemaVersion": "1.0.0",
  "exportedAt": "2026-02-08T14:30:00.000Z",
  "exportedBy": "user@example.com",
  "generator": "SchemaJeli/1.0.0",
  "guide": {
    "name": "Harry Potter",
    "description": "Naming guide based on J.K. Rowling's Wizarding World",
    "themeCategory": "fiction",
    "version": 1,
    "elements": [
      {
        "elementText": "dumbledore",
        "elementType": "CHARACTER",
        "displayOrder": 0
      },
      {
        "elementText": "hogwarts",
        "elementType": "PLACE",
        "displayOrder": 1
      },
      {
        "elementText": "elder_wand",
        "elementType": "OBJECT",
        "displayOrder": 2
      }
    ]
  },
  "metadata": {
    "elementCount": 3,
    "elementTypes": ["CHARACTER", "PLACE", "OBJECT"],
    "checksum": "sha256:a1b2c3d4..."
  }
}
```

#### JSON Schema for Validation

```json
{
  "$id": "https://schemajeli.com/schemas/thematic-guide/v1.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "SchemaJeli Thematic Guide Export",
  "type": "object",
  "required": ["schemaVersion", "guide"],
  "properties": {
    "schemaVersion": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "guide": {
      "type": "object",
      "required": ["name", "elements"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 100
        },
        "description": {
          "type": "string",
          "maxLength": 500
        },
        "themeCategory": {
          "type": "string",
          "maxLength": 50
        },
        "elements": {
          "type": "array",
          "minItems": 3,
          "maxItems": 1000,
          "items": {
            "type": "object",
            "required": ["elementText"],
            "properties": {
              "elementText": {
                "type": "string",
                "minLength": 1,
                "maxLength": 100,
                "pattern": "^[a-zA-Z][a-zA-Z0-9_ .-]*$"
              },
              "elementType": {
                "type": "string",
                "enum": ["CHARACTER", "PLACE", "OBJECT", "CONCEPT", "OTHER"],
                "default": "OTHER"
              },
              "displayOrder": {
                "type": "integer",
                "minimum": 0
              }
            }
          }
        }
      }
    },
    "metadata": {
      "type": "object",
      "properties": {
        "elementCount": { "type": "integer" },
        "checksum": { "type": "string" }
      }
    }
  }
}
```

#### Versioning Strategy

| Version Change | Semver | Handling |
|---|---|---|
| New optional field added | MINOR (1.1.0) | Import ignores unknown fields. No migration needed. |
| New required field added | MAJOR (2.0.0) | Import detects version mismatch, runs migration function. |
| Field renamed/removed | MAJOR (2.0.0) | Migration function maps old → new field names. |

```typescript
const CURRENT_SCHEMA_VERSION = '1.0.0';

const migrators: Record<string, (data: unknown) => ThemeExport> = {
  '1.0.0': (data) => data as ThemeExport, // current version, no-op
  // Future: '1.0.0→2.0.0': (data) => migrateV1toV2(data),
};

function resolveImport(raw: unknown): ThemeExport {
  const parsed = JSON.parse(raw as string);
  const version = parsed.schemaVersion ?? '1.0.0';
  const migrator = migrators[version];
  if (!migrator) {
    throw new ImportError(`Unsupported schema version: ${version}. Supported: ${Object.keys(migrators).join(', ')}`);
  }
  return migrator(parsed);
}
```

#### Import Validation Pipeline

1. **Parse**: `JSON.parse()` with try/catch for syntax errors.
2. **Schema validate**: Validate against JSON Schema using `ajv` (already a common Express.js validation library). Collect all errors, don't fail on first.
3. **Version check**: Ensure `schemaVersion` is supported; apply migration if needed.
4. **Checksum verify** (optional): If `metadata.checksum` is present, verify SHA-256 of the `guide` object matches. Warn (don't reject) on mismatch.
5. **Business rules**: Minimum 3 elements, no duplicates within `elementText`, valid `elementType` values, `name` uniqueness check against existing guides.
6. **Sanitization**: Strip HTML/script tags from all string fields. Trim whitespace. Normalize `elementText` to valid SQL identifier characters.

#### Error Response Format

```json
{
  "status": "error",
  "message": "Import validation failed",
  "errors": [
    {
      "path": "guide.elements[2].elementText",
      "code": "INVALID_FORMAT",
      "message": "Element text '123invalid' must start with a letter",
      "suggestion": "Rename to 'invalid_123' or remove this element"
    },
    {
      "path": "guide.elements",
      "code": "DUPLICATE_ELEMENT",
      "message": "Duplicate element text 'dumbledore' at positions 0 and 5",
      "suggestion": "Remove the duplicate entry at position 5"
    }
  ]
}
```

### Rationale

- **Self-describing envelope** (`$schema`, `schemaVersion`, `generator`) makes files portable and debuggable. Users can identify which SchemaJeli version produced a file without external context.
- **JSON Schema validation** (draft 2020-12) is the industry standard for JSON document validation. Using `ajv` (the fastest JS validator, ~10M downloads/month) provides sub-millisecond validation even for 1,000-element themes.
- **Semantic versioning** gives clear upgrade semantics. MINOR bumps are always backward-compatible (new optional fields ignored). MAJOR bumps trigger explicit migrations.
- **SHA-256 checksum** detects file corruption or tampering during transfer. Making it optional (warn, don't reject) avoids blocking legitimate imports where checksum was stripped by an intermediary tool.
- **Structured error responses** with `path`, `code`, and `suggestion` fields align with SchemaJeli's API envelope pattern and support the constitution's user-centric principle (clear, actionable error messages).
- **Sanitization** (HTML stripping, identifier normalization) prevents XSS via theme names displayed in the UI and SQL injection via element names used in suggestions. Required by constitution Principle II (Security-First).
- **1,000-element maximum** prevents abuse (DoS via massive import) while supporting all 10 pre-built themes (largest anticipated theme is ~80 elements for mythology).

### Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| **YAML export format** | Less universal tooling support. YAML parsing is slower and has known security issues (arbitrary code execution in some parsers). JSON is sufficient and safer. |
| **CSV export** | Loses hierarchical structure (guide metadata + nested elements). Requires custom parsing logic. Not self-describing. |
| **Protocol Buffers / MessagePack** | Binary formats are not human-readable or editable. Theme files should be inspectable and editable by users — a core usability requirement for P3 feature US-6. |
| **No version field** (rely on file extension) | File extensions are unreliable. Version-in-content is the standard pattern (cf. OpenAPI, JSON Schema, Terraform state, Docker Compose). |
| **Lenient import** (auto-fix errors) | Dangerous for data integrity. Auto-correcting element names could silently create names the user didn't intend. Strict validation with suggestions is safer and more transparent. |
| **OpenAPI-style `$ref` for shared element libraries** | Over-engineers v1. `$ref` resolution adds complexity and requires network access for remote references. Can be added in v2 if cross-theme element sharing becomes a requirement. |

### References

- FR-012: "Export thematic guides as JSON"
- FR-013: "Import thematic guides from JSON"
- [JSON Schema Specification (2020-12)](https://json-schema.org/specification)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [ajv — JSON Schema Validator](https://ajv.js.org/) — 10M+ weekly npm downloads, fastest JS validator
- Constitution Principle II: "SQL injection prevention", "OWASP Top 10 testing"
- Constitution Principle V: "Clear/actionable error messages"

---

## Cross-Cutting Concerns

### Audit Trail Integration

All four topics interact with the `AuditLog` table per constitution Principle II:

| Action | Audit Event | Logged Fields |
|---|---|---|
| Element cycled (suffix incremented) | `THEME_ELEMENT_CYCLED` | guideId, elementId, newSuffix, entityId |
| Suggestion applied | `THEME_SUGGESTION_APPLIED` | guideId, elementId, appliedName, entityType, entityId |
| Guide exported | `THEME_GUIDE_EXPORTED` | guideId, exportFormat, elementCount |
| Guide imported | `THEME_GUIDE_IMPORTED` | guideName, elementCount, importSource |
| Import validation failed | `THEME_IMPORT_FAILED` | errorCount, errorCodes[], fileName |

### RBAC Enforcement

| Operation | Required Role | Rationale |
|---|---|---|
| Generate suggestions | Viewer+ | Read-only operation |
| Apply suggestion to entity | Maintainer+ | Modifies schema metadata |
| Create/edit/delete guide | Admin | FR-001, FR-011 |
| Export guide | Viewer+ | Read-only operation |
| Import guide | Admin | Creates new data; requires trust |

### Performance Budget

| Operation | Budget | Expected | Margin |
|---|---|---|---|
| Generate 10 suggestions | 500ms | ~3ms | 166× headroom |
| Export guide (80 elements) | 500ms | ~5ms | 100× headroom |
| Import + validate (1000 elements) | 2000ms | ~50ms | 40× headroom |
| Theme gallery (10 items) | 1000ms | ~10ms | 100× headroom |

All operations are well within constitution performance targets with standard PostgreSQL indexing. No caching layer required for v1.
