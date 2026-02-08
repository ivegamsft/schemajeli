# Feature Specification: Authentication & Authorization System

**Feature Branch**: `N/A - Core System Feature`  
**Created**: 2026-02-08  
**Status**: Implemented  
**Input**: User description: "Authentication and authorization system using Azure Entra ID (MSAL), RBAC roles (Admin, Maintainer, Viewer), JWT validation, and security best practices for SchemaJeli - a cloud-native database metadata repository."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secure Single Sign-On Access (Priority: P1)

As a database engineer or administrator, I need to securely access SchemaJeli using my organization's Azure Entra ID credentials so that I can view and manage database metadata without maintaining separate login credentials.

**Why this priority**: This is the foundation of all system access. Without authentication, no other functionality can be used securely. Single sign-on provides enterprise-grade security and eliminates password management overhead.

**Independent Test**: Can be fully tested by attempting to log in with valid Azure Entra ID credentials through the frontend application and receiving an access token that allows viewing of database metadata. Success means user can authenticate, receive a valid JWT token, and access protected resources.

**Acceptance Scenarios**:

1. **Given** a user with valid Azure Entra ID credentials, **When** they click "Sign In" on the SchemaJeli login page, **Then** they are redirected to Microsoft login, authenticate successfully, and return to SchemaJeli with an active session.

2. **Given** an authenticated user with an active session, **When** their access token expires (after 1 hour), **Then** the system automatically refreshes the token silently without requiring re-login.

3. **Given** a user with invalid or expired credentials, **When** they attempt to access protected resources, **Then** they receive a 401 Unauthorized response and are redirected to login.

4. **Given** an authenticated user, **When** they click "Sign Out", **Then** their session is terminated, tokens are cleared, and they cannot access protected resources until re-authenticating.

---

### User Story 2 - Role-Based Access Control (Priority: P1)

As a system administrator, I need to assign different permission levels (Admin, Maintainer, Viewer) to users so that I can control who can view, edit, or delete database metadata based on their organizational role.

**Why this priority**: Authorization is equally critical as authentication. Users must only be able to perform actions appropriate to their role to prevent unauthorized data modification or deletion. This is essential for data integrity and compliance.

**Independent Test**: Can be tested by assigning different roles to test users and verifying that each role can only perform permitted actions. For example, a Viewer attempting to delete a database entry should receive a 403 Forbidden response, while an Admin performing the same action should succeed.

**Acceptance Scenarios**:

1. **Given** a user with Admin role, **When** they attempt to create, read, update, or delete any resource (servers, databases, tables, users), **Then** all operations succeed.

2. **Given** a user with Maintainer role, **When** they attempt to create, read, update, or delete databases, tables, or abbreviations, **Then** these operations succeed, but attempting to delete servers or manage users returns 403 Forbidden.

3. **Given** a user with Viewer role, **When** they attempt to read any resource, **Then** the read succeeds, but attempting any create, update, or delete operation returns 403 Forbidden.

4. **Given** a user's Azure Entra ID group membership changes (e.g., added to Admin group), **When** they log in again or their token refreshes, **Then** their new role permissions are immediately effective.

---

### User Story 3 - Audit Trail and Accountability (Priority: P2)

As a compliance officer or administrator, I need to see a complete audit trail of all data modifications (who changed what, when) so that I can track changes, investigate incidents, and meet regulatory compliance requirements.

**Why this priority**: Audit logging is critical for compliance, security incident investigation, and accountability. While not blocking basic functionality, it must be implemented early to ensure no data changes go untracked.

**Independent Test**: Can be tested by performing various CRUD operations as different users and verifying that each operation is logged in the AuditLog table with correct user ID, timestamp, action type, entity details, and IP address. Success means complete auditability of all data modifications.

**Acceptance Scenarios**:

1. **Given** an authenticated user creates a new database entry, **When** the creation succeeds, **Then** an audit log entry is created with action="CREATE", userId, entityType="Database", entityId, timestamp, and IP address.

