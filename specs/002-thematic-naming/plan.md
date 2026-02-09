# Implementation Plan: Thematic Naming Guide

**Branch**: `002-thematic-naming` | **Date**: February 8, 2026 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-thematic-naming/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Enable teams to create and use themed naming guides that provide pre-defined, themed naming conventions for schema elements. Users can choose from 10 built-in themes (Harry Potter, Star Wars, fruits, animals, etc.) or create custom themes with their own element lists. The system generates contextually-themed naming suggestions for database tables, columns, and other schema elements, making naming fun, memorable, and consistent while maintaining team identity. Implementation requires REST API endpoints for CRUD operations on thematic guides, a theme library browser, naming suggestion engine with element cycling, and role-based access control restricting guide management to Admins.

## Technical Context

**Language/Version**: TypeScript 5.5+ with Node.js 18+ LTS  
**Primary Dependencies**: Express.js (backend), React 19 (frontend), Prisma ORM (database), Azure MSAL (authentication)  
**Storage**: PostgreSQL 15+ with Prisma migrations  
**Testing**: Vitest (backend unit/integration), Playwright (E2E)  
**Target Platform**: Web application - Azure App Service (backend) + Azure Static Web App (frontend)  
**Project Type**: Web (backend API + frontend SPA)  
**Performance Goals**: API response <500ms p95, naming suggestions <500ms, theme gallery load <1s  
**Constraints**: Admin-only guide creation/editing (RBAC), 100+ concurrent users, theme search <1s, all operations with audit trail  
**Scale/Scope**: 10 pre-built themes with 400+ elements total, support for unlimited custom themes, element cycling for 1000+ suggestions, export/import JSON format

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Security-First (NON-NEGOTIABLE)
- ✅ **Authentication/Authorization**: All endpoints protected with Azure Entra ID JWT validation (MSAL)
- ✅ **RBAC Enforcement**: Theme guide creation/modification/deletion restricted to Admin role only
- ✅ **Input Validation**: Joi schema validation for all theme creation and editing endpoints
- ✅ **SQL Injection Prevention**: Prisma ORM with parameterized queries
- ✅ **Audit Trail**: All CRUD operations on thematic guides logged to AuditLog table with user, timestamp, action, changes

### Test-Driven Development (MANDATORY)
- ✅ **Minimum 70% Coverage**: Target set for all theme services and API endpoints
- ✅ **Test Types**: Unit tests (naming engine, element cycling), integration tests (API contracts), E2E tests (theme creation workflow, naming suggestion flow)
- ✅ **Test-First Approach**: Tests written before implementation for all functional requirements

### Data Integrity & Parent-Child Relationships
- ✅ **Relational Hierarchy**: ThematicGuide → ThemeElement (one-to-many) enforced with foreign keys
- ✅ **Cascade Deletion**: ThemeElement records cascade delete when parent ThematicGuide is deleted
- ✅ **No Orphaned Records**: Foreign key constraints prevent orphaned theme elements
- ✅ **Soft Deletes**: ThematicGuide includes deletedAt for audit compliance

### User-Centric Development
- ✅ **User Validation**: Theme browser and preview functionality validates usability before commitment
- ✅ **Error Messages**: Clear validation messages for minimum element count, permission errors, naming conflicts
- ✅ **Help Documentation**: Theme creation wizard with contextual help and examples
- ✅ **No Breaking Changes**: New feature addition - no existing API contracts modified

### Observability & Monitoring
- ✅ **Structured Logging**: Winston logs for all theme operations (create, apply, export) with request context
- ✅ **Performance Metrics**: Timing logs for naming suggestion generation and theme search
- ✅ **Health Checks**: Database connectivity checks include theme-related tables
- ✅ **Error Tracking**: All theme service errors logged with stack traces to Application Insights

### Rebranding Completeness
- ✅ **SchemaJeli Branding**: All UI components, API documentation, error messages use SchemaJeli branding
- ✅ **No Legacy References**: Feature is new - no legacy "CompanyName" references

