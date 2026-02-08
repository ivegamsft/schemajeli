# Security Specifications

Security architecture, authentication, authorization, and compliance requirements.

## Authentication

### Azure Entra ID Integration

SchemaJeli uses Azure Entra ID for enterprise-grade authentication.

#### Configuration
- **Tenant:** ibuyspy.net (62837751-4e48-4d06-8bcb-57be1a669b78)
- **Backend App Registration:** b521d5cf-a911-4ea4-bba6-109a1fcb9fe9
- **Frontend App Registration:** 97a5b577-ca4e-4250-844d-3b167e4496c6

#### Frontend (MSAL)
- OpenID Connect with MSAL (@azure/msal-browser)
- Redirect URI: http://localhost:5173/auth/callback
- Token cached in browser localStorage
- Automatic token refresh via MSAL

#### Backend (JWT)
- Bearer token validation
- JWT signature verification via JWKS endpoint
- Token claims validation:
  - Audience (JWT_AUDIENCE)
  - Issuer (JWT_ISSUER)
  - Expiration (exp)
  - Not Before (nbf)
- JWKS endpoint: https://login.microsoftonline.com/{tenant_id}/discovery/v2.0/keys

## Authorization (RBAC)

### Role Hierarchy

| Role | Level | Permissions |
|------|-------|-------------|
| Admin | 3 | Full system access, user management, all CRUD operations |
| Maintainer | 2 | Schema editing, database management, abbreviation management |
| Viewer | 1 | Read-only access to all entities |

### Permission Matrix

| Resource | Admin | Maintainer | Viewer |
|----------|-------|-----------|--------|
| Servers | CRUD | R | R |
| Databases | CRUD | CRUD | R |
| Tables | CRUD | CRUD | R |
| Elements | CRUD | CRUD | R |
| Abbreviations | CRUD | CRUD | R |
| Users | CRU | - | - |
| Reports | Generate | Generate | Generate |

### Role Mapping

Roles are determined from:
1. **Token claims** - `roles` claim from token
2. **Group membership** - Mapped via environment variables:
   - RBAC_GROUP_ADMIN
   - RBAC_GROUP_MAINTAINER
   - RBAC_GROUP_VIEWER
3. **Mock roles** (dev only) - RBAC_MOCK_ROLES for local testing

## Token Security

### JWT Token Structure

```
Header:
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "<key-id>"
}

Payload:
{
  "oid": "<user-object-id>",
  "sub": "<subject>",
  "name": "<user-name>",
  "email": "<user-email>",
  "roles": ["Admin"],
  "groups": ["<group-id>"],
  "aud": "api://b521d5cf-a911-4ea4-bba6-109a1fcb9fe9",
  "iss": "https://sts.windows.net/62837751-4e48-4d06-8bcb-57be1a669b78/",
  "exp": <expiration-time>,
  "iat": <issued-at-time>,
  "nbf": <not-before-time>
}
```

### Token Lifecycle
- Access token: Short-lived (1 hour typical)
- Refresh token: Long-lived (session-based)
- Token validation on every API request
- Expired tokens trigger re-authentication

## On-Behalf-Of (OBO) Flow

Secure token exchange for backend-to-Graph API communication.

### Flow
1. Frontend acquires user token from Entra ID
2. Frontend sends token to backend in Authorization header
3. Backend exchanges user token for Graph API token via OBO flow
4. Backend calls Graph API with Graph token
5. User context preserved throughout flow

### Configuration
- AZURE_OBO_SCOPES: Requested scopes for Graph API
- Client credentials: AZURE_CLIENT_ID + AZURE_CLIENT_SECRET
- MSAL Node library for token exchange

## Secret Management

All secrets stored in Azure Key Vault:
- Database credentials
- JWT signing keys
- API keys
- Certificates

### Secret Rotation
- Database passwords: Recommended 90-day rotation
- Client secrets: 24-month expiration
- API keys: Rotate on security incidents

### Access Control
- Managed identities for service-to-service auth
- RBAC role assignments for human access
- Audit logging of secret access

## Network Security

### Transport Security
- TLS 1.2+ for all communications
- HTTPS enforced
- Certificate pinning (optional)

### Network Isolation
- Virtual Network with private subnets
- Network Security Groups for traffic control
- Private endpoints for Azure services (optional)

## Data Security

### In Transit
- TLS/HTTPS encryption
- Secure cookies (HttpOnly, Secure flags)

### At Rest
- Database encryption (Azure Disk Encryption)
- Storage Account encryption
- Key Vault encryption

### Data Classification
- Public: Non-sensitive metadata
- Internal: Business schema information
- Confidential: User information, credentials

## Audit & Compliance

### Audit Logging
- User authentication events
- Authorization decisions (RBAC checks)
- Data modification (CRUD operations)
- Error/exception logging

### Monitoring
- Failed authentication attempts
- Permission denied events
- Unauthorized access attempts
- API rate limiting (see Rate Limiting section below)

### Compliance
- GDPR data retention policies
- SOC 2 compliance considerations
- Data residency requirements (Azure region)
- Backup and recovery procedures

## Rate Limiting

### Thresholds
- **Per-user limit:** 100 requests per minute (sliding window)
- **Unauthenticated endpoints:** 20 requests per minute per IP
- **Authentication endpoints:** 10 requests per minute per IP (brute-force protection)

