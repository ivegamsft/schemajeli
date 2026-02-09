# Implementation Plan: Style Guide Management

**Branch**: `001-style-guides` | **Date**: 2026-02-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-style-guides/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Enable administrators to create, import, modify, and apply reusable style guides for database naming conventions. Style guides enforce consistent naming patterns across databases, tables, columns, and schema elements. System validates schemas against style guides and reports violations with correction suggestions. All operations maintain audit trail for compliance and governance.

## Technical Context

**Language/Version**: TypeScript 5.5 (Backend: Node.js 18+ LTS, Frontend: React 19)  
**Primary Dependencies**: Backend: Express.js, Prisma, Joi validation, Winston logging; Frontend: React 19, Vite, Zustand, React Hook Form, Zod  
**Storage**: PostgreSQL 15+ (via Prisma ORM)  
**Testing**: Vitest (unit/integration), Playwright (E2E), React Testing Library (component)  
**Target Platform**: Web application deployed on Azure (Backend: Azure App Service, Frontend: Azure Static Web App)  
**Project Type**: Web application (backend + frontend)  
**Performance Goals**: API response <500ms p95, validation of 1000-table schema <5 seconds, list view loads 50 guides <1 second  
**Constraints**: Admin-only operations, 70% code coverage required, audit trail mandatory, soft deletes  
**Scale/Scope**: 100+ concurrent users, support for style guides with 1000+ naming rules, multi-database platform support

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Security & Authentication ✅
- **Admin-only operations**: All style guide management (CRUD) operations restricted to ADMIN role (FR-012)
- **Azure Entra ID**: JWT authentication via existing MSAL integration
- **Audit trail**: All operations logged with user, timestamp, action (FR-009)
- **Input validation**: Joi/Zod validation on all API endpoints and forms
- **SQL injection prevention**: Prisma ORM with parameterized queries

### Testing Requirements ✅
- **70% code coverage minimum**: Unit tests for business logic, integration tests for API contracts
- **Test-Driven Development**: Tests written before implementation
- **E2E tests**: User workflows for create, import, modify, validate, export

### Data Integrity ✅
- **Referential integrity**: Foreign keys for StyleGuideUsage → StyleGuide
- **Soft deletes**: All style guides use deletedAt timestamp
- **Uniqueness**: Style guide names must be unique (FR-002)
- **Prevent deletion of in-use guides**: System blocks deletion when guide is applied to resources (FR-007, SC-006)

### Technology Standards ✅
- **Backend**: Node.js 18+ LTS, Express.js, TypeScript, Prisma
- **Frontend**: React 19, TypeScript, Vite, Zustand
- **Database**: PostgreSQL 15+ (via Prisma)
- **API Design**: RESTful with OpenAPI 3.0 specification
- **Logging**: Winston structured JSON logs to Application Insights

### Performance Targets ✅
- **Validation**: 1000-table schema validation <5 seconds (SC-003)
- **List view**: 50 guides load <1 second with pagination (SC-004)
- **Import**: JSON/YAML import <2 seconds (SC-002)
- **Response time**: API endpoints <500ms p95

### Observability ✅
- **Structured logging**: Winston JSON logs for all operations
- **Audit trail**: Complete change history with user, timestamp, action (SC-005)
- **Error messages**: Clear and actionable validation errors

### Constitution Compliance: ✅ PASS
No violations detected. Feature aligns with all constitution principles.

## Project Structure

### Documentation (this feature)

```text
specs/001-style-guides/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
src/backend/
├── src/
│   ├── models/
│   │   └── styleGuide.ts              # StyleGuide, NamingRule, ValidationRule entities
│   ├── services/
│   │   ├── styleGuideService.ts       # CRUD operations, import/export logic
│   │   └── validationService.ts       # Schema validation against style guides
│   ├── api/
│   │   └── styleGuides.ts             # REST endpoints for style guide management
│   ├── middleware/
│   │   └── roleCheck.ts               # Admin role enforcement (existing)
│   └── utils/
│       ├── fileParser.ts              # JSON/YAML parsing utilities
│       └── versionManager.ts          # Version increment logic (major.minor)
└── tests/
    ├── unit/
    │   ├── styleGuideService.test.ts
    │   └── validationService.test.ts
    ├── integration/
    │   └── styleGuides.test.ts
    └── contract/
        └── styleGuides.contract.test.ts

src/frontend/
├── src/
│   ├── components/
│   │   ├── StyleGuideForm.tsx         # Create/Edit form with naming rule builder
│   │   ├── StyleGuideList.tsx         # Paginated list with search/filter
│   │   ├── ImportDialog.tsx           # File upload with preview
│   │   ├── ValidationReport.tsx       # Violation display with suggestions
│   │   └── VersionHistory.tsx         # Version timeline viewer
│   ├── pages/
│   │   ├── StyleGuidesPage.tsx        # Main list page
│   │   └── StyleGuideDetailPage.tsx   # View/Edit/Apply page
│   ├── services/
│   │   └── styleGuideApi.ts           # API client methods
│   ├── store/
│   │   └── styleGuideStore.ts         # Zustand store for state management
│   └── types/
│       └── styleGuide.ts              # TypeScript interfaces
└── tests/
    ├── components/
    │   ├── StyleGuideForm.test.tsx
    │   └── ValidationReport.test.tsx
    └── e2e/
        └── styleGuides.spec.ts        # Playwright E2E tests
```

**Structure Decision**: Web application structure with backend API and frontend React app. Backend implements business logic and persistence via Prisma. Frontend provides UI for all user scenarios. Follows existing SchemaJeli architecture with separation of concerns: models → services → API → frontend.

## Complexity Tracking

No constitutional violations. This section is not applicable.

---

## Phase Completion Status

### ✅ Phase 0: Research (COMPLETED)
- **Output**: `research.md`
- **Status**: All NEEDS CLARIFICATION items resolved
- **Key Decisions**:
  - Naming validation: Zod + cached RegExp
  - Versioning: Semantic versioning with event sourcing
  - File formats: JSON primary, YAML optional
  - Performance: In-memory caching + batch processing
  - Security: Admin-only + JWT + full audit trail

### ✅ Phase 1: Design & Contracts (COMPLETED)
- **Outputs**: 
  - `data-model.md` - Complete database schema with 6 entities
  - `contracts/openapi.yaml` - OpenAPI 3.0 specification with 15 endpoints
  - `quickstart.md` - Implementation guide with code samples
- **Status**: All design artifacts generated
- **Post-Design Constitution Re-check**: ✅ PASS (no violations)
- **Agent Context Updated**: GitHub Copilot context file updated with new technology stack

### 🔄 Phase 2: Tasks Generation (PENDING)
- **Command**: Run `/speckit.tasks` to generate `tasks.md`
- **Note**: Task generation is handled by separate command (not part of `/speckit.plan`)

---

## Next Steps

1. **Generate tasks**: Run `.specify/scripts/powershell/generate-tasks.ps1` or use `/speckit.tasks` command
2. **Review tasks**: Verify task breakdown and dependencies
3. **Begin implementation**: Start with Phase 1 tasks (P1 user stories from spec)
4. **Run tests**: Maintain 70% coverage throughout implementation

---

## Summary

Implementation planning complete. Feature is ready for task generation and implementation.

**Branch**: `001-style-guides`  
**Design Artifacts**: ✅ Complete  
**Constitution Compliance**: ✅ Pass  
**Estimated Implementation**: 2-3 weeks  
**Next Command**: `/speckit.tasks`