2. **Given** an authenticated user updates an existing table, **When** the update succeeds, **Then** an audit log entry captures the before/after state in the changes JSON field, along with user, timestamp, and action="UPDATE".

3. **Given** an Admin user deletes a server (soft delete), **When** the deletion succeeds, **Then** an audit log entry records action="DELETE", and the server's deletedAt timestamp is set (not physically removed).

4. **Given** an administrator reviews recent changes, **When** they query the audit log filtered by date range and entity type, **Then** they receive a complete chronological list of all matching operations with full user context.

---

### User Story 4 - Secure Development and Testing (Priority: P3)

As a developer, I need to test authentication and authorization flows locally without requiring production Azure Entra ID credentials so that I can develop and debug security features efficiently in my development environment.

**Why this priority**: Developer productivity is important, but lower priority than production security features. This story enables faster development cycles without compromising production security.

**Independent Test**: Can be tested by setting the RBAC_MOCK_ROLES environment variable in a local development environment and verifying that the backend accepts requests without full Azure Entra ID token validation while still enforcing role-based access control.

**Acceptance Scenarios**:

1. **Given** a developer sets RBAC_MOCK_ROLES="Admin,Maintainer" in their .env file, **When** they make API requests without a valid Azure Entra ID token, **Then** the backend treats the request as if the user has Admin and Maintainer roles.

2. **Given** a developer with RBAC_MOCK_ROLES="Viewer", **When** they attempt to delete a resource via the API, **Then** the request is denied with 403 Forbidden (RBAC still enforced).

3. **Given** the application is deployed to production (NODE_ENV=production), **When** any request is made, **Then** the RBAC_MOCK_ROLES environment variable is ignored and full JWT validation is enforced.

---

### User Story 5 - Resilient External Service Integration (Priority: P3)

As a system user, I need the application to remain functional even when Azure services (Key Vault, Graph API) experience temporary outages so that I can continue working with database metadata without interruption during external service disruptions.

**Why this priority**: Resilience improves user experience and system reliability, but is lower priority than core authentication/authorization. This story ensures graceful degradation rather than complete system failure.

**Independent Test**: Can be tested by simulating Azure Key Vault or Graph API failures (network disconnect, mock service unavailable) and verifying that core functionality (metadata CRUD) continues to work, with appropriate degraded behavior (e.g., profile photos unavailable) and logged warnings.

**Acceptance Scenarios**:

1. **Given** Azure Key Vault becomes unreachable during operation (not startup), **When** the application needs to refresh secrets, **Then** it continues using cached secrets and logs a warning without disrupting user operations.

2. **Given** the Microsoft Graph API is unavailable, **When** a user views their profile, **Then** basic profile information from the JWT token is displayed, but extended features (profile photo, org chart) are gracefully omitted with a user-friendly message.

3. **Given** Azure Key Vault is unreachable at application startup, **When** the backend initializes, **Then** it fails fast with a clear error message indicating Key Vault connectivity issue and required configuration.

4. **Given** the Microsoft Graph API fails 5 times in 60 seconds, **When** the next request requiring Graph API is made, **Then** the circuit breaker opens for 30 seconds, temporarily skipping Graph API calls to allow the service to recover.

---

### Edge Cases

- **Concurrent role changes**: What happens when a user's Azure Entra ID group membership changes while they have an active session? **Answer**: Role changes take effect on next token issuance (typically within 1 hour or on next login). The JWT token carries the roles at time of issuance.

- **Token clock skew**: How does the system handle JWT expiration validation when server clocks are slightly misaligned? **Answer**: JWT validation allows a 5-minute clock skew tolerance for `nbf` (not before) and `exp` (expiration) claims.

- **Multiple browser sessions**: What happens when a user logs in from multiple browser tabs simultaneously? **Answer**: MSAL manages tokens in localStorage shared across tabs. Lock contention is handled by MSAL library automatically.

- **Malformed or tampered tokens**: How does the system respond to requests with invalid JWT signatures or manipulated token payloads? **Answer**: JWT verification fails at the signature validation step, returning 401 Unauthorized with error details in development mode only.

