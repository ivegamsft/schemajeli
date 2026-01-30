# SchemaJeli - Migration Plan

## Executive Summary

This plan outlines the modernization and rebranding of the legacy CompanyName Repository System into SchemaJeli, a contemporary cloud-native metadata repository. The migration will be executed in 4 phases over 16 weeks, with careful preservation of functionality while introducing modern architecture, improved security, and enhanced scalability.

---

## Phase Overview

| Phase | Duration | Focus | Outcomes |
|-------|----------|-------|----------|
| **Phase 1** | Weeks 1-3 | Foundation & Analysis | Architecture design, build setup, test harness |
| **Phase 2** | Weeks 4-8 | Core API Implementation | User auth, CRUD operations, search, validation |
| **Phase 3** | Weeks 9-13 | Frontend & Integration | Web UI, reports, data import/export |
| **Phase 4** | Weeks 14-16 | Testing, Deployment, Handoff | Performance tuning, documentation, deployment |

---

## Architecture Decision Records (ADRs)

### ADR-1: Technology Stack

**Decision:** 
- **Backend:** Node.js 18+ with Express.js or Python 3.11+ with FastAPI
- **Frontend:** React 18+ with TypeScript
- **Database:** PostgreSQL 14+ with TimescaleDB extension for audit trails
- **Deployment:** Docker containers, Kubernetes orchestration (with Helm charts)
- **Cloud Provider:** Azure (primary) with AWS/On-Prem fallback

**Rationale:**
- Industry-standard modern stack with strong ecosystem
- Language-agnostic API design enables future client diversity
- PostgreSQL offers superior JSON support and audit capabilities
- Containerization ensures environment consistency
- Cloud-native approach enables horizontal scaling

**Alternatives Considered:**
- Django + Vue.js (considered but Node.js offers better real-time capabilities)
- MongoDB (rejected - normalized relational schema essential)
- Custom orchestration (Kubernetes standard for enterprise)

---

### ADR-2: Database Migration Strategy

**Decision:** 
- Create new PostgreSQL schema via Terraform/Bicep IaC
- Implement ETL pipeline to migrate Informix/DB2 data
- Run parallel systems during transition period
- Cutover after validation and sign-off

**Rationale:**
- Allows incremental data validation
- Enables rollback if issues detected
- Zero downtime migration possible
- Clean schema opportunity (data cleanup)

**Phases:**
1. PostgreSQL schema setup in dev/test environments
2. ETL development and testing with sample data
3. Full data migration in staging environment
4. Validation period with read-only access
5. Cutover to production with rollback plan

---

### ADR-3: Authentication & Authorization

**Decision:**
- JWT-based stateless authentication
- Role-based access control (RBAC) with 3 roles: Admin, Maintainer, Viewer
- OAuth2/OpenID Connect for SSO integration (future)
- Bcrypt for password hashing with salt
- Multi-factor authentication (MFA) optional, Admin enforced

**Rationale:**
- JWT enables horizontal scaling without session store
- RBAC simplicity meets current requirements with extension path
- OAuth2 enables enterprise directory integration (AD, LDAP)
- Bcrypt industry standard for password security
- MFA addresses modern security requirements

---

### ADR-4: API Design

**Decision:**
- RESTful API design with clear resource hierarchy
- OpenAPI 3.0 specification for all endpoints
- Versioning via URL path (/api/v1/, /api/v2/)
- JSON request/response format exclusively
- Comprehensive error responses with correlation IDs

**Rationale:**
- REST familiar to most developers
- OpenAPI enables client generation and documentation
- URL versioning prevents silent API breaks
- JSON standard for modern web applications
- Error tracking aids debugging and support

**Example Resource Hierarchy:**
```
/api/v1/servers
/api/v1/servers/{id}/databases
/api/v1/servers/{id}/databases/{db_id}/tables
/api/v1/servers/{id}/databases/{db_id}/tables/{table_id}/elements
/api/v1/abbreviations
/api/v1/search
```

---

### ADR-5: Frontend Architecture

**Decision:**
- Single-page application (SPA) with React
- State management via Redux Toolkit or Zustand
- Component library with Tailwind CSS for consistent UI
- Responsive design mobile-first approach
- Progressive enhancement (works without JavaScript)

