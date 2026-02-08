# Implementation Plan: SchemaJeli Architecture

**Branch**: `master` | **Date**: 2026-02-08 | **Spec**: [specs/architecture/README.md](../architecture/README.md)
**Input**: Feature specification from `/specs/architecture/README.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

SchemaJeli is a modern metadata repository for managing database schemas across multiple RDBMS platforms. This plan covers the complete system architecture including frontend (React 19 SPA), backend (Node.js/Express REST API), PostgreSQL database, and Azure-only infrastructure deployment. Authentication is exclusively via Azure Entra ID with role-based access control (Admin, Maintainer, Viewer).

## Technical Context

**Language/Version**: TypeScript with Node.js 18+ LTS (backend), React 19 with TypeScript (frontend)  
**Primary Dependencies**: Express.js, Prisma ORM, MSAL (Azure Entra ID), Zustand, Tailwind CSS v4, Vite  
**Storage**: PostgreSQL 15+ with Prisma Migrate (all entities use soft deletes via `deletedAt` field)  
**Testing**: Vitest (unit), Supertest (integration), React Testing Library (component), Playwright (E2E)  
**Target Platform**: Azure App Service (backend), Azure Static Web App (frontend), PostgreSQL Flexible Server  
**Project Type**: Web application (React SPA + REST API backend)  
**Performance Goals**: <100ms simple queries, <500ms p95 complex searches, <10s reports, 100+ concurrent users  
**Constraints**: Azure-only deployment (no Kubernetes/AKS), Entra ID-only auth (no local passwords), soft deletes mandatory  
**Scale/Scope**: Enterprise metadata repository, 100+ concurrent users, Server→Database→Table→Element hierarchy with RBAC

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Security-First (NON-NEGOTIABLE)
- **Status**: PASS
- Azure Entra ID authentication on all endpoints (JWT via JWKS)
- Role-based access control (Admin, Maintainer, Viewer) from token claims
- Soft deletes mandatory (`deletedAt` field) - no physical deletion
- Audit trail via `createdById`/`updatedById` FK to minimal local user record
- Secrets in Azure Key Vault
- Rate limiting: 100 req/min per user
- TLS/HTTPS enforced
- SQL injection prevention via Prisma parameterized queries

### ✅ Test-Driven Development (MANDATORY)
- **Status**: PASS
- Testing stack defined: Vitest (unit), Supertest (integration), React Testing Library, Playwright (E2E)
- Constitution requires 70% coverage minimum
- Tests to be written BEFORE implementation per TDD mandate

### ✅ Modernization with Care
- **Status**: PASS
- Modern stack: TypeScript, React 19, Node.js 18+ LTS, REST API, Azure cloud-native
- Legacy ASP code preserved in `legacy/` folder for reference
- Migration strategy defined (ETL scripts with validation/rollback)

### ✅ Data Integrity & Parent-Child Relationships
- **Status**: PASS
- Relational hierarchy: Server → Database → Table → Element
- Enforced at database level via Prisma schema foreign keys
- Soft deletes prevent orphaned records
- Cascade rules defined in data model

### ⚠️ Technology Standards - Partial Deviation
- **Status**: CONDITIONAL PASS (justification required)
- **Deviation 1**: Constitution mandates "Backend: Node.js 18+ LTS with Express.js OR Python 3.11+ with FastAPI"
  - **Chosen**: Node.js 18+ LTS with Express.js ✅
- **Deviation 2**: Constitution mandates "Orchestration: Kubernetes (AKS recommended)"
  - **Chosen**: Azure App Service (no Kubernetes)
  - **Justification**: Simpler operational model, lower cost, sufficient scaling for 100+ concurrent users, Static Web App provides built-in CDN
  - **Complexity Check**: Required below

### ✅ Performance & Scalability
- **Status**: PASS
- Targets: <100ms simple queries, <500ms p95 complex, <10s reports
- 100+ concurrent users supported
- Stateless API design (horizontal scaling via App Service)
- Connection pooling via Prisma

### ✅ Observability & Monitoring
- **Status**: PASS
- Structured JSON logging (Winston)
- Application Insights for metrics/tracing
- Health check endpoints defined
- Correlation IDs for distributed tracing

### ✅ Rebranding Completeness
- **Status**: PASS
- All new code uses "SchemaJeli" branding
- Legacy code preserved in `legacy/` folder
- No legacy "CompanyName" branding in modern application

### Gate Summary (Pre-Phase 0)
- **PASS**: 7/8 requirements fully compliant
- **CONDITIONAL PASS**: 1 requirement (Kubernetes → App Service) requires complexity justification
- **Phase 0 Research**: APPROVED to proceed

### Post-Phase 1 Re-Check ✅

**Status**: ALL GATES PASS

Following Phase 1 design completion, all constitution requirements verified:

1. **Security-First**: ✅ PASS
   - Azure Entra ID JWT validation via JWKS implemented in research
   - Soft delete patterns defined in data-model.md with `deletedAt` field
   - Audit middleware pattern documented with `createdById`, `updatedById`, `deletedById`
   - OpenAPI spec enforces Bearer token authentication on all endpoints

2. **Test-Driven Development**: ✅ PASS
   - Testing strategy defined: Vitest (unit), Supertest (integration), Playwright (E2E)
   - 70%+ coverage target established in quickstart.md
   - Test structure documented with unit/integration/e2e directories

3. **Data Integrity**: ✅ PASS
   - Server→Database→Table→Element hierarchy enforced via Prisma foreign keys
   - Cascade rules defined: `onDelete: Cascade` at database level
   - Soft delete propagation documented in data-model.md

4. **Technology Standards**: ✅ PASS (JUSTIFIED)
   - Node.js 18+ LTS + Express.js chosen (constitution approved option)
   - Kubernetes deviation justified in Complexity Tracking section
   - All other tech choices align with constitution

5. **Observability**: ✅ PASS
   - Application Insights integration documented
   - Winston structured logging pattern established
   - Health check endpoints defined in OpenAPI spec (`/api/health`)

**Phase 2 Planning**: APPROVED to proceed

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
SchemaJeli/
├── .github/workflows/          # CI/CD pipelines
│   ├── backend-ci.yml         # Backend build, test, security scan
│   ├── frontend-ci.yml        # Frontend build, test, lint
│   └── deploy.yml             # Azure deployment pipeline
│
├── .specify/                   # SpecKit planning documents
│   ├── memory/
│   │   └── constitution.md    # Project principles
│   ├── scripts/               # Workflow automation
│   └── templates/             # Document templates
│
├── infrastructure/             # Infrastructure as Code
│   └── terraform/             # Azure-only Terraform modules
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/           # App Service, Static Web App, PostgreSQL, Key Vault
│
├── src/
│   ├── backend/               # Node.js/Express REST API
│   │   ├── src/
│   │   │   ├── api/           # Routes, controllers
│   │   │   ├── models/        # Prisma schema
│   │   │   ├── services/      # Business logic
│   │   │   ├── middleware/    # Auth, RBAC, validation, logging
│   │   │   ├── config/        # Configuration (Azure Key Vault integration)
│   │   │   ├── utils/         # Utilities
│   │   │   └── app.ts         # Express app setup
│   │   ├── tests/
│   │   │   ├── unit/          # Vitest unit tests
│   │   │   └── integration/   # Supertest API tests
│   │   ├── prisma/
│   │   │   └── schema.prisma  # Database schema
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── .env.example
│   │   └── Dockerfile
│   │
│   └── frontend/              # React 19 SPA
│       ├── src/
│       │   ├── components/    # Reusable React components
│       │   ├── pages/         # Page components (Servers, Databases, Tables, Elements)
│       │   ├── services/      # API client (MSAL token acquisition)
│       │   ├── store/         # Zustand state management
│       │   ├── hooks/         # Custom React hooks
│       │   ├── utils/         # Utilities
│       │   ├── types/         # TypeScript types
│       │   ├── App.tsx
│       │   └── main.tsx
│       ├── public/            # Static assets
│       ├── tests/
│       │   ├── unit/          # Vitest component tests
│       │   └── e2e/           # Playwright E2E tests
│       ├── package.json
│       ├── vite.config.ts
│       ├── tsconfig.json
│       └── Dockerfile
│
├── legacy/                     # Archived legacy ASP code (reference only)
│
├── specs/                      # Feature specifications
│   ├── architecture/          # This spec
│   └── master/                # Implementation plan artifacts
│       ├── plan.md            # This file
│       ├── research.md        # Phase 0 output
│       ├── data-model.md      # Phase 1 output
│       ├── quickstart.md      # Phase 1 output
│       └── contracts/         # Phase 1 OpenAPI specs
│
├── docker-compose.yml          # Local development environment
└── README.md
```

