# SchemaJeli

**Modern Database Metadata Repository System**

[![CI Pipeline](https://github.com/ivegamsft/schemajeli/actions/workflows/ci.yml/badge.svg)](https://github.com/ivegamsft/schemajeli/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue.svg)](https://www.typescriptlang.org/)

## Overview

SchemaJeli is a cloud-native metadata repository system for managing and documenting database schemas across multiple servers and database platforms. Modernized from a legacy ASP-based system (1999), it provides a centralized platform for tracking servers, databases, tables, columns, and their relationships with powerful search and reporting capabilities.

### 🚀 Key Features

- **Multi-Database Support** - Track schemas across PostgreSQL, MySQL, Oracle, SQL Server, and Informix
- **Comprehensive Metadata** - Document servers, databases, tables, columns with rich descriptions
- **Powerful Search** - Full-text search across all metadata with filtering and faceting
- **Role-Based Access Control** - ADMIN, EDITOR, and VIEWER roles with granular permissions
- **Rich Reports** - Generate detailed reports on database schemas and metadata
- **Modern Tech Stack** - React 18, Node.js, TypeScript, PostgreSQL, Prisma ORM
- **RESTful API** - Complete OpenAPI 3.0 specification
- **Cloud-Native** - Designed for Azure with Infrastructure as Code (Terraform)
- **Developer Experience** - Comprehensive testing, CI/CD, monitoring, and documentation

## 🚀 Quick Start

## 🏃 Quick Start

```bash
# Clone the repository
git clone https://github.com/ivegamsft/schemajeli.git
cd schemajeli

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
npm run db:migrate

# Seed the database with sample data
npm run db:seed

# Start development servers
npm run dev

# Backend: http://localhost:3000
# Frontend: http://localhost:5173
```

## 📦 Prerequisites

- **Node.js**: ≥18.0.0
- **npm**: ≥9.0.0
- **PostgreSQL**: ≥14.0
- **Git**: ≥2.30

## 📁 Project Structure

```
schemajeli/
├── .github/                # GitHub Actions workflows
├── docs/                   # Documentation
│   ├── design/            # Design documents
│   └── api/               # API documentation
├── infrastructure/         # Terraform configuration
├── src/
│   ├── backend/           # Node.js backend
│   │   ├── controllers/   # Request handlers
│   │   ├── middleware/    # Express middleware
│   │   ├── routes/        # API routes
│   │   ├── services/      # Business logic
│   │   ├── prisma/        # Prisma schema & migrations
│   │   └── utils/         # Utilities
│   └── frontend/          # React frontend
│       ├── components/    # React components
│       ├── pages/         # Page components
│       ├── hooks/         # Custom hooks
│       ├── services/      # API clients
│       └── store/         # Redux store
├── tests/                 # Test files
│   ├── integration/       # API integration tests
│   └── e2e/              # End-to-end tests
├── .specify/             # SpecKit working files
└── README.md
```

## 🛠️ Technology Stack

### Frontend
- React 18, TypeScript, Vite
- Tailwind CSS, Redux Toolkit, React Query
- React Router, React Hook Form, Zod

### Backend
- Node.js 18+, Express.js, TypeScript
- Prisma ORM, JWT (jsonwebtoken), bcrypt
- Winston (logging), Joi (validation)

### Database
- PostgreSQL 14+
- Prisma schema with migrations

### Infrastructure
- Azure App Service, Azure Static Web Apps
- Azure Database for PostgreSQL
- Azure Container Registry, Application Insights
- Terraform for Infrastructure as Code

### DevOps
- GitHub Actions (CI/CD)
- Docker, Playwright (E2E testing)
- Vitest (unit/integration testing)

## 💻 Development

### Available Scripts

```bash
# Development
npm run dev              # Start backend + frontend
npm run dev:backend      # Start backend only
npm run dev:frontend     # Start frontend only

# Building
npm run build            # Build backend + frontend
npm run build:backend    # Build backend TypeScript
npm run build:frontend   # Build frontend for production

# Database
npm run db:migrate       # Run Prisma migrations
npm run db:seed          # Seed database
npm run db:studio        # Open Prisma Studio
npm run db:generate      # Generate Prisma Client

# Testing
npm test                 # Run all tests
npm run test:backend     # Backend unit tests
npm run test:frontend    # Frontend unit tests
npm run test:integration # API integration tests
npm run test:e2e         # End-to-end tests
npm run test:coverage    # Generate coverage report

# Code Quality
npm run lint             # Run ESLint
npm run lint:fix         # Fix ESLint errors
npm run format           # Format with Prettier
npm run format:check     # Check Prettier formatting
npm run type-check       # TypeScript type checking
```

## 🧪 Testing

SchemaJeli follows a comprehensive testing strategy:

```
         ┌─────────────┐
         │   E2E (5%)  │  ← Playwright (critical user flows)
         ├─────────────┤
         │Integration  │  ← Supertest (API endpoints)
         │  (15%)      │
         ├─────────────┤
         │   Unit      │  ← Vitest (business logic)
         │  (80%)      │
         └─────────────┘
```

**Coverage Requirements:**
- **Backend**: ≥80% coverage
- **Frontend**: ≥70% coverage
- **Integration**: ≥60% coverage

## 🚢 Deployment

### Deployment Environments

| Environment | URL | Branch | Auto-Deploy |
|-------------|-----|--------|-------------|
| **Staging** | staging.schemajeli.com | `develop` | ✅ Automatic |
| **Production** | schemajeli.com | `main` | ⚠️ Manual approval |

### Deployment Process

1. **Merge to `develop`**: Automatically deploys to staging
2. **E2E tests run** on staging environment
3. **Create PR** from `develop` to `main`
4. **Approve and merge**: Triggers production deployment workflow
5. **Manual approval** required before production deployment
6. **Blue-green deployment** to production with automatic rollback on failure

## 📖 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Database Schema](docs/design/database-schema-plan.md)** - Database design and ERD
- **[API Specification](.specify/openapi.yaml)** - OpenAPI 3.0 REST API spec
- **[Authentication Flow](docs/design/authentication-authorization.md)** - Auth and authorization
- **[Frontend Architecture](docs/design/frontend-architecture.md)** - React app structure
- **[Testing Strategy](docs/design/testing-strategy.md)** - Testing approach and tools
- **[CI/CD Pipeline](docs/design/cicd-pipeline.md)** - Deployment pipeline
- **[Monitoring & Logging](docs/design/monitoring-logging.md)** - Observability
- **[Legacy System Assessment](docs/design/legacy-system-assessment.md)** - Migration analysis

## 🔒 Security

### Security Features

- ✅ JWT-based authentication with refresh tokens
- ✅ Password hashing with bcrypt (10 salt rounds)
- ✅ Role-based access control (RBAC)
- ✅ Rate limiting on authentication endpoints
- ✅ HTTPS only in production
- ✅ Security headers (CSP, HSTS, X-Frame-Options)
- ✅ Input validation and sanitization
- ✅ SQL injection protection (Prisma ORM)
- ✅ Dependency scanning (Snyk)
- ✅ Regular security updates

### Reporting Security Issues

Please report security vulnerabilities to **security@schemajeli.example.com** (do not use public issues).

## 📊 Project Status

**Current Phase**: Phase 1 - Design & Specification ✅ Complete

**Completed:**
- ✅ Database schema design
- ✅ REST API specification
- ✅ Frontend architecture
- ✅ Authentication & authorization design
- ✅ Legacy system assessment
- ✅ CI/CD pipeline design
- ✅ Testing strategy
- ✅ Monitoring & logging architecture
- ✅ Core documentation

**Next Steps:**
- ⏳ Phase 2: Backend implementation
- ⏳ Phase 3: Data migration
- ⏳ Phase 4: Frontend implementation
- ⏳ Phase 5: Integration & testing
- ⏳ Phase 6: Deployment & cutover

See [docs/design/phase-1-summary.md](docs/design/phase-1-summary.md) for detailed progress.

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Quick Contribution Guide

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and add tests
4. **Commit with conventional commits**: `git commit -m "feat: add amazing feature"`
5. **Push to your fork**: `git push origin feature/amazing-feature`
6. **Open a Pull Request**

### Code Style

- **TypeScript**: Strict mode enabled
- **ESLint**: Airbnb style guide
- **Prettier**: Automatic formatting
- **Conventional Commits**: Required for commit messages

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/ivegamsft/schemajeli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ivegamsft/schemajeli/discussions)
- **Email**: support@schemajeli.example.com

---

**Built with ❤️ using modern web technologies**

- **Documentation:** See [ARCHITECTURE.md](ARCHITECTURE.md) and `.specify/` folder
- **Issues:** GitHub Issues
- **Questions:** Create a GitHub Discussion

## 🔗 Links

- [Project Planning](.specify/README.md)
- [Architecture Decisions](.specify/plan.md#architecture-decision-records-adrs)
- [API Documentation](http://localhost:3000/api-docs) (when running)
- [Azure Portal](https://portal.azure.com) (for deployed resources)

---

**Last Updated:** January 29, 2026  
**Version:** 1.0.0 (Scaffold)  
**Status:** Phase 1 - Foundation