**Rationale:**
- React provides rich interactive experience
- State management simplifies complex metadata operations
- Tailwind accelerates development and ensures consistency
- Mobile-first ensures broad device support
- Progressive enhancement meets accessibility standards

---

### ADR-6: Data Validation & Integrity

**Decision:**
- Schema validation at API layer (Zod/Joi)
- Database constraints enforce business rules
- Naming validation regex patterns maintained in configuration
- Forbidden characters blacklist in database
- Parent-child relationship enforcement via foreign keys

**Rationale:**
- Layered validation prevents invalid data entry
- Database constraints provide last-line defense
- Centralized validation rules enable consistency
- Configuration-driven validation allows admin changes
- Referential integrity guaranteed by database

---

### ADR-7: Audit & Compliance

**Decision:**
- All data modifications logged with user, timestamp, change delta
- Immutable audit log with separate retention policy
- Soft deletes (logical deletion) with audit trail
- Change tracking via UUID-based temporal tables
- Export audit logs to compliance system (SIEM)

**Rationale:**
- Regulatory compliance (SOX, GDPR, HIPAA)
- Investigative capability for data changes
- Audit trail enables change rollback if needed
- UUID ensures uniqueness across systems
- SIEM integration supports enterprise security

---

## Technology Stack Details

### Backend Requirements

**Runtime & Frameworks:**
- Node.js 18+ LTS with Express.js OR Python 3.11+ with FastAPI
- TypeScript for type safety and IDE support
- Package management: npm/yarn (Node) or poetry (Python)

**Key Dependencies:**
- Database: `pg` (Node) or `psycopg3` (Python)
- Auth: `jsonwebtoken`, `bcryptjs`, `passport.js`
- Validation: `zod` or `pydantic`
- API Docs: `swagger-ui-express`, `@nestjs/swagger`
- Testing: `jest`, `supertest` (Node) or `pytest` (Python)
- Logging: `winston`, `bunyan` (Node) or `structlog` (Python)
- Monitoring: OpenTelemetry instrumentation

**Environment Variables (dotenv):**
```
NODE_ENV=production|development|test
DATABASE_URL=postgresql://...
JWT_SECRET=...
JWT_EXPIRY=3600
BCRYPT_ROUNDS=12
LOG_LEVEL=info|debug
CORS_ORIGIN=https://schemajeli.com
```

---

### Frontend Requirements

**Runtime & Frameworks:**
- Node.js 18+ for development
- React 18+, TypeScript
- Build tooling: Vite or Next.js
- CSS: Tailwind CSS + PostCSS

**Key Dependencies:**
- State: Redux Toolkit, React Query
- UI Components: Radix UI, Shadcn/UI
- Forms: React Hook Form, Zod
- HTTP: axios with interceptors
- Testing: Vitest, React Testing Library
- E2E: Playwright or Cypress

**Build Output:**
- Static SPA deployed to CDN
- No server-side rendering initially
- Progressive enhancement with fallbacks

---

### Database Schema (PostgreSQL)

**Core Tables:**
- `users` - User accounts with roles
- `audit_log` - Immutable change log
- `servers` - Database server definitions
- `databases` - Database definitions with status
- `tables` - Table definitions with parent reference
- `elements` - Column/element definitions with properties
- `abbreviations` - Standard naming abbreviations
- `forbidden_chars` - Character validation blacklist
- `user_audit_trails` - Activity logging

**Indexes:**
- B-tree on commonly searched columns (name, status)
- Full-text search on descriptions/keywords
- Composite indexes on (server_id, database_id, etc.)

---

## Data Migration Strategy

### ETL Pipeline

**Step 1: Assessment (Week 1)**
- Document Informix/DB2 schema
- Identify data quality issues
- Plan transformation rules

**Step 2: Schema Creation (Week 2)**
- Create PostgreSQL schema in dev environment
- Set up test data fixtures
- Create reverse migration scripts

**Step 3: ETL Development (Weeks 3-4)**
- Build Informix-to-PostgreSQL data loader
- Handle data type conversions
- Implement validation and reconciliation

**Step 4: Testing & Validation (Weeks 5-6)**
- Test with sample data subsets
- Validate data integrity
- Performance testing on full dataset

**Step 5: Parallel Operation (Weeks 7-8)**
- Run dual systems with data synchronization
- User acceptance testing in new system
- Issue identification and remediation

**Step 6: Cutover (Week 8)**
- Final data sync
- System switchover during maintenance window
- Rollback procedures on standby

