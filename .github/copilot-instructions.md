# Copilot Instructions for SchemaJeli

## Project Overview

SchemaJeli is a cloud-native database metadata repository for documenting schemas across multiple RDBMS platforms (PostgreSQL, MySQL, Oracle, DB2, Informix). It modernizes a legacy ASP system (1999) into a TypeScript monorepo with separate backend and frontend apps.

## Repository Layout

- `src/backend/` — Express.js API (own `package.json`, runs on port 3000)
- `src/frontend/` — React 19 + Vite SPA (own `package.json`, runs on port 5173 dev / 8081 Docker)
- `infrastructure/terraform/` — Azure IaC (App Service, PostgreSQL, monitoring)
- `.specify/` — SpecKit planning artifacts (spec.md, plan.md, tasks.md, constitution)
- Root `package.json` — only has Playwright for cross-app E2E tests

Each app is independently installable. Always `cd` into the correct directory before running commands.

## Build, Test & Lint

### Backend (`src/backend/`)

```bash
npm install
npm run build                    # tsc
npm run dev                      # tsx watch src/index.ts
npm test                         # vitest (all unit tests)
npx vitest run src/path/to.test.ts  # single test file
npm run test:coverage            # vitest --coverage (80% threshold)
npm run lint                     # eslint src/**/*.ts
npm run lint:fix
npm run format                   # prettier
npm run prisma:generate          # generate Prisma Client
npm run prisma:migrate           # prisma migrate dev
npm run prisma:seed              # tsx prisma/seed.ts
```

### Frontend (`src/frontend/`)

```bash
npm install
npm run build                    # tsc -b && vite build
npm run dev                      # vite dev server
npm test                         # vitest run
npx vitest run src/path/to.test.tsx  # single test file
npm run test:coverage
npm run lint                     # eslint
```

### E2E Tests (root)

```bash
npm install                      # installs Playwright
npx playwright test              # runs against http://localhost:8081
npx playwright test tests/frontend/e2e/specific.spec.ts  # single spec
```

### Docker (full stack)

```bash
docker-compose up -d             # postgres:5433, backend:8080, frontend:8081
```

## Architecture

### Domain Model Hierarchy

Server → Database → Table → Element (column). This parent-child hierarchy is enforced via Prisma foreign keys with `onDelete: Restrict`. All entities use **soft deletes** (`deletedAt` field) — never physically delete records.

### Authentication & Authorization

- **Azure Entra ID (MSAL)** — no local user/password auth
- Backend validates JWTs via Microsoft JWKS endpoint (`src/backend/src/middleware/auth.ts`)
- Frontend uses `@azure/msal-browser` for login flows (`src/frontend/src/config/auth.ts`)
- RBAC roles: **Admin**, **Maintainer**, **Viewer** — derived from Entra ID token claims (`roles` or `groups`)
- Dev fallback: `RBAC_MOCK_ROLES` env var for local testing without Azure
- Write endpoints require `authenticateJWT` + `requireRole('Admin', 'Maintainer')`; deletes require `Admin` only

### Backend Patterns

- All API routes defined in a single file: `src/backend/src/index.ts` (not split into route files yet)
- All routes prefixed `/api/v1/`
- Standard response envelope: `{ status: 'success'|'error', data?, message? }`
- Pagination: `page` + `limit` query params; response includes `total`, `page`, `limit`, `totalPages`
- Prisma is the sole database client; access via `src/backend/src/db/prisma.ts`
- ESM modules (`"type": "module"`, `.js` extensions in imports)

### Frontend Patterns

- **State management**: Zustand (not Redux) with `persist` middleware for auth state
- **Styling**: Tailwind CSS v4 with `@` path alias (`@/components/...`)
- **Forms**: React Hook Form + Zod validation
- **API client**: Axios-based service files per entity in `src/frontend/src/services/`
- **Routing**: React Router v7 with `createBrowserRouter` in `Router.tsx`
- **Components**: Functional components only; PascalCase filenames; prop interfaces required
- **Testing**: Vitest + React Testing Library + MSW for API mocking

## Key Conventions

- **TypeScript strict mode** in both apps
- **Conventional Commits** required: `feat(scope):`, `fix(scope):`, etc.
- **Prettier config** (backend): semi, singleQuote, trailingComma es5, printWidth 80, tabWidth 2
- **Branch naming**: `feature/`, `fix/`, `docs/`, `refactor/`, `test/`, `chore/`
- Prefer `interface` over `type` for object shapes; avoid `any`, use `unknown`
- PascalCase for types/interfaces/classes, camelCase for variables/functions, UPPER_CASE for constants
- Prisma schema maps camelCase fields to snake_case DB columns via `@map()`

## Constitution Principles (`.specify/memory/constitution.md`)

- Security-first: every endpoint must have auth, OWASP Top 10 tested
- Minimum 70% code coverage; tests written before implementation
- Soft deletes mandatory — no physical deletion of data
- API response times: simple queries <100ms, complex searches <500ms p95
- All audit-trail modifications logged to `AuditLog` table
