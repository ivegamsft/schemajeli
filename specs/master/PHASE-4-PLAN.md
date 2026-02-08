# Phase 4: Frontend Implementation - PLAN

**Duration:** 4 weeks (Weeks 11-14)  
**Status:** Starting  
**Dependencies:** Phase 2 Backend (✅ COMPLETE)

---

## 📋 Overview

Build a modern React frontend application for SchemaJeli that consumes the Phase 2 backend API. The frontend will provide users with an intuitive interface for browsing, managing, and analyzing database schemas.

---

## 🎯 Phase 4 Sub-Phases

### **P-4.1: Project Setup & Infrastructure** (Week 11)
**Objectives:**
- Initialize Vite + React + TypeScript project
- Configure development environment
- Set up routing, state management, styling
- Create base layout and navigation structure
- Implement environment configuration

**Deliverables:**
- Vite project scaffold with React 18, TypeScript 5
- React Router v6 setup with main routes
- Zustand store for state management
- Tailwind CSS + UI component library setup
- Base layout with header, sidebar, main content area
- API client configuration with Axios/Fetch
- Environment variables setup (.env.local, .env.production)

**Success Criteria:**
- `npm run dev` starts app at http://localhost:5173
- Hot reload working for development
- TypeScript strict mode enabled
- ESLint + Prettier configured

---

### **P-4.2: Authentication & User Management UI** (Week 11-12)
**Objectives:**
- Build login/logout pages
- Implement session/token management
- Create user profile and settings pages
- Implement role-based UI rendering
- Add protected routes

**Deliverables:**
- `LoginPage.tsx` - Login form with email/password
- `LogoutPage.tsx` - Logout confirmation
- `ProfilePage.tsx` - User profile view and edit
- `SettingsPage.tsx` - User settings (change password, preferences)
- `ProtectedRoute.tsx` - Route guard component
- `useAuth.ts` hook - Authentication context/state
- `AuthService.ts` - API calls to backend auth endpoints

**Routes:**
- `/login` - Login page
- `/logout` - Logout page
- `/profile` - User profile
- `/settings` - Settings page
- `/dashboard` - Protected dashboard

**Success Criteria:**
- Login works with test credentials
- JWT token stored in localStorage
- Refresh token refreshes automatically
- Protected routes redirect to login
- UI adapts based on user role

---

### **P-4.3: Server & Database Management Pages** (Week 12-13)
**Objectives:**
- Build server list, create, edit, delete pages
- Build database list, create, edit, delete pages
- Implement pagination, filtering, sorting
- Add bulk operations
- Create data tables with sorting and filtering

**Deliverables:**
- `ServersPage.tsx` - List servers with pagination/filtering
- `ServerDetailPage.tsx` - Server details, edit server
- `CreateServerPage.tsx` - Create new server
- `DatabasesPage.tsx` - List databases with filtering
- `DatabaseDetailPage.tsx` - Database details and tables
- `CreateDatabasePage.tsx` - Create new database
- `ServerForm.tsx` - Reusable server form component
- `DatabaseForm.tsx` - Reusable database form component
- `DataTable.tsx` - Generic data table with sorting/filtering
- Data tables with columns: name, host, type, location, status
- Forms with validation (Zod or Yup)
- Modal dialogs for create/edit operations
- Toast notifications for success/error messages

**Routes:**
- `/servers` - Servers list
- `/servers/:id` - Server details
- `/servers/new` - Create server
- `/databases` - Databases list
- `/databases/:id` - Database details
- `/databases/new` - Create database

**Success Criteria:**
- Fetch data from backend API
- CRUD operations functional
- Pagination works (10, 25, 50 items/page)
- Filtering by search term, status, type
- Delete confirmation dialogs
- Sorting on table columns
- Form validation before submission
- Error handling with user-friendly messages

---

### **P-4.4: Table & Column Management Pages** (Week 13)
**Objectives:**
- Build table list and detail pages
- Build element/column management UI
- Implement element position management
- Create data type selectors
- Add metadata editing