---

## Rebranding Plan

### Scope of Changes

1. **User-Facing Branding**
   - Page titles: "CompanyName Repository" → "SchemaJeli"
   - Help system references updated
   - Logo/imagery replacement (new SchemaJeli branding)
   - Color scheme update (if applicable)

2. **Internal References**
   - Code comments and documentation
   - Database object names (functions, procedures)
   - Configuration values and strings
   - Error messages and help text

3. **URLs and Paths**
   - Domain: `schemajeli.example.com` → `schemajeli.{company}.com`
   - API paths: `/api/CompanyName/` → `/api/schemajeli/` (optional)
   - Deployment paths: adjust as needed

4. **Code Artifacts**
   - Repository rename (Git)
   - Package names: `@CompanyName/repository` → `@schemajeli/core`
   - Docker image names: `CompanyName-repo` → `schemajeli-server`

### Rebranding Execution

**Phase 1 Deliverables:**
- Create find-replace list for all CompanyName → SchemaJeli references
- Update all help HTML files
- Update UI text and labels
- Update configuration files

**Quality Assurance:**
- Search codebase for missed references
- Visual review of all user-facing pages
- Test all help links and documentation

---

## Deployment Strategy

### Environments

**Development:** Local dev + shared dev server  
**Staging:** Production-like environment for testing  
**Production:** Azure App Service or AKS cluster  

### Deployment Pipeline

```
Git Push → GitHub Actions
  → Build Docker image
  → Run security scanning
  → Run tests
  → Push to registry
  → Deploy to staging
  → Smoke tests
  → Deploy to production
  → Health checks
```

### Infrastructure as Code

**Terraform/Bicep Resources:**
- PostgreSQL database (managed service)
- App Service or AKS cluster
- Key Vault for secrets
- Application Insights for monitoring
- CDN for static assets
- Network security groups and WAF

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Data loss during migration | Low | Critical | Incremental testing, parallel systems, backups |
| Performance degradation | Medium | High | Load testing, caching strategy, index optimization |
| User adoption | Medium | Medium | Training, documentation, gradual rollout |
| Breaking API changes | Low | High | Versioning strategy, deprecation warnings |
| Security vulnerabilities | Medium | Critical | OWASP review, penetration testing, SSO integration |
| Schedule delays | Medium | Medium | Buffer time in schedule, phased delivery |

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Test Coverage | 70%+ | Code coverage tools |
| API Response Time | <500ms p95 | Application Performance Monitoring |
| Uptime | 99.5% | Monitoring dashboards |
| Data Accuracy | 100% | Audit trail comparison |
| User Adoption | 90% | Usage analytics |
| Security Score | A+ | OWASP ZAP, Snyk |

---

## Timeline & Milestones

- **Week 1-2:** Architecture finalized, project setup, team onboarding
- **Week 3-4:** Core API endpoints complete, database schema finalized
- **Week 5-8:** Full backend implementation, ETL pipeline operational
- **Week 9-11:** Frontend development, UI implementation
- **Week 12-13:** Integration testing, performance optimization
- **Week 14-15:** Security audit, documentation, training
- **Week 16:** Production deployment, monitoring, support handoff

---

## Resources & Team

**Required Roles:**
- Backend Architect/Lead (1-2 engineers)
- Frontend Lead (1-2 engineers)
- DevOps/Infrastructure Engineer (1)
- QA Engineer (1)
- Product Manager (1)
- Technical Writer (0.5)

**Estimated Effort:** ~20-25 person-weeks total

---

## Assumptions & Dependencies

**Assumptions:**
- Legacy Informix/DB2 system remains available during migration
- Existing schema documentation is reasonably accurate
- Business requirements haven't fundamentally changed
- Cloud infrastructure (Azure) available and approved

**Dependencies:**
- Admin access to legacy databases
- Cloud platform approval and setup
- Team skilled in modern development practices
- Stakeholder availability for UAT

---

## Rollback Plan

**If Critical Issues Detected:**
1. Revert to legacy CompanyName system within 2 hours
2. Maintain data synchronization during troubleshooting
3. Root cause analysis before second cutover attempt
4. Enhanced testing before retry

**Rollback Triggers:**
- Data integrity issues detected post-cutover
- Business-critical functionality not working
- Performance below acceptable thresholds
- Security vulnerabilities discovered