- **Missing or invalid RBAC group mappings**: What happens when the RBAC_GROUP_ADMIN environment variable is misconfigured or empty? **Answer**: Group-to-role mapping is skipped for that group. If no roles are resolved from token claims or groups, and RBAC_MOCK_ROLES is not set, the user has no roles and is denied access to all protected resources.

- **Soft delete cascades**: When a parent entity (e.g., Server) is soft-deleted, what happens to child entities (Databases)? **Answer**: Soft deletes must cascade to children (setting their deletedAt timestamp) or be blocked if children exist, based on business rules. Audit log records the cascade.

- **Rate limit exceeded**: What happens when a user exceeds the rate limit (100 requests per minute)? **Answer**: The server responds with HTTP 429 (Too Many Requests) including a `Retry-After` header indicating seconds until the next allowed request. The frontend displays a user-friendly throttle message.

- **JWKS key rotation**: How does the system handle Microsoft rotating their JWT signing keys? **Answer**: The jwks-rsa library automatically fetches updated keys from the JWKS endpoint (cached for performance). Key rotation is transparent to the application.

- **Token refresh failure during critical operation**: What happens if token refresh fails while a user is submitting important data? **Answer**: The frontend catches token acquisition failures, prompts the user to re-authenticate, preserves form state in session storage, and allows resuming the operation after successful re-login.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST authenticate users exclusively via Azure Entra ID (MSAL) with no local password storage or authentication.

- **FR-002**: System MUST validate JWT tokens on every API request by verifying the digital signature using Microsoft's JWKS endpoint public keys.

- **FR-003**: System MUST validate JWT token claims including audience (JWT_AUDIENCE), issuer (JWT_ISSUER), expiration (exp), and not-before (nbf) timestamps.

- **FR-004**: System MUST support three distinct role levels: Admin (full access), Maintainer (create/read/update databases, tables, abbreviations), and Viewer (read-only access).

- **FR-005**: System MUST determine user roles from JWT token in the following precedence: (1) `roles` claim, (2) `groups` claim mapped via RBAC_GROUP_* environment variables, (3) RBAC_MOCK_ROLES for development only.

- **FR-006**: System MUST enforce role-based access control on every write operation: create/update endpoints require Admin or Maintainer roles; delete endpoints require Admin role only.

- **FR-007**: System MUST log all data modification operations (create, update, delete) to the AuditLog table including user ID, entity type/ID, action, timestamp, IP address, user agent, and before/after state changes.

- **FR-008**: System MUST implement soft deletes for all entity deletions by setting a `deletedAt` timestamp rather than physically removing records from the database.

- **FR-009**: System MUST automatically refresh access tokens silently when they expire (typically 1-hour expiration) using MSAL's token refresh mechanism without requiring user re-login.

- **FR-010**: System MUST cache JWT signing keys from the JWKS endpoint with rate limiting (5 requests per minute) to optimize performance and reduce external API calls.

- **FR-011**: System MUST implement rate limiting with thresholds of 100 requests per minute per authenticated user, 20 requests per minute per IP for unauthenticated endpoints, and 10 requests per minute per IP for authentication endpoints.

- **FR-012**: System MUST respond with HTTP 429 (Too Many Requests) when rate limits are exceeded, including `Retry-After`, `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` headers.

- **FR-013**: System MUST allow the health check endpoint (`/api/v1/health`) to be exempt from rate limiting and authentication requirements.

- **FR-014**: System MUST support development mode mock authentication via RBAC_MOCK_ROLES environment variable, but MUST ignore this variable in production environments (NODE_ENV=production).

- **FR-015**: System MUST cache Azure Key Vault secrets in memory at startup with a 6-hour refresh interval, continuing with cached secrets if Key Vault is temporarily unreachable during refresh.

- **FR-016**: System MUST fail fast at application startup if Azure Key Vault is unreachable, displaying a clear error message indicating the Key Vault connectivity issue.

