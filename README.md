# SchemaJeli

> Modern database metadata repository and schema management system

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node](https://img.shields.io/badge/node-18+-green.svg)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue.svg)](https://www.typescriptlang.org/)

## Overview

SchemaJeli is a comprehensive metadata repository system for managing enterprise database schemas, naming standards, and documentation across multiple database servers and platforms. Modernized from the legacy CompanyName Repository System (1999), SchemaJeli provides a cloud-native, web-based platform for:

- **Schema Management** - Centralized repository for servers, databases, tables, and columns
- **Naming Standards** - Enforce and document enterprise naming conventions
- **Advanced Search** - Find schema objects across your entire data estate
- **Reporting** - Generate schema documentation and DDL scripts
- **Audit Trail** - Track all changes with comprehensive audit logging
- **Role-Based Access** - Secure access control for different user types

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm 9+
- Docker and Docker Compose
- Git

### Local Development

```bash
# Clone the repository
git clone https://github.com/yourorg/schemajeli.git
cd schemajeli

# Start all services with Docker Compose
docker-compose up -d

# Access the applications
# Frontend: http://localhost:5173
# Backend API: http://localhost:3000
# API Docs: http://localhost:3000/api-docs
# PgAdmin: http://localhost:5050
```

### Manual Setup

**Backend:**
```bash
cd src/backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm run dev
```

**Frontend:**
```bash
cd src/frontend
npm install
npm run dev
```

## 📁 Project Structure

```
SchemaJeli/
├── .github/workflows/      # CI/CD pipelines
├── .specify/               # Planning & specifications
│   ├── spec.md            # Requirements
│   ├── plan.md            # Architecture & migration plan
│   ├── tasks.md           # Task breakdown
│   └── memory/
│       └── constitution.md # Project principles
├── infrastructure/         # Infrastructure as Code
│   ├── terraform/         # Azure Terraform modules
│   └── kubernetes/        # K8s manifests
├── src/
│   ├── backend/           # Node.js/Express API
│   └── frontend/          # React web application
├── legacy/                # Archived ASP code (reference)
├── docker-compose.yml     # Local development environment
└── ARCHITECTURE.md        # Architecture documentation
```

## 🛠️ Technology Stack

### Backend
- **Runtime:** Node.js 18+ with TypeScript
- **Framework:** Express.js
- **Database:** PostgreSQL 14+
- **ORM:** Prisma
- **Auth:** JWT, bcrypt, Passport.js
- **Testing:** Jest, Supertest
- **API Docs:** OpenAPI/Swagger

### Frontend
- **Framework:** React 18+ with TypeScript
- **Build Tool:** Vite
- **UI:** Tailwind CSS + Shadcn/UI
- **State:** Redux Toolkit + React Query
- **Routing:** React Router
- **Forms:** React Hook Form + Zod
- **Testing:** Vitest, Playwright

### Infrastructure
- **IaC:** Terraform for Azure
- **Containers:** Docker
- **Orchestration:** Kubernetes (AKS)
- **Monitoring:** Azure Application Insights
- **CI/CD:** GitHub Actions

## 📖 Documentation

- [**Architecture Guide**](ARCHITECTURE.md) - Complete architecture overview
- [**Specification**](.specify/spec.md) - Requirements and features
- [**Migration Plan**](.specify/plan.md) - Architecture decisions (ADRs)
- [**Task Breakdown**](.specify/tasks.md) - Implementation tasks
- [**Scaffold Status**](SCAFFOLD-STATUS.md) - Current progress
- [**API Documentation**](http://localhost:3000/api-docs) - Interactive API docs (when running)

## 🔐 Security

- JWT-based authentication with refresh tokens
- Role-based access control (Admin, Maintainer, Viewer)
- bcrypt password hashing (12 rounds)
- HTTPS/TLS encryption in production
- SQL injection prevention via parameterized queries
- CSRF protection
- Rate limiting
- Comprehensive audit logging
- OWASP Top 10 compliance

## 🧪 Testing

```bash
# Backend tests
cd src/backend
npm test                    # Unit tests
npm run test:coverage       # Coverage report
npm run test:integration    # Integration tests

# Frontend tests
cd src/frontend
npm test                    # Unit tests
npm run test:e2e           # E2E tests with Playwright
```

## 🚢 Deployment

### Using Docker Compose (Development)
```bash
docker-compose up -d
```

### Using Terraform (Azure Production)
```bash
cd infrastructure/terraform
terraform init
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

### Using GitHub Actions
Push to `main` branch triggers:
1. Build & test
2. Security scanning
3. Deploy to staging
4. Manual approval for production
5. Deploy to production

## 📊 Project Status

| Phase | Status | Timeline |
|-------|--------|----------|
| **Phase 1:** Foundation | 🔄 In Progress | Weeks 1-3 |
| **Phase 2:** Core API | ⏳ Not Started | Weeks 4-8 |
| **Phase 3:** Frontend | ⏳ Not Started | Weeks 9-13 |
| **Phase 4:** Testing & Deploy | ⏳ Not Started | Weeks 14-16 |

See [SCAFFOLD-STATUS.md](SCAFFOLD-STATUS.md) for detailed progress.

## 🎯 Features

### ✅ Current (Legacy ASP System)
- Server/Database/Table/Element management
- Advanced search with wildcards
- Standard abbreviations library
- Multiple report types
- DDL generation
- Role-based access
- Help system

### 🚧 Planned (Modern System)
- RESTful API
- React web UI
- Real-time search
- Export to CSV/JSON/PDF
- API-first design
- Cloud-native deployment
- Comprehensive monitoring
- 99.5% uptime SLA

## 🤝 Contributing

1. Review [.specify/constitution.md](.specify/memory/constitution.md) for project principles
2. Check [.specify/tasks.md](.specify/tasks.md) for available tasks
3. Create a feature branch
4. Make your changes
5. Write/update tests
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Project Lead:** [To Be Assigned]
- **Tech Lead Backend:** [To Be Assigned]
- **Tech Lead Frontend:** [To Be Assigned]
- **DevOps Lead:** [To Be Assigned]

## 🆘 Support

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