**Structure Decision**: Web application architecture (Option 2) with separate `backend/` and `frontend/` directories under `src/`. This structure supports the React SPA + REST API pattern with clear separation of concerns. Infrastructure code is isolated in `infrastructure/terraform/` for Azure-only deployment. Legacy ASP code is archived in `legacy/` per constitution rebranding requirements.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Kubernetes (AKS) → Azure App Service | App Service provides sufficient scaling for 100+ concurrent users, simpler operational model, lower cost, built-in CI/CD integration, Static Web App provides CDN for frontend | Kubernetes adds operational complexity (cluster management, pod orchestration, networking configuration) without clear benefit for the deployment profile. Constitution allows "Kubernetes (AKS recommended)" but does not mandate it. App Service meets all scalability requirements (<500ms p95, 100+ users) with significantly reduced operational overhead. |

**Decision Rationale**: The constitution states "Kubernetes (AKS recommended)" which indicates preference but not a hard requirement. Given the project scope (100+ concurrent users, read-heavy metadata repository), the operational complexity of Kubernetes outweighs the benefits. App Service provides:
- Automatic scaling without manual pod configuration
- Built-in SSL/TLS management
- Integrated monitoring (Application Insights)
- Lower cost (no cluster management overhead)
- Faster deployment pipeline
- Static Web App for frontend (CDN, global distribution)

