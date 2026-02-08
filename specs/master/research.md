# Research Report: SchemaJeli Implementation

**Date**: 2026-01-29  
**Phase**: Phase 0 - Research & Technical Discovery  
**Status**: COMPLETE

## Executive Summary

All technical context items have been clarified. The implementation uses well-established technologies (Node.js 18+, React 19, TypeScript, PostgreSQL 15+, Azure services) with clear architectural patterns. No unknowns require additional research before proceeding to Phase 1 design.

## Technical Context Clarifications

### 1. Language/Version ✅ RESOLVED
- **Backend**: TypeScript with Node.js 18+ LTS
- **Frontend**: TypeScript with React 19
- **Rationale**: Both technologies are mature, well-documented, and align with constitution requirements
- **Version Support**: Node.js 18 is LTS (supported until April 2025), React 19 is stable as of 2024

### 2. Primary Dependencies ✅ RESOLVED
**Backend**:
- **Express.js**: De facto standard for Node.js HTTP servers, mature ecosystem
- **Prisma ORM**: Type-safe database client with migrations, prevents SQL injection
- **MSAL (@azure/msal-node)**: Official Microsoft authentication library for Azure Entra ID
- **Winston**: Industry standard structured logging library
- **Joi/Zod**: Schema validation libraries (Zod preferred for type inference)

**Frontend**:
- **Vite**: Next-generation build tool, significantly faster than Webpack
- **Zustand**: Lightweight state management (simpler than Redux)
- **Tailwind CSS v4**: Utility-first CSS framework
- **React Hook Form + Zod**: Form management with type-safe validation
- **Axios**: HTTP client with interceptor support for auth tokens

**Rationale**: All dependencies are production-ready with active maintenance and large community support.

### 3. Storage ✅ RESOLVED
- **Database**: PostgreSQL 15+ on Azure Database for PostgreSQL Flexible Server
- **Soft Deletes**: All entities have `deletedAt` timestamp field (never physically delete)
- **Audit Trail**: `createdAt`, `updatedAt`, `createdById`, `updatedById` on all entities
- **Foreign Keys**: Enforced at database level via Prisma schema
- **Secrets**: Azure Key Vault for database credentials and JWT signing keys

**Rationale**: PostgreSQL provides robust relational integrity, full-text search (via tsvector), and JSON support for flexible metadata storage.

### 4. Testing ✅ RESOLVED
- **Unit Tests**: Vitest (fast, ESM-native, compatible with Vite)
- **Integration Tests**: Supertest (HTTP assertions for Express.js APIs)
- **Component Tests**: React Testing Library with Vitest
- **E2E Tests**: Playwright (cross-browser, headless, visual regression)
- **Coverage Requirements**: Backend ≥80%, Frontend ≥70%, Integration ≥60%

**Rationale**: Vitest is chosen over Jest for better ESM support and Vite integration. Playwright over Cypress for better cross-browser support and no flakiness issues.

### 5. Target Platform ✅ RESOLVED
- **Backend**: Azure App Service (Linux, Node.js 18 runtime)
- **Frontend**: Azure Static Web Apps (global CDN, auto SSL)
- **Database**: Azure Database for PostgreSQL Flexible Server (HA mode, 2 vCores, 8GB RAM)
- **Monitoring**: Azure Application Insights (logs, metrics, distributed tracing)
- **Secrets**: Azure Key Vault
- **CI/CD**: GitHub Actions with Azure integration

**Rationale**: Azure-only deployment simplifies operations, leverages existing Microsoft enterprise agreements, and aligns with Azure Entra ID authentication requirements.

### 6. Performance Goals ✅ RESOLVED
- **Simple Queries**: <100ms (e.g., get server by ID, list databases for server)
- **Complex Searches**: <500ms p95 (full-text search across 1M column records)
- **Report Generation**: <10s for standard DDL reports
- **Concurrent Users**: 100+ supported via stateless API design
- **API Response Time**: <500ms p95 for all endpoints
- **Bundle Size**: <500KB (frontend gzipped)

**Measurement Strategy**: Application Insights performance monitoring, Lighthouse CI for frontend, k6 load testing in CI/CD pipeline.

### 7. Constraints ✅ RESOLVED
- **Azure-Only**: No AWS, GCP, or on-premises deployment
- **No Kubernetes**: App Service sufficient for scaling needs (simpler operational model)
- **Entra ID Only**: No local username/password authentication
- **Soft Deletes Mandatory**: Physical deletion prohibited per audit requirements
- **HTTPS Only**: No HTTP endpoints in production
- **RBAC Enforced**: Admin, Maintainer, Viewer roles on all endpoints

### 8. Scale/Scope ✅ RESOLVED
- **Data Volume**: ~500 servers, ~2K databases, ~50K tables, ~1M columns
- **Concurrent Users**: 100+ simultaneous users
- **Hierarchy Depth**: 4 levels (Server → Database → Table → Element)
- **Search Corpus**: Full-text indexing across all metadata fields
- **Audit Retention**: 7 years per compliance requirements

