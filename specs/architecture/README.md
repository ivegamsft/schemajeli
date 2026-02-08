# Architecture Specifications

High-level system architecture, design decisions, and component documentation.

> **Clarification Log (2026-02-08):** Five underspecified areas were identified during
> SpecKit clarification and resolved. See [Clarifications Resolved](#clarifications-resolved)
> at the end of this document.

## System Architecture

SchemaJeli is a metadata repository for managing database schemas across multiple RDBMS platforms.

### Components

#### Frontend
- React 19 SPA with TypeScript
- MSAL integration for Azure Entra ID authentication (no local login/password)
- Role-based access control: **Admin**, **Maintainer**, **Viewer**
- Components: Servers, Databases, Tables, Elements, Abbreviations management
- State management: Zustand with persist middleware

#### Backend
- Node.js 18+ LTS / Express REST API with TypeScript
- JWT authentication via Azure Entra ID (JWKS validation, no local auth)
- RBAC with group-based role mapping from Entra ID token claims
- On-Behalf-Of (OBO) flow for Graph API access
- PostgreSQL database via Prisma ORM
- Soft deletes on all entities (`deletedAt` field) — no physical deletion

#### Infrastructure (Azure-only)
- Azure App Service (Backend API)
- Azure Static Web App (Frontend)
- PostgreSQL Flexible Server (Database)
- Azure Storage (File uploads/exports)
- Azure Key Vault (Secrets management)
- Azure App Configuration (Configuration management)
- Application Insights (Monitoring)
- Terraform for all IaC (no Kubernetes, no AKS)

### User Data Model

Users are authenticated exclusively via Azure Entra ID. A **minimal local user record** is auto-created on first Entra ID login and stores:
- Entra ID object ID (`oid` from JWT)
- Display name and email (cached from token claims)
- User preferences (UI settings, default filters)

This local record serves as the FK target for audit trail fields (`createdById`, `updatedById`) across all entities. Role/permission data is **not** stored locally — it is derived from Entra ID token claims (`roles` or `groups`) on every request.

### Entity Status Model

All schema entities (Server, Database, Table, Element) use a **lifecycle-oriented** status enum:
- **ACTIVE** — Currently in use
- **INACTIVE** — Temporarily disabled, retained for reference
- **ARCHIVED** — Permanently archived for historical reference

## Authentication Architecture

### Entra ID Integration (Sole Auth Provider)
- **No local username/password authentication** — all auth is via Azure Entra ID
- Tenant: ibuyspy.net (62837751-4e48-4d06-8bcb-57be1a669b78)
- Backend App: b521d5cf-a911-4ea4-bba6-109a1fcb9fe9
- Frontend App: 97a5b577-ca4e-4250-844d-3b167e4496c6
- User account management (create, modify, disable) is handled in Entra ID, not in SchemaJeli
- Dev fallback: `RBAC_MOCK_ROLES` env var for local testing without Azure

### Role Hierarchy
1. **Admin** (Level 3) - Full system access, user management (in Entra ID)
2. **Maintainer** (Level 2) - Schema editing, database management
3. **Viewer** (Level 1) - Read-only access

> **Note:** The canonical role names are **Admin, Maintainer, Viewer**. Earlier documentation
> referencing "Editor" is superseded.

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, TypeScript, Vite, MSAL, Zustand, Tailwind CSS v4 |
| Backend | Node.js 18+ LTS, Express, TypeScript, Prisma ORM |
| Database | PostgreSQL 15+, Prisma Migrate |
| Infrastructure | Azure (App Service, Static Web App, PostgreSQL Flexible Server) |
| IaC | Terraform (Azure-only, no Kubernetes) |
| Monitoring | Application Insights, Winston structured logging |
| Auth | Azure Entra ID (MSAL), JWT, JWKS |
| Testing | Vitest, React Testing Library, Playwright (E2E) |

## Data Flow

```
User Browser
  ↓ (Sign in)
Azure Entra ID
  ↓ (Access Token with roles/groups claims)
Frontend (MSAL)
  ↓ (API Request + Bearer Token)
Backend (JWT Validation via JWKS)
  ↓ (RBAC Check from token claims)
  ↓ (Auto-create/update local user record if needed)
Database (PostgreSQL via Prisma)
  ↓ (Data with soft-delete filtering)
Response to Frontend
```

## Design Decisions

### Why Azure Entra ID (no local auth)?
- Enterprise-grade authentication with MFA, Conditional Access
- No password storage liability — eliminates bcrypt/credential management
- User lifecycle managed centrally in Entra ID
- Modern standards (OAuth 2.0, OpenID Connect)

### Why MSAL for Frontend Auth?
- Official Microsoft library for Entra ID integration
- Multi-tenant support
- Automatic token refresh and caching
- Conditional Access policies

### Why OBO Flow?
- Secure token exchange for Graph API access
- User context preserved
- Improved audit trail

### Why Terraform for IaC?
- Repeatable, version-controlled infrastructure
- Modular design for easy customization
- Azure-native provider with full resource coverage

### Why Azure-Only (No Kubernetes)?
- App Service provides sufficient scaling for expected load (100+ concurrent users)
- Simpler operational model than AKS
- Lower cost for the deployment profile
- Static Web App provides built-in CDN and CI/CD for frontend

### Why Soft Deletes?
- Audit compliance requires data retention (7-year audit log policy)
- Prevents accidental data loss
- Enables "undo" workflows
- All queries filter on `deletedAt IS NULL` by default

## API Design

RESTful API following OpenAPI 3.0.3 specification:
- All routes prefixed `/api/v1/`
- Standard response envelope: `{ status: 'success'|'error', data?, message? }`
- Pagination: `page` + `limit` query params; response includes `total`, `page`, `limit`, `totalPages`
- Bearer token authentication (Entra ID JWT)
- Standard HTTP methods (GET, POST, PUT, DELETE)

## Security

- Azure Entra ID authentication on all endpoints (no local passwords)
- JWT token validation via Microsoft JWKS endpoint
- Role-based access control (Admin, Maintainer, Viewer) from token claims
- Soft deletes — no physical deletion of data
- Secrets managed in Azure Key Vault
- Managed identities for Azure service-to-service auth
- TLS/HTTPS for all communications
- Rate limiting: 100 req/min per user

## Clarifications Resolved

The following underspecified areas were identified and resolved on 2026-02-08:

| # | Area | Issue | Resolution |
|---|------|-------|------------|
| 1 | Authentication | `spec.md` referenced local username/password auth (REQ-1.1, SEC-3.1) contradicting the Entra ID implementation | **Entra ID-only** — no local auth. Spec updated to match. |
| 2 | Role Naming | Data-model spec used "Editor" while implementation uses "Maintainer" | **Admin, Maintainer, Viewer** is canonical. Data-model spec updated. |
| 3 | Deployment Target | spec.md and constitution referenced multi-cloud/Kubernetes; infrastructure is Azure-only | **Azure-only** (App Service + Static Web App). No Kubernetes. |
| 4 | Entity Status Enum | spec.md used "Production/Development/Testing/Approval"; data-model uses "ACTIVE/INACTIVE/ARCHIVED" | **ACTIVE, INACTIVE, ARCHIVED** (lifecycle-oriented). |
| 5 | Local User Table | Data-model defined full User entity but Entra ID handles auth externally | **Minimal local user record** auto-created from Entra ID login for audit trail FKs and preferences. |
