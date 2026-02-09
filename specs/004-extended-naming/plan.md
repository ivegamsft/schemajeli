# Implementation Plan: Extended Naming

**Branch**: `004-extended-naming` | **Date**: February 8, 2026 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-extended-naming/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Extend SchemaJeli's naming ecosystem with a business glossary, cross-guide naming composition, naming lineage tracking, and extended element attributes (aliases, synonyms, tags, classifications). The business glossary maps technical database names to business-friendly terminology with many-to-many element links. The composition engine generates prioritized naming suggestions by combining active style guides, thematic guides, and industry guides into a single ranked list. Naming history provides an immutable audit trail of all element rename events. Extended attributes enrich schema elements with searchable aliases, synonyms, data steward assignments, and classification tags. Implementation spans backend (Prisma models, REST API endpoints, composition service) and frontend (glossary management UI, suggestion panel, history timeline, attribute editor).

## Technical Context

**Language/Version**: TypeScript 5.5 (Backend: Node.js 18+ LTS, Frontend: React 19)
**Primary Dependencies**: Backend: Express.js, Prisma 5.20+, Joi validation, Winston logging; Frontend: React 19, Vite, Zustand, React Hook Form, Zod, Tailwind CSS v4
**Storage**: PostgreSQL 15+ (via Prisma ORM with full-text search extensions)
**Testing**: Vitest (unit/integration), Playwright (E2E), React Testing Library + MSW (component/API mocking)
**Target Platform**: Web application deployed on Azure (Backend: Azure App Service, Frontend: Azure Static Web App)
**Project Type**: Web application (backend + frontend monorepo with separate package.json files)
**Performance Goals**: Glossary search <200ms, composition suggestions <500ms, naming history load <1s, unified search <500ms, bulk import 500 terms <10s
**Constraints**: Admin/Maintainer-only writes, 70% code coverage required, audit trail mandatory, soft deletes, immutable naming history
**Scale/Scope**: 100+ concurrent users, 10,000+ glossary terms, 1M+ element-term associations, multi-guide composition

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Security & Authentication ✅
- **Role enforcement**: Glossary write operations restricted to ADMIN and MAINTAINER roles (FR-011)
- **Azure Entra ID**: JWT authentication via existing MSAL integration — no new auth mechanisms needed
- **Audit trail**: All glossary term, link, and attribute operations logged with user, timestamp, action (FR-012)
- **Input validation**: Joi validation on all API endpoints; Zod validation on frontend forms
- **SQL injection prevention**: Prisma ORM with parameterized queries for all database access

### Testing Requirements ✅
- **70% code coverage minimum**: Unit tests for glossary service, composition engine, lineage service; integration tests for API endpoints
- **Test-Driven Development**: Tests written before implementation per constitution mandate
- **E2E tests**: User workflows for glossary CRUD, element linking, composed suggestions, history viewing

### Data Integrity ✅
- **Referential integrity**: Foreign keys for ElementGlossaryLink → GlossaryTerm, NamingHistory → Entity
- **Soft deletes**: GlossaryTerm and ExtendedAttribute use deletedAt timestamp — never physically deleted
- **Uniqueness**: Glossary term names unique per domain (FR-009)
- **Immutable history**: NamingHistory entries append-only, never modified or deleted
- **Circular reference prevention**: Synonym cycle detection before persisting relationships (FR-016)

### Technology Standards ✅
- **Backend**: Node.js 18+ LTS, Express.js, TypeScript strict mode, Prisma ORM
- **Frontend**: React 19, TypeScript strict mode, Vite, Zustand state management
- **Database**: PostgreSQL 15+ with Prisma migrations
- **API Design**: RESTful endpoints under `/api/v1/` prefix with standard response envelope
- **Logging**: Winston structured JSON logs

### Performance Targets ✅
- **Glossary search**: Typeahead results <200ms (SC-002)
- **Composition**: Multi-guide suggestions <500ms (SC-004)
- **Naming history**: Paginated load <1 second (SC-005)
- **Unified search**: Faceted results <500ms (SC-008)
- **Bulk import**: 500 terms with validation <10 seconds (SC-007)

### Observability ✅
- **Structured logging**: Winston JSON logs for all glossary and composition operations
- **Audit trail**: Complete change history via AuditLog table for all write operations (SC-009)
- **Error messages**: Clear, actionable validation errors for duplicate terms, circular synonyms, role violations