**Deliverables:**
- `TablesPage.tsx` - List tables by database
- `TableDetailPage.tsx` - Table details with elements/columns
- `ElementsPage.tsx` - Elements management
- `ElementDetailPage.tsx` - Element details, metadata editor
- `TableForm.tsx` - Create/edit table form
- `ElementForm.tsx` - Create/edit element form
- `ElementsTable.tsx` - Elements list with position management
- `DataTypeSelector.tsx` - Data type picker component
- Element metadata editor (dataType, length, precision, scale, constraints)
- Drag-and-drop for column reordering (position)
- PK/FK flag toggles with visual indicators

**Routes:**
- `/databases/:databaseId/tables` - Tables in database
- `/tables/:id` - Table details
- `/tables/:id/elements` - Table elements
- `/elements/:id` - Element details
- `/tables/new` - Create table
- `/elements/new` - Create element

**Success Criteria:**
- Display table metadata
- List columns with all attributes
- Drag-drop column reordering
- Edit column properties
- PK/FK indicators visible
- Create new tables and columns
- Delete tables/columns with confirmation
- Position tracking maintained

---

### **P-4.5: Search & Discovery Pages** (Week 13-14)
**Objectives:**
- Build advanced search interface
- Implement cross-entity search
- Create search results page
- Build filters and facets
- Add search history/saved searches

**Deliverables:**
- `SearchPage.tsx` - Advanced search interface
- `SearchResultsPage.tsx` - Search results display
- `SearchBar.tsx` - Global search component
- `SearchFilters.tsx` - Filter sidebar
- `SearchResults.tsx` - Results list with preview
- `AbbreviationSearchPage.tsx` - Abbreviation lookup
- Advanced search with filters:
  - Entity type (Server, Database, Table, Element)
  - RDBMS type
  - Status (Active/Inactive)
  - Data type (for elements)
- Search across all entity types simultaneously
- Faceted search results
- Quick filters (Active only, My databases, etc.)

**Routes:**
- `/search` - Advanced search page
- `/search/results` - Search results
- `/search/abbreviations` - Abbreviation lookup

**Success Criteria:**
- Search returns results in <500ms
- Filters reduce results appropriately
- Results paginated
- Entity type filters working
- Click on result shows details
- Abbreviation lookup functional

---

### **P-4.6: Reports & Analytics Pages** (Week 14)
**Objectives:**
- Build dashboard with key metrics
- Create schema statistics pages
- Implement export functionality
- Add visualization charts

**Deliverables:**
- `DashboardPage.tsx` - Main dashboard with KPIs
- `StatisticsPage.tsx` - Detailed statistics
- `SchemaAnalysisPage.tsx` - Schema analysis and insights
- Dashboard widgets:
  - Total servers, databases, tables, columns count
  - RDBMS type distribution (pie chart)
  - Table sizes (bar chart)
  - Data type distribution
  - Recently modified items
  - Active user stats
- Export functionality (CSV, JSON, PDF)
- Statistics tables with sorting/filtering
- Charts using Chart.js or Recharts

**Routes:**
- `/dashboard` - Main dashboard
- `/statistics` - Statistics and reports
- `/analysis` - Schema analysis

**Success Criteria:**
- Dashboard loads in <2s
- Charts render correctly
- Statistics calculated accurately
- Export to CSV/JSON working
- Responsive on mobile devices

---

### **P-4.7: Testing & Optimization** (Week 14)
**Objectives:**
- Implement comprehensive test suite
- Achieve 70% code coverage
- Optimize performance
- Fix bugs and issues
- Security hardening

**Deliverables:**
- Unit tests for all components (Jest + React Testing Library)
- Integration tests for main features
- E2E tests for critical user flows (Playwright)
- Component tests covering:
  - Form validation
  - Data table interactions
  - API error handling
  - Loading states
  - Empty states
- Performance optimization:
  - Code splitting and lazy loading
  - Image optimization
  - Bundle size analysis
  - Caching strategies
- Security:
  - XSS prevention
  - CSRF tokens
  - Secure storage of tokens
  - Input sanitization
- Bug fixes and edge case handling

**Test Coverage Targets:**
- Components: 70%+
- Services: 80%+
- Hooks: 75%+
- Overall: 70%+

