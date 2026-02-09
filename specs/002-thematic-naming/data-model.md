# Data Model: Thematic Naming Guide

> **Feature**: 002-thematic-naming  
> **Status**: Draft  
> **Last Updated**: 2026-02-08  
> **Source**: [spec.md](./spec.md), [research.md](./research.md), `src/backend/prisma/schema.prisma`

---

## Table of Contents

1. [Overview](#overview)
2. [Entity Relationship Diagram](#entity-relationship-diagram)
3. [Enums](#enums)
4. [Entities](#entities)
   - [ThematicGuide](#thematicguide)
   - [ThemeElement](#themeelement)
   - [ThemeLibraryItem](#themelibraryitem)
   - [ThemeUsageRecord](#themeusagerecord)
   - [AuditLog (existing)](#auditlog-existing)
5. [Indexes & Query Optimization](#indexes--query-optimization)
6. [Prisma Schema](#prisma-schema)
7. [Validation Rules](#validation-rules)
8. [State Transitions](#state-transitions)
9. [Cascade & Deletion Behavior](#cascade--deletion-behavior)
10. [Audit Trail Integration](#audit-trail-integration)

---

## Overview

The thematic naming feature introduces four new entities and two new enums into the SchemaJeli data model. These entities support the full lifecycle of themed naming guides: creation, element management, suggestion generation, usage tracking, and export/import.

**Design principles** (from [research.md](./research.md) §2):

- Partially normalized model — `ThemeUsageRecord` is fully normalized for audit integrity; `usageCount`/`lastUsedAt` are denormalized on `ThemeElement` for read performance.
- UUID primary keys — consistent with existing models (`Server`, `Database`, `Table`, `Element`).
- Soft deletes via `deletedAt` on `ThematicGuide` only — element-level soft deletes would complicate the cycling algorithm.
- `@map()` snake_case column naming — matches existing Prisma conventions.

---

## Entity Relationship Diagram

```
┌──────────────────────┐
│   ThemeLibraryItem   │  (standalone — built-in theme templates)
│                      │
│  id (PK)             │
│  name                │
│  category            │
│  description         │
│  iconUrl             │
│  elementCount        │
│  popularityScore     │
│  previewElements[]   │
│  createdAt           │
└──────────────────────┘

┌──────────────────────┐       1:N        ┌──────────────────────┐
│    ThematicGuide     │ ───────────────── │    ThemeElement       │
│                      │                   │                      │
│  id (PK)             │                   │  id (PK)             │
│  name                │                   │  guideId (FK)        │
│  description         │                   │  elementText         │
│  themeCategory       │                   │  elementType (enum)  │
│  isBuiltIn           │                   │  displayOrder        │
│  isActive            │                   │  usageCount          │
│  version             │                   │  lastUsedAt          │
│  createdBy           │                   │  createdAt           │
│  createdAt           │                   │                      │
│  updatedAt           │                   │  UNIQUE(guideId,     │
│  deletedAt           │                   │    elementText)      │
└──────┬───────────────┘                   └──────┬───────────────┘
       │                                          │
       │           1:N                             │  1:N
       │                                          │
       └──────────────┐    ┌──────────────────────┘
                      │    │
                      ▼    ▼
              ┌──────────────────────┐
              │  ThemeUsageRecord    │
              │                      │
              │  id (PK)             │
              │  guideId (FK)        │
              │  elementId (FK)      │
              │  entityType          │
              │  entityId            │
              │  appliedName         │
              │  selectedBy          │
              │  selectedAt          │
              └──────────────────────┘

              ┌──────────────────────┐
              │  AuditLog (existing) │
              │                      │
              │  entityType includes │
              │  THEMATIC_GUIDE      │
              └──────────────────────┘
```

---

## Enums

### ElementType (new)

Categorizes theme elements for context-aware suggestion generation (research.md §3 — character names for tables, place names for schemas).

| Value       | Description                                      |
|-------------|--------------------------------------------------|
| `CHARACTER` | Named characters (e.g., Harry, Dumbledore, Yoda) |
| `PLACE`     | Locations (e.g., Hogwarts, Tatooine, Everest)    |
| `OBJECT`    | Things/items (e.g., Elder Wand, Lightsaber)      |
| `CONCEPT`   | Abstract ideas (e.g., Courage, Gravity, Harmony) |
| `OTHER`     | Uncategorized elements                           |

**Prisma definition**:
```prisma
enum ElementType {
  CHARACTER
  PLACE
  OBJECT
  CONCEPT
  OTHER
}
```

**Rationale**: Enum over separate table — with 5 fixed categories a lookup table adds a join with zero benefit (research.md §2). If categories need to become user-extensible, migration to a table is straightforward.

### ThemeCategory (new)

Classifies guides by theme origin, supporting both built-in and custom themes (FR-002, FR-004a, FR-005).

| Value       | Description                                               |
|-------------|-----------------------------------------------------------|
| `FICTION`   | Fictional universes (Harry Potter, Star Wars, Mythology)  |
| `NATURE`    | Natural world (Fruit, Animals, Flowers, Planets)          |
| `CULTURE`   | Cultural references (Musical Artists, Famous Artists, Colors) |
| `CUSTOM`    | Admin-created custom themes                               |

**Prisma definition**:
```prisma
enum ThemeCategory {
  FICTION
  NATURE
  CULTURE
  CUSTOM
}
```

**Rationale**: Stored as a Prisma enum mapped to a PostgreSQL native enum type (4 bytes, indexable). The `CUSTOM` value covers all admin-created themes per FR-005. Categories align with the 10 built-in themes: Fiction (Harry Potter, Star Wars, Mythology), Nature (Fruit, Animals, Flowers, Planets), Culture (Musical Artists, Famous Artists, Colors).

### EntityType (existing — extend)

The existing `EntityType` enum in the Prisma schema must be extended with a new value to support audit logging for thematic guides:

| New Value         | Description                    |
|-------------------|--------------------------------|
| `THEMATIC_GUIDE`  | Thematic naming guide entity   |

---

## Entities

### ThematicGuide

**Purpose**: Represents a named set of themed naming elements. A guide is the top-level container that users create, browse, apply, and export. Supports both built-in themes (pre-populated at launch) and custom admin-created themes.

**Database table**: `thematic_guides`

| Field           | Type            | Constraints                         | Default        | Description                                                  |
|-----------------|-----------------|--------------------------------------|----------------|--------------------------------------------------------------|
| `id`            | `String (UUID)` | PK                                  | `uuid()`       | Unique identifier                                            |
| `name`          | `String`        | Required, max 100 chars, unique      | —              | Display name of the guide (e.g., "Harry Potter")             |
| `description`   | `String?`       | Optional, max 500 chars             | `null`         | Human-readable description of the theme                      |
| `themeCategory` | `ThemeCategory` | Required                            | `CUSTOM`       | Classification: FICTION, NATURE, CULTURE, or CUSTOM           |
| `isBuiltIn`     | `Boolean`       | Required                            | `false`        | Whether this is a system-provided built-in theme             |
| `isActive`      | `Boolean`       | Required                            | `true`         | Active flag for guide lifecycle (FR-006)                     |
| `version`       | `Int`           | Required, min 1                     | `1`            | Version number, incremented on each edit (FR-006)            |
| `iconUrl`       | `String?`       | Optional, max 255 chars             | `null`         | URL/path to theme icon for gallery display                   |
| `createdBy`     | `String`        | Required                            | —              | User ID of the guide creator (audit trail, FR-015)           |
| `createdAt`     | `DateTime`      | Required                            | `now()`        | Creation timestamp                                           |
| `updatedAt`     | `DateTime`      | Required, auto-updated              | `@updatedAt`   | Last modification timestamp                                  |
| `deletedAt`     | `DateTime?`     | Optional                            | `null`         | Soft delete timestamp (constitution: no physical deletes)    |

**Relationships**:
- `elements` → `ThemeElement[]` (one-to-many, cascade delete)
- `usageRecords` → `ThemeUsageRecord[]` (one-to-many, cascade delete)

**Validation rules**:
- `name`: 1–100 characters, must be unique across non-deleted guides
- `description`: 0–500 characters
- Guide must have ≥ 3 elements before activation (FR-001, acceptance scenario 4)
- Only users with `Admin` role may create, edit, or delete guides (FR-011)
- Built-in guides (`isBuiltIn = true`) cannot be deleted, only deactivated

---

### ThemeElement

**Purpose**: Represents a single themed name available for use within a guide (e.g., "dumbledore", "hermione", "tatooine"). Tracks usage metadata for the LRU cycling algorithm (research.md §1).

**Database table**: `theme_elements`

| Field          | Type          | Constraints                                 | Default     | Description                                                     |
|----------------|---------------|----------------------------------------------|-------------|-----------------------------------------------------------------|
| `id`           | `String (UUID)` | PK                                        | `uuid()`    | Unique identifier                                               |
| `guideId`      | `String`      | FK → ThematicGuide.id, required             | —           | Parent guide                                                    |
| `elementText`  | `String`      | Required, max 100 chars                     | —           | The themed name text (e.g., "dumbledore")                       |
| `elementType`  | `ElementType`  | Required                                   | `CHARACTER` | Category for context-aware suggestion ranking                   |
| `displayOrder` | `Int`         | Required, min 0                             | `0`         | Sort order within the guide                                     |
| `usageCount`   | `Int`         | Required, min 0                             | `0`         | Denormalized counter — times this element has been applied (FR-007) |
| `lastUsedAt`   | `DateTime?`   | Optional                                    | `null`      | Timestamp of most recent usage (FR-007)                         |
| `createdAt`    | `DateTime`    | Required                                    | `now()`     | Creation timestamp                                              |

**Relationships**:
- `guide` → `ThematicGuide` (many-to-one, FK on `guideId`, `onDelete: Cascade`)
- `usageRecords` → `ThemeUsageRecord[]` (one-to-many, cascade delete)

**Validation rules**:
- `elementText`: 1–100 characters, must match pattern `^[a-zA-Z][a-zA-Z0-9_ .-]*$` (research.md §4 — must start with a letter, valid SQL identifier characters)
- `elementText` must be unique within its guide (`@@unique([guideId, elementText])`)
- `usageCount` is updated transactionally when a `ThemeUsageRecord` is created (research.md §2 — denormalized for query performance)
- `lastUsedAt` is updated transactionally alongside `usageCount`
- Elements are physically deleted when their parent guide is deleted (cascade); no element-level soft deletes (research.md §2 — soft-deleting individual elements complicates cycling)

**Denormalization note**: `usageCount` and `lastUsedAt` are denormalized from `ThemeUsageRecord` to avoid expensive `COUNT(*)` aggregation on every suggestion request. They are updated within a Prisma transaction when a usage record is created. This is the critical optimization for the <500ms p95 target (research.md §2).

---

### ThemeLibraryItem

**Purpose**: Represents a built-in theme template in the theme library/gallery. These are pre-populated at system launch and serve as read-only catalog entries that users can browse and use to create new `ThematicGuide` instances. ThemeLibraryItem is a standalone entity — not linked to ThematicGuide by foreign key — because library items are catalog metadata, not live guides.

**Database table**: `theme_library_items`

| Field             | Type        | Constraints               | Default  | Description                                                       |
|-------------------|-------------|---------------------------|----------|-------------------------------------------------------------------|
| `id`              | `String (UUID)` | PK                   | `uuid()` | Unique identifier                                                 |
| `name`            | `String`    | Required, max 100 chars, unique | —   | Theme name (e.g., "Harry Potter")                                 |
| `category`        | `ThemeCategory` | Required             | —        | Theme classification: FICTION, NATURE, CULTURE                    |
| `description`     | `String?`   | Optional, max 500 chars  | `null`   | Human-readable theme description                                  |
| `iconUrl`         | `String?`   | Optional, max 255 chars  | `null`   | URL/path to theme icon for gallery cards                          |
| `elementCount`    | `Int`       | Required, min 0          | `0`      | Total number of elements available in this theme                  |
| `popularityScore` | `Int`       | Required, min 0          | `0`      | Usage ranking score for sorting in gallery (incremented on use)   |
| `previewElements` | `String[]`  | Required                 | `[]`     | 3–5 sample element names for gallery preview cards                |
| `seedElements`    | `Json`      | Required                 | —        | Full element list as JSON array for guide creation (elementText + elementType + displayOrder) |
| `createdAt`       | `DateTime`  | Required                 | `now()`  | Creation timestamp                                                |

**Relationships**: None (standalone catalog entity).

**Validation rules**:
- `name`: 1–100 characters, unique across library items
- `previewElements`: PostgreSQL native array type (`String[]`), 3–5 elements recommended
- `seedElements`: JSON array matching the export schema element structure (research.md §4)
- `popularityScore` is incremented when a user creates a guide from this library item
- Library items are immutable after seed — updates only to `popularityScore`

**Design rationale** (research.md §2): `previewElements` as `String[]` avoids a join to `ThemeElement` for the gallery view, supporting SC-002 ("theme gallery load <1s"). `seedElements` as `Json` stores the full element payload used to populate a new `ThematicGuide` and its `ThemeElement` records on guide creation.

---

### ThemeUsageRecord

**Purpose**: Tracks when and how theme elements are applied to schema entities. Provides the audit trail for naming decisions and the data source for the LRU cycling algorithm (research.md §1). Each record captures a single application of a themed name to a specific schema entity.

**Database table**: `theme_usage_records`

| Field         | Type        | Constraints                          | Default  | Description                                                        |
|---------------|-------------|---------------------------------------|----------|--------------------------------------------------------------------|
| `id`          | `String (UUID)` | PK                              | `uuid()` | Unique identifier                                                  |
| `guideId`     | `String`    | FK → ThematicGuide.id, required      | —        | The guide that was used                                            |
| `elementId`   | `String`    | FK → ThemeElement.id, required       | —        | The specific element that was applied                              |
| `entityType`  | `String`    | Required, max 50 chars               | —        | Schema entity type: `schema`, `table`, `column`, `index`, `constraint` |
| `entityId`    | `String`    | Required                             | —        | UUID of the schema entity that received the themed name            |
| `appliedName` | `String`    | Required, max 150 chars              | —        | Actual name applied including prefix/suffix (e.g., "tbl_dumbledore_2") |
| `selectedBy`  | `String`    | Required                             | —        | User ID who applied the name                                       |
| `selectedAt`  | `DateTime`  | Required                             | `now()`  | Timestamp of name application                                      |

**Relationships**:
- `guide` → `ThematicGuide` (many-to-one, FK on `guideId`, `onDelete: Cascade`)
- `element` → `ThemeElement` (many-to-one, FK on `elementId`, `onDelete: Cascade`)

**Validation rules**:
- `entityType`: must be one of `schema`, `table`, `column`, `index`, `constraint`
- `appliedName`: 1–150 characters, represents the final formatted name (research.md §3 — includes prefix and numeric suffix)
- `appliedName` should be unique within the same `entityType` + target scope (enforced at application layer, not DB constraint — see research.md §3 collision avoidance)
- On insert, the parent `ThemeElement.usageCount` must be incremented and `ThemeElement.lastUsedAt` updated within the same transaction

**LRU query support** (research.md §1):
```sql
SELECT te.id, te.element_text,
       COUNT(tur.id) AS times_used,
       MAX(tur.selected_at) AS last_used_at
FROM "theme_elements" te
LEFT JOIN "theme_usage_records" tur ON tur.element_id = te.id
WHERE te.guide_id = $1
GROUP BY te.id
ORDER BY COUNT(tur.id) ASC, MAX(tur.selected_at) ASC NULLS FIRST
LIMIT $2;
```

---

### AuditLog (existing)

**Purpose**: The existing `AuditLog` model records all entity lifecycle events. Thematic guide operations integrate with this model by using the `THEMATIC_GUIDE` entity type (requires extending the `EntityType` enum).

**No schema changes to AuditLog itself** — only the `EntityType` enum requires a new value.

**Integration pattern**:

| Operation                  | `entityType`       | `action`  | `changes` (JSON)                                             |
|----------------------------|--------------------|-----------|--------------------------------------------------------------|
| Guide created              | `THEMATIC_GUIDE`   | `CREATE`  | `{ name, themeCategory, elementCount }`                      |
| Guide updated              | `THEMATIC_GUIDE`   | `UPDATE`  | `{ field: { old, new } }` for each changed field             |
| Guide soft-deleted         | `THEMATIC_GUIDE`   | `DELETE`  | `{ name, elementCount, deletedAt }`                          |
| Guide restored             | `THEMATIC_GUIDE`   | `RESTORE` | `{ name, restoredAt }`                                       |
| Suggestion applied         | `THEMATIC_GUIDE`   | `UPDATE`  | `{ event: "SUGGESTION_APPLIED", guideId, elementId, appliedName, entityType, entityId }` |
| Guide exported             | `THEMATIC_GUIDE`   | `UPDATE`  | `{ event: "GUIDE_EXPORTED", exportFormat: "json", elementCount }` |
| Guide imported             | `THEMATIC_GUIDE`   | `CREATE`  | `{ event: "GUIDE_IMPORTED", elementCount, importSource }`    |

**References**: FR-015, constitution Principle II (audit trail for all modifications).

---

## Indexes & Query Optimization

All indexes are designed to support the query patterns identified in research.md.

### ThematicGuide indexes

| Index                                  | Purpose                                                       |
|----------------------------------------|---------------------------------------------------------------|
| `@@index([themeCategory])`             | Filter guides by category in theme browser (FR-010)           |
| `@@index([isActive])`                  | Filter active guides only                                     |
| `@@index([name])`                      | Search guides by name (FR-010, SC-009)                        |
| `@@index([createdBy])`                 | List guides created by a specific user                        |
| `@@index([deletedAt])`                 | Exclude soft-deleted records efficiently                      |

### ThemeElement indexes

| Index                                          | Purpose                                                          |
|------------------------------------------------|------------------------------------------------------------------|
| `@@unique([guideId, elementText])`             | Prevent duplicate element names within a guide (research.md §2)  |
| `@@index([guideId, usageCount, lastUsedAt])`   | LRU suggestion query — index scan for `ORDER BY usageCount ASC, lastUsedAt ASC NULLS FIRST` (research.md §1, §2) |
| `@@index([guideId, elementType])`              | Context-aware filtering by element type (research.md §3)        |

### ThemeLibraryItem indexes

| Index                    | Purpose                                          |
|--------------------------|--------------------------------------------------|
| `@@index([category])`   | Filter library by theme category                 |
| `@@index([name])`        | Search library by theme name (FR-010)            |

### ThemeUsageRecord indexes

| Index                                  | Purpose                                                       |
|----------------------------------------|---------------------------------------------------------------|
| `@@index([guideId, elementId])`        | Join for LRU query and per-element usage count (research.md §1) |
| `@@index([entityType, entityId])`      | Lookup usage records for a specific schema entity             |
| `@@index([selectedBy])`               | List usage records by user for audit/reporting                |
| `@@index([selectedAt])`               | Time-range queries for usage reporting                        |

---

## Prisma Schema

Complete Prisma model definitions following existing project conventions. These should be added to `src/backend/prisma/schema.prisma`.

```prisma
// ─── Thematic Naming Enums ───────────────────────────────────────────

enum ElementType {
  CHARACTER
  PLACE
  OBJECT
  CONCEPT
  OTHER
}

enum ThemeCategory {
  FICTION
  NATURE
  CULTURE
  CUSTOM
}

// ─── Thematic Naming Models ──────────────────────────────────────────

model ThematicGuide {
  id            String        @id @default(uuid())
  name          String        @unique @db.VarChar(100)
  description   String?       @db.VarChar(500)
  themeCategory ThemeCategory @default(CUSTOM) @map("theme_category")
  isBuiltIn     Boolean       @default(false) @map("is_built_in")
  isActive      Boolean       @default(true) @map("is_active")
  version       Int           @default(1)
  iconUrl       String?       @map("icon_url") @db.VarChar(255)
  createdBy     String        @map("created_by")
  createdAt     DateTime      @default(now()) @map("created_at")
  updatedAt     DateTime      @updatedAt @map("updated_at")
  deletedAt     DateTime?     @map("deleted_at")

  elements     ThemeElement[]
  usageRecords ThemeUsageRecord[]

  @@index([themeCategory])
  @@index([isActive])
  @@index([name])
  @@index([createdBy])
  @@index([deletedAt])
  @@map("thematic_guides")
}

model ThemeElement {
  id           String      @id @default(uuid())
  guideId      String      @map("guide_id")
  elementText  String      @map("element_text") @db.VarChar(100)
  elementType  ElementType @default(CHARACTER) @map("element_type")
  displayOrder Int         @default(0) @map("display_order")
  usageCount   Int         @default(0) @map("usage_count")
  lastUsedAt   DateTime?   @map("last_used_at")
  createdAt    DateTime    @default(now()) @map("created_at")

  guide        ThematicGuide    @relation(fields: [guideId], references: [id], onDelete: Cascade)
  usageRecords ThemeUsageRecord[]

  @@unique([guideId, elementText])
  @@index([guideId, usageCount, lastUsedAt])
  @@index([guideId, elementType])
  @@map("theme_elements")
}

model ThemeLibraryItem {
  id              String        @id @default(uuid())
  name            String        @unique @db.VarChar(100)
  category        ThemeCategory
  description     String?       @db.VarChar(500)
  iconUrl         String?       @map("icon_url") @db.VarChar(255)
  elementCount    Int           @default(0) @map("element_count")
  popularityScore Int           @default(0) @map("popularity_score")
  previewElements String[]      @map("preview_elements")
  seedElements    Json          @map("seed_elements")
  createdAt       DateTime      @default(now()) @map("created_at")

  @@index([category])
  @@index([name])
  @@map("theme_library_items")
}

model ThemeUsageRecord {
  id          String   @id @default(uuid())
  guideId     String   @map("guide_id")
  elementId   String   @map("element_id")
  entityType  String   @map("entity_type") @db.VarChar(50)
  entityId    String   @map("entity_id")
  appliedName String   @map("applied_name") @db.VarChar(150)
  selectedBy  String   @map("selected_by")
  selectedAt  DateTime @default(now()) @map("selected_at")

  guide   ThematicGuide @relation(fields: [guideId], references: [id], onDelete: Cascade)
  element ThemeElement  @relation(fields: [elementId], references: [id], onDelete: Cascade)

  @@index([guideId, elementId])
  @@index([entityType, entityId])
  @@index([selectedBy])
  @@index([selectedAt])
  @@map("theme_usage_records")
}
```

### Required change to existing EntityType enum

```prisma
enum EntityType {
  SERVER
  DATABASE
  TABLE
  ELEMENT
  ABBREVIATION
  USER
  THEMATIC_GUIDE    // ← new value for audit logging
}
```

---

## Validation Rules

Consolidated validation rules for API-layer enforcement (Zod schemas on backend, React Hook Form + Zod on frontend).

### ThematicGuide

| Field           | Rule                                                                 | Source  |
|-----------------|----------------------------------------------------------------------|---------|
| `name`          | Required, 1–100 chars, unique across non-deleted guides              | FR-001  |
| `description`   | Optional, max 500 chars                                              | FR-001  |
| `themeCategory` | Must be valid `ThemeCategory` enum value                             | FR-002  |
| `elements`      | Minimum 3 elements required on creation/activation                   | FR-001, US-1 scenario 4 |
| `version`       | Auto-incremented on update, minimum 1                                | FR-006  |
| `isBuiltIn`     | Cannot be set to `true` by user — system-managed only                | FR-002  |
| `createdBy`     | Must be a valid user ID with Admin role                              | FR-011  |

### ThemeElement

| Field          | Rule                                                                  | Source       |
|----------------|-----------------------------------------------------------------------|--------------|
| `elementText`  | Required, 1–100 chars, pattern `^[a-zA-Z][a-zA-Z0-9_ .-]*$`         | research.md §4 |
| `elementText`  | Unique within parent guide                                            | research.md §2 |
| `elementType`  | Must be valid `ElementType` enum value                                | research.md §2 |
| `displayOrder` | Non-negative integer                                                  | —            |
| `usageCount`   | Non-negative integer, system-managed (not user-settable)              | FR-007       |
| `lastUsedAt`   | System-managed (not user-settable)                                    | FR-007       |

### ThemeLibraryItem

| Field             | Rule                                                               | Source  |
|-------------------|--------------------------------------------------------------------|---------|
| `name`            | Required, 1–100 chars, unique                                      | FR-002  |
| `category`        | Must be valid `ThemeCategory` enum value (not CUSTOM)               | FR-002  |
| `previewElements` | Array of 3–5 string elements                                       | research.md §2 |
| `seedElements`    | JSON array, each item: `{ elementText, elementType, displayOrder }` | research.md §4 |
| `elementCount`    | Must match length of `seedElements` array                           | FR-009  |

### ThemeUsageRecord

| Field         | Rule                                                                 | Source       |
|---------------|----------------------------------------------------------------------|--------------|
| `entityType`  | Must be one of: `schema`, `table`, `column`, `index`, `constraint`   | FR-004       |
| `entityId`    | Must be a valid UUID of an existing schema entity                    | FK integrity |
| `appliedName` | Required, 1–150 chars                                                | research.md §2 |
| `selectedBy`  | Must be a valid user ID with Maintainer+ role                       | RBAC (research.md §Cross-Cutting) |

---

## State Transitions

### ThematicGuide Lifecycle

```
                    ┌─────────┐
        create      │  DRAFT  │   (isActive=false, elements < 3)
       ────────►    │         │
                    └────┬────┘
                         │ add ≥ 3 elements + activate
                         ▼
                    ┌─────────┐
                    │ ACTIVE  │   (isActive=true, deletedAt=null)
                    │         │◄──── restore (set deletedAt=null)
                    └────┬────┘
                    │    │
           edit     │    │ soft delete
  (version++)  ◄────┘    ▼
                    ┌──────────┐
                    │ DELETED  │   (deletedAt=timestamp)
                    │  (soft)  │
                    └──────────┘
```

**State definitions**:

| State    | Condition                            | Behavior                                |
|----------|--------------------------------------|-----------------------------------------|
| Draft    | `isActive = false`, `deletedAt = null` | Cannot be used for suggestions; editable |
| Active   | `isActive = true`, `deletedAt = null`  | Available for suggestions and export    |
| Deleted  | `deletedAt IS NOT NULL`               | Hidden from all queries; restorable by Admin |

**Transition rules**:
- Draft → Active: requires ≥ 3 elements, Admin role
- Active → Active: edit triggers `version++` and `updatedAt` update
- Active → Deleted: sets `deletedAt = now()`, Admin role required
- Deleted → Active: sets `deletedAt = null`, Admin role required (RESTORE audit action)
- Built-in guides (`isBuiltIn = true`): cannot transition to Deleted — only deactivated (`isActive = false`)

### ThemeElement (no lifecycle — immutable states)

Elements do not have independent lifecycle states. They are created with the guide and physically cascade-deleted when the guide is deleted. The `usageCount` and `lastUsedAt` fields are transactionally updated but do not represent state transitions.

---

## Cascade & Deletion Behavior

| Parent Entity    | Child Entity       | On Delete Behavior | Rationale                                                    |
|------------------|--------------------|---------------------|--------------------------------------------------------------|
| ThematicGuide    | ThemeElement       | **CASCADE**         | Elements have no meaning without their guide                 |
| ThematicGuide    | ThemeUsageRecord   | **CASCADE**         | Usage records reference the guide; orphaned records have no value |
| ThemeElement     | ThemeUsageRecord   | **CASCADE**         | Usage records reference the element; cascade maintains consistency |

**Soft delete scope**: Only `ThematicGuide` supports soft deletes (`deletedAt`). When a guide is soft-deleted:
- The guide and all its elements remain in the database but are excluded from queries via `WHERE deleted_at IS NULL`
- Usage records are preserved for historical audit purposes
- Cascade physical delete only occurs if an Admin permanently purges the record (future admin tooling)

**Constitution compliance**: Foreign key constraints enforce referential integrity at the database level (constitution Principle IV). `onDelete: Restrict` is NOT used for thematic entities because elements and usage records are fully owned by their parent guide — unlike the Server → Database → Table hierarchy where children have independent significance.

---

## Audit Trail Integration

All thematic guide operations are logged to the existing `AuditLog` table per constitution Principle II and FR-015.

### Audit events by operation

| Operation                   | AuditLog Fields                                                                                      |
|-----------------------------|------------------------------------------------------------------------------------------------------|
| Create guide                | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: CREATE`, `changes: { name, themeCategory, elementCount }` |
| Update guide                | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: UPDATE`, `changes: { field: { old, new } }` |
| Soft-delete guide           | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: DELETE`, `changes: { name }` |
| Restore guide               | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: RESTORE`, `changes: { name }` |
| Apply suggestion            | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: UPDATE`, `changes: { event: "SUGGESTION_APPLIED", elementId, appliedName, targetEntityType, targetEntityId }` |
| Export guide                | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: UPDATE`, `changes: { event: "GUIDE_EXPORTED", format: "json", elementCount }` |
| Import guide                | `entityType: THEMATIC_GUIDE`, `entityId: guide.id`, `action: CREATE`, `changes: { event: "GUIDE_IMPORTED", elementCount, source }` |

### Implementation pattern

Audit log creation should be performed within the same Prisma transaction as the primary operation:

```typescript
await prisma.$transaction([
  prisma.thematicGuide.create({ data: guideData }),
  prisma.auditLog.create({
    data: {
      entityType: 'THEMATIC_GUIDE',
      entityId: guideData.id,
      action: 'CREATE',
      userId: currentUser.id,
      changes: { name: guideData.name, themeCategory: guideData.themeCategory },
    },
  }),
]);
```

---

## Appendix: Built-in Theme Mapping

The 10 pre-populated `ThemeLibraryItem` records map to `ThemeCategory` as follows:

| Library Item     | `ThemeCategory` | Approximate Element Count |
|------------------|-----------------|---------------------------|
| Harry Potter     | `FICTION`        | 50+                       |
| Star Wars        | `FICTION`        | 60+                       |
| Mythology        | `FICTION`        | 40+                       |
| Fruit            | `NATURE`         | 30+                       |
| Animals          | `NATURE`         | 50+                       |
| Flowers          | `NATURE`         | 35+                       |
| Planets          | `NATURE`         | 40+                       |
| Musical Artists  | `CULTURE`        | 75+                       |
| Famous Artists   | `CULTURE`        | 40+                       |
| Colors           | `CULTURE`        | 40+                       |

**Total**: 460+ themed elements across 10 built-in themes (SC-011: "400+ total themed elements").
