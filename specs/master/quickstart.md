# QuickStart Guide: SchemaJeli

**Version**: 1.0.0  
**Last Updated**: 2026-02-08  
**Target Audience**: Developers, DevOps Engineers

## Overview

SchemaJeli is a modern metadata repository for managing database schemas across multiple RDBMS platforms. This guide will get you up and running with a local development environment in under 30 minutes.

## Prerequisites

### Required Software
- **Node.js** 18+ LTS ([download](https://nodejs.org/))
- **Docker Desktop** 4.0+ ([download](https://www.docker.com/products/docker-desktop))
- **Git** 2.0+ ([download](https://git-scm.com/downloads))
- **VS Code** (recommended) with TypeScript and Prisma extensions

### Azure Entra ID Configuration (For Authentication)
- Azure subscription with App Registration for:
  - **Backend App**: `<backend-app-registration-id>`
  - **Frontend App**: `<frontend-app-registration-id>`
  - **Tenant ID**: `<tenant-id>` (<tenant-domain>)
- For local development without Azure, use `RBAC_MOCK_ROLES` environment variable

### System Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 10GB free space
- **OS**: Windows 10/11, macOS 11+, or Linux (Ubuntu 20.04+)

---

## Step 1: Clone Repository

```bash
git clone https://github.com/yourorg/schemajeli.git
cd schemajeli
```

**Expected Output**: Repository cloned to `./schemajeli` directory.

---

## Step 2: Start Infrastructure (Docker Compose)

SchemaJeli uses Docker Compose for local PostgreSQL database.

```bash
# Start PostgreSQL database
docker-compose up -d

# Verify services are running
docker-compose ps
```

**Expected Output**:
```
NAME                SERVICE             STATUS
schemajeli-db-1     postgres            running
```

**Services Started**:
- **PostgreSQL 15**: `localhost:5432` (user: `postgres`, password: `postgres`, database: `schemajeli_dev`)

**Troubleshooting**:
- If port 5432 is already in use, edit `docker-compose.yml` to use a different port (e.g., `5433:5432`)
- Check logs: `docker-compose logs -f postgres`

---

## Step 3: Backend Setup

### 3.1 Install Dependencies

```bash
cd src/backend
npm install
```

**Expected Output**: Dependencies installed in `node_modules/` (this may take 2-3 minutes).

### 3.2 Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Database (Docker Compose default)
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/schemajeli_dev"

# Azure Entra ID (Backend App Registration)
AZURE_TENANT_ID="<tenant-id>"
AZURE_CLIENT_ID="<backend-app-registration-id>"
AZURE_CLIENT_SECRET="<your-secret-from-key-vault>"

# JWT Validation
JWT_AUDIENCE="api://<backend-app-registration-id>"
JWT_ISSUER="https://sts.windows.net/<tenant-id>/"

# RBAC Group Mapping (Entra ID group object IDs)
RBAC_GROUP_ADMIN="<admin-group-id>"
RBAC_GROUP_MAINTAINER="<maintainer-group-id>"
RBAC_GROUP_VIEWER="<viewer-group-id>"

# Local Dev Fallback (use mock roles without Azure)
RBAC_MOCK_ROLES="Admin"  # Options: Admin, Maintainer, Viewer (comma-separated)

# Server Configuration
NODE_ENV="development"
PORT=3000
```

**⚠️ Security Note**: Never commit `.env` file to version control. The file is gitignored by default.

### 3.3 Database Migration

```bash
# Generate Prisma Client types
npx prisma generate

# Run database migrations
npx prisma migrate dev

# Seed database with sample data (optional)
npm run db:seed
```

**Expected Output**:
```
✔ Generated Prisma Client
✔ Migrations applied: 5 pending migrations
✔ Database seeded with 10 servers, 50 databases, 200 tables
```

**Verify Database**:
```bash
npx prisma studio
```
Opens Prisma Studio at `http://localhost:5555` for database browsing.

### 3.4 Start Backend Server

```bash
npm run dev
```

**Expected Output**:
```
[2026-02-08 10:00:00] INFO: Server started on http://localhost:3000
[2026-02-08 10:00:00] INFO: Database connected
[2026-02-08 10:00:00] INFO: API documentation: http://localhost:3000/api-docs
```

**Health Check**:
```bash
curl http://localhost:3000/api/health
```

**Expected Response**:
```json
{
  "status": "ok",
  "timestamp": 1707387600000,
  "uptime": 5.123,
  "database": "connected"
}
```

---

## Step 4: Frontend Setup

### 4.1 Install Dependencies

Open a **new terminal window** (keep backend running):

```bash
cd src/frontend
npm install
```

### 4.2 Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# API Backend
VITE_API_BASE_URL="http://localhost:3000/api/v1"

# Azure Entra ID (Frontend App Registration)
VITE_AZURE_TENANT_ID="<tenant-id>"
VITE_AZURE_CLIENT_ID="<frontend-app-registration-id>"
VITE_AZURE_REDIRECT_URI="http://localhost:5173"

# Feature Flags
VITE_FEATURE_SEARCH="true"
VITE_FEATURE_REPORTS="true"
```

### 4.3 Start Frontend Dev Server

```bash
npm run dev
```

**Expected Output**:
```
VITE v5.0.0  ready in 1200 ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
➜  press h + enter to show help
```

---

## Step 5: Access Application

Open your browser and navigate to:

**Frontend**: http://localhost:5173  
**Backend API**: http://localhost:3000  
**API Documentation**: http://localhost:3000/api-docs  
**Database Studio**: http://localhost:5555 (if running `npx prisma studio`)

### Authentication Flow

#### With Azure Entra ID (Production-like):
1. Click **"Sign In"** button
2. Redirected to Microsoft login page
3. Authenticate with your Entra ID credentials
4. Redirected back to SchemaJeli with access token
5. User role (Admin/Maintainer/Viewer) determined from Entra ID group membership

#### Without Azure (Local Dev Fallback):
- Backend uses `RBAC_MOCK_ROLES` from `.env`
- Set `RBAC_MOCK_ROLES="Admin"` for full access
- No actual authentication required (mock user injected)

---

## Step 6: Verify Installation

### Run Backend Tests

```bash
cd src/backend

# Unit tests
npm test

# Integration tests
npm run test:integration

# Coverage report
npm run test:coverage
```

**Expected Output**:
```
✓ tests/unit/services/serverService.test.ts (12 tests)
✓ tests/integration/api/servers.test.ts (8 tests)

Test Files: 24 passed (24)
Tests:      156 passed (156)
Coverage:   85.4% (target: 80%)
```

### Run Frontend Tests

```bash
cd src/frontend

# Unit + component tests
npm test

# E2E tests (requires backend + frontend running)
npm run test:e2e
```

**Expected Output**:
```
✓ tests/unit/components/ServerList.test.tsx (5 tests)
✓ tests/e2e/servers.spec.ts (3 tests)

Test Files: 18 passed (18)
Tests:      92 passed (92)
```

---

## Step 7: Explore API (Optional)

### Using API Documentation (Swagger UI)

Navigate to http://localhost:3000/api-docs

Interactive API documentation with request/response examples.

### Using curl

#### Get All Servers (Requires Auth Token)

```bash
# Get access token (if using Azure)
TOKEN="<your-jwt-token>"

# Query servers
curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:3000/api/v1/servers
```

**Expected Response**:
```json
{
  "status": "success",
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Production PostgreSQL",
      "serverType": "POSTGRESQL",
      "host": "prod-db.example.com",
      "port": 5432,
      "status": "ACTIVE",
      "createdAt": "2026-01-15T10:00:00Z"
    }
  ],
  "meta": {
    "total": 10,
    "page": 1,
    "limit": 25
  }
}
```

#### Create a New Server (Admin Only)

```bash
curl -X POST http://localhost:3000/api/v1/servers \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Dev MySQL Server",
       "serverType": "MYSQL",
       "host": "dev-mysql.local",
       "port": 3306,
       "description": "Development environment MySQL"
     }'
```

---

## Common Issues & Troubleshooting

### Issue: Port 5432 Already in Use

**Symptom**: `docker-compose up` fails with "port is already allocated"

**Solution**:
```bash
# Find process using port 5432
# Windows:
netstat -ano | findstr :5432
taskkill /PID <process-id> /F

# macOS/Linux:
lsof -i :5432
kill -9 <process-id>

# OR change port in docker-compose.yml:
# ports:
#   - "5433:5432"  # Use 5433 on host
```

### Issue: `npx prisma migrate dev` Fails

**Symptom**: "P1001: Can't reach database server at localhost:5432"

**Solution**:
1. Verify Docker containers are running: `docker-compose ps`
2. Check database logs: `docker-compose logs postgres`
3. Test database connection:
   ```bash
   # macOS/Linux:
   psql postgresql://postgres:postgres@localhost:5432/schemajeli_dev
   
   # Windows (use pgAdmin or DBeaver)
   ```

### Issue: Frontend Cannot Reach Backend API

**Symptom**: API calls return `ERR_CONNECTION_REFUSED` in browser console

**Solution**:
1. Verify backend is running: `curl http://localhost:3000/api/health`
2. Check `VITE_API_BASE_URL` in `src/frontend/.env`
3. Ensure CORS is configured (backend allows `http://localhost:5173`)

### Issue: Authentication Fails (Azure Entra ID)

**Symptom**: "AADSTS50011: The redirect URI does not match"

**Solution**:
1. Verify redirect URI in Azure App Registration matches `VITE_AZURE_REDIRECT_URI`
2. Check `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` are correct
3. For local dev without Azure, use `RBAC_MOCK_ROLES` fallback

### Issue: Tests Fail with Database Errors

**Symptom**: "P2002: Unique constraint failed on the fields: (`name`)"

**Solution**:
```bash
# Reset test database
cd src/backend
npx prisma migrate reset --force
npm run db:seed
npm test
```

---

## Next Steps

### Development Workflow

1. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**: Edit code in `src/backend/` or `src/frontend/`

3. **Run Tests**:
   ```bash
   # Backend
   cd src/backend && npm test
   
   # Frontend
   cd src/frontend && npm test
   ```

4. **Commit Changes**:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push and Create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```
   Open pull request on GitHub.

### Code Quality Checks

Before committing:

```bash
# Lint code
npm run lint

# Type check
npm run type-check

# Format code
npm run format

# Run all checks
npm run validate
```

### Database Schema Changes

1. Edit `src/backend/prisma/schema.prisma`
2. Create migration:
   ```bash
   npx prisma migrate dev --name add-new-field
   ```
3. Commit migration files in `prisma/migrations/`

### Useful Commands

```bash
# Backend
npm run dev              # Start dev server (hot reload)
npm run build            # Build for production
npm run start            # Start production server
npm test                 # Run unit tests
npm run test:watch       # Watch mode for tests
npm run db:reset         # Reset database (data loss!)

# Frontend
npm run dev              # Start dev server (hot reload)
npm run build            # Build for production
npm run preview          # Preview production build
npm test                 # Run tests
npm run test:e2e         # E2E tests
npm run lint             # Lint code
```

---

## Architecture Overview

### Project Structure

```
SchemaJeli/
├── src/
│   ├── backend/          # Node.js/Express API
│   │   ├── src/
│   │   │   ├── api/      # Routes, controllers
│   │   │   ├── services/ # Business logic
│   │   │   ├── models/   # Prisma schema
│   │   │   └── middleware/ # Auth, RBAC, logging
│   │   ├── tests/        # Unit + integration tests
│   │   └── prisma/       # Database schema + migrations
│   └── frontend/         # React 19 SPA
│       ├── src/
│       │   ├── components/ # React components
│       │   ├── pages/    # Page components
│       │   ├── store/    # Zustand state management
│       │   └── services/ # API client (MSAL)
│       └── tests/        # Unit + E2E tests
├── infrastructure/       # Terraform (Azure IaC)
├── specs/                # Feature specifications
├── docker-compose.yml    # Local development environment
└── README.md
```

### Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, TypeScript, Vite, Tailwind CSS v4 |
| Backend | Node.js 18+ LTS, Express, Prisma ORM |
| Database | PostgreSQL 15+ |
| Auth | Azure Entra ID (MSAL) |
| State | Zustand (frontend) |
| Testing | Vitest, React Testing Library, Playwright |
| Infrastructure | Azure App Service, Static Web App, Terraform |

---

## Additional Resources

- **Main Documentation**: [README.md](../../README.md)
- **Architecture**: [ARCHITECTURE.md](../../ARCHITECTURE.md)
- **Contributing**: [CONTRIBUTING.md](../../CONTRIBUTING.md)
- **API Reference**: http://localhost:3000/api-docs (when running locally)
- **Prisma Docs**: https://www.prisma.io/docs
- **React Docs**: https://react.dev
- **Azure Entra ID**: https://learn.microsoft.com/en-us/entra/identity-platform/

---

## Support

- **Issues**: [GitHub Issues](https://github.com/yourorg/schemajeli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourorg/schemajeli/discussions)
- **Email**: support@schemajeli.dev

---

**Last Updated**: 2026-02-08  
**Maintainer**: SchemaJeli Development Team