**Approval**: This architectural decision was documented in the architecture spec (specs/architecture/README.md) with the heading "Why Azure-Only (No Kubernetes)?" and aligns with pragmatic engineering for the specified load profile.

---

## Implementation Phases Status

### ✅ Phase 0: Research & Discovery (COMPLETE)

**Deliverables**:
- ✅ `research.md` - Technical context clarifications, technology deep dives, best practices research
- ✅ All unknowns resolved (no NEEDS CLARIFICATION items remaining)
- ✅ Technology decisions documented with rationale
- ✅ Risk mitigation strategies defined

**Key Decisions**:
- Backend: Node.js 18+ LTS with Express.js and Prisma ORM
- Frontend: React 19 with Vite, Zustand, and Tailwind CSS v4
- Database: PostgreSQL 15+ with full-text search (tsvector/tsquery)
- Authentication: Azure Entra ID (MSAL) with JWT validation
- Testing: Vitest (unit), Supertest (integration), Playwright (E2E)
- Deployment: Azure App Service (backend) + Static Web App (frontend)

### ✅ Phase 1: Design & Contracts (COMPLETE)

**Deliverables**:
- ✅ `data-model.md` - Complete entity definitions, relationships, validation rules, Prisma schema
- ✅ `contracts/openapi.yaml` - Full REST API specification (OpenAPI 3.0)
- ✅ `quickstart.md` - Developer onboarding guide (already existed, verified current)
- ✅ Agent context updated - `.github/agents/copilot-instructions.md` with project technologies

**Design Artifacts Summary**:
- **Entities**: User, Server, Database, Table, Element, Abbreviation, AuditLog
- **Relationships**: Hierarchical (Server → Database → Table → Element) with foreign key constraints
- **Soft Deletes**: All entities use `deletedAt` timestamp field
- **Audit Trail**: `createdAt`, `updatedAt`, `createdById`, `updatedById` on all entities
- **Full-Text Search**: PostgreSQL tsvector with GIN indexes
- **API Endpoints**: Complete REST API with CRUD operations, search, and report generation
- **Authentication**: Azure Entra ID with role-based access control (ADMIN, MAINTAINER, VIEWER)

### ✅ Constitution Re-Check (Post-Design)

All constitution requirements remain compliant after Phase 1 design:

- ✅ **Security-First**: JWT auth, RBAC, soft deletes, audit trail, Prisma parameterized queries
- ✅ **TDD Mandatory**: Testing stack defined (Vitest, Supertest, Playwright), coverage targets set (80/70/60%)
- ✅ **Modernization**: TypeScript, React 19, Node.js 18+, PostgreSQL 15+, Azure cloud-native
- ✅ **Data Integrity**: Foreign key constraints, soft deletes, cascade behavior defined
- ✅ **Observability**: Winston JSON logging, Application Insights, health checks, correlation IDs
- ✅ **Rebranding**: All new code uses "SchemaJeli", legacy code archived in `legacy/` folder

**No new violations introduced during design phase.**

### ⏸️ Phase 2: Tasks Generation (PENDING)

**Next Steps**:
- Run `/speckit.tasks` command to generate `tasks.md` with actionable implementation tasks
- Tasks will be dependency-ordered and reference design artifacts from Phase 1
- Implementation can begin after task generation

---

## Phase 1 Completion Summary

**Date Completed**: 2026-01-29  
**Branch**: `master`  
**Status**: ✅ **ALL PHASE 1 DELIVERABLES COMPLETE**

**Generated Artifacts**:
1. ✅ `specs/master/research.md` (15KB) - Technical research and decisions
2. ✅ `specs/master/data-model.md` (26KB) - Complete data model with Prisma schema
3. ✅ `specs/master/contracts/openapi.yaml` (41KB) - Full REST API specification
4. ✅ `specs/master/quickstart.md` (14KB) - Developer quick start guide (verified)
5. ✅ `.github/agents/copilot-instructions.md` - Agent context file

**Ready for Implementation**: The design artifacts provide a complete specification for implementing the SchemaJeli system. All entities, relationships, API contracts, and technical decisions are documented and ready for task breakdown in Phase 2.
