# SchemaJeli - Modern Architecture

## Project Structure

```
SchemaJeli/
├── .github/workflows/          # CI/CD GitHub Actions workflows
│   ├── backend-ci.yml         # Backend build, test, security scan
│   ├── frontend-ci.yml        # Frontend build, test, lint
│   └── deploy.yml             # Deployment pipeline
│
├── .specify/                   # SpecKit planning documents
│   ├── spec.md                # Complete specification
│   ├── plan.md                # Migration plan & ADRs
│   ├── tasks.md               # Task breakdown
│   └── memory/
│       └── constitution.md    # Project principles
│
├── infrastructure/             # Infrastructure as Code
│   └── terraform/             # Terraform modules
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/
│
├── src/                        # Source code
│   ├── backend/               # Node.js/Express API
│   │   ├── src/
│   │   │   ├── api/           # API routes and controllers
│   │   │   ├── models/        # Database models
│   │   │   ├── services/      # Business logic
│   │   │   ├── middleware/    # Auth, validation, logging
│   │   │   ├── config/        # Configuration
│   │   │   ├── utils/         # Utilities
│   │   │   └── app.ts         # Express app setup
│   │   ├── tests/             # Test files
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── .env.example
│   │   └── Dockerfile
│   │
│   └── frontend/              # React web application
│       ├── src/
│       │   ├── components/    # React components
│       │   ├── pages/         # Page components
│       │   ├── services/      # API client
│       │   ├── store/         # State management
│       │   ├── hooks/         # Custom hooks
│       │   ├── utils/         # Utilities
│       │   ├── types/         # TypeScript types
│       │   ├── App.tsx
│       │   └── main.tsx
│       ├── public/            # Static assets
│       ├── tests/             # Test files
│       ├── package.json
│       ├── vite.config.ts
│       ├── tsconfig.json
│       └── Dockerfile
│
├── legacy/                     # Archived legacy ASP code
│   └── (moved from root)
│
├── docker-compose.yml          # Local development environment
├── .gitignore
├── .dockerignore
└── README.md
```

## Technology Stack

### Backend
- **Runtime:** Node.js 18+ LTS
- **Framework:** Express.js with TypeScript
- **ORM:** Prisma
- **Validation:** Zod
- **Auth:** Azure Entra ID (MSAL) — JWT validation via JWKS endpoint (no local passwords)
- **Testing:** Vitest, Supertest
- **Logging:** Winston (structured JSON logging)
- **API Docs:** Swagger/OpenAPI

### Frontend
- **Framework:** React 19
- **Build Tool:** Vite
- **Language:** TypeScript
- **UI Library:** Tailwind CSS v4
- **State:** Zustand (with persist middleware for auth state)
- **Forms:** React Hook Form + Zod
- **Testing:** Vitest, React Testing Library
- **E2E:** Playwright

### Database
- **Primary:** PostgreSQL 15+
- **Migration Tool:** Prisma Migrate
- **Audit Trail:** AuditLog table (soft deletes on all entities)

### Infrastructure
- **IaC:** Terraform
- **Containers:** Docker
- **Cloud Provider:** Azure
- **Compute:** Azure App Service (Backend), Azure Static Web App (Frontend)
- **Monitoring:** Azure Application Insights
- **CI/CD:** GitHub Actions

## Development Workflow

### Local Development Setup

1. **Clone Repository:**
   ```bash
   git clone https://github.com/yourorg/schemajeli.git
   cd schemajeli
   ```

2. **Start Infrastructure:**
   ```bash
   docker-compose up -d
   ```

3. **Backend Setup:**
   ```bash
   cd src/backend
   npm install
   cp .env.example .env
   npm run db:migrate
   npm run dev
   ```

4. **Frontend Setup:**
   ```bash
   cd src/frontend
   npm install
   npm run dev
   ```

5. **Access:**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:3000
   - API Docs: http://localhost:3000/api-docs

### Testing

```bash
# Backend tests
cd src/backend
npm test                    # Unit tests
npm run test:integration    # Integration tests
npm run test:coverage       # Coverage report

# Frontend tests
cd src/frontend
npm test                    # Unit tests
npm run test:e2e           # E2E tests
```

### Code Quality

```bash
# Linting
npm run lint

# Type checking
npm run type-check

# Security scanning
npm audit
```

## Deployment

### Environments

- **Development:** Local Docker Compose
- **Staging:** Azure App Service (staging slot)
- **Production:** Azure App Service + Azure Static Web App

