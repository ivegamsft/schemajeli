# CI/CD Pipeline Design

**Project:** SchemaJeli  
**Phase:** 1.3.1 - Infrastructure & DevOps Setup  
**Version:** 1.0  
**Last Updated:** January 30, 2026

## Table of Contents
1. [Overview](#overview)
2. [Pipeline Architecture](#pipeline-architecture)
3. [GitHub Actions Workflows](#github-actions-workflows)
4. [Environment Strategy](#environment-strategy)
5. [Build Process](#build-process)
6. [Testing Automation](#testing-automation)
7. [Deployment Strategy](#deployment-strategy)
8. [Azure Infrastructure](#azure-infrastructure)
9. [Secrets Management](#secrets-management)
10. [Monitoring & Notifications](#monitoring--notifications)
11. [Rollback Strategy](#rollback-strategy)

---

## Overview

SchemaJeli uses **GitHub Actions** for continuous integration and continuous deployment (CI/CD). The pipeline automates building, testing, and deploying both backend and frontend components to Azure.

### Key Objectives
- ✅ Automated testing on every pull request
- ✅ Automated deployment to staging on merge to `develop`
- ✅ Manual approval for production deployment
- ✅ Infrastructure as Code (Terraform) for Azure resources
- ✅ Security scanning and dependency updates
- ✅ Performance and quality gates

### Technology Stack
| Component | Technology | Purpose |
|-----------|-----------|---------|
| **CI/CD Platform** | GitHub Actions | Workflow automation |
| **Infrastructure as Code** | Terraform | Azure resource provisioning |
| **Container Registry** | Azure Container Registry (ACR) | Docker image storage |
| **Backend Hosting** | Azure App Service (Linux) | Node.js application hosting |
| **Frontend Hosting** | Azure Static Web Apps | React SPA hosting |
| **Database** | Azure Database for PostgreSQL | Managed PostgreSQL |
| **Secrets Management** | Azure Key Vault + GitHub Secrets | Secure credential storage |
| **Monitoring** | Azure Application Insights | APM and logging |

---

## Pipeline Architecture

### High-Level Workflow

```mermaid
graph LR
    Developer[Developer] -->|git push| GitHub[GitHub Repository]
    GitHub -->|trigger| CI[CI Pipeline]
    
    CI --> Lint[Linting]
    CI --> Test[Unit Tests]
    CI --> Build[Build Artifacts]
    CI --> Scan[Security Scan]
    
    Lint --> QualityGate{Quality Gate}
    Test --> QualityGate
    Build --> QualityGate
    Scan --> QualityGate
    
    QualityGate -->|Pass| CD[CD Pipeline]
    QualityGate -->|Fail| Notify[Notify Developer]
    
    CD --> Staging[Deploy to Staging]
    Staging --> E2E[E2E Tests]
    E2E -->|Pass| Approval{Manual Approval}
    Approval -->|Approved| Production[Deploy to Production]
    Approval -->|Rejected| Stop[Stop]
    
    Production --> Monitor[Monitor Deployment]
    Monitor --> HealthCheck{Health Check}
    HealthCheck -->|Pass| Complete[Deployment Complete]
    HealthCheck -->|Fail| Rollback[Automatic Rollback]
    
    style CI fill:#3498db,color:#fff
    style CD fill:#e74c3c,color:#fff
    style Production fill:#27ae60,color:#fff
    style Rollback fill:#e74c3c,color:#fff
```

### Pipeline Stages

| Stage | Trigger | Duration | Responsibility |
|-------|---------|----------|----------------|
| **1. Lint & Format Check** | Every push | ~30s | Enforce code style |
| **2. Unit Tests** | Every push | ~2 min | Verify code correctness |
| **3. Build** | Every push | ~3 min | Compile TypeScript, bundle frontend |
| **4. Integration Tests** | Every push | ~5 min | Test API endpoints |
| **5. Security Scan** | Every push | ~2 min | Dependency vulnerabilities |
| **6. Docker Build** | Merge to `develop`/`main` | ~4 min | Container images |
| **7. Deploy Staging** | Merge to `develop` | ~5 min | Staging environment |
| **8. E2E Tests** | After staging deploy | ~10 min | Full user flows |
| **9. Deploy Production** | Manual approval | ~5 min | Production environment |
| **10. Smoke Tests** | After production deploy | ~2 min | Verify critical paths |

**Total Pipeline Time:**
- **PR Pipeline**: ~12 minutes (stages 1-5)
- **Staging Deployment**: ~24 minutes (stages 1-8)
- **Production Deployment**: ~7 minutes (stages 9-10, after approval)

---

## GitHub Actions Workflows

### Repository Structure

```
.github/
└── workflows/
    ├── ci.yml                    # Main CI pipeline (PR checks)
    ├── cd-staging.yml            # Deploy to staging
    ├── cd-production.yml         # Deploy to production
    ├── dependency-update.yml     # Automated dependency updates
    ├── security-scan.yml         # Weekly security scans
    ├── infrastructure.yml        # Terraform apply
    └── cleanup.yml               # Clean up old preview deployments
```

### 1. CI Workflow (`ci.yml`)

**Trigger:** Every push to any branch, every pull request

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: ['**']
  pull_request:
    branches: [develop, main]

env:
  NODE_VERSION: '18.x'

jobs:
  lint:
    name: Lint & Format Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint (Backend)
        run: npm run lint:backend
      
      - name: Run ESLint (Frontend)
        run: npm run lint:frontend
      
      - name: Check Prettier formatting
        run: npm run format:check

  test-backend:
    name: Backend Unit Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: schemajeli_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run Prisma migrations (test DB)
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/schemajeli_test
      
      - name: Run unit tests
        run: npm run test:backend -- --coverage
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/schemajeli_test
          JWT_SECRET: test-secret-key
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/backend/lcov.info
          flags: backend

  test-frontend:
    name: Frontend Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:frontend -- --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/frontend/lcov.info
          flags: frontend

  build:
    name: Build Application
    runs-on: ubuntu-latest
    needs: [lint, test-backend, test-frontend]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build backend
        run: npm run build:backend
      
      - name: Build frontend
        run: npm run build:frontend
        env:
          VITE_API_URL: https://api-staging.schemajeli.com
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            dist/
            src/backend/prisma/
          retention-days: 7

  security-scan:
    name: Security Vulnerability Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run npm audit
        run: npm audit --audit-level=moderate
        continue-on-error: true
      
      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

  integration-tests:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: [build]
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: schemajeli_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
      
      - name: Run Prisma migrations
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/schemajeli_test
      
      - name: Seed test data
        run: npm run db:seed
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/schemajeli_test
      
      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/schemajeli_test
          JWT_SECRET: test-secret-key
          PORT: 3001
```

### 2. CD Staging Workflow (`cd-staging.yml`)

**Trigger:** Merge to `develop` branch

```yaml
# .github/workflows/cd-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [develop]
  workflow_dispatch: # Manual trigger

env:
  AZURE_REGISTRY: schemajelistaging.azurecr.io
  BACKEND_IMAGE: schemajeli-backend
  FRONTEND_IMAGE: schemajeli-frontend
  NODE_VERSION: '18.x'

jobs:
  build-and-push:
    name: Build and Push Docker Images
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Azure Container Registry
        uses: azure/docker-login@v1
        with:
          login-server: ${{ env.AZURE_REGISTRY }}
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      
      - name: Build backend image
        run: |
          docker build \
            -t ${{ env.AZURE_REGISTRY }}/${{ env.BACKEND_IMAGE }}:${{ github.sha }} \
            -t ${{ env.AZURE_REGISTRY }}/${{ env.BACKEND_IMAGE }}:staging \
            -f src/backend/Dockerfile .
      
      - name: Build frontend image
        run: |
          docker build \
            -t ${{ env.AZURE_REGISTRY }}/${{ env.FRONTEND_IMAGE }}:${{ github.sha }} \
            -t ${{ env.AZURE_REGISTRY }}/${{ env.FRONTEND_IMAGE }}:staging \
            -f src/frontend/Dockerfile .
      
      - name: Push images to ACR
        run: |
          docker push ${{ env.AZURE_REGISTRY }}/${{ env.BACKEND_IMAGE }}:${{ github.sha }}
          docker push ${{ env.AZURE_REGISTRY }}/${{ env.BACKEND_IMAGE }}:staging
          docker push ${{ env.AZURE_REGISTRY }}/${{ env.FRONTEND_IMAGE }}:${{ github.sha }}
          docker push ${{ env.AZURE_REGISTRY }}/${{ env.FRONTEND_IMAGE }}:staging

  deploy-staging:
    name: Deploy to Azure Staging
    runs-on: ubuntu-latest
    needs: [build-and-push]
    environment:
      name: staging
      url: https://staging.schemajeli.com
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS_STAGING }}
      
      - name: Deploy backend to App Service
        uses: azure/webapps-deploy@v2
        with:
          app-name: schemajeli-backend-staging
          images: ${{ env.AZURE_REGISTRY }}/${{ env.BACKEND_IMAGE }}:${{ github.sha }}
      
      - name: Run database migrations
        run: |
          az webapp config connection-string set \
            --name schemajeli-backend-staging \
            --resource-group schemajeli-staging-rg \
            --settings DATABASE_URL="${{ secrets.DATABASE_URL_STAGING }}" \
            --connection-string-type Custom
          
          az webapp ssh --name schemajeli-backend-staging \
            --resource-group schemajeli-staging-rg \
            --command "npx prisma migrate deploy"
      
      - name: Deploy frontend to Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_STAGING }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: 'upload'
          app_location: '/src/frontend'
          api_location: ''
          output_location: 'dist'

  e2e-tests:
    name: End-to-End Tests (Staging)
    runs-on: ubuntu-latest
    needs: [deploy-staging]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps
      
      - name: Run E2E tests against staging
        run: npm run test:e2e
        env:
          BASE_URL: https://staging.schemajeli.com
          API_URL: https://api-staging.schemajeli.com
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
      
      - name: Notify on failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'E2E tests failed on staging deployment'
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 3. CD Production Workflow (`cd-production.yml`)

**Trigger:** Manual approval after successful staging deployment

```yaml
# .github/workflows/cd-production.yml
name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: 'Docker image tag to deploy (commit SHA)'
        required: true
        type: string

env:
  AZURE_REGISTRY: schemajeli.azurecr.io
  BACKEND_IMAGE: schemajeli-backend
  FRONTEND_IMAGE: schemajeli-frontend

jobs:
  deploy-production:
    name: Deploy to Azure Production
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://schemajeli.com
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS_PRODUCTION }}
      
      - name: Create deployment slot
        run: |
          az webapp deployment slot create \
            --name schemajeli-backend-prod \
            --resource-group schemajeli-prod-rg \
            --slot blue-green \
            --configuration-source schemajeli-backend-prod
      
      - name: Deploy backend to slot
        uses: azure/webapps-deploy@v2
        with:
          app-name: schemajeli-backend-prod
          slot-name: blue-green
          images: ${{ env.AZURE_REGISTRY }}/${{ env.BACKEND_IMAGE }}:${{ inputs.image_tag }}
      
      - name: Run database migrations
        run: |
          az webapp ssh \
            --name schemajeli-backend-prod \
            --slot blue-green \
            --resource-group schemajeli-prod-rg \
            --command "npx prisma migrate deploy"
      
      - name: Warm up deployment slot
        run: |
          curl -f https://schemajeli-backend-prod-blue-green.azurewebsites.net/api/health || exit 1
          sleep 10
          curl -f https://schemajeli-backend-prod-blue-green.azurewebsites.net/api/health || exit 1
      
      - name: Swap deployment slots (Blue-Green Deployment)
        run: |
          az webapp deployment slot swap \
            --name schemajeli-backend-prod \
            --resource-group schemajeli-prod-rg \
            --slot blue-green \
            --target-slot production
      
      - name: Deploy frontend to production
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_PRODUCTION }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: 'upload'
          app_location: '/src/frontend'
          output_location: 'dist'

  smoke-tests:
    name: Production Smoke Tests
    runs-on: ubuntu-latest
    needs: [deploy-production]
    steps:
      - uses: actions/checkout@v4
      
      - name: Health check - Backend API
        run: |
          curl -f https://api.schemajeli.com/health || exit 1
      
      - name: Health check - Frontend
        run: |
          curl -f https://schemajeli.com || exit 1
      
      - name: Test authentication flow
        run: |
          npm run test:smoke -- --grep "Authentication"
        env:
          BASE_URL: https://schemajeli.com
      
      - name: Test critical paths
        run: |
          npm run test:smoke -- --grep "Critical"
        env:
          BASE_URL: https://schemajeli.com
      
      - name: Rollback on failure
        if: failure()
        run: |
          az webapp deployment slot swap \
            --name schemajeli-backend-prod \
            --resource-group schemajeli-prod-rg \
            --slot blue-green \
            --target-slot production
      
      - name: Notify success
        if: success()
        uses: 8398a7/action-slack@v3
        with:
          status: 'success'
          text: '🚀 Production deployment successful!'
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
      
      - name: Notify failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: 'failure'
          text: '⚠️ Production deployment failed and was rolled back'
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Environment Strategy

### Environment Tiers

| Environment | Branch | URL | Purpose | Auto-Deploy |
|-------------|--------|-----|---------|-------------|
| **Development** | `feature/*` | localhost | Local development | ❌ Manual |
| **Staging** | `develop` | staging.schemajeli.com | Pre-production testing | ✅ Automatic |
| **Production** | `main` | schemajeli.com | Live system | ⚠️ Manual approval |

### Branch Strategy (Git Flow)

```mermaid
gitGraph
    commit id: "Initial commit"
    branch develop
    checkout develop
    commit id: "Setup project"
    
    branch feature/auth
    checkout feature/auth
    commit id: "Add JWT auth"
    commit id: "Add tests"
    checkout develop
    merge feature/auth
    commit id: "Deploy to staging" tag: "v1.1.0-staging"
    
    branch feature/search
    checkout feature/search
    commit id: "Add search API"
    checkout develop
    merge feature/search
    
    checkout main
    merge develop tag: "v1.1.0"
    commit id: "Deploy to production"
    
    checkout develop
    branch feature/reports
    commit id: "Add reports"
```

**Branch Rules:**

1. **`main` branch**:
   - Protected - requires PR approval
   - Only accepts merges from `develop`
   - Represents production-ready code
   - Tagged with semantic versions (v1.0.0, v1.1.0)

2. **`develop` branch**:
   - Protected - requires PR approval
   - Integration branch for features
   - Auto-deploys to staging on merge
   - Pre-release versions (v1.1.0-rc.1)

3. **`feature/*` branches**:
   - Short-lived feature branches
   - Merged to `develop` via pull request
   - Deleted after merge

4. **`hotfix/*` branches**:
   - Emergency fixes for production
   - Merged to both `main` and `develop`
   - Tagged with patch version (v1.0.1)

---

## Build Process

### Backend Build

**Dockerfile** (`src/backend/Dockerfile`):

```dockerfile
# Multi-stage build for optimized image size
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY src/backend/package*.json ./src/backend/

# Install dependencies
RUN npm ci --workspace=backend

# Copy source code
COPY src/backend ./src/backend
COPY tsconfig.json ./

# Build TypeScript
RUN npm run build:backend

# Generate Prisma Client
RUN npx prisma generate --schema=src/backend/prisma/schema.prisma

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
COPY src/backend/package*.json ./src/backend/
RUN npm ci --workspace=backend --omit=dev

# Copy built files from builder
COPY --from=builder /app/dist/backend ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/src/backend/prisma ./prisma

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

# Run application
CMD ["node", "dist/server.js"]
```

**Build Command:**
```bash
docker build -t schemajeli-backend:latest -f src/backend/Dockerfile .
```

### Frontend Build

**Dockerfile** (`src/frontend/Dockerfile`):

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY src/frontend/package*.json ./src/frontend/

# Install dependencies
RUN npm ci --workspace=frontend

# Copy source code
COPY src/frontend ./src/frontend
COPY tsconfig.json ./

# Build Vite app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build:frontend

# Production stage - Nginx to serve static files
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/src/frontend/dist /usr/share/nginx/html

# Copy Nginx configuration
COPY src/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**Nginx Configuration** (`src/frontend/nginx.conf`):

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # SPA routing - all routes serve index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

---

## Testing Automation

### Test Pyramid

```
         ┌─────────────┐
         │   E2E (5%)  │  ← Playwright (critical user flows)
         ├─────────────┤
         │Integration  │  ← Supertest (API endpoints)
         │  (15%)      │
         ├─────────────┤
         │   Unit      │  ← Vitest/Jest (business logic)
         │  (80%)      │
         └─────────────┘
```

### Test Coverage Requirements

| Layer | Tool | Target Coverage | Gate |
|-------|------|-----------------|------|
| **Backend Unit** | Vitest | 80% | ✅ Required |
| **Frontend Unit** | Vitest + React Testing Library | 70% | ✅ Required |
| **Integration** | Supertest | 60% | ⚠️ Warning |
| **E2E** | Playwright | Critical paths | ⚠️ Warning |

### Package Scripts (`package.json`)

```json
{
  "scripts": {
    "test": "npm run test:backend && npm run test:frontend",
    "test:backend": "vitest run --config src/backend/vitest.config.ts",
    "test:frontend": "vitest run --config src/frontend/vitest.config.ts",
    "test:integration": "vitest run --config tests/integration/vitest.config.ts",
    "test:e2e": "playwright test",
    "test:smoke": "playwright test --grep @smoke",
    "test:watch": "vitest watch",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## Deployment Strategy

### Blue-Green Deployment (Production)

**Concept:** Run two identical production environments (Blue and Green). Deploy to inactive environment, then switch traffic.

```mermaid
graph TB
    Users[Users] -->|Traffic| LoadBalancer[Azure Load Balancer]
    LoadBalancer -->|100%| Blue[Blue Environment<br/>v1.0.0 - ACTIVE]
    LoadBalancer -.->|0%| Green[Green Environment<br/>v1.1.0 - IDLE]
    
    Deploy[New Deployment] --> Green
    Green --> Test{Health Check}
    Test -->|Pass| Switch[Switch Traffic]
    Switch --> LoadBalancer
    
    LoadBalancer2[After Switch] -->|0%| Blue2[Blue Environment<br/>v1.0.0 - IDLE]
    LoadBalancer2 -->|100%| Green2[Green Environment<br/>v1.1.0 - ACTIVE]
    
    style Blue fill:#3498db,color:#fff
    style Green fill:#2ecc71,color:#fff
    style Green2 fill:#2ecc71,color:#fff
```

**Advantages:**
- ✅ Zero downtime deployments
- ✅ Instant rollback (switch back to blue)
- ✅ Full production testing before switch

**Azure Implementation:**
- Use Azure App Service **Deployment Slots**
- `production` slot = Active (Blue)
- `blue-green` slot = Staging (Green)
- Swap slots after validation

### Rolling Deployment (Staging)

**Concept:** Gradually replace old instances with new ones.

**Azure Implementation:**
- Azure App Service handles rolling updates automatically
- No manual orchestration needed

---

## Azure Infrastructure

### Infrastructure as Code (Terraform)

**Directory Structure:**
```
infrastructure/
├── terraform/
│   ├── main.tf                # Main configuration
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   ├── backend.tf             # State backend config
│   ├── modules/
│   │   ├── app-service/       # Backend hosting
│   │   ├── static-web-app/    # Frontend hosting
│   │   ├── database/          # PostgreSQL
│   │   ├── container-registry/# ACR
│   │   └── monitoring/        # Application Insights
│   ├── environments/
│   │   ├── staging.tfvars     # Staging variables
│   │   └── production.tfvars  # Production variables
│   └── README.md
```

### Resource Provisioning Workflow

```yaml
# .github/workflows/infrastructure.yml
name: Terraform Infrastructure

on:
  push:
    paths:
      - 'infrastructure/terraform/**'
    branches: [main, develop]
  workflow_dispatch:

jobs:
  terraform-plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Terraform Init
        run: terraform init
        working-directory: infrastructure/terraform
      
      - name: Terraform Plan (Staging)
        if: github.ref == 'refs/heads/develop'
        run: terraform plan -var-file=environments/staging.tfvars -out=tfplan
        working-directory: infrastructure/terraform
      
      - name: Terraform Plan (Production)
        if: github.ref == 'refs/heads/main'
        run: terraform plan -var-file=environments/production.tfvars -out=tfplan
        working-directory: infrastructure/terraform
      
      - name: Upload plan
        uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: infrastructure/terraform/tfplan

  terraform-apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    needs: [terraform-plan]
    environment:
      name: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0
      
      - name: Download plan
        uses: actions/download-artifact@v4
        with:
          name: tfplan
          path: infrastructure/terraform
      
      - name: Terraform Apply
        run: terraform apply tfplan
        working-directory: infrastructure/terraform
```

---

## Secrets Management

### GitHub Secrets

**Repository Secrets (Settings → Secrets and variables → Actions):**

| Secret Name | Purpose | Environment |
|-------------|---------|-------------|
| `AZURE_CREDENTIALS_STAGING` | Azure service principal (staging) | Staging |
| `AZURE_CREDENTIALS_PRODUCTION` | Azure service principal (production) | Production |
| `ACR_USERNAME` | Container registry username | Both |
| `ACR_PASSWORD` | Container registry password | Both |
| `DATABASE_URL_STAGING` | PostgreSQL connection string | Staging |
| `DATABASE_URL_PRODUCTION` | PostgreSQL connection string | Production |
| `JWT_SECRET` | JWT signing key | Both |
| `JWT_REFRESH_SECRET` | Refresh token signing key | Both |
| `SNYK_TOKEN` | Snyk security scanning token | Both |
| `SLACK_WEBHOOK_URL` | Slack notifications webhook | Both |
| `AZURE_STATIC_WEB_APPS_API_TOKEN_STAGING` | Frontend deployment token | Staging |
| `AZURE_STATIC_WEB_APPS_API_TOKEN_PRODUCTION` | Frontend deployment token | Production |

### Azure Key Vault Integration

**Runtime Secrets** (accessed by applications):

```typescript
// src/backend/config/secrets.ts
import { DefaultAzureCredential } from '@azure/identity';
import { SecretClient } from '@azure/keyvault-secrets';

const credential = new DefaultAzureCredential();
const vaultUrl = process.env.AZURE_KEY_VAULT_URL!;
const client = new SecretClient(vaultUrl, credential);

export async function getSecret(secretName: string): Promise<string> {
  const secret = await client.getSecret(secretName);
  return secret.value!;
}

// Usage
const dbPassword = await getSecret('database-password');
const jwtSecret = await getSecret('jwt-secret');
```

---

## Monitoring & Notifications

### Slack Notifications

**Events to notify:**
- ✅ Staging deployment success/failure
- ✅ Production deployment success/failure
- ✅ E2E test failures
- ✅ Security vulnerability detected (high/critical)
- ✅ Rollback triggered

**Slack Integration:**

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: |
      Deployment to ${{ github.event.inputs.environment }} ${{ job.status }}
      Commit: ${{ github.sha }}
      Author: ${{ github.actor }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
  if: always()
```

### Deployment Dashboard

**GitHub Environments:** Track deployment history and approvals

- View deployment logs
- See approval history
- Track deployment frequency
- Monitor failure rates

---

## Rollback Strategy

### Automatic Rollback Triggers

1. **Health check failures** after production deployment
2. **Smoke test failures** after production deployment
3. **Error rate spike** (>5% in first 10 minutes)
4. **Response time degradation** (>2x baseline)

### Manual Rollback Process

**Option 1: Swap deployment slots back**

```bash
az webapp deployment slot swap \
  --name schemajeli-backend-prod \
  --resource-group schemajeli-prod-rg \
  --slot blue-green \
  --target-slot production
```

**Option 2: Redeploy previous version**

```bash
# Trigger production deployment with previous commit SHA
gh workflow run cd-production.yml -f image_tag=abc1234
```

**Option 3: Restore from backup (database)**

```bash
az postgres flexible-server restore \
  --resource-group schemajeli-prod-rg \
  --name schemajeli-db-prod \
  --restore-point-in-time "2026-01-30T10:00:00Z" \
  --source-server schemajeli-db-prod-backup
```

### Rollback SLA

- **Detection Time**: < 5 minutes (automated monitoring)
- **Decision Time**: < 5 minutes (manual approval or automatic)
- **Execution Time**: < 2 minutes (slot swap)
- **Total RTO (Recovery Time Objective)**: < 12 minutes

---

## Implementation Checklist

### Phase 1: Setup (Week 1)

- [ ] Create GitHub Actions workflow files
- [ ] Configure GitHub environments (staging, production)
- [ ] Set up Azure Container Registry
- [ ] Configure Azure service principals
- [ ] Add all GitHub secrets
- [ ] Set up Slack webhook integration

### Phase 2: CI Pipeline (Week 2)

- [ ] Implement lint/format checks
- [ ] Set up unit test runners
- [ ] Configure test coverage reporting (Codecov)
- [ ] Add security scanning (Snyk)
- [ ] Implement build artifact generation
- [ ] Add integration test runner

### Phase 3: Staging Deployment (Week 3)

- [ ] Create Dockerfiles (backend + frontend)
- [ ] Test Docker builds locally
- [ ] Implement staging deployment workflow
- [ ] Configure Azure App Service (staging)
- [ ] Configure Azure Static Web Apps (staging)
- [ ] Add E2E test runner
- [ ] Test full staging pipeline

### Phase 4: Production Deployment (Week 4)

- [ ] Implement blue-green deployment workflow
- [ ] Configure Azure App Service slots (production)
- [ ] Add smoke test runner
- [ ] Configure rollback automation
- [ ] Test production deployment workflow (dry run)
- [ ] Document deployment procedures

### Phase 5: Infrastructure as Code (Week 5)

- [ ] Write Terraform modules
- [ ] Test Terraform in staging
- [ ] Create Terraform workflow
- [ ] Apply to production
- [ ] Document Terraform usage

---

**Document Status:** ✅ Complete  
**Next Step:** Proceed to P-1.3.2 (Testing Strategy)