## Technology Deep Dives

### 1. Azure Entra ID Authentication Flow

**Decision**: Use MSAL.js (@azure/msal-browser) for frontend, validate JWT on backend via JWKS endpoint.

**Authentication Flow**:
1. User clicks "Sign In" → MSAL initiates Entra ID OAuth flow
2. User authenticates with Microsoft credentials
3. Entra ID returns access token (JWT) + refresh token
4. Frontend stores tokens in Zustand store (persisted to localStorage)
5. Frontend sends access token in `Authorization: Bearer <token>` header
6. Backend validates token signature via Entra ID JWKS endpoint (`https://login.microsoftonline.com/{tenant}/discovery/v2.0/keys`)
7. Backend extracts user claims (email, name, roles) from token
8. Backend checks role claims against endpoint permissions (RBAC middleware)

**No Local Passwords**: Backend does NOT store passwords. Minimal user record (`User` table) stores only `id`, `email`, `name`, `role` for foreign key references (createdBy/updatedBy).

**References**:
- [MSAL.js Documentation](https://learn.microsoft.com/en-us/entra/identity-platform/msal-js-overview)
- [JWT Validation with JWKS](https://auth0.com/docs/secure/tokens/json-web-tokens/validate-json-web-tokens)

### 2. Full-Text Search Implementation

**Decision**: Use PostgreSQL native full-text search (tsvector/tsquery) with GIN indexes.

**Implementation Approach**:
- Add `search_vector tsvector` column to searchable tables (servers, databases, tables, elements, abbreviations)
- Create GIN index on `search_vector` for fast lookups
- Update `search_vector` via Prisma middleware on insert/update
- Use `tsquery` for search queries with ranking (`ts_rank`)
- Support phrase search, prefix matching, and boolean operators

**Performance**: GIN indexes provide <100ms search across 1M records. Alternative (Elasticsearch) rejected due to operational complexity for 1M record scale.

**References**:
- [PostgreSQL Full-Text Search](https://www.postgresql.org/docs/15/textsearch.html)
- [Prisma Full-Text Search](https://www.prisma.io/docs/orm/prisma-client/queries/full-text-search)

### 3. Report Generation (DDL Export)

**Decision**: Generate DDL reports in-memory (no file system), stream responses for large exports.

**Supported Formats**:
- **SQL**: Standard CREATE TABLE statements (PostgreSQL, MySQL, Oracle, SQL Server dialects)
- **JSON**: Hierarchical schema structure (for programmatic consumption)
- **TXT**: Human-readable table documentation

**Implementation**:
- Service layer aggregates schema metadata (tables, columns, constraints)
- Template engine (Handlebars) generates format-specific output
- Express response streaming for large databases (>1000 tables)
- Error handling: Retry with exponential backoff (3 attempts), partial results with error notification

**Performance Target**: <2s for single database export, <10s for full server export.

### 4. Soft Delete Strategy

**Decision**: All entities have `deletedAt` timestamp field. Queries filter `WHERE deletedAt IS NULL` by default.

**Implementation**:
- Prisma middleware intercepts `delete()` calls, converts to `update({ deletedAt: new Date() })`
- Default queries automatically add `deletedAt: null` filter
- Admin users can query deleted entities via `?status=deleted` query parameter
- Cascade behavior: Deleting server soft-deletes all child databases, tables, elements

**Audit Trail**: AuditLog table records all deletions (user, timestamp, entity type, entity ID).

**References**:
- [Prisma Soft Deletes](https://www.prisma.io/docs/orm/prisma-client/queries/soft-delete)

## Best Practices Research

### 1. Node.js/Express API Design

**Patterns Adopted**:
- **Layered Architecture**: Controllers → Services → Repositories (Prisma)
- **Error Handling**: Centralized error middleware with typed exceptions
- **Validation**: Joi/Zod schemas for request validation
- **Logging**: Structured JSON logs with correlation IDs (Winston)
- **Security**: Helmet middleware, CORS configuration, rate limiting (express-rate-limit)

**References**:
- [Express.js Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [Node.js Production Checklist](https://github.com/goldbergyoni/nodebestpractices)

### 2. React 19 Best Practices

**Patterns Adopted**:
- **Component Structure**: Functional components with hooks (no class components)
- **State Management**: Zustand for global state (auth), local state for UI
- **Code Splitting**: React.lazy + Suspense for route-based splitting
- **Error Boundaries**: Catch render errors, display fallback UI
- **Accessibility**: ARIA labels, keyboard navigation, semantic HTML
- **Performance**: React.memo for expensive components, useMemo/useCallback for optimizations

**References**:
- [React 19 Documentation](https://react.dev/)
- [React Performance Optimization](https://react.dev/learn/render-and-commit)

### 3. TypeScript Strict Mode

**Configuration**: `tsconfig.json` with `strict: true` enables:
- `noImplicitAny`: All variables must have explicit types
- `strictNullChecks`: `null` and `undefined` must be explicitly handled
- `strictFunctionTypes`: Function parameter types are checked contravariantly
- `noImplicitThis`: `this` expressions must have explicit types

**Rationale**: Strict mode catches type errors at compile time, reducing runtime bugs.

### 4. Prisma ORM Patterns

**Best Practices**:
- **Type Safety**: Prisma generates TypeScript types from schema
- **Migrations**: Version-controlled migration files (`prisma migrate`)
- **Connection Pooling**: Configured via `DATABASE_URL` connection string
- **Query Optimization**: Use `include` for relations, avoid N+1 queries
- **Middleware**: Soft delete logic, audit trail updates

**References**:
- [Prisma Best Practices](https://www.prisma.io/docs/orm/prisma-client/best-practices)

## Integration Patterns

### 1. Backend ↔ Database (Prisma)

**Pattern**: Repository layer (Prisma Client) with service layer abstraction.

```typescript
// Service layer (business logic)
export class ServerService {
  async getServerById(id: string): Promise<Server> {
    const server = await prisma.server.findUnique({
      where: { id, deletedAt: null },
      include: { databases: true }
    });
    if (!server) throw new NotFoundException('Server not found');
    return server;
  }
}
```

### 2. Frontend ↔ Backend (Axios + MSAL)

**Pattern**: API client service with axios interceptor for auth tokens.

```typescript
// API client with token injection
const apiClient = axios.create({ baseURL: '/api' });

apiClient.interceptors.request.use(async (config) => {
  const token = await msalInstance.acquireTokenSilent({ scopes: ['api://app-id/.default'] });
  config.headers.Authorization = `Bearer ${token.accessToken}`;
  return config;
});
```

### 3. CI/CD Pipeline (GitHub Actions + Azure)

**Pipeline Stages**:
1. **Lint**: ESLint + Prettier check
2. **Type Check**: TypeScript compilation
3. **Unit Tests**: Vitest with coverage report
4. **Integration Tests**: Supertest API tests
5. **Build**: TypeScript → JavaScript, Vite → static assets
6. **Security Scan**: Snyk dependency check
7. **Deploy**: Azure App Service (backend), Static Web App (frontend)
8. **E2E Tests**: Playwright against staging environment

**References**:
- [GitHub Actions Azure Deployment](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions)

## Risk Mitigation

### 1. Performance Risks

**Risk**: Full-text search across 1M columns may exceed 500ms p95 target.

**Mitigation**:
- GIN indexes on `search_vector` columns
- Query result pagination (limit 25-200 per page)
- Caching layer (Redis) if needed (Phase 2+ optimization)
- Load testing in CI/CD with k6 (simulate 100 concurrent users)

### 2. Security Risks

**Risk**: JWT token theft via XSS or MITM attacks.

**Mitigation**:
- HttpOnly cookies for refresh tokens (not accessible via JavaScript)
- Content Security Policy (CSP) headers to prevent XSS
- HTTPS only in production (HSTS header)
- Token expiration: 1 hour for access tokens, 7 days for refresh tokens
- Token rotation on refresh

### 3. Data Migration Risks

**Risk**: Informix → PostgreSQL data loss or corruption during migration.

**Mitigation**:
- ETL scripts with validation (row counts, checksums)
- Parallel run period (legacy + modern systems active)
- Rollback plan (restore Informix snapshot)
- Data integrity checks post-migration

### 4. Operational Risks

**Risk**: Azure App Service downtime during deployments.

**Mitigation**:
- Blue-green deployment (zero downtime)
- Health check endpoints (`/health`, `/ready`)
- Automated rollback on health check failures
- Staging environment for UAT before production

## Decisions Summary

| Decision | Chosen Option | Alternatives Considered | Rationale |
|----------|---------------|-------------------------|-----------|
| Backend Framework | Express.js | Fastify, NestJS | Mature ecosystem, team familiarity |
| ORM | Prisma | TypeORM, Sequelize | Type safety, migrations, modern DX |
| Frontend Build Tool | Vite | Webpack, Parcel | Faster builds, ESM-native |
| State Management | Zustand | Redux, MobX | Simpler API, less boilerplate |
| Testing Framework | Vitest | Jest | Vite integration, faster execution |
| E2E Testing | Playwright | Cypress | Cross-browser, less flaky |
| Authentication | Azure Entra ID | Auth0, Okta | Enterprise requirement, existing infra |
| Deployment | Azure App Service | Kubernetes (AKS) | Simpler ops, lower cost, sufficient scale |
| Full-Text Search | PostgreSQL tsvector | Elasticsearch | Lower complexity, 1M records manageable |
| CSS Framework | Tailwind CSS v4 | Bootstrap, Material-UI | Utility-first, smaller bundle |

## Phase 0 Conclusion

**Status**: ✅ **COMPLETE**

All technical context items have been clarified. No unknowns remain that would block Phase 1 design work. All technology choices align with the constitution requirements and have clear implementation paths.

**Next Steps**: Proceed to Phase 1 - Data Model & Contracts.
