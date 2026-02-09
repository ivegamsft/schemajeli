# Implementation Plan: Industry Naming Standards

**Branch**: `003-industry-naming` | **Date**: 2026-02-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-industry-naming/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Enable teams to create and apply industry-standard naming conventions (Healthcare HL7/FHIR, Finance FIX/ISO 20022, Legal LEDES, Manufacturing ISA-95, Insurance ACORD, Retail GS1, Telecom TMForum, Government NIEM) to database schemas. Users select from 8 pre-built industry standards or create custom guides, then generate domain-appropriate naming suggestions for tables, columns, and other schema elements. Implementation requires Prisma schema extensions for industry guide entities, REST API endpoints for CRUD operations on industry guides, an industry standards library browser, a naming suggestion engine with reserved-word detection, and role-based access control restricting guide management to Admins. The architecture closely parallels the thematic naming feature (002) with added support for standard versioning, regulatory references, compliance notes, and RDBMS-reserved word conflict detection.

## Technical Context

**Language/Version**: TypeScript 5.5+ with Node.js 18+ LTS  
**Primary Dependencies**: Express.js (backend API), React 19 (frontend SPA), Prisma ORM (database), Azure MSAL (authentication), Zustand (state management), Zod + React Hook Form (validation)  
**Storage**: PostgreSQL 15+ with Prisma migrations  
**Testing**: Vitest (backend unit/integration), React Testing Library + MSW (frontend), Playwright (E2E)  
**Target Platform**: Web application — Azure App Service (backend) + Azure Static Web App (frontend)  
**Project Type**: Web (backend API + frontend SPA)  
**Performance Goals**: API response <500ms p95, naming suggestions <500ms, standards library load <1s, search/filter <1s  
**Constraints**: Admin-only guide creation/editing (RBAC), 100+ concurrent users, all operations with audit trail, soft deletes only, RDBMS-reserved word detection across 6 platforms  
**Scale/Scope**: 8 pre-built industry standards with 385+ terms total, support for unlimited custom guides, term cycling for 1000+ suggestions, export/import JSON format, standard versioning

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Security & Authentication ✅
- **Admin-only operations**: All industry guide management (CRUD) restricted to ADMIN role (FR-012)
- **Azure Entra ID**: JWT authentication via existing MSAL integration — no local passwords
- **Audit trail**: All operations logged with user, timestamp, action (FR-017)
- **Input validation**: Zod validation on all API endpoints and forms; minimum 5 terms enforced (FR-001)
- **SQL injection prevention**: Prisma ORM with parameterized queries throughout
- **Reserved word detection**: RDBMS-reserved word conflicts flagged before suggestions committed (FR-016)

### Testing Requirements ✅
- **70% code coverage minimum**: Unit tests for suggestion engine, term cycling, reserved-word detection; integration tests for API contracts
- **Test-Driven Development**: Tests written before implementation per constitution mandate
- **E2E tests**: User workflows for create guide, apply suggestions, browse standards, export/import

### Data Integrity ✅
- **Referential integrity**: Foreign keys for IndustryTermUsageRecord → IndustryGuide → IndustryTerm
- **Soft deletes**: All industry guides and terms use deletedAt timestamp — no physical deletion
- **Uniqueness**: Guide names unique; terms unique within guide
- **Standard versioning**: Guides reference specific standard versions (e.g., HL7 FHIR R4 vs. R5)

### Technology Standards ✅
- **Backend**: Node.js 18+ LTS, Express.js, TypeScript strict mode, Prisma ORM
- **Frontend**: React 19, TypeScript strict mode, Vite, Zustand, Tailwind CSS v4
- **Database**: PostgreSQL 15+ (via Prisma migrations)
- **API Design**: RESTful with `/api/v1/` prefix, standard response envelope `{ status, data?, message? }`
- **Logging**: Winston structured JSON logs to Application Insights