### Constitution Compliance: ✅ PASS
No violations detected. Feature aligns with all constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/004-extended-naming/
├── spec.md              # Feature specification
├── plan.md              # This file (/speckit.plan command output)
├── data-model.md        # Phase 1 output — Prisma schema additions
├── quickstart.md        # Phase 1 output — developer setup guide
├── contracts/           # Phase 1 output — API contract definitions
│   ├── glossary.yaml    # Glossary term CRUD endpoints
│   ├── composition.yaml # Cross-guide composition endpoints
│   ├── lineage.yaml     # Naming history endpoints
│   └── attributes.yaml  # Extended attribute endpoints
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
src/backend/
├── prisma/
│   ├── schema.prisma            # Add: GlossaryTerm, GlossaryTermSynonym,
│   │                            #   ElementGlossaryLink, NamingHistory,
│   │                            #   ExtendedAttribute, ComposedSuggestionLog
│   └── migrations/              # New migration for extended naming models
├── src/
│   ├── services/
│   │   ├── glossary.service.ts          # CRUD for glossary terms, synonym mgmt
│   │   ├── glossary-link.service.ts     # Element-term association management
│   │   ├── composition.service.ts       # Cross-guide suggestion engine
│   │   ├── naming-history.service.ts    # Immutable naming lineage recording
│   │   └── extended-attribute.service.ts # Alias/synonym/tag management
│   ├── routes/
│   │   ├── glossary.routes.ts           # /api/v1/glossary/* endpoints
│   │   ├── composition.routes.ts        # /api/v1/composition/* endpoints
│   │   ├── naming-history.routes.ts     # /api/v1/naming-history/* endpoints
│   │   └── extended-attributes.routes.ts # /api/v1/extended-attributes/* endpoints
│   └── validators/
│       ├── glossary.validator.ts        # Joi schemas for glossary input
│       └── extended-attribute.validator.ts # Joi schemas for attribute input
└── tests/
    ├── unit/
    │   ├── glossary.service.test.ts
    │   ├── composition.service.test.ts
    │   ├── naming-history.service.test.ts
    │   └── extended-attribute.service.test.ts
    └── integration/
        ├── glossary.routes.test.ts
        ├── composition.routes.test.ts
        └── naming-history.routes.test.ts

src/frontend/
├── src/
│   ├── components/
│   │   ├── glossary/
│   │   │   ├── GlossaryTermForm.tsx     # Create/edit glossary term form
│   │   │   ├── GlossaryTermList.tsx     # Paginated glossary term list
│   │   │   ├── GlossaryTermDetail.tsx   # Term detail with linked elements
│   │   │   ├── GlossarySearch.tsx       # Typeahead search component
│   │   │   └── GlossaryLinkPicker.tsx   # Element-term linking dialog
│   │   ├── composition/
│   │   │   ├── ComposedSuggestionPanel.tsx  # Multi-guide suggestion display
│   │   │   └── SuggestionCard.tsx           # Individual suggestion with source badge
│   │   ├── naming-history/
│   │   │   ├── NamingTimeline.tsx        # Chronological naming history
│   │   │   └── HistoryEntry.tsx          # Single history entry component
│   │   └── extended-attributes/
│   │       ├── AttributeEditor.tsx       # Alias/synonym/tag editor panel
│   │       ├── TagBadge.tsx              # Classification tag display
│   │       └── DataStewardField.tsx      # Data steward assignment
│   ├── pages/
│   │   ├── GlossaryPage.tsx             # Business glossary management page
│   │   └── NamingHistoryPage.tsx         # Naming lineage explorer page
│   ├── services/
│   │   ├── glossary.service.ts          # Axios API client for glossary
│   │   ├── composition.service.ts       # Axios API client for composition
│   │   ├── naming-history.service.ts    # Axios API client for history
│   │   └── extended-attribute.service.ts # Axios API client for attributes
│   └── stores/
│       └── glossaryStore.ts             # Zustand store for glossary state
└── tests/
    ├── components/
    │   ├── GlossaryTermForm.test.tsx
    │   ├── GlossaryTermList.test.tsx
    │   └── ComposedSuggestionPanel.test.tsx
    └── pages/
        └── GlossaryPage.test.tsx

tests/
└── frontend/e2e/
    ├── glossary.spec.ts                 # E2E: glossary CRUD workflow
    └── composition.spec.ts              # E2E: cross-guide suggestions