### Architecture & Technology Standards
- ✅ **Backend**: Node.js 18+ LTS with Express.js and TypeScript
- ✅ **Frontend**: React 19 with TypeScript
- ✅ **Database**: PostgreSQL 15+ via Prisma ORM
- ✅ **API Design**: REST with OpenAPI 3.0 specification for theme endpoints
- ✅ **Authentication**: Azure Entra ID (MSAL) with JWT validation
- ✅ **Logging**: Structured JSON logs via Winston to Application Insights

### Performance & Scalability
- ✅ **Response Times**: Theme search <1s, naming suggestions <500ms (per SC-003, SC-009)
- ✅ **Scalability**: Stateless API design for horizontal scaling, connection pooling for database
- ✅ **Caching**: Optional Redis caching for built-in theme library (static data)

### Quality Assurance
- ✅ **Testing Coverage**: Unit, integration, E2E tests for all 6 user stories
- ✅ **Accessibility**: WCAG 2.1 AA compliance for theme browser UI
- ✅ **Security Testing**: OWASP ZAP scans for theme API endpoints

**GATE STATUS**: ✅ **PASSED** - All constitution principles satisfied. No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Web application structure (backend API + frontend SPA)

src/backend/
├── src/
│   ├── models/
│   │   └── (existing Prisma models)
│   ├── services/
│   │   ├── thematicGuideService.ts      # CRUD operations for guides
│   │   ├── themeLibraryService.ts       # Built-in theme management
│   │   ├── namingSuggestionService.ts   # Name generation engine
│   │   └── themeExportService.ts        # JSON export/import
│   ├── middleware/
│   │   ├── auth.ts                       # (existing) JWT validation
│   │   └── rbac.ts                       # NEW: Admin-only route guard
│   └── routes/
│       └── thematicGuides.ts             # NEW: Theme API endpoints
├── prisma/
│   ├── schema.prisma                     # EXTEND: Add theme entities
│   ├── migrations/                       # NEW: Theme table migrations
│   └── seed.ts                           # EXTEND: Seed built-in themes
└── tests/
    ├── unit/
    │   ├── thematicGuideService.test.ts
    │   ├── namingSuggestionService.test.ts
    │   └── themeLibraryService.test.ts
    └── integration/
        └── thematicGuidesAPI.test.ts

src/frontend/
├── src/
│   ├── components/
│   │   ├── themes/
│   │   │   ├── ThemeLibraryBrowser.tsx  # US-4: Browse themes
│   │   │   ├── ThemeCreationWizard.tsx  # US-1, US-2: Create guide
│   │   │   ├── ThemeCustomizer.tsx      # US-5: Customize theme
│   │   │   ├── NamingSuggestionPanel.tsx # US-3: Apply and suggest
│   │   │   └── ThemeExportDialog.tsx    # US-6: Export/import
│   │   └── (existing components)
│   ├── pages/
│   │   └── ThematicGuidesPage.tsx       # Main theme management page
│   ├── services/
│   │   └── thematicGuideAPI.ts          # API client for theme endpoints
│   └── hooks/
│       ├── useThemeLibrary.ts           # Fetch and cache themes
│       └── useNamingSuggestions.ts      # Generate name suggestions
└── tests/
    └── e2e/
        ├── theme-creation.spec.ts        # US-1, US-2
        ├── naming-suggestions.spec.ts    # US-3
        ├── theme-browser.spec.ts         # US-4
        ├── theme-customization.spec.ts   # US-5
        └── theme-export.spec.ts          # US-6

tests/ (root - E2E tests)
└── thematic-naming/
    └── (Playwright E2E tests referenced above)
