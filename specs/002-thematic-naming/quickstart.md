# Thematic Naming Feature — Developer Quickstart

> **Feature Branch**: `002-thematic-naming`
> **Time to Setup**: ~30 minutes
> **Last Updated**: 2026-02-08

---

## 1. Overview

The thematic naming feature lets teams create and apply themed naming guides (e.g., Harry Potter, Star Wars, Fruit) to schema elements like tables and columns. Instead of manually choosing names, users select a theme and the system generates contextually-ranked naming suggestions using an LRU-based algorithm with a three-stage pipeline: Filter → Rank → Format. The feature supports 10 pre-populated built-in themes with 400+ elements, custom admin-created themes, element cycling with numeric suffixes for large schemas, and JSON export/import for portability.

Architecturally, this feature adds four new Prisma models (`ThematicGuide`, `ThemeElement`, `ThemeLibraryItem`, `ThemeUsageRecord`), two new enums (`ElementType`, `ThemeCategory`), and four API route groups under `/api/v1/` — all following SchemaJeli's existing patterns of UUID primary keys, soft deletes, `@map()` snake_case columns, and the standard `{ status, data, message }` response envelope. RBAC enforcement requires Admin role for guide creation/modification and Viewer+ for browsing and suggestion generation.

The backend is built with Express.js + Prisma on PostgreSQL 15+. The frontend uses React 19, Zustand for state, React Hook Form + Zod for validation, and Axios for API calls. Styling uses Tailwind CSS v4. Tests use Vitest (unit/integration) and Playwright (E2E).

---

## 2. Prerequisites

| Requirement | Version | Verify |
|---|---|---|
| Node.js | ≥ 18.0.0 | `node --version` |
| npm | ≥ 9.0.0 | `npm --version` |
| PostgreSQL | ≥ 15.0 | `psql --version` |
| Git | ≥ 2.30 | `git --version` |

**Additionally required**:

- **Azure Entra ID credentials** configured in `src/backend/.env` (or use `RBAC_MOCK_ROLES="Admin"` for local dev — see [Troubleshooting](#8-troubleshooting))
- **Development environment** set up per [CONTRIBUTING.md](../../CONTRIBUTING.md) (fork, clone, upstream remote)
- **VS Code** recommended with ESLint + Prettier extensions

---

## 3. Setup Steps

### 3.1 Create the feature branch

```bash
git checkout main
git pull origin main
git checkout -b feature/002-thematic-naming
```

### 3.2 Install backend dependencies

```bash
cd src/backend
npm install
```

### 3.3 Configure environment

```bash
cp .env.example .env
```

Edit `src/backend/.env` and ensure these are set:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/schemajeli?schema=public"
RBAC_MOCK_ROLES="Admin"          # Grants Admin role locally without Azure
NODE_ENV="development"
PORT=3000
```

> **Note**: `RBAC_MOCK_ROLES="Admin"` bypasses Azure Entra ID auth for local testing. Never use this in production.

### 3.4 Run database migrations

After adding the new Prisma schema models (Step 1 in Implementation Workflow):

```bash
cd src/backend
npx prisma migrate dev --name add-thematic-naming
npm run prisma:generate
```

### 3.5 Seed built-in themes

Extend the existing seed file at `src/backend/prisma/seed.ts` to include the 10 built-in themes, then run:

```bash
cd src/backend
npm run prisma:seed
```

### 3.6 Start the backend

```bash
cd src/backend
npm run dev
```

Verify: `curl http://localhost:3000/health` → `{ "status": "healthy", "database": "connected" }`

### 3.7 Install and start the frontend

```bash
cd src/frontend
npm install
npm run dev
```

Verify: Open `http://localhost:5173` in your browser.

### 3.8 (Alternative) Docker full stack

```bash
# From repository root
docker-compose up -d
# postgres:5433, backend:8080, frontend:8081
```

---

## 4. Implementation Workflow

Follow this order to minimize blocked work. Each step builds on the previous.

### Step 1: Prisma Schema + Migrations

**Reference**: [data-model.md](./data-model.md)

Add to `src/backend/prisma/schema.prisma`:

1. New enums: `ElementType` (CHARACTER, PLACE, OBJECT, CONCEPT, OTHER) and `ThemeCategory` (FICTION, NATURE, CULTURE, CUSTOM)
2. Extend existing `EntityType` enum with `THEMATIC_GUIDE`
3. New models: `ThematicGuide`, `ThemeElement`, `ThemeLibraryItem`, `ThemeUsageRecord`
4. Indexes: `@@index([guideId, usageCount, lastUsedAt])` on ThemeElement, `@@index([guideId, elementId])` and `@@index([entityType, entityId])` on ThemeUsageRecord

```bash
cd src/backend
npx prisma migrate dev --name add-thematic-naming
npm run prisma:generate
```

**Key points**:
- All models use UUID PKs (`@id @default(uuid())`)
- Use `@map("snake_case")` for column names
- `ThematicGuide` has `deletedAt` for soft deletes — elements cascade-delete with their guide
- `@@unique([guideId, elementText])` prevents duplicate elements within a guide

### Step 2: Backend Services (service layer)

Create service files following existing patterns (reference: `src/backend/src/services/server.service.ts`):

| File to Create | Purpose |
|---|---|
| `src/backend/src/services/thematicGuide.service.ts` | CRUD for guides, soft-delete, version increment |
| `src/backend/src/services/themeLibrary.service.ts` | Browse/search built-in theme library |
| `src/backend/src/services/namingSuggestion.service.ts` | Three-stage suggestion pipeline (Filter → Rank → Format) |
| `src/backend/src/services/themeExport.service.ts` | JSON export with SHA-256 checksum, import with validation |

**Suggestion algorithm** (from [research.md](./research.md) §3):

```typescript
// Scoring weights — make these configurable
const WEIGHTS = { typeMatch: 0.40, freshness: 0.30, recency: 0.20, suffixPenalty: 0.10 };

// Context-aware type mapping
const ENTITY_TYPE_PREFERENCES: Record<string, ElementType[]> = {
  schema: ['PLACE'],
  table: ['CHARACTER'],
  column: ['OBJECT', 'CONCEPT'],
  index: ['CONCEPT'],
  constraint: ['CONCEPT'],
};
```

**Key patterns**:
- Use `prisma` client from `src/backend/src/db/prisma.ts`
- Use Prisma transactions when creating usage records + updating denormalized counters
- Reference `src/backend/src/services/audit.service.ts` for audit logging patterns
- Reference `src/backend/src/services/oboClient.ts` for service structure patterns

### Step 3: API Routes with RBAC Middleware

Add routes to `src/backend/src/index.ts` (all routes are currently in this single file).

**Reference**: [contracts/](./contracts/) — OpenAPI specs for exact request/response shapes.

| Route Group | Contract File | RBAC |
|---|---|---|
| `GET/POST/PUT/DELETE /api/v1/thematic-guides` | `thematic-guides-api.yaml` | Admin for write, Viewer+ for read |
| `POST /api/v1/naming-suggestions` | `naming-suggestions-api.yaml` | Viewer+ |
| `POST /api/v1/naming-suggestions/apply` | `naming-suggestions-api.yaml` | Maintainer+ |
| `GET /api/v1/naming-suggestions/usage` | `naming-suggestions-api.yaml` | Viewer+ |
| `GET /api/v1/theme-library` | `theme-library-api.yaml` | Viewer+ |
| `GET /api/v1/theme-library/search` | `theme-library-api.yaml` | Viewer+ |
| `GET /api/v1/theme-library/:id` | `theme-library-api.yaml` | Viewer+ |
| `GET /api/v1/thematic-guides/:id/export` | `theme-export-api.yaml` | Viewer+ |
| `POST /api/v1/thematic-guides/import` | `theme-export-api.yaml` | Admin |
| `POST /api/v1/thematic-guides/import/validate` | `theme-export-api.yaml` | Viewer+ |
| `POST /api/v1/thematic-guides/:id/preview` | `thematic-guides-api.yaml` | Viewer+ |

**RBAC middleware usage** (existing pattern from `src/backend/src/middleware/auth.ts`):

```typescript
// Read-only — any authenticated user
app.get('/api/v1/theme-library', authenticateJWT, async (req, res) => { ... });

// Admin-only write
app.post('/api/v1/thematic-guides', authenticateJWT, requireRole('Admin'), async (req, res) => { ... });

// Maintainer+ write
app.post('/api/v1/naming-suggestions/apply', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => { ... });
```

**Response envelope** (existing pattern):

```typescript
res.status(200).json({ status: 'success', data: result });
res.status(400).json({ status: 'error', message: 'Validation failed' });
```

### Step 4: Frontend API Client + Hooks

Create Axios service files following existing patterns (reference: `src/frontend/src/services/serverService.ts`):

| File to Create | Purpose |
|---|---|
| `src/frontend/src/services/thematicGuideService.ts` | CRUD API calls for guides |
| `src/frontend/src/services/themeLibraryService.ts` | Browse/search theme library |
| `src/frontend/src/services/namingSuggestionService.ts` | Generate/apply suggestions |

Create React hooks:

| File to Create | Purpose |
|---|---|
| `src/frontend/src/hooks/useThematicGuides.ts` | Data fetching + mutations for guides |
| `src/frontend/src/hooks/useThemeLibrary.ts` | Theme library browsing state |
| `src/frontend/src/hooks/useNamingSuggestions.ts` | Suggestion generation + application |

Optionally create a Zustand store for theme-related state:

| File to Create | Purpose |
|---|---|
| `src/frontend/src/store/themeStore.ts` | Selected theme, active guide, UI state |

### Step 5: React Components

Create a `themes/` subdirectory under components. Build in this order (each depends on the previous):

| Order | Component File | Description |
|---|---|---|
| 1 | `src/frontend/src/components/themes/ThemeLibraryBrowser.tsx` | Gallery grid of built-in themes with search/filter (US-4) |
| 2 | `src/frontend/src/components/themes/ThemeDetailPanel.tsx` | Theme detail view with grouped elements by type |
| 3 | `src/frontend/src/components/themes/ThemeCreationWizard.tsx` | Multi-step form: choose built-in or custom → add elements → save (US-1, US-2) |
| 4 | `src/frontend/src/components/themes/ThemeElementList.tsx` | Editable list of theme elements with add/remove (US-5) |
| 5 | `src/frontend/src/components/themes/NamingSuggestionPanel.tsx` | Display generated suggestions with scores, allow selection (US-3) |
| 6 | `src/frontend/src/components/themes/ThemeExportImport.tsx` | Export/import buttons and file upload (US-6) |
| 7 | `src/frontend/src/components/themes/ThemeGuideCard.tsx` | Summary card for guide list views |

Create the page component:

| File to Create | Description |
|---|---|
| `src/frontend/src/pages/ThemesPage.tsx` | Main page routing between library browser, guide list, and creation wizard |

Add route to `src/frontend/src/Router.tsx`:

```typescript
{ path: '/themes', element: <ThemesPage /> }
```

**Component patterns** (from CONTRIBUTING.md):
- Functional components only, PascalCase filenames
- Define prop interfaces for every component
- Use React Hook Form + Zod for form validation
- Use Tailwind CSS v4 for styling with `@/` path alias

### Step 6: Tests

#### Unit Tests (Vitest)

| File to Create | Tests |
|---|---|
| `src/backend/tests/unit/services/thematicGuide.service.test.ts` | Guide CRUD, soft delete, version increment |
| `src/backend/tests/unit/services/namingSuggestion.service.test.ts` | Suggestion pipeline, LRU cycling, collision avoidance, scoring |
| `src/backend/tests/unit/services/themeExport.service.test.ts` | Export format, import validation, checksum verify |
| `src/backend/tests/unit/services/themeLibrary.service.test.ts` | Browse, search, detail retrieval |

```bash
cd src/backend
npx vitest run src/path/to/test.test.ts   # Run single file
npm test                                    # Run all
npm run test:coverage                       # 80% threshold
```

#### Frontend Unit Tests

| File to Create | Tests |
|---|---|
| `src/frontend/src/components/themes/__tests__/ThemeLibraryBrowser.test.tsx` | Renders gallery, filters, search |
| `src/frontend/src/components/themes/__tests__/ThemeCreationWizard.test.tsx` | Form validation, submit flow |
| `src/frontend/src/components/themes/__tests__/NamingSuggestionPanel.test.tsx` | Displays suggestions, apply action |
| `src/frontend/src/hooks/__tests__/useThematicGuides.test.ts` | API integration via MSW mocks |

```bash
cd src/frontend
npx vitest run src/path/to/test.test.tsx
npm run test:coverage
```

#### E2E Tests (Playwright)

| File to Create | Tests |
|---|---|
| `tests/frontend/e2e/thematic-naming.spec.ts` | Full flow: browse library → create guide → generate suggestions → apply |

```bash
# From repository root
npx playwright test tests/frontend/e2e/thematic-naming.spec.ts
```

---

## 5. Testing the Feature

### 5.1 Set up a test user with Admin role

For local development, set `RBAC_MOCK_ROLES="Admin"` in `src/backend/.env`. This grants Admin role to all requests without Azure Entra ID.

For Azure-authenticated testing, ensure your test user has the Admin role assigned in Azure AD app roles or group membership (configure `RBAC_GROUP_ADMIN` in `.env`).

### 5.2 cURL Examples

**List theme library** (browse built-in themes):

```bash
curl -s http://localhost:3000/api/v1/theme-library | jq
```

**Get theme library item detail**:

```bash
curl -s http://localhost:3000/api/v1/theme-library/{id} | jq
```

**Search theme library**:

```bash
curl -s "http://localhost:3000/api/v1/theme-library/search?q=space" | jq
```

**Create a custom thematic guide** (Admin only):

```bash
curl -X POST http://localhost:3000/api/v1/thematic-guides \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Greek Titans",
    "description": "Custom theme based on Greek Titan mythology",
    "themeCategory": "CUSTOM",
    "elements": [
      { "elementText": "kronos", "elementType": "CHARACTER", "displayOrder": 0 },
      { "elementText": "atlas", "elementType": "CHARACTER", "displayOrder": 1 },
      { "elementText": "prometheus", "elementType": "CHARACTER", "displayOrder": 2 },
      { "elementText": "olympus", "elementType": "PLACE", "displayOrder": 3 }
    ]
  }' | jq
```

**Create guide from built-in theme**:

```bash
curl -X POST http://localhost:3000/api/v1/thematic-guides \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Harry Potter Guide",
    "description": "Team Alpha HP guide",
    "libraryItemId": "<library-item-uuid>"
  }' | jq
```

**Generate naming suggestions**:

```bash
curl -X POST http://localhost:3000/api/v1/naming-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "guideId": "<guide-uuid>",
    "entityType": "table",
    "count": 5,
    "existingNames": ["users", "orders"],
    "prefix": "tbl"
  }' | jq
```

**Apply a suggestion** (Maintainer+ only):

```bash
curl -X POST http://localhost:3000/api/v1/naming-suggestions/apply \
  -H "Content-Type: application/json" \
  -d '{
    "guideId": "<guide-uuid>",
    "elementId": "<element-uuid>",
    "entityType": "table",
    "entityId": "<target-entity-uuid>",
    "appliedName": "tbl_dumbledore"
  }' | jq
```

**Preview guide suggestions**:

```bash
curl -X POST http://localhost:3000/api/v1/thematic-guides/<guide-uuid>/preview \
  -H "Content-Type: application/json" \
  -d '{ "entityTypes": ["table", "column"], "count": 5, "prefix": "tbl" }' | jq
```

**Export a guide**:

```bash
curl -s http://localhost:3000/api/v1/thematic-guides/<guide-uuid>/export | jq
```

**Import a guide** (Admin only):

```bash
curl -X POST http://localhost:3000/api/v1/thematic-guides/import \
  -H "Content-Type: application/json" \
  -d @exported-guide.json | jq
```

### 5.3 UI Navigation Flow

1. Navigate to `http://localhost:5173/themes`
2. **Browse**: View the theme library gallery with 10 built-in themes
3. **Search**: Use the search box to filter themes (e.g., "space" → Star Wars, Planets)
4. **Create from built-in**: Click a theme → "Create Guide" → confirm → guide created
5. **Create custom**: Click "Create New" → enter name + elements (≥3) → save
6. **Generate suggestions**: Select a guide → choose entity type (table/column) → click "Generate"
7. **Apply**: Click a suggestion to apply it to a schema element
8. **Export**: Open guide detail → click "Export" → download JSON file

### 5.4 Verify Audit Logs

After performing operations, check the AuditLog table:

```bash
cd src/backend
npx prisma studio
```

Navigate to the `AuditLog` table and verify entries with `entityType = 'THEMATIC_GUIDE'` for guide creation, modification, and usage events.

---

## 6. Key Files to Modify/Create

### Backend

| Action | File Path |
|---|---|
| **Modify** | `src/backend/prisma/schema.prisma` — Add enums + 4 new models |
| **Modify** | `src/backend/prisma/seed.ts` — Add 10 built-in themes seed data |
| **Modify** | `src/backend/src/index.ts` — Add all new API routes |
| **Create** | `src/backend/src/services/thematicGuide.service.ts` |
| **Create** | `src/backend/src/services/themeLibrary.service.ts` |
| **Create** | `src/backend/src/services/namingSuggestion.service.ts` |
| **Create** | `src/backend/src/services/themeExport.service.ts` |
| **Create** | `src/backend/tests/unit/services/thematicGuide.service.test.ts` |
| **Create** | `src/backend/tests/unit/services/namingSuggestion.service.test.ts` |
| **Create** | `src/backend/tests/unit/services/themeExport.service.test.ts` |
| **Create** | `src/backend/tests/unit/services/themeLibrary.service.test.ts` |
| **Create** | `src/backend/tests/integration/thematicGuide.test.ts` |

### Frontend

| Action | File Path |
|---|---|
| **Create** | `src/frontend/src/services/thematicGuideService.ts` |
| **Create** | `src/frontend/src/services/themeLibraryService.ts` |
| **Create** | `src/frontend/src/services/namingSuggestionService.ts` |
| **Create** | `src/frontend/src/hooks/useThematicGuides.ts` |
| **Create** | `src/frontend/src/hooks/useThemeLibrary.ts` |
| **Create** | `src/frontend/src/hooks/useNamingSuggestions.ts` |
| **Create** | `src/frontend/src/store/themeStore.ts` |
| **Create** | `src/frontend/src/components/themes/ThemeLibraryBrowser.tsx` |
| **Create** | `src/frontend/src/components/themes/ThemeDetailPanel.tsx` |
| **Create** | `src/frontend/src/components/themes/ThemeCreationWizard.tsx` |
| **Create** | `src/frontend/src/components/themes/ThemeElementList.tsx` |
| **Create** | `src/frontend/src/components/themes/NamingSuggestionPanel.tsx` |
| **Create** | `src/frontend/src/components/themes/ThemeExportImport.tsx` |
| **Create** | `src/frontend/src/components/themes/ThemeGuideCard.tsx` |
| **Create** | `src/frontend/src/pages/ThemesPage.tsx` |
| **Modify** | `src/frontend/src/Router.tsx` — Add `/themes` route |
| **Modify** | `src/frontend/src/components/Layout.tsx` — Add "Themes" nav link |

### Tests

| Action | File Path |
|---|---|
| **Create** | `src/frontend/src/components/themes/__tests__/ThemeLibraryBrowser.test.tsx` |
| **Create** | `src/frontend/src/components/themes/__tests__/ThemeCreationWizard.test.tsx` |
| **Create** | `src/frontend/src/components/themes/__tests__/NamingSuggestionPanel.test.tsx` |
| **Create** | `src/frontend/src/hooks/__tests__/useThematicGuides.test.ts` |
| **Create** | `tests/frontend/e2e/thematic-naming.spec.ts` |

---

## 7. Development Tips

### Follow existing service patterns

Reference `src/backend/src/services/server.service.ts` for CRUD service structure and `src/backend/src/services/oboClient.ts` for external service integration. All services import Prisma from `src/backend/src/db/prisma.ts`.

### Auth middleware patterns

```typescript
import { authenticateJWT, requireRole } from './middleware/auth.js';

// Note: ESM imports require .js extension
// requireRole accepts one or more role strings
```

### Prisma client regeneration

After **any** change to `schema.prisma`, always run:

```bash
cd src/backend
npm run prisma:generate
```

If you forget, you'll get TypeScript errors about missing model types.

### Winston logging

Use structured JSON logging following the existing `LOG_LEVEL` config:

```typescript
import logger from '../config/index.js';

logger.info('Thematic guide created', { guideId, guideName, createdBy });
logger.error('Suggestion generation failed', { guideId, error: err.message });
```

### React component organization

Place all theme-related components under `src/frontend/src/components/themes/`. This mirrors the existing flat structure while keeping the feature scoped. Follow PascalCase filenames and always define prop interfaces.

### Seed data structure

When extending `src/backend/prisma/seed.ts`, create ThemeLibraryItem records for the 10 built-in themes. Include `previewElements` (3–5 sample names) for the gallery view. The full element lists should be created as ThematicGuide + ThemeElement records with `isBuiltIn: true`.

### Soft delete pattern

Reference `src/backend/src/middleware/soft-delete.middleware.ts` for the existing soft-delete pattern. All queries against `ThematicGuide` should filter `WHERE deletedAt IS NULL` by default.

### Performance targets

| Operation | Budget |
|---|---|
| Generate 10 suggestions | < 500ms (expect ~3ms) |
| Theme gallery load (10 items) | < 1 second (expect ~10ms) |
| Export guide (80 elements) | < 500ms (expect ~5ms) |
| Import + validate (1000 elements) | < 2 seconds (expect ~50ms) |

---

## 8. Troubleshooting

### Migration errors

**"relation already exists"**: Drop and recreate the migration:

```bash
cd src/backend
npx prisma migrate reset     # WARNING: drops all data
npx prisma migrate dev --name add-thematic-naming
```

**"enum type already exists"**: If you added enums manually, remove them before re-running migrations:

```sql
DROP TYPE IF EXISTS "ElementType";
DROP TYPE IF EXISTS "ThemeCategory";
```

### Seed data conflicts

**"Unique constraint failed"**: The seed script is not idempotent. Reset first:

```bash
cd src/backend
npx prisma migrate reset
npm run prisma:seed
```

To make seeding idempotent, use `upsert` in seed.ts:

```typescript
await prisma.themeLibraryItem.upsert({
  where: { id: 'known-uuid' },
  update: {},
  create: { ... },
});
```

### Auth failures

**"UNAUTHORIZED" on all requests**: Ensure `RBAC_MOCK_ROLES` is set in `src/backend/.env`:

```env
RBAC_MOCK_ROLES="Admin"
```

**"FORBIDDEN" on guide creation**: You need `Admin` role. If using `RBAC_MOCK_ROLES`, set it to `"Admin"` (not `"Viewer"` or `"Maintainer"`).

**Token validation fails**: If running with real Azure tokens, ensure `JWT_AUDIENCE`, `JWT_ISSUER`, and `JWT_JWKS_URI` are correctly configured in `src/backend/.env`.

### Prisma client out of sync

**"Unknown model ThematicGuide"** or similar TypeScript errors:

```bash
cd src/backend
npm run prisma:generate
```

### Where to find logs

- **Backend console**: stdout when running `npm run dev` (structured JSON via Winston)
- **Log files**: `src/backend/logs/app.log` (configured via `LOG_FILE_PATH`)
- **Prisma queries**: Set `PRISMA_QUERY_LOG=true` in `.env` for verbose SQL output
- **Azure Application Insights**: Configure `APPINSIGHTS_INSTRUMENTATION_KEY` for production monitoring
- **Prisma Studio** (visual DB browser): `cd src/backend && npx prisma studio`

### Reset theme data for testing

To wipe all theme-related data without affecting other tables:

```bash
cd src/backend
npx prisma studio
```

Or via SQL:

```sql
DELETE FROM "theme_usage_records";
DELETE FROM "theme_elements";
DELETE FROM "thematic_guides";
DELETE FROM "theme_library_items";
```

Then re-seed: `npm run prisma:seed`

---

## Quick Reference

| Task | Command | Directory |
|---|---|---|
| Install backend deps | `npm install` | `src/backend/` |
| Install frontend deps | `npm install` | `src/frontend/` |
| Run migration | `npx prisma migrate dev --name <name>` | `src/backend/` |
| Generate Prisma client | `npm run prisma:generate` | `src/backend/` |
| Seed database | `npm run prisma:seed` | `src/backend/` |
| Start backend | `npm run dev` | `src/backend/` |
| Start frontend | `npm run dev` | `src/frontend/` |
| Run backend tests | `npm test` | `src/backend/` |
| Run frontend tests | `npm test` | `src/frontend/` |
| Run E2E tests | `npx playwright test` | Repository root |
| Backend lint | `npm run lint` | `src/backend/` |
| Frontend lint | `npm run lint` | `src/frontend/` |
| Open Prisma Studio | `npx prisma studio` | `src/backend/` |
| Docker full stack | `docker-compose up -d` | Repository root |