```

**Structure Decision**: Web application structure using the existing `src/backend/` and `src/frontend/` monorepo layout. New services and routes follow existing patterns (Express routes in `src/backend/src/`, React components in `src/frontend/src/components/`). All API routes prefixed `/api/v1/` per project convention. Note: current backend has all routes in `src/backend/src/index.ts` — this feature introduces route files for better modularity but should be registered from `index.ts`.

## Data Model Design

### New Prisma Models

```prisma
model GlossaryTerm {
  id          String    @id @default(uuid())
  name        String
  definition  String
  domain      String?
  status      EntityStatus @default(ACTIVE)
  createdBy   String
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")
  deletedAt   DateTime? @map("deleted_at")

  creator     User      @relation("GlossaryTermCreator", fields: [createdBy], references: [id])
  synonymsFrom GlossaryTermSynonym[] @relation("SynonymFrom")
  synonymsTo   GlossaryTermSynonym[] @relation("SynonymTo")
  elementLinks ElementGlossaryLink[]

  @@unique([name, domain])
  @@index([domain])
  @@index([deletedAt])
  @@map("glossary_terms")
}

model GlossaryTermSynonym {
  id              String   @id @default(uuid())
  termId          String   @map("term_id")
  synonymTermId   String   @map("synonym_term_id")
  relationshipType String  @default("synonym") @map("relationship_type")
  createdAt       DateTime @default(now()) @map("created_at")

  term        GlossaryTerm @relation("SynonymFrom", fields: [termId], references: [id], onDelete: Restrict)
  synonymTerm GlossaryTerm @relation("SynonymTo", fields: [synonymTermId], references: [id], onDelete: Restrict)

  @@unique([termId, synonymTermId])
  @@map("glossary_term_synonyms")
}

model ElementGlossaryLink {
  id              String    @id @default(uuid())
  glossaryTermId  String    @map("glossary_term_id")
  entityType      EntityType
  entityId        String    @map("entity_id")
  linkedBy        String    @map("linked_by")
  linkedAt        DateTime  @default(now()) @map("linked_at")
  unlinkedAt      DateTime? @map("unlinked_at")

  glossaryTerm GlossaryTerm @relation(fields: [glossaryTermId], references: [id], onDelete: Restrict)
  linker       User         @relation("ElementGlossaryLinker", fields: [linkedBy], references: [id])

  @@index([entityType, entityId])
  @@index([glossaryTermId])
  @@map("element_glossary_links")
}

model NamingHistory {
  id                 String    @id @default(uuid())
  entityType         EntityType
  entityId           String    @map("entity_id")
  previousName       String    @map("previous_name")
  newName            String    @map("new_name")
  changedBy          String    @map("changed_by")
  changedAt          DateTime  @default(now()) @map("changed_at")
  sourceGuideId      String?   @map("source_guide_id")
  sourceGuideVersion String?   @map("source_guide_version")
  reason             String?

  changer User @relation("NamingHistoryChanger", fields: [changedBy], references: [id])

  @@index([entityType, entityId, changedAt])
  @@map("naming_history")
}

model ExtendedAttribute {
  id             String    @id @default(uuid())
  entityType     EntityType
  entityId       String    @map("entity_id")
  attributeType  String    @map("attribute_type")
  attributeValue String    @map("attribute_value")
  createdBy      String    @map("created_by")
  createdAt      DateTime  @default(now()) @map("created_at")
  deletedAt      DateTime? @map("deleted_at")

  creator User @relation("ExtendedAttributeCreator", fields: [createdBy], references: [id])

  @@index([entityType, entityId, attributeType])
  @@index([deletedAt])
  @@map("extended_attributes")
}

