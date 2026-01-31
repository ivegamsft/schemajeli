# SchemaJeli Architecture

**Version:** 1.0  
**Last Updated:** January 30, 2026  
**Status:** Design Complete

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Technology Stack](#technology-stack)
4. [Data Architecture](#data-architecture)
5. [API Architecture](#api-architecture)
6. [Frontend Architecture](#frontend-architecture)
7. [Security Architecture](#security-architecture)
8. [Deployment Architecture](#deployment-architecture)
9. [Scalability & Performance](#scalability--performance)
10. [Monitoring & Observability](#monitoring--observability)

## Overview

SchemaJeli is a **cloud-native metadata repository system** built with modern web technologies. It provides a centralized platform for managing and documenting database schemas across multiple servers and database platforms.

### Design Principles

1. **API-First**: RESTful API with OpenAPI specification
2. **Cloud-Native**: Designed for Azure with containerization and orchestration
3. **Security by Default**: JWT authentication, RBAC, encrypted communication
4. **Developer Experience**: Comprehensive testing, CI/CD, documentation
5. **Performance**: Sub-second response times, efficient database queries
6. **Maintainability**: Clean code, separation of concerns, modular design

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Client Layer                              │
│  ┌────────────┐  ┌─────────────┐  ┌──────────────┐              │
│  │  Browser   │  │Mobile Apps  │  │  API Clients │              │
│  │  (React)   │  │  (Future)   │  │   (Future)   │              │
│  └──────┬─────┘  └──────┬──────┘  └───────┬──────┘              │
└─────────┼────────────────┼─────────────────┼───────────────────┘
          │                │                 │
          └────────────────┼─────────────────┘
                           │ HTTPS/REST
┌──────────────────────────┼─────────────────────────────────────┐
│                    Application Layer                             │
│  ┌────────────────────────┴───────────────────────┐             │
│  │        Azure Static Web Apps (Frontend)         │             │
│  │   - React SPA, Static hosting, CDN              │             │
│  └──────────────────────────────────────────────────┘             │
│                           │                                       │
│                           │ REST API                              │
│  ┌────────────────────────┴───────────────────────┐             │
│  │     Azure App Service (Backend)                 │             │
│  │   - Node.js/Express API                         │             │
│  │   - JWT Auth, RBAC, Business Logic              │             │
│  │   - Containerized (Docker)                      │             │
│  └──────────────────────┬───────────────────────────┘             │
└─────────────────────────┼───────────────────────────────────────┘
                          │ PostgreSQL Protocol
┌─────────────────────────┼───────────────────────────────────────┐
│                    Data Layer                                     │
│  ┌────────────────────────┴───────────────────────┐             │
│  │   Azure Database for PostgreSQL                 │             │
│  │   - Prisma ORM, Migrations, Full-text search    │             │
│  │   - Backup & Recovery, High Availability        │             │
│  └──────────────────────────────────────────────────┘             │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                   Supporting Services                             │
│  ┌──────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Azure Container │  │  Application    │  │   Azure Key     │ │
│  │    Registry      │  │    Insights     │  │     Vault       │ │
│  │   (ACR)          │  │  (Monitoring)   │  │   (Secrets)     │ │
│  └──────────────────┘  └─────────────────┘  └─────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

## System Architecture

### Three-Tier Architecture

SchemaJeli follows a **3-tier architecture** pattern:

#### 1. Presentation Tier (Frontend)
- **Technology**: React 18 + TypeScript
- **Hosting**: Azure Static Web Apps
- **Responsibilities**:
  - User interface rendering
  - Client-side routing
  - State management
  - API communication
  - User input validation

#### 2. Application Tier (Backend)
- **Technology**: Node.js 18 + Express + TypeScript
- **Hosting**: Azure App Service (Linux containers)
- **Responsibilities**:
  - Business logic
  - Authentication & authorization
  - API endpoint handling
  - Data validation
  - Database operations via ORM

#### 3. Data Tier (Database)
- **Technology**: PostgreSQL 14+
- **Hosting**: Azure Database for PostgreSQL
- **Responsibilities**:
  - Data persistence
  - Query execution
  - Full-text search
  - Data integrity enforcement
  - Backup & recovery

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend (React)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────┐  ┌──────────────┐  ┌───────────┐  ┌─────────┐  │
│  │   Pages    │→ │  Components  │  │   Hooks   │  │  Store  │  │
│  └────────────┘  └──────────────┘  └───────────┘  └─────────┘  │
│         │                                                 │      │
│         └─────────────────┬───────────────────────────────┘      │
│                           ▼                                      │
│                  ┌─────────────────┐                             │
│                  │  API Client     │                             │
│                  │  (axios)        │                             │
│                  └────────┬────────┘                             │
└───────────────────────────┼──────────────────────────────────────┘
                            │ HTTP/REST
┌───────────────────────────┼──────────────────────────────────────┐
│                 Backend (Node.js/Express)                        │
├───────────────────────────┼──────────────────────────────────────┤
│                           ▼                                      │
│  ┌──────────┐  ┌───────────────┐  ┌───────────┐  ┌──────────┐  │
│  │  Routes  │→ │  Controllers  │→ │ Services  │→ │  Prisma  │  │
│  └──────────┘  └───────────────┘  └───────────┘  │   ORM    │  │
│       │               │                    │      └────┬─────┘  │
│       │               │                    │           │        │
│  ┌────▼───────┐  ┌───▼──────────┐  ┌──────▼──┐        │        │
│  │Middleware  │  │ Validation   │  │ Utils   │        │        │
│  │- Auth      │  │ - Zod/Joi    │  │ - Logger│        │        │
│  │- Error     │  │ - Sanitize   │  │ - Crypto│        │        │
│  │- Logger    │  └──────────────┘  └─────────┘        │        │
│  └────────────┘                                        │        │
└────────────────────────────────────────────────────────┼────────┘
                                                         │ SQL
┌────────────────────────────────────────────────────────┼────────┐
│                    PostgreSQL Database                  │        │
├────────────────────────────────────────────────────────┼────────┤
│  Tables: Server, Database, Table, Element, User, ...   │        │
│  Indexes, Constraints, Triggers, Full-text Search      ▼        │
└─────────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| **React** | 18.x | UI framework |
| **TypeScript** | 5.3.x | Type safety |
| **Vite** | 5.x | Build tool |
| **Tailwind CSS** | 3.x | Styling |
| **Redux Toolkit** | 2.x | Global state |
| **React Query** | 5.x | Server state & caching |
| **React Router** | 6.x | Client-side routing |
| **React Hook Form** | 7.x | Form handling |
| **Zod** | 3.x | Schema validation |
| **Axios** | 1.x | HTTP client |

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Node.js** | 18.x LTS | Runtime environment |
| **Express.js** | 4.x | Web framework |
| **TypeScript** | 5.3.x | Type safety |
| **Prisma** | 5.x | ORM & migrations |
| **jsonwebtoken** | 9.x | JWT handling |
| **bcrypt** | 5.x | Password hashing |
| **Winston** | 3.x | Logging |
| **Joi** | 17.x | Validation |
| **express-validator** | 7.x | Request validation |
| **express-rate-limit** | 7.x | Rate limiting |

### Database

| Technology | Version | Purpose |
|------------|---------|---------|
| **PostgreSQL** | 14.x+ | Relational database |
| **pgvector** | 0.5.x | Vector similarity (future) |
| **pg_trgm** | - | Fuzzy text search |
| **Full-text search** | - | Search functionality |

### DevOps & Infrastructure

| Technology | Version | Purpose |
|------------|---------|---------|
| **Docker** | 24.x | Containerization |
| **Terraform** | 1.6.x | Infrastructure as Code |
| **GitHub Actions** | - | CI/CD pipeline |
| **Azure** | - | Cloud platform |
| **Vitest** | 1.x | Unit testing |
| **Playwright** | 1.x | E2E testing |
| **Snyk** | - | Security scanning |

## Data Architecture

### Database Schema

See [docs/design/database-schema-plan.md](docs/design/database-schema-plan.md) for detailed schema design.

**Core Entities:**

```
┌───────────┐       ┌────────────┐       ┌─────────┐       ┌──────────┐
│   User    │       │   Server   │──1:N──│Database │──1:N──│  Table   │
└───────────┘       └────────────┘       └─────────┘       └─────┬────┘
                                                                  │
                                                                1:N│
                                                                  │
    ┌──────────────┐                                         ┌────▼────┐
    │ AuditLog     │──N:1──────────────────────────────────│ Element  │
    └──────────────┘                                         └──────────┘
    
    ┌──────────────┐
    │ Abbreviation │ (Independent)
    └──────────────┘
```

### Entity Relationships

- **One Server** has **many Databases**
- **One Database** has **many Tables**
- **One Table** has **many Elements** (columns)
- **All entities** have **audit logs** (polymorphic)
- **Abbreviations** are independent reference data

### Data Flow

```
User Action → Frontend → API → Controller → Service → Prisma → PostgreSQL
                 │                                        ▲
                 │                                        │
                 └──── Validation ────> Error Handling ───┘
```

## API Architecture

### RESTful API Design

See [.specify/openapi.yaml](.specify/openapi.yaml) for complete API specification.

**Base URL**: `/api`

**Resource Structure**:

```
/api
├── /auth
│   ├── POST   /login
│   ├── POST   /refresh
│   ├── POST   /logout
│   ├── POST   /forgot-password
│   └── POST   /reset-password
├── /users
│   ├── GET    /
│   ├── POST   /
│   ├── GET    /:id
│   ├── PUT    /:id
│   ├── DELETE /:id
│   └── PUT    /:id/activate
├── /servers
│   ├── GET    /
│   ├── POST   /
│   ├── GET    /:id
│   ├── PUT    /:id
│   └── DELETE /:id
├── /databases
├── /tables
├── /elements
├── /abbreviations
├── /search
│   └── GET    ?q=query
└── /reports
    ├── GET    /element-summary
    ├── GET    /table-summary
    ├── GET    /database-details
    └── GET    /server-summary
```

### API Layers

```
┌────────────────────────────────────────────────────────────┐
│                      API Request                            │
└───────────────────────┬────────────────────────────────────┘
                        │
        ┌───────────────▼───────────────┐
        │     Middleware Stack          │
        │  - CORS                        │
        │  - Body Parser                 │
        │  - Request Logger              │
        │  - Rate Limiter                │
        │  - Authentication (JWT)        │
        │  - Authorization (RBAC)        │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │     Route Handler              │
        │  (Express Router)              │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │     Controller                 │
        │  - Input validation            │
        │  - Call service layer          │
        │  - Format response             │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │     Service Layer              │
        │  - Business logic              │
        │  - Data transformation         │
        │  - Error handling              │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │     Data Access Layer          │
        │  (Prisma ORM)                  │
        │  - Query building              │
        │  - Transaction handling        │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │        PostgreSQL              │
        └────────────────────────────────┘
```

## Frontend Architecture

See [docs/design/frontend-architecture.md](docs/design/frontend-architecture.md) for detailed frontend design.

### Component Hierarchy (Atomic Design)

```
Pages (Routes)
    │
    ├─── Templates (Layouts)
    │       │
    │       ├─── Organisms (Complex components)
    │       │       │
    │       │       ├─── Molecules (Composite components)
    │       │       │       │
    │       │       │       └─── Atoms (Base components)
    │       │       │
    │       │       └─── Atoms
    │       │
    │       └─── Molecules
    │
    └─── Organisms
```

### State Management Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    Application State                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐          ┌─────────────────────────┐  │
│  │  Server State    │          │     UI State            │  │
│  │  (React Query)   │          │  (Redux Toolkit)        │  │
│  ├──────────────────┤          ├─────────────────────────┤  │
│  │ - API data       │          │ - Theme                 │  │
│  │ - Caching        │          │ - Modals                │  │
│  │ - Pagination     │          │ - Sidebar               │  │
│  │ - Prefetching    │          │ - Filters               │  │
│  └──────────────────┘          │ - Notifications         │  │
│                                 └─────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Component State (useState)                  │   │
│  │  - Form inputs, local toggles, ephemeral UI state   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Security Architecture

See [docs/design/authentication-authorization.md](docs/design/authentication-authorization.md) for detailed security design.

### Authentication Flow

```
┌──────────┐     1. Login      ┌──────────┐
│  Client  ├──────────────────►│   API    │
└────┬─────┘                   └────┬─────┘
     │                              │
     │                              │ 2. Validate credentials
     │                              │    (bcrypt.compare)
     │                              ▼
     │                         ┌─────────┐
     │                         │Database │
     │                         └────┬────┘
     │                              │
     │      3. Return tokens        │
     │◄─────────────────────────────┘
     │      - Access Token (15min)
     │      - Refresh Token (7d, HTTP-only cookie)
     │
     │      4. API Request
     │      Authorization: Bearer <access_token>
     ├──────────────────────────────►
     │                                │ 5. Verify JWT
     │                                │    Extract user
     │                                │    Check permissions
     │      6. Response               │
     │◄────────────────────────────────
     │
```

### Authorization (RBAC)

```
┌───────────────────────────────────────────────────────────────┐
│                   Role Hierarchy                               │
│                                                                │
│           ADMIN (Full Access)                                  │
│              │                                                 │
│              ├──► User Management                              │
│              ├──► Delete Operations                            │
│              └──► All EDITOR permissions                       │
│                        │                                       │
│                        ▼                                       │
│                   EDITOR (Create/Edit)                         │
│                        │                                       │
│                        ├──► Create/Update Servers              │
│                        ├──► Create/Update Databases            │
│                        └──► All VIEWER permissions             │
│                                  │                             │
│                                  ▼                             │
│                            VIEWER (Read-Only)                  │
│                                  │                             │
│                                  ├──► View all metadata        │
│                                  ├──► Search                   │
│                                  └──► Generate reports         │
└───────────────────────────────────────────────────────────────┘
```

## Deployment Architecture

See [docs/design/cicd-pipeline.md](docs/design/cicd-pipeline.md) for detailed deployment design.

### Azure Infrastructure

```
┌────────────────────────────────────────────────────────────────┐
│                         Azure Cloud                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Azure Static Web Apps                        │  │
│  │  - Frontend hosting with CDN                              │  │
│  │  - Custom domain: schemajeli.com                          │  │
│  │  - SSL/TLS certificates                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                           │ API calls                           │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           Azure App Service (Linux)                       │  │
│  │  - Docker containers                                      │  │
│  │  - Auto-scaling (2-10 instances)                          │  │
│  │  - Blue-green deployment slots                            │  │
│  │  - Application Insights integration                       │  │
│  └───────────────────────┬──────────────────────────────────┘  │
│                          │                                      │
│                          │ PostgreSQL protocol                  │
│                          ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      Azure Database for PostgreSQL (Flexible Server)      │  │
│  │  - 2 vCores, 8GB RAM (scalable)                           │  │
│  │  - Automated backups (7 days)                             │  │
│  │  - Point-in-time restore                                  │  │
│  │  - High availability (zone redundant)                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │  Azure Container │  │  Application    │  │  Azure Key   │  │
│  │    Registry      │  │    Insights     │  │    Vault     │  │
│  │    (ACR)         │  │  (Monitoring)   │  │  (Secrets)   │  │
│  └──────────────────┘  └─────────────────┘  └──────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

### Deployment Pipeline

```
Developer → GitHub → CI Pipeline → Container Registry → Staging → Production
    │          │          │               │                 │          │
    │          │          │               │                 │          │
   Code      Push      Tests          Build Docker      Auto       Manual
   Push                Lint            Push to ACR      Deploy     Approval
                       Build                           
                       Security
```

## Scalability & Performance

### Horizontal Scaling

- **Frontend**: CDN edge locations worldwide
- **Backend**: Azure App Service auto-scaling (2-10 instances)
- **Database**: Read replicas for reporting (future)

### Caching Strategy

```
┌────────────────────────────────────────────────────────────┐
│                    Caching Layers                           │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Level 1: Browser Cache (Static assets)                    │
│           - 1 year for immutable assets                    │
│           - Cache-Control headers                          │
│                                                             │
│  Level 2: CDN Cache (Azure Static Web Apps)                │
│           - Frontend assets                                │
│           - Edge locations worldwide                       │
│                                                             │
│  Level 3: React Query Client Cache                         │
│           - API responses (5 minutes default)              │
│           - Smart invalidation on mutations                │
│                                                             │
│  Level 4: Database Query Cache (future)                    │
│           - Redis for frequently accessed data             │
│           - 15 minute TTL                                  │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### Performance Targets

| Metric | Target | Actual |
|--------|--------|--------|
| **API Response Time (p95)** | <500ms | TBD |
| **API Response Time (p99)** | <1000ms | TBD |
| **Frontend Load Time (p95)** | <2s | TBD |
| **Database Query (avg)** | <100ms | TBD |
| **Uptime** | >99.5% | TBD |

## Monitoring & Observability

See [docs/design/monitoring-logging.md](docs/design/monitoring-logging.md) for detailed monitoring design.

### Observability Stack

```
┌───────────────────────────────────────────────────────────┐
│                Application Components                      │
│  ┌──────────┐  ┌─────────┐  ┌──────────┐                 │
│  │ Frontend │  │ Backend │  │ Database │                 │
│  └────┬─────┘  └────┬────┘  └────┬─────┘                 │
│       │             │             │                        │
│       │ Metrics     │ Logs        │ Metrics                │
│       │ Traces      │ Metrics     │ Slow queries           │
│       │             │ Traces      │                        │
│       └─────────────┼─────────────┘                        │
│                     ▼                                      │
│  ┌──────────────────────────────────────────┐             │
│  │    Azure Application Insights             │             │
│  │  - APM (Application Performance)          │             │
│  │  - Distributed tracing                    │             │
│  │  - Custom events & metrics                │             │
│  │  - Log aggregation                        │             │
│  │  - Alerting                               │             │
│  └──────────────────┬───────────────────────┘             │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────────┐             │
│  │    Azure Monitor Dashboards               │             │
│  │  - Real-time metrics                      │             │
│  │  - Custom queries (KQL)                   │             │
│  │  - Alerts & notifications                 │             │
│  └──────────────────────────────────────────┘             │
└───────────────────────────────────────────────────────────┘
```

### Key Metrics Monitored

- **Golden Signals**: Latency, Traffic, Errors, Saturation
- **Business Metrics**: User activity, feature usage
- **Infrastructure**: CPU, memory, disk, network
- **Security**: Failed logins, unauthorized access attempts

---

**Document Status:** ✅ Complete  
**For detailed design, see individual documents in [docs/design/](docs/design/)**