**Success Criteria:**
- All critical paths tested
- Tests passing on CI/CD
- Build size < 500KB (gzipped)
- Lighthouse score > 80
- No console errors in development
- Accessibility score > 90 (WCAG 2.1 AA)

---

## 📁 Project Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Navigation.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Layout.tsx
│   │   ├── auth/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── ProtectedRoute.tsx
│   │   │   └── LogoutButton.tsx
│   │   ├── table/
│   │   │   ├── DataTable.tsx
│   │   │   ├── TableActions.tsx
│   │   │   └── Pagination.tsx
│   │   ├── forms/
│   │   │   ├── ServerForm.tsx
│   │   │   ├── DatabaseForm.tsx
│   │   │   ├── TableForm.tsx
│   │   │   └── ElementForm.tsx
│   │   ├── modals/
│   │   │   ├── ConfirmDialog.tsx
│   │   │   ├── Modal.tsx
│   │   │   └── FormModal.tsx
│   │   └── search/
│   │       ├── SearchBar.tsx
│   │       ├── SearchFilters.tsx
│   │       └── SearchResults.tsx
│   ├── pages/
│   │   ├── AuthPages/
│   │   │   ├── LoginPage.tsx
│   │   │   ├── LogoutPage.tsx
│   │   │   └── ProfilePage.tsx
│   │   ├── ServerPages/
│   │   │   ├── ServersPage.tsx
│   │   │   ├── ServerDetailPage.tsx
│   │   │   └── CreateServerPage.tsx
│   │   ├── DatabasePages/
│   │   │   ├── DatabasesPage.tsx
│   │   │   ├── DatabaseDetailPage.tsx
│   │   │   └── CreateDatabasePage.tsx
│   │   ├── TablePages/
│   │   │   ├── TablesPage.tsx
│   │   │   ├── TableDetailPage.tsx
│   │   │   └── CreateTablePage.tsx
│   │   ├── ElementPages/
│   │   │   ├── ElementsPage.tsx
│   │   │   ├── ElementDetailPage.tsx
│   │   │   └── CreateElementPage.tsx
│   │   ├── SearchPages/
│   │   │   ├── SearchPage.tsx
│   │   │   ├── SearchResultsPage.tsx
│   │   │   └── AbbreviationSearchPage.tsx
│   │   ├── ReportPages/
│   │   │   ├── DashboardPage.tsx
│   │   │   ├── StatisticsPage.tsx
│   │   │   └── SchemaAnalysisPage.tsx
│   │   └── ErrorPages/
│   │       ├── NotFoundPage.tsx
│   │       └── ErrorBoundary.tsx
│   ├── services/
│   │   ├── api.ts
│   │   ├── authService.ts
│   │   ├── serverService.ts
│   │   ├── databaseService.ts
│   │   ├── tableService.ts
│   │   ├── elementService.ts
│   │   ├── searchService.ts
│   │   └── abbreviationService.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useApi.ts
│   │   ├── useDebounce.ts
│   │   ├── useFetch.ts
│   │   ├── usePagination.ts
│   │   └── useLocalStorage.ts
│   ├── store/
│   │   ├── authStore.ts
│   │   ├── uiStore.ts
│   │   ├── dataStore.ts
│   │   └── index.ts
│   ├── types/
│   │   ├── auth.ts
│   │   ├── entities.ts
│   │   ├── api.ts
│   │   └── ui.ts
│   ├── utils/
│   │   ├── apiClient.ts
│   │   ├── validators.ts
│   │   ├── formatters.ts
│   │   ├── storage.ts
│   │   └── constants.ts
│   ├── styles/
│   │   ├── globals.css
│   │   ├── variables.css
│   │   └── components.css
│   ├── App.tsx
│   ├── Router.tsx
│   ├── main.tsx
│   └── index.css
├── tests/
│   ├── components/
│   ├── pages/
│   ├── services/
│   ├── hooks/
│   └── utils/
├── public/
│   ├── images/
│   ├── icons/
│   └── favicon.ico
├── .env.local
├── .env.example
├── vite.config.ts
├── vitest.config.ts
├── tsconfig.json
├── tailwind.config.js
├── postcss.config.js
├── package.json
├── README.md
└── .prettierrc
```

---

## 🛠️ Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Framework** | React | 18.x |
| **Build Tool** | Vite | 5.x |
| **Language** | TypeScript | 5.x |
| **Routing** | React Router | 6.x |
| **State Management** | Zustand | 4.x |
| **Styling** | Tailwind CSS | 3.x |
| **UI Components** | shadcn/ui | Latest |
| **HTTP Client** | Axios | 1.x |
| **Form Validation** | Zod | 3.x |
| **Testing** | Vitest + RTL | Latest |
| **E2E Testing** | Playwright | Latest |
| **Linting** | ESLint | 9.x |
| **Formatting** | Prettier | 3.x |
| **Icons** | React Icons | Latest |
| **Charts** | Recharts | 2.x |
| **Notifications** | Sonner/Toast | Latest |

---

## 🔗 API Integration

**Backend API Base URL:** `http://localhost:3000/api/v1`