```

**Structure Decision**: Follows existing web application architecture with backend/frontend separation. Theme functionality integrated into established patterns:
- Backend services extend existing service layer (alongside oboClient.ts)
- Frontend components organized under `themes/` subdirectory for clear feature isolation
- Prisma schema extended with new theme-related models (ThematicGuide, ThemeElement, ThemeLibraryItem, ThemeUsageRecord)
- Testing mirrors existing structure (Vitest for backend, Playwright for E2E)
- All routes protected by existing auth.ts middleware, enhanced with new rbac.ts for Admin-only operations

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**NO VIOLATIONS** - This section is empty because all constitution gates passed. The thematic naming feature introduces no additional complexity beyond standard patterns already established in the SchemaJeli codebase:
- Standard CRUD operations following existing service patterns
- RBAC enforcement using existing authentication infrastructure
- Prisma ORM models extending existing schema conventions
- REST API endpoints following established Express.js routing patterns
- React components following established component structure

---

## Phase 0: Research (Completed)

**Artifact**: [research.md](./research.md) - 491 lines

**Key Decisions**:
1. **Element Cycling**: LRU selection first, then numeric suffixing (`_2`, `_3`...) for maximum diversity
2. **Data Structure**: Partially normalized Prisma schema with denormalized `usageCount`/`lastUsedAt` for <500ms performance
3. **Suggestion Algorithm**: 3-stage pipeline (Filter→Rank→Format) with weighted scoring, ~3ms expected latency
4. **Export/Import**: Self-describing JSON envelope with JSON Schema validation, semver versioning, SHA-256 checksum

All NEEDS CLARIFICATION items from Technical Context resolved.

---

## Phase 1: Design & Contracts (Completed)

**Artifacts**:
- [data-model.md](./data-model.md) - Complete entity definitions, Prisma schema, validation rules, indexes
- [contracts/](./contracts/) - 5 OpenAPI 3.0 YAML files covering 15 endpoints across 4 API surfaces
- [quickstart.md](./quickstart.md) - Developer onboarding guide with setup steps, workflow, and testing

**Data Model Summary**:
- **4 new entities**: ThematicGuide, ThemeElement, ThemeLibraryItem, ThemeUsageRecord
- **2 new enums**: ThemeCategory (BUILT_IN, CUSTOM), ElementType (CHARACTER, PLACE, OBJECT, GENERIC)
- **Foreign keys**: ThemeElement → ThematicGuide (cascade delete), ThemeUsageRecord → ThematicGuide + ThemeElement
- **Soft deletes**: ThematicGuide.deletedAt (audit compliance)
- **Performance indexes**: 7 indexes for search, filtering, LRU queries

**API Contract Summary**:
- **15 endpoints** across 4 contract files
- **RBAC enforcement**: Admin-only mutations, Viewer+ reads
- **Performance SLOs**: <500ms naming suggestions, <1s theme search (documented in OpenAPI descriptions)
- **Requirements traceability**: All 15 FR requirements and 4 success criteria mapped to specific endpoints

**Agent Context**: Updated GitHub Copilot instructions with TypeScript/Express/Prisma/React stack

### Constitution Check Re-Evaluation (Post-Phase 1)

All design artifacts reviewed against constitution principles:

- ✅ **Security-First**: Confirmed in contracts - all endpoints require JWT, Admin-only mutations, Joi validation schemas
- ✅ **Data Integrity**: Confirmed in data-model.md - foreign keys, cascade deletes, no orphans, soft deletes
- ✅ **Test-Driven**: Confirmed in quickstart.md - test file paths specified, 70% coverage target documented
- ✅ **Observability**: Confirmed in contracts - structured error responses, audit trail endpoints
- ✅ **Performance**: Confirmed in research.md - algorithm complexity analysis shows <500ms target achievable

**GATE STATUS**: ✅ **RE-VALIDATED PASSED** - All Phase 1 designs comply with constitution. Ready for Phase 2 task generation.

---

## Next Steps

**Phase 2 (NOT executed by this command)**: Run `/speckit.tasks` to generate actionable tasks.md based on the artifacts above. The tasks command will:
- Create dependency-ordered implementation tasks
- Break down services, routes, components, and tests
- Define acceptance criteria per task
- Generate task graph for parallel execution where possible

**Implementation**: After tasks.md is generated, run `/speckit.implement` to execute the implementation plan.