- **FR-017**: System MUST implement a circuit breaker for Microsoft Graph API calls that opens for 30 seconds after 5 consecutive failures within 60 seconds.

- **FR-018**: System MUST allow concurrent browser sessions with shared MSAL token cache in localStorage, with lock contention handled by the MSAL library.

- **FR-019**: System MUST allow a 5-minute clock skew tolerance when validating JWT `nbf` (not before) and `exp` (expiration) claims to accommodate minor server clock differences.

- **FR-020**: System MUST enforce HTTPS for all communications in production, with TLS 1.2 or higher.

- **FR-021**: System MUST set secure cookie flags (HttpOnly, Secure) for any cookies used by the application.

- **FR-022**: System MUST implement Content Security Policy (CSP) headers: `default-src 'self'; script-src 'self'; connect-src 'self' https://login.microsoftonline.com https://*.azure.com; img-src 'self' data: https:`.

- **FR-023**: System MUST use Prisma ORM with parameterized queries exclusively for all database operations, with no raw SQL string concatenation permitted.

- **FR-024**: System MUST validate all user inputs on both frontend and backend to prevent injection attacks, cross-site scripting (XSS), and other OWASP Top 10 vulnerabilities.

- **FR-025**: System MUST log security events including authentication successes/failures, authorization denials, rate limit violations, and token validation errors.

### Key Entities *(include if feature involves data)*

- **User (from JWT Token)**: Represents an authenticated user with Azure Entra ID credentials. Key attributes: user object ID (oid), name, email, assigned roles (from token claims or group mappings). Not persisted in local database; identity is fully delegated to Azure Entra ID.

- **AuditLog**: Represents a record of a data modification event. Key attributes: unique ID, entity type (Server, Database, Table, etc.), entity ID, action (CREATE, UPDATE, DELETE), user ID, before/after changes (JSON), IP address, user agent, timestamp. Immutable; never deleted or modified after creation.

- **JWT Token Claims**: Represents the validated payload from an Azure Entra ID access token. Key attributes: oid (user object ID), sub (subject), name, email, roles array, groups array, audience (aud), issuer (iss), expiration (exp), issued-at (iat), not-before (nbf). Validated on every request.

- **Role Mapping Configuration**: Represents the mapping between Azure Entra ID security groups and SchemaJeli roles. Key attributes: RBAC_GROUP_ADMIN (group ID), RBAC_GROUP_MAINTAINER (group ID), RBAC_GROUP_VIEWER (group ID). Configured via environment variables.

- **Rate Limit State**: Represents the request count tracking for rate limiting enforcement. Key attributes: user ID or IP address, request count, window start time, window duration. Stored in-memory for single instance or Redis for scaled deployments.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can authenticate and access the application in under 5 seconds from clicking "Sign In" to viewing their first protected page (excluding Microsoft login UI time).

- **SC-002**: JWT token validation completes in under 10 milliseconds per request with JWKS keys cached in memory.

- **SC-003**: RBAC authorization checks complete in under 5 milliseconds per request.

- **SC-004**: Rate limit evaluation completes in under 2 milliseconds per request.

- **SC-005**: System maintains 99.5% uptime for authentication and authorization services over any 30-day period.

- **SC-006**: Zero security incidents related to unauthorized access, privilege escalation, or token tampering over any 90-day period.

- **SC-007**: 100% of data modification operations are captured in the audit log with complete user context and timestamp.

- **SC-008**: Silent token refresh succeeds without user interaction for 95% of token expirations (5% may require interactive re-login due to session expiration).

- **SC-009**: System handles 10,000 concurrent authenticated users without authentication/authorization latency degradation beyond 20%.

- **SC-010**: Role changes in Azure Entra ID take effect within 1 hour or on next user login, whichever comes first.

- **SC-011**: Failed authentication attempts are detected and logged with 100% accuracy, generating alerts when more than 50 attempts per minute occur from a single IP address.

- **SC-012**: Rate limiting prevents brute force attacks by blocking more than 10 authentication requests per minute per IP address with 100% effectiveness.