### Performance Targets ✅
- **Suggestion generation**: <500ms for any schema element (SC-003)
- **Standards library**: 8+ standards load <1 second (SC-002)
- **Search/filter**: Results in <1 second (SC-009)
- **Guide creation**: Built-in standard → guide + first suggestions <3 seconds (SC-004)
- **Simple queries**: <100ms per constitution requirement

### Observability ✅
- **Structured logging**: Winston JSON logs for all industry guide operations
- **Audit trail**: Complete change history with user, timestamp, action, change summary (SC-008)
- **Error messages**: Clear and actionable validation errors (reserved word conflicts, minimum term count)

### Constitution Compliance: ✅ PASS
No violations detected. Feature aligns with all constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/003-industry-naming/
├── spec.md              # Feature specification
├── plan.md              # This file (/speckit.plan command output)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
src/backend/
├── prisma/
│   ├── schema.prisma                     # Add IndustryGuide, IndustryTerm, IndustryStandard models
│   ├── migrations/                       # New migration for industry naming tables
│   └── seed-industry-standards.ts        # Seed data for 8 built-in industry standards (385+ terms)
├── src/
│   ├── index.ts                          # Add industry guide API routes (/api/v1/industry-guides/*)
│   ├── services/
│   │   ├── industryGuideService.ts       # CRUD business logic for industry guides
│   │   ├── industrySuggestionService.ts  # Naming suggestion engine with term cycling
│   │   └── reservedWordService.ts        # RDBMS-reserved word detection across 6 platforms
│   ├── validators/
│   │   └── industryGuideValidator.ts     # Zod schemas for guide creation/update
│   └── middleware/
│       └── auth.ts                       # Existing — reuse authenticateJWT + requireRole
└── tests/
    ├── services/
    │   ├── industryGuideService.test.ts
    │   ├── industrySuggestionService.test.ts
    │   └── reservedWordService.test.ts
    └── routes/
        └── industryGuides.test.ts        # Integration tests for API endpoints

src/frontend/
├── src/
│   ├── components/
│   │   └── industry/
│   │       ├── IndustryStandardsLibrary.tsx   # Standards gallery/browser
│   │       ├── IndustryGuideDetail.tsx        # Guide detail view
│   │       ├── IndustryGuideForm.tsx          # Create/edit guide form
│   │       ├── IndustrySuggestionPanel.tsx    # Naming suggestion display
│   │       ├── IndustryTermList.tsx           # Term list with categories
│   │       └── IndustryGuideExport.tsx        # Export/import controls
│   ├── pages/
│   │   ├── IndustryStandardsPage.tsx          # Standards library page
│   │   └── IndustryGuideDetailPage.tsx        # Individual guide page
│   ├── services/
│   │   └── industryGuideService.ts            # Axios API client for industry guides
│   ├── stores/
│   │   └── industryGuideStore.ts              # Zustand store for industry guide state
│   └── types/
│       └── industryGuide.ts                   # TypeScript interfaces for industry entities
└── tests/
    └── components/
        └── industry/
            ├── IndustryStandardsLibrary.test.tsx
            ├── IndustryGuideForm.test.tsx
            └── IndustrySuggestionPanel.test.tsx

tests/frontend/e2e/
└── industry-naming.spec.ts                    # Playwright E2E tests
```

**Structure Decision**: Web application structure (Option 2) with separate backend (`src/backend/`) and frontend (`src/frontend/`) apps, consistent with existing repository layout. Industry naming feature adds new Prisma models, backend services, and frontend components following established patterns from servers/databases/tables CRUD and the thematic naming feature (002).

## Data Model (High-Level)

### New Prisma Models

```
IndustryStandard (built-in templates)
├── id: UUID
├── name: String (unique)
├── industrySector: String
├── description: String
├── regulatoryBody: String?
├── standardVersion: String
├── iconUrl: String?
├── termCount: Int
├── createdAt: DateTime
└── terms: IndustryStandardTerm[]

