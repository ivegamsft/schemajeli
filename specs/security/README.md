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
- API rate limiting

### Compliance
- GDPR data retention policies
- SOC 2 compliance considerations
- Data residency requirements (Azure region)
- Backup and recovery procedures

## Security Best Practices

### Frontend
- Never store sensitive data in localStorage (tokens only)
- Validate all user input
- Use HTTPS only
- Implement CSRF protection
- Security headers (CSP, X-Frame-Options, etc.)

### Backend
- Validate all inputs server-side
- Enforce RBAC on every endpoint
- Log security events
- Implement rate limiting
- Regular dependency updates

### Infrastructure
- Enable Azure Firewall (production)
- Azure DDoS Protection
- Azure Security Center monitoring
- Regular security assessments
- Principle of least privilege

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