- **SC-013**: Application continues operating with cached secrets for at least 6 hours during temporary Azure Key Vault outages.

- **SC-014**: Core metadata CRUD operations remain functional during Microsoft Graph API outages, with only enhanced features (profile photos, org charts) gracefully degraded.

- **SC-015**: Soft deletes are used for 100% of entity deletions, with zero physical record removals except for data retention policy enforcement.

- **SC-016**: Users with Viewer role attempting write operations receive 403 Forbidden responses with 100% accuracy (zero false positives or negatives).

- **SC-017**: OWASP Top 10 vulnerability testing shows zero critical or high-severity findings related to authentication, authorization, or session management.

- **SC-018**: Security headers (CSP, X-Frame-Options, HSTS, etc.) are present and correctly configured on 100% of HTTP responses in production.

- **SC-019**: Development teams can set up local development environments with mock authentication in under 10 minutes following documentation.

- **SC-020**: Security incident response procedures can be executed within 24 hours for critical issues (detection, isolation, evidence collection, remediation).

## Assumptions

1. **Azure Entra ID Availability**: We assume Azure Entra ID (formerly Azure Active Directory) maintains its published SLA of 99.99% uptime. If Azure Entra ID is unavailable, users cannot authenticate, and the system is effectively unavailable.

2. **Tenant Configuration**: We assume the Azure Entra ID tenant (ibuyspy.net) is properly configured with app registrations for both backend (b521d5cf-a911-4ea4-bba6-109a1fcb9fe9) and frontend (97a5b577-ca4e-4250-844d-3b167e4496c6), including appropriate redirect URIs, API permissions, and group claims.

3. **Group Management**: We assume organization administrators manage Azure Entra ID security groups and user memberships. SchemaJeli reads group membership from token claims but does not create, modify, or delete groups.

4. **Network Security**: We assume production deployment includes proper network security controls (Azure Firewall, Network Security Groups, DDoS Protection) managed at the infrastructure level, not within the application code.

5. **Certificate Management**: We assume TLS/SSL certificates are managed via Azure App Service or equivalent infrastructure and are automatically renewed before expiration.

6. **Database Encryption**: We assume the database platform (Azure SQL, PostgreSQL, etc.) provides encryption at rest, and this is configured at the infrastructure level rather than within application code.

7. **Compliance Requirements**: We assume GDPR, SOC 2, and other compliance frameworks are interpreted and scoped by legal/compliance teams. The audit trail and data retention features support compliance but do not guarantee it without proper operational procedures.

8. **Development Environment**: We assume developers have access to a non-production Azure Entra ID tenant or use RBAC_MOCK_ROLES for local development. Production credentials are never used in development environments.

9. **Token Expiration**: We assume standard Microsoft token lifetimes (1-hour access tokens, long-lived refresh tokens) unless customized by Azure Entra ID tenant administrators. The application adapts to configured expiration times.

10. **Single Region Deployment**: We assume initial deployment in a single Azure region. Multi-region deployments may require distributed rate limiting (Redis) and session state management, which are not in scope for the initial implementation.

11. **User Provisioning**: We assume users are pre-provisioned in Azure Entra ID by organization administrators. Just-in-time (JIT) provisioning on first login is not required for the initial implementation.

12. **Role Exclusivity**: We assume a user has one primary role (Admin, Maintainer, or Viewer) for UI purposes, but may have multiple roles in their token claims. The highest privilege role takes precedence (Admin > Maintainer > Viewer).

13. **Audit Log Retention**: We assume audit logs are retained indefinitely (or per organizational policy) and are never deleted. Archival strategies for very large audit logs are out of scope for the initial implementation.

14. **Rate Limit Storage**: We assume single-instance deployment uses in-memory rate limit tracking. Production scale-out deployments requiring shared rate limit state (Redis) are a future enhancement.

15. **OWASP Testing**: We assume OWASP Top 10 security testing is performed manually or via automated security scanning tools (not implemented within the application itself). The application follows OWASP best practices but does not self-test.
