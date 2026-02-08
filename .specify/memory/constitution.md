# SchemaJeli Constitution

## Core Principles

### I. Modernization with Care
Modern architecture MUST be adopted: TypeScript, REST APIs, containerized deployment, cloud-native design. However, business logic and data integrity from the legacy system MUST be preserved. Complete feature parity required before deprecating legacy code.

### II. Security-First (NON-NEGOTIABLE)
Every endpoint MUST have authentication/authorization. Passwords hashed with bcrypt (≥12 rounds). SQL injection prevented via parameterized queries. OWASP Top 10 vulnerabilities explicitly tested. Audit trail maintained for all data modifications.

### III. Test-Driven Development (MANDATORY)
Minimum 70% code coverage required. Tests written BEFORE implementation. Unit tests for business logic. Integration tests for API contracts. E2E tests for user workflows. No merged code without passing test suite.

### IV. Data Integrity & Parent-Child Relationships
Relational hierarchy (Server → Database → Table → Element) MUST be enforced at database level via foreign keys. Orphaned records not permitted. Deletion cascades properly defined. Circular dependencies prevented.

### V. User-Centric Development
Features MUST be validated with actual users. Help documentation MUST be current and comprehensive. Error messages MUST be clear and actionable. No breaking API changes without deprecation period and migration guide.

### VI. Observability & Monitoring
All services MUST emit structured logs. Health checks on all critical dependencies. Metrics collection for performance monitoring. Alerting for error conditions and performance degradation. Tracing for request flow visibility.

### VII. Rebranding Completeness
ALL new code MUST use "SchemaJeli" branding. No legacy "CompanyName" branding in user-facing content of new application. Legacy code preserved in `legacy/` folder for reference only. All modern documentation, configuration, help systems, and UI use SchemaJeli exclusively.

## Development Workflow

### Code Quality Gates
- **Static Analysis:** ESLint + TypeScript strict mode mandatory
- **Testing:** Minimum 70% coverage, all tests passing
- **Security:** Snyk dependency check, no high-severity vulnerabilities
- **Performance:** API response times <500ms p95, bundle size <500KB
- **Documentation:** API endpoints documented, complex logic commented

### Deployment Process
- All code merged to main MUST pass CI/CD pipeline
- Staging deployment for UAT before production
- Blue-green deployment for zero-downtime updates
- Automated rollback triggers (health check failures, error rate >5%)
- Approval required for production deployments

### Review & Approval
- Code review by at least one senior engineer
- Security review for auth/database changes
- UX review for user-facing features
- Performance review for data-heavy operations

## Architecture & Technology Standards

### MUST Adopt
- **Backend:** Node.js 18+ LTS with Express.js and TypeScript
- **Frontend:** React 19 with TypeScript
- **Database:** PostgreSQL 15+ (primary)
- **Container:** Docker with multi-stage builds
- **Deployment:** Azure App Service (backend) + Azure Static Web App (frontend)
- **API Design:** REST with OpenAPI 3.0 specification
- **Authentication:** Azure Entra ID (MSAL) — JWT with JWKS validation, no local passwords
- **Logging:** Structured JSON logs via Winston to Application Insights

### MUST NOT Adopt (Legacy)
- VBScript/ASP (except for migration utilities)
- Informix as primary database (migration only)
- Browser version detection (modern browsers only)
- Session-based authentication (JWT only)
- Stored procedures for business logic (move to application layer)

## Performance & Scalability

### Response Time Targets
- Simple queries: <100ms
- Complex searches: <500ms p95
- Report generation: <10s standard reports
- API health checks: <50ms

### Scalability Requirements
- Support 100+ concurrent users minimum
- Stateless API design (horizontal scaling)
- Connection pooling for database (minimum 20 connections)
- Caching strategy for frequently accessed data (Redis optional)

## Security & Compliance

### Mandatory Security Controls
- All data transmitted over HTTPS/TLS
- Password minimum 12 characters, complexity required (for Entra ID policy — not managed locally)
- MFA optional for users, mandatory for admins (managed via Entra ID Conditional Access)
- Rate limiting: 100 requests/minute per user
- Input validation on all forms and API endpoints
- CSRF tokens on all state-changing operations
- XSS protection via Content Security Policy

### Audit & Compliance
- All database modifications logged (user, timestamp, before/after values)
- Soft deletes for data (never physically delete)
- Data retention policy: 7 years for audit logs
- Regular backup testing (weekly restore tests)
- Incident response plan documented

## Quality Assurance

### Testing Requirements
- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical user workflows
- Performance/load tests for scalability
- Security tests (OWASP ZAP, dependency scanning)
- Accessibility tests (WCAG 2.1 AA)

### Monitoring & SLOs
- Availability: 99.5% uptime SLA
- Response time: 95th percentile <500ms
- Error rate: <0.1% (5xx errors)
- Data accuracy: 100% (audit trail enabled)

## Governance & Amendments

This constitution supersedes all other technical practices and guidelines. All technical decisions must comply with these principles. Exceptions require explicit approval and documentation.

**Amendment Process:** Changes require consensus from tech leads and documented with rationale and transition plan.

**Compliance Verification:** All PRs verified against constitution. Violations flagged in review. Non-compliant code not merged.

**Version**: 1.0.0 | **Ratified**: 2026-01-29 | **Last Amended**: 2026-01-29