### Deployment Process

1. **Push to GitHub:** Triggers CI/CD pipeline
2. **Build & Test:** All tests must pass
3. **Security Scan:** Snyk, OWASP ZAP
4. **Deploy to Staging:** Automatic
5. **Smoke Tests:** Automated validation
6. **Deploy to Production:** Manual approval
7. **Health Checks:** Automated monitoring

## API Structure

```
/api/v1
├── /auth
│   └── GET /me                  # Returns current user profile from Entra ID token
├── /servers
│   ├── GET /
│   ├── GET /:id
│   ├── POST /
│   ├── PUT /:id
│   └── DELETE /:id
├── /servers/:serverId/databases
│   └── (CRUD operations)
├── /servers/:serverId/databases/:dbId/tables
│   └── (CRUD operations)
├── /tables/:tableId/elements
│   └── (CRUD operations)
├── /search
│   ├── GET /servers
│   ├── GET /databases
│   ├── GET /tables
│   └── GET /elements
├── /abbreviations
│   └── (CRUD operations)
└── /reports
    ├── GET /server-summary
    ├── GET /database-detail
    └── POST /generate-ddl
```

> **Note:** Authentication is handled entirely by Azure Entra ID (MSAL).
> The frontend acquires tokens via MSAL and sends Bearer tokens to the backend.
> There are no local login/password endpoints — all user management is in Entra ID.

## Security

- All endpoints require Azure Entra ID authentication (JWT Bearer tokens)
- Role-based access control (Admin, Maintainer, Viewer) derived from Entra ID token claims
- JWT tokens validated via Microsoft JWKS endpoint
- Dev fallback: `RBAC_MOCK_ROLES` env var for local testing without Azure
- Rate limiting: 100 req/min per user
- HTTPS only in production
- SQL injection prevention via Prisma parameterized queries
- CSRF protection
- Comprehensive audit logging (AuditLog table)
- Soft deletes on all entities — no physical deletion of data

## Monitoring

- Application Insights for metrics
- Structured JSON logging (Winston)
- Distributed tracing with correlation IDs
- Health check endpoints
- Performance monitoring
- Error tracking and alerting

## Caching Strategy

SchemaJeli is a read-heavy metadata repository. The caching strategy is kept simple initially:

- **API response caching:** `Cache-Control` headers on GET endpoints for metadata that changes infrequently (e.g., server/database/table listings). Short TTLs (60–300s) to balance freshness and performance.
- **Frontend static assets:** Vite-generated hashed filenames enable long-lived cache (`max-age=31536000, immutable`) served via Azure Static Web App CDN.
- **No server-side cache layer** (e.g., Redis) initially — Prisma query performance against PostgreSQL is sufficient. Revisit if p95 response times exceed 100ms for simple queries.

## Legacy Data Migration Strategy

SchemaJeli modernizes a legacy ASP system (1999). The data migration approach:

1. **Assessment:** Inventory legacy database schemas and map to new Prisma data model (Server → Database → Table → Element hierarchy).
2. **ETL Scripts:** One-time TypeScript migration scripts (using Prisma Client) to extract legacy data, transform to new schema, and load into PostgreSQL.
3. **Validation:** Row-count and data-integrity checks comparing legacy and migrated data.
4. **Rollback:** Database snapshots before migration; migration scripts are idempotent so they can be re-run safely.
5. **Cutover:** Migration runs during a maintenance window; legacy system remains read-only until validation passes.

> **Status:** Not started. Migration scripts will be developed after backend CRUD implementation is stable.

## Migration Status

- ✅ Specification complete
- ✅ Planning complete
- ✅ Task breakdown complete
- ✅ Project structure scaffolded
- 🔄 Infrastructure code (in progress)
- 🔄 Backend implementation (not started)
- 🔄 Frontend implementation (not started)
- ❌ Data migration (not started)
- ❌ Deployment (not started)

## Next Steps

1. Review and approve project structure
2. Complete infrastructure code (Terraform)
3. Implement backend Phase 1 tasks
4. Implement frontend Phase 1 tasks
5. Setup CI/CD pipelines
6. Begin Phase 2 implementation
7. Develop legacy data migration scripts

## Contact

- **Project Lead:** [To Be Assigned]
- **Tech Lead Backend:** [To Be Assigned]
- **Tech Lead Frontend:** [To Be Assigned]
- **DevOps Lead:** [To Be Assigned]
