# Architecture Specifications

High-level system architecture, design decisions, and component documentation.

## System Architecture

SchemaJeli is a metadata repository for managing database schemas across multiple RDBMS platforms.

### Components

#### Frontend
- React 19 SPA with TypeScript
- MSAL integration for Azure Entra ID authentication
- Role-based access control (Admin, Maintainer, Viewer)
- Components: Servers, Databases, Tables, Elements, Abbreviations management

#### Backend
- Node.js/Express REST API
- JWT authentication with Azure Entra ID
- RBAC with group-based role mapping
- On-Behalf-Of (OBO) flow for Graph API access
- PostgreSQL database

#### Infrastructure
- Azure App Service (Backend API)
- Azure Static Web App (Frontend)
- PostgreSQL Flexible Server (Database)
- Azure Storage (File uploads/exports)
- Azure Key Vault (Secrets management)
- Azure App Configuration (Configuration management)
- Application Insights (Monitoring)

## Authentication Architecture

### Entra ID Integration
- Tenant: ibuyspy.net (62837751-4e48-4d06-8bcb-57be1a669b78)
- Backend App: b521d5cf-a911-4ea4-bba6-109a1fcb9fe9
- Frontend App: 97a5b577-ca4e-4250-844d-3b167e4496c6

### Role Hierarchy
1. **Admin** (Level 3) - Full system access, user management
2. **Maintainer** (Level 2) - Schema editing, database management
3. **Viewer** (Level 1) - Read-only access

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, TypeScript, Vite, MSAL |
| Backend | Node.js 18 LTS, Express, TypeScript |
| Database | PostgreSQL 15, Prisma ORM |
| Infrastructure | Azure (App Service, Static Web App, PostgreSQL) |
| IaC | Terraform |
| Monitoring | Application Insights |
| Auth | Azure Entra ID, JWT, JWKS |

## Data Flow

```
User Browser
  ↓ (Sign in)
Azure Entra ID
  ↓ (Access Token)
Frontend (MSAL)
  ↓ (API Request + Bearer Token)
Backend (JWT Validation)
  ↓ (RBAC Check)
Database (PostgreSQL)
  ↓ (Data)
Response to Frontend
```

## Design Decisions

### Why MSAL for Frontend Auth?
- Enterprise-grade authentication
- Multi-tenant support
- Conditional Access policies
- Modern standards (OAuth 2.0, OpenID Connect)

### Why OBO Flow?
- Secure token exchange for Graph API access
- User context preserved
- Improved audit trail

### Why Terraform for IaC?
- Multi-cloud compatibility
- Repeatable, version-controlled infrastructure
- Modular design for easy customization

## API Design

RESTful API following OpenAPI 3.0.3 specification:
- Resource-based URLs
- Standard HTTP methods (GET, POST, PUT, DELETE)
- Consistent JSON response format
- Pagination support for list endpoints
- Bearer token authentication

## Security

- TLS/HTTPS for all communications
- JWT token validation with JWKS
- Role-based access control (RBAC)
- Secrets managed in Azure Key Vault
- Managed identities for Azure service-to-service auth