model ComposedSuggestionLog {
  id                   String   @id @default(uuid())
  entityType           EntityType
  entityId             String   @map("entity_id")
  selectedName         String   @map("selected_name")
  contributingGuideIds Json     @map("contributing_guide_ids")
  selectedBy           String   @map("selected_by")
  selectedAt           DateTime @default(now()) @map("selected_at")

  selector User @relation("ComposedSuggestionSelector", fields: [selectedBy], references: [id])

  @@index([entityType, entityId])
  @@map("composed_suggestion_logs")
}
```

### Key Design Decisions

1. **GlossaryTerm uniqueness scoped to domain**: `@@unique([name, domain])` allows the same term name in different business domains (e.g., "Account" in Finance vs. "Account" in Auth)
2. **EntityType reuse**: Leverages existing `EntityType` enum (SERVER, DATABASE, TABLE, ELEMENT, etc.) for polymorphic entity references
3. **NamingHistory immutability**: No `updatedAt` or `deletedAt` fields — entries are append-only
4. **ExtendedAttribute flexibility**: `attributeType` is a string (not enum) to allow future attribute types without schema migration
5. **ComposedSuggestionLog JSON field**: `contributingGuideIds` stored as JSON array since guide types may vary
6. **Soft deletes on GlossaryTerm**: Uses `deletedAt` per constitution mandate; ElementGlossaryLink uses `unlinkedAt` for association soft-delete

## API Contract Overview

### Glossary Term Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST   | `/api/v1/glossary` | Create glossary term | Admin, Maintainer |
| GET    | `/api/v1/glossary` | List/search glossary terms (paginated) | All roles |
| GET    | `/api/v1/glossary/:id` | Get glossary term detail | All roles |
| PUT    | `/api/v1/glossary/:id` | Update glossary term | Admin, Maintainer |
| DELETE | `/api/v1/glossary/:id` | Soft-delete glossary term | Admin |
| POST   | `/api/v1/glossary/import` | Bulk import from CSV/JSON | Admin |
| GET    | `/api/v1/glossary/export` | Export all terms as JSON | Admin, Maintainer |

### Element-Glossary Link Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST   | `/api/v1/glossary-links` | Link term to element | Admin, Maintainer |
| GET    | `/api/v1/glossary-links?entityType=TABLE&entityId=:id` | Get links for element | All roles |
| DELETE | `/api/v1/glossary-links/:id` | Soft-unlink term from element | Admin, Maintainer |

### Composition Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST   | `/api/v1/composition/suggest` | Generate cross-guide suggestions | All roles |
| POST   | `/api/v1/composition/accept` | Record accepted suggestion | Admin, Maintainer |

### Naming History Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET    | `/api/v1/naming-history?entityType=TABLE&entityId=:id` | Get naming history (paginated) | All roles |

### Extended Attribute Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST   | `/api/v1/extended-attributes` | Add attribute to element | Admin, Maintainer |
| GET    | `/api/v1/extended-attributes?entityType=TABLE&entityId=:id` | Get attributes for element | All roles |
| PUT    | `/api/v1/extended-attributes/:id` | Update attribute | Admin, Maintainer |
| DELETE | `/api/v1/extended-attributes/:id` | Soft-delete attribute | Admin, Maintainer |

### Standard Response Envelope

All endpoints use the existing response envelope pattern:
```json
{
  "status": "success",
  "data": { ... },
  "message": "Optional message"
}
```

Paginated responses include:
```json
{
  "status": "success",
  "data": [...],
  "total": 150,
  "page": 1,
  "limit": 25,
  "totalPages": 6
}
```

## Implementation Phases

### Phase 1: Database Schema & Models (Backend)
- Add new Prisma models (GlossaryTerm, GlossaryTermSynonym, ElementGlossaryLink, NamingHistory, ExtendedAttribute, ComposedSuggestionLog)
- Run `prisma migrate dev` to generate migration
- Add User relations for new models
- Create seed data for glossary terms (test data)

### Phase 2: Backend Services & API (Backend)
- Glossary service: CRUD, search with typeahead, synonym management with cycle detection
- Glossary link service: link/unlink terms to elements
- Naming history service: append-only recording, paginated retrieval
- Extended attribute service: CRUD for aliases/tags/steward/notes
- Composition service: multi-guide suggestion engine with priority ranking
- Joi validators for all input
- Route registration in index.ts

### Phase 3: Frontend Components & Pages (Frontend)
- Glossary management page (list, create, edit, search)
- Glossary term detail with linked elements
- Element detail integration (show linked glossary terms, extended attributes)
- Composed suggestion panel for naming workflows
- Naming history timeline component
- Attribute editor panel (aliases, tags, steward, classification)
- Zustand store for glossary state management

### Phase 4: Integration & Polish
- Unified search extension to include glossary terms, aliases, tags
- Bulk import/export for glossary terms
- E2E tests for key workflows
- Performance optimization (indexes, query optimization)
- Accessibility review (WCAG 2.1 AA)

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations detected. All design decisions align with constitution principles.

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| Polymorphic entity references | `entityType` + `entityId` pattern | Avoids separate link tables per entity type; consistent with existing AuditLog pattern |
| attributeType as string (not enum) | Flexibility for future attribute types | Avoids Prisma migration for each new attribute type; validated at application layer |
| JSON field for contributingGuideIds | Array of guide IDs stored as JSON | Guide types may vary; avoids separate junction table for a logging concern |