**Authentication:**
```typescript
// Token stored in localStorage
const token = localStorage.getItem('accessToken');

// Headers
Authorization: Bearer ${token}
Content-Type: application/json
```

**Service Pattern:**
```typescript
// Example: ServerService
export const serverService = {
  getAll: (page, limit) => axios.get('/servers', { params: { page, limit } }),
  getById: (id) => axios.get(`/servers/${id}`),
  create: (data) => axios.post('/servers', data),
  update: (id, data) => axios.put(`/servers/${id}`, data),
  delete: (id) => axios.delete(`/servers/${id}`),
  getStats: () => axios.get('/servers/stats'),
};
```

---

## 🎨 Design System

**Color Palette:**
- Primary: #0066cc (Blue)
- Success: #28a745 (Green)
- Warning: #ffc107 (Yellow)
- Error: #dc3545 (Red)
- Dark: #1a1a1a
- Light: #f8f9fa

**Typography:**
- Font Family: Inter, system-ui, sans-serif
- Heading: 32px (h1), 24px (h2), 20px (h3)
- Body: 16px (regular), 14px (small)
- Line Height: 1.5x for body, 1.2x for headings

**Spacing:** 8px base unit (4, 8, 16, 24, 32, 48px)

**Components:**
- Buttons: Primary, Secondary, Danger, Ghost
- Forms: Input, Select, Textarea, Checkbox, Radio
- Tables: Data table with sort/filter
- Cards: For grouping related content
- Modals: For confirmations and forms
- Tabs: For organizing content

---

## 📊 Success Metrics

- ✅ All 7 main routes fully functional
- ✅ CRUD operations for all entities
- ✅ Authentication and role-based access working
- ✅ Search and filtering functional
- ✅ 70%+ test coverage
- ✅ Lighthouse score > 80
- ✅ < 500KB bundle size (gzipped)
- ✅ Zero console errors
- ✅ All forms validated
- ✅ Responsive on mobile/tablet/desktop

---

## 📈 Development Timeline

| Week | Focus | Deliverables |
|------|-------|--------------|
| **Week 11** | Setup & Auth UI | Vite project, login, routing |
| **Week 12** | Server/DB Pages | CRUD pages, forms, tables |
| **Week 13** | Tables/Cols & Search | Element management, search |
| **Week 14** | Reports & Testing | Dashboard, tests, optimization |

---

## 🚀 Getting Started

```bash
# Initialize frontend project with Vite
npm create vite@latest frontend -- --template react-ts

# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Install additional packages
npm install react-router-dom zustand axios zod
npm install -D tailwindcss postcss autoprefixer
npm install -D vitest @testing-library/react @testing-library/jest-dom

# Start development server
npm run dev

# Run tests
npm run test

# Build for production
npm run build
```

---

**Phase 4 Status:** 🟡 **NOT STARTED**  
**Estimated Completion:** Week 14  
**Team Velocity:** TBD (Backend: 1 day, Frontend: ~4 weeks)

---

*Plan Created: January 30, 2026*