### Behavior
- HTTP 429 (Too Many Requests) response when limit exceeded
- `Retry-After` header included with seconds until next allowed request
- `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers on all responses
- Rate limit state stored in-memory (single instance) or Redis (scaled deployment)

### Exemptions
- Health check endpoint (`/api/v1/health`) is exempt from rate limiting

## Role Lifecycle & Group Synchronization

### Group-to-Role Sync
- Roles are resolved **on each authenticated request** from the JWT token claims
- Group membership is read from the `groups` claim in the token (requires Entra ID "Group Claims" configuration)
- **Cache TTL:** 15 minutes — group-to-role mappings are cached per user session to reduce token introspection overhead
- Cache is invalidated on explicit logout or token expiration

### User Deprovisioning
- Disabled Entra ID accounts are denied access at the JWT validation layer (token issuance ceases)
- No local user records to deactivate; all identity is delegated to Entra ID
- Audit log retains historical records for deprovisioned users (soft-delete compliant)

## Failure Handling & Resilience

### Graph API Failures (OBO Flow)
- If Graph API is unreachable, OBO-dependent features (e.g., profile photo, org chart) degrade gracefully
- Backend returns partial responses with a `warnings` array indicating degraded fields
- **Circuit breaker:** After 5 consecutive Graph API failures within 60 seconds, the circuit opens for 30 seconds before retrying
- All Graph API errors are logged with correlation IDs for troubleshooting

### Azure Key Vault Failures
- Secrets are cached in-memory at application startup with a **6-hour refresh interval**
- If Key Vault is unreachable during refresh, the application continues using cached secrets and logs a warning
- If Key Vault is unreachable at startup (cold start), the application fails fast with a clear error message
- Health check endpoint reports Key Vault connectivity status

### Token Refresh Edge Cases
- **Silent refresh failure:** If MSAL silent token acquisition fails, the user is prompted to re-authenticate via interactive flow
- **Concurrent sessions:** Multiple browser tabs share the same MSAL token cache in localStorage; MSAL handles lock contention
- **Concurrent role changes:** Role changes in Entra ID take effect on next token issuance (typically within 1 hour or on next login)
- **Clock skew:** JWT validation allows a 5-minute clock skew tolerance for `nbf` and `exp` claims

## Security Best Practices

### Frontend
- Token storage: MSAL-managed tokens in localStorage are acceptable per [Microsoft guidance](https://learn.microsoft.com/en-us/entra/identity-platform/scenario-spa-sign-in); no other sensitive data (PII, credentials, API keys) may be stored client-side
- Validate all user input
- Use HTTPS only
- Implement CSRF protection
- Security headers (CSP, X-Frame-Options, etc.)

### Backend
- Validate all inputs server-side
- Enforce RBAC on every endpoint
- Log security events
- Implement rate limiting (see Rate Limiting section)
- Regular dependency updates

### Infrastructure
- Enable Azure Firewall (production)
- Azure DDoS Protection
- Azure Security Center monitoring
- Regular security assessments
- Principle of least privilege

## Performance & Observability Targets

### Security-Related Performance
- **JWT validation:** < 10ms per request (JWKS keys cached in memory)
- **RBAC authorization check:** < 5ms per request
- **Rate limit evaluation:** < 2ms per request
- **OBO token exchange:** < 500ms p95 (network-dependent)

### Security Observability Metrics
- Authentication success/failure rate (per minute)
- Rate limit trigger count (per endpoint, per minute)
- RBAC denial count by role and endpoint
- OBO flow latency and failure rate
- Token refresh success/failure rate
- Circuit breaker state transitions (Graph API, Key Vault)

### Alerting Thresholds
- **Critical:** > 50 failed auth attempts per minute from a single IP
- **Warning:** > 10 rate limit triggers per minute for a single user
- **Critical:** Key Vault unreachable for > 5 minutes
- **Warning:** OBO flow error rate > 5% over 5-minute window

## Incident Response

### Security Incident Steps
1. Detect anomaly via monitoring/alerts
2. Isolate affected systems
3. Collect evidence and logs
4. Assess impact
5. Remediate vulnerability
6. Deploy fix
7. Monitor for recurrence

### Security Contact
- Report issues to: security@ibuyspy.net
- Response time: 24 hours for critical issues

## Clarifications

### Session 2026-01-29

- Q: What is the password policy for local development mock authentication? → A: No local password auth; use RBAC_MOCK_ROLES environment variable for dev only; production exclusively uses Azure Entra ID
- Q: How should API keys for third-party integrations be managed? → A: Store in Azure Key Vault with 180-day rotation; use managed identity for Azure service auth (passwordless preferred)
- Q: What is the session timeout configuration? → A: No server-side session state; JWT access tokens 1-hour expiry (handled by Entra ID); MSAL handles silent refresh
- Q: How should SQL injection be prevented? → A: Prisma ORM parameterized queries exclusively; no raw SQL concatenation allowed; static analysis (ESLint security plugin) enforces
- Q: What content security policy (CSP) should the frontend enforce? → A: `default-src 'self'; script-src 'self'; connect-src 'self' https://login.microsoftonline.com https://*.azure.com; img-src 'self' data: https:`
