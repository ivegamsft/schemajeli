# SchemaJeli Frontend Architecture (P-1.2.3)

**Phase:** 1.2 – Design & Specification  
**Owner:** Frontend Lead  
**Status:** Complete (Initial Design)

## Objectives

1. Define component architecture (Atomic Design)
2. Specify routing and page structure
3. Choose state management strategy
4. Define API integration pattern
5. Establish UI/UX conventions
6. Provide folder structure and naming rules

---

## Tech Stack

- **Framework:** React 18 + TypeScript
- **Build Tool:** Vite
- **Styling:** Tailwind CSS
- **State:** Redux Toolkit + React Query
- **Forms:** React Hook Form + Zod
- **Routing:** React Router
- **Icons:** Lucide (or Heroicons)
- **Testing:** Vitest + React Testing Library + Playwright

---

## Application Structure

```
src/frontend/
  src/
    app/
      store.ts
      queryClient.ts
      routes.tsx
      providers.tsx
    assets/
    components/
      atoms/
      molecules/
      organisms/
      templates/
      pages/
    features/
      auth/
      servers/
      databases/
      tables/
      elements/
      abbreviations/
      reports/
      search/
    hooks/
    layouts/
    services/
      apiClient.ts
      authService.ts
      metadataService.ts
    types/
    utils/
    App.tsx
    main.tsx
```

---

## Component Architecture (Atomic Design)

### Atoms
- Button, Input, Select, Badge, Spinner, Icon

### Molecules
- SearchBar, Pagination, FormField, Breadcrumbs, StatusChip

### Organisms
- DataTable, SidebarNav, TopBar, FiltersPanel, DetailPanel

### Templates
- DashboardLayout, EntityListLayout, EntityDetailLayout

### Pages
- LoginPage
- DashboardPage
- ServersPage
- ServerDetailPage
- DatabasesPage
- TablesPage
- ElementsPage
- AbbreviationsPage
- ReportsPage
- SearchPage
- NotFoundPage

---

## Routing Structure

```
/                         → DashboardPage
/login                   → LoginPage
/servers                 → ServersPage
/servers/:id             → ServerDetailPage
/servers/:id/databases   → DatabasesPage
/databases/:id/tables    → TablesPage
/tables/:id/elements     → ElementsPage
/abbreviations           → AbbreviationsPage
/search                  → SearchPage
/reports                 → ReportsPage
```

---

## State Management Strategy

- **React Query**: server state, caching, pagination
- **Redux Toolkit**: UI state (theme, modals, filters)
- **Local State**: component-only (forms, toggles)

Example split:
- React Query handles `/servers`, `/databases`, `/tables`, `/elements`
- Redux handles sidebar collapse, filters, selected entity IDs

---

## API Integration

**Pattern:**
- `services/apiClient.ts` wraps Axios (or fetch)
- `services/*Service.ts` modules expose entity-based functions
- React Query hooks live in `features/{entity}/hooks.ts`

Example:
```ts
// services/metadataService.ts
export const getServers = (params) => api.get('/servers', { params });
```

---

## Authentication Flow (Frontend)

1. User logs in → POST `/auth/login`
2. Store JWT in memory + httpOnly cookie (if supported)
3. Attach bearer token to API requests
4. Auto-refresh tokens when expired
5. Redirect to `/login` on 401

---

## UI/UX Standards

- **Color System:** Semantic tokens (primary, secondary, success, warning, danger)
- **Spacing:** 4/8/12/16 scale
- **Typography:** 3 font sizes (sm, base, lg)
- **Data Tables:** 20 row default, infinite scroll optional
- **Search:** global omnibox + filtered entity search

---

## Wireframes (Textual)

### Dashboard
- KPI cards (Servers, Databases, Tables, Elements)
- Recent changes (Audit log summary)
- Quick search

### Entity List Pages
- Left: Filters panel
- Center: Table listing
- Right: Detail preview (optional)

### Entity Detail
- Header with actions (Edit / Delete)
- Tabs: Overview | Columns | Dependencies | Audit

---

## Accessibility

- WCAG 2.1 AA compliance
- Keyboard navigation
- Focus states on all inputs
- Screen-reader labels

---

## Testing Strategy

- **Unit Tests:** Components and hooks (Vitest)
- **Integration Tests:** Page flows
- **E2E Tests:** Login, browse, search, detail

---

## Deliverables

- [x] Frontend architecture document
- [ ] Component library setup
- [ ] Page routing implementation
- [ ] State management wiring
- [ ] API services abstraction

---

## Next Step

Proceed to **P-1.2.4: Authentication and Authorization Flow** design.