IndustryStandardTerm (template terms)
├── id: UUID
├── standardId: UUID → IndustryStandard
├── termText: String
├── termCategory: Enum (ENTITY, ATTRIBUTE, RELATIONSHIP)
├── definition: String?
└── regulatoryReference: String?

IndustryGuide (user-created guides)
├── id: UUID
├── name: String (unique)
├── description: String?
├── industrySector: String
├── standardReference: String?
├── standardVersion: String?
├── complianceNotes: String?
├── source: Enum (BUILT_IN, CUSTOM, CUSTOMIZED)
├── sourceStandardId: UUID? → IndustryStandard
├── version: Int (default 1)
├── isActive: Boolean (default true)
├── createdById: UUID → User
├── createdAt: DateTime
├── updatedAt: DateTime
├── deletedAt: DateTime? (soft delete)
└── terms: IndustryGuideTerm[]

IndustryGuideTerm (guide terms)
├── id: UUID
├── guideId: UUID → IndustryGuide
├── termText: String
├── termCategory: Enum (ENTITY, ATTRIBUTE, RELATIONSHIP)
├── definition: String?
├── regulatoryReference: String?
├── frequencyUsed: Int (default 0)
├── lastUsedAt: DateTime?
├── createdAt: DateTime
└── deletedAt: DateTime? (soft delete)

IndustryTermUsage (usage tracking)
├── id: UUID
├── guideId: UUID → IndustryGuide
├── termId: UUID → IndustryGuideTerm
├── entityType: Enum (TABLE, COLUMN, INDEX, CONSTRAINT)
├── entityId: UUID
├── selectedById: UUID → User
└── selectedAt: DateTime
```

### API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/industry-standards` | Any | List built-in industry standards |
| GET | `/api/v1/industry-standards/:id` | Any | Get standard detail with terms |
| GET | `/api/v1/industry-guides` | Any | List user-created guides (paginated) |
| GET | `/api/v1/industry-guides/:id` | Any | Get guide detail with terms |
| POST | `/api/v1/industry-guides` | Admin | Create guide (from standard or custom) |
| PUT | `/api/v1/industry-guides/:id` | Admin | Update guide |
| DELETE | `/api/v1/industry-guides/:id` | Admin | Soft-delete guide |
| POST | `/api/v1/industry-guides/:id/suggestions` | Any | Generate naming suggestions |
| POST | `/api/v1/industry-guides/:id/terms` | Admin | Add terms to guide |
| DELETE | `/api/v1/industry-guides/:id/terms/:termId` | Admin | Remove term from guide |
| GET | `/api/v1/industry-guides/:id/export` | Any | Export guide as JSON |
| POST | `/api/v1/industry-guides/import` | Admin | Import guide from JSON |
| POST | `/api/v1/industry-guides/check-reserved-words` | Any | Check terms against RDBMS reserved words |

### Suggestion Engine Design

The naming suggestion engine generates domain-appropriate names by:

1. **Term matching**: Match schema element context (table purpose, column data type) to industry terms by category
2. **Pattern application**: Apply naming patterns per element type (e.g., `tbl_{term}`, `col_{term}_{qualifier}`)
3. **Term cycling**: When terms are exhausted, cycle with contextual suffixes (e.g., `tbl_patient_demographics`, `tbl_patient_history`)
4. **Reserved word detection**: Check generated names against RDBMS-reserved word lists for the target platform
5. **Usage tracking**: Track which terms have been used and when, prioritizing less-used terms in suggestions

### Reserved Word Detection

Maintain curated reserved-word lists for each supported RDBMS platform:
- PostgreSQL, MySQL, Oracle, DB2, Informix, SQL Server

When generating suggestions, cross-reference against the target RDBMS reserved words and flag conflicts with alternative suggestions.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *None* | Constitution check passed | N/A |
