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
│   ├── terraform/             # Terraform modules
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── azure-postgresql.tf
│   │   ├── azure-app-service.tf
│   │   └── azure-monitoring.tf
│   ├── bicep/                 # Azure Bicep (alternative)
│   └── kubernetes/            # K8s manifests
│       ├── deployment.yml
│       ├── service.yml
│       └── ingress.yml
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
- **ORM:** Prisma or TypeORM
- **Validation:** Zod
- **Auth:** JWT (jsonwebtoken), bcrypt, Passport.js
- **Testing:** Jest, Supertest
- **Logging:** Winston or Pino
- **API Docs:** Swagger/OpenAPI

### Frontend
- **Framework:** React 18+
- **Build Tool:** Vite
- **Language:** TypeScript
- **UI Library:** Tailwind CSS + Shadcn/UI
- **State:** Redux Toolkit + React Query
- **Forms:** React Hook Form + Zod
- **Testing:** Vitest, React Testing Library
- **E2E:** Playwright

### Database
- **Primary:** PostgreSQL 14+
- **Migration Tool:** Prisma Migrate or Flyway
- **Audit Trail:** TimescaleDB extension

### Infrastructure
- **IaC:** Terraform (primary) or Azure Bicep
- **Containers:** Docker
- **Orchestration:** Kubernetes (AKS)
- **Cloud Provider:** Azure (primary)
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
- **Production:** Azure Kubernetes Service (AKS)

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
│   ├── POST /login
│   ├── POST /logout
│   └── POST /refresh
├── /users
│   ├── GET /
│   ├── GET /:id
│   ├── POST /
│   ├── PUT /:id
│   └── DELETE /:id
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

## Security

- All endpoints require authentication (except /auth/login)
- Role-based access control (Admin, Maintainer, Viewer)
- JWT tokens with 1-hour expiry
- Refresh tokens with 7-day expiry
- Password hashing with bcrypt (12 rounds)
- Rate limiting: 100 req/min per user
- HTTPS only in production
- SQL injection prevention via parameterized queries
- CSRF protection
- Comprehensive audit logging

## Monitoring

- Application Insights for metrics
- Structured JSON logging
- Distributed tracing with correlation IDs
- Health check endpoints
- Performance monitoring
- Error tracking and alerting

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
2. Complete infrastructure code (Terraform/Bicep)
3. Implement backend Phase 1 tasks
4. Implement frontend Phase 1 tasks
5. Setup CI/CD pipelines
6. Begin Phase 2 implementation

## Contact

- **Project Lead:** [To Be Assigned]
- **Tech Lead Backend:** [To Be Assigned]
- **Tech Lead Frontend:** [To Be Assigned]
- **DevOps Lead:** [To Be Assigned]
