# Authentication & Authorization Design

**Project:** SchemaJeli  
**Phase:** 1.2.4 - Design & Specification  
**Version:** 1.0  
**Last Updated:** January 30, 2026

## Table of Contents
1. [Overview](#overview)
2. [Authentication Strategy](#authentication-strategy)
3. [JWT Token Structure](#jwt-token-structure)
4. [Authentication Flows](#authentication-flows)
5. [Authorization Model (RBAC)](#authorization-model-rbac)
6. [Role Permissions Matrix](#role-permissions-matrix)
7. [Password Security](#password-security)
8. [Middleware Architecture](#middleware-architecture)
9. [Session Management](#session-management)
10. [Future Enhancements](#future-enhancements)
11. [Security Best Practices](#security-best-practices)

---

## Overview

SchemaJeli implements a **JWT-based authentication system** with **Role-Based Access Control (RBAC)**. The system supports three user roles (ADMIN, EDITOR, VIEWER) with granular permissions across all API endpoints.

### Key Requirements
- Stateless authentication using JWT tokens
- Role-based access control with three tiers
- Secure password storage with bcrypt hashing
- Token refresh mechanism for extended sessions
- Audit logging for authentication events
- Protection against common vulnerabilities (XSS, CSRF, brute force)

### Technology Stack
- **JWT Generation**: `jsonwebtoken` library
- **Password Hashing**: `bcrypt` (10 salt rounds)
- **Token Storage**: HTTP-only cookies (refresh) + localStorage (access)
- **Validation**: `express-validator` for input sanitization
- **Rate Limiting**: `express-rate-limit` for brute force protection

---

## Authentication Strategy

### JWT-Based Authentication
We use **JSON Web Tokens (JWT)** for stateless authentication:

**Advantages:**
- ✅ Stateless - no server-side session storage required
- ✅ Scalable - works across multiple server instances
- ✅ Self-contained - token includes all necessary user claims
- ✅ Standard - industry-standard RFC 7519

**Token Types:**
1. **Access Token**: Short-lived (15 minutes), used for API requests
2. **Refresh Token**: Long-lived (7 days), used to obtain new access tokens

### Authentication vs. Authorization
- **Authentication**: Verifies user identity (login with credentials)
- **Authorization**: Verifies user permissions (role-based access)

---

## JWT Token Structure

### Access Token Payload
```json
{
  "userId": "uuid-v4-string",
  "email": "user@example.com",
  "role": "ADMIN | EDITOR | VIEWER",
  "iat": 1706659200,
  "exp": 1706660100
}
```

**Fields:**
- `userId`: Unique user identifier (maps to User.id in database)
- `email`: User email address
- `role`: User role (ADMIN, EDITOR, VIEWER)
- `iat`: Issued at timestamp (Unix epoch)
- `exp`: Expiration timestamp (Unix epoch)

### Refresh Token Payload
```json
{
  "userId": "uuid-v4-string",
  "tokenVersion": 1,
  "type": "refresh",
  "iat": 1706659200,
  "exp": 1707264000
}
```

**Fields:**
- `userId`: Unique user identifier
- `tokenVersion`: Counter to invalidate all tokens when changed
- `type`: Token type identifier
- `iat`: Issued at timestamp
- `exp`: Expiration timestamp (7 days from issue)

### Token Lifetimes
| Token Type | Lifetime | Storage Location | Use Case |
|------------|----------|------------------|----------|
| Access Token | 15 minutes | localStorage | API requests (Authorization header) |
| Refresh Token | 7 days | HTTP-only cookie | Silent token refresh |

### JWT Signing
- **Algorithm**: HS256 (HMAC with SHA-256)
- **Secret Key**: 256-bit randomly generated secret stored in environment variable
- **Environment Variable**: `JWT_SECRET` (required)
- **Refresh Secret**: `JWT_REFRESH_SECRET` (separate key for refresh tokens)

---

## Authentication Flows

### 1. Login Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB
    participant JWT

    Client->>API: POST /api/auth/login<br/>{email, password}
    API->>API: Validate input format
    API->>DB: SELECT * FROM User WHERE email=?
    DB-->>API: User record
    API->>API: bcrypt.compare(password, hash)
    
    alt Password Valid
        API->>JWT: Generate access token (15min)
        API->>JWT: Generate refresh token (7d)
        API->>DB: INSERT AuditLog (LOGIN_SUCCESS)
        API->>API: Set refresh token in HTTP-only cookie
        API-->>Client: 200 OK<br/>{accessToken, user{id, email, role}}
        Client->>Client: Store accessToken in localStorage
    else Password Invalid
        API->>DB: INSERT AuditLog (LOGIN_FAILED)
        API-->>Client: 401 Unauthorized<br/>{error: "Invalid credentials"}
    end
```

**API Endpoint:** `POST /api/auth/login`

**Request:**
```json
{
  "email": "admin@example.com",
  "password": "SecurePassword123!"
}
```

**Success Response (200):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-v4",
    "email": "admin@example.com",
    "name": "Admin User",
    "role": "ADMIN"
  }
}
```

**Cookie Set:**
```
Set-Cookie: refreshToken=eyJhbGc...; HttpOnly; Secure; SameSite=Strict; Max-Age=604800
```

---

### 2. Token Refresh Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant JWT
    participant DB

    Client->>API: POST /api/auth/refresh<br/>(refreshToken in cookie)
    API->>API: Extract refresh token from cookie
    API->>JWT: Verify refresh token signature
    
    alt Token Valid
        JWT-->>API: Decoded payload {userId, tokenVersion}
        API->>DB: SELECT * FROM User WHERE id=?
        DB-->>API: User {id, email, role, tokenVersion}
        API->>API: Compare tokenVersion
        
        alt Version Matches
            API->>JWT: Generate new access token (15min)
            API->>JWT: Generate new refresh token (7d)
            API->>API: Set new refresh token in cookie
            API-->>Client: 200 OK<br/>{accessToken}
        else Version Mismatch
            API-->>Client: 401 Unauthorized<br/>(token invalidated)
        end
    else Token Invalid/Expired
        API-->>Client: 401 Unauthorized<br/>{error: "Please login again"}
    end
```

**API Endpoint:** `POST /api/auth/refresh`

**Request:**
- No body required
- Refresh token sent automatically via HTTP-only cookie

**Success Response (200):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 3. Logout Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB

    Client->>API: POST /api/auth/logout<br/>(accessToken in header)
    API->>API: Authenticate user from access token
    API->>API: Clear refresh token cookie
    API->>DB: INSERT AuditLog (LOGOUT)
    API-->>Client: 200 OK<br/>{message: "Logged out successfully"}
    Client->>Client: Clear localStorage (accessToken)
    Client->>Client: Redirect to /login
```

**API Endpoint:** `POST /api/auth/logout`

**Request Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Success Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

**Cookie Cleared:**
```
Set-Cookie: refreshToken=; HttpOnly; Secure; SameSite=Strict; Max-Age=0
```

---

### 4. Password Reset Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB
    participant Email

    Client->>API: POST /api/auth/forgot-password<br/>{email}
    API->>DB: SELECT * FROM User WHERE email=?
    
    alt User Exists
        DB-->>API: User record
        API->>API: Generate reset token (UUID)
        API->>DB: UPDATE User SET resetToken, resetExpiry
        API->>Email: Send reset link email
        API-->>Client: 200 OK<br/>{message: "Reset email sent"}
    else User Not Found
        API-->>Client: 200 OK<br/>(prevent email enumeration)
    end

    Note over Client,Email: User clicks link in email

    Client->>API: POST /api/auth/reset-password<br/>{token, newPassword}
    API->>DB: SELECT * FROM User WHERE resetToken=?
    API->>API: Validate token expiry (1 hour)
    
    alt Token Valid
        API->>API: bcrypt.hash(newPassword)
        API->>DB: UPDATE User SET password, clear resetToken
        API->>DB: INCREMENT tokenVersion (invalidate all sessions)
        API->>DB: INSERT AuditLog (PASSWORD_RESET)
        API-->>Client: 200 OK<br/>{message: "Password updated"}
    else Token Invalid/Expired
        API-->>Client: 400 Bad Request<br/>{error: "Invalid reset token"}
    end
```

---

### 5. Protected API Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant AuthMiddleware
    participant AuthzMiddleware
    participant Controller
    participant DB

    Client->>AuthMiddleware: GET /api/servers<br/>Authorization: Bearer <token>
    AuthMiddleware->>AuthMiddleware: Extract token from header
    AuthMiddleware->>AuthMiddleware: jwt.verify(token, JWT_SECRET)
    
    alt Token Valid
        AuthMiddleware->>AuthMiddleware: Decode payload {userId, role}
        AuthMiddleware->>DB: SELECT * FROM User WHERE id=?
        DB-->>AuthMiddleware: User record
        AuthMiddleware->>AuthMiddleware: Attach req.user = user
        AuthMiddleware->>AuthzMiddleware: Next()
        
        AuthzMiddleware->>AuthzMiddleware: Check role permissions
        alt Has Permission
            AuthzMiddleware->>Controller: Next()
            Controller->>DB: Execute business logic
            DB-->>Controller: Data
            Controller-->>Client: 200 OK + Data
        else No Permission
            AuthzMiddleware-->>Client: 403 Forbidden
        end
    else Token Invalid/Expired
        AuthMiddleware-->>Client: 401 Unauthorized
    end
```

---

## Authorization Model (RBAC)

### Role Hierarchy

```mermaid
graph TD
    ADMIN[ADMIN<br/>Full System Access]
    EDITOR[EDITOR<br/>Create/Edit/View]
    VIEWER[VIEWER<br/>Read-Only Access]
    
    ADMIN --> EDITOR
    EDITOR --> VIEWER
    
    style ADMIN fill:#e74c3c,color:#fff
    style EDITOR fill:#f39c12,color:#fff
    style VIEWER fill:#3498db,color:#fff
```

**Role Descriptions:**

| Role | Description | Use Case |
|------|-------------|----------|
| **ADMIN** | Full system access including user management | System administrators, DBAs |
| **EDITOR** | Can create, edit, and view all metadata | Database developers, data architects |
| **VIEWER** | Read-only access to all metadata | Analysts, business users, auditors |

### Permission Inheritance
- **ADMIN** inherits all EDITOR permissions
- **EDITOR** inherits all VIEWER permissions
- Permissions are additive (higher role = more permissions)

---

## Role Permissions Matrix

### Authentication Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/auth/login` | POST | ✅ | ✅ | ✅ | ✅ |
| `/api/auth/refresh` | POST | ✅ | ✅ | ✅ | ✅ |
| `/api/auth/logout` | POST | ✅ | ✅ | ✅ | - |
| `/api/auth/forgot-password` | POST | ✅ | ✅ | ✅ | ✅ |
| `/api/auth/reset-password` | POST | ✅ | ✅ | ✅ | ✅ |

### User Management Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/users` | GET | ✅ | ❌ | ❌ | - |
| `/api/users` | POST | ✅ | ❌ | ❌ | - |
| `/api/users/:id` | GET | ✅ | ✅ (self) | ✅ (self) | - |
| `/api/users/:id` | PUT | ✅ | ✅ (self) | ✅ (self) | - |
| `/api/users/:id` | DELETE | ✅ | ❌ | ❌ | - |
| `/api/users/:id/activate` | PUT | ✅ | ❌ | ❌ | - |
| `/api/users/:id/deactivate` | PUT | ✅ | ❌ | ❌ | - |

**Notes:**
- `(self)` = Users can only access/modify their own profile
- ADMIN can manage all users

### Server Management Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/servers` | GET | ✅ | ✅ | ✅ | - |
| `/api/servers` | POST | ✅ | ✅ | ❌ | - |
| `/api/servers/:id` | GET | ✅ | ✅ | ✅ | - |
| `/api/servers/:id` | PUT | ✅ | ✅ | ❌ | - |
| `/api/servers/:id` | DELETE | ✅ | ❌ | ❌ | - |

### Database Management Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/databases` | GET | ✅ | ✅ | ✅ | - |
| `/api/databases` | POST | ✅ | ✅ | ❌ | - |
| `/api/databases/:id` | GET | ✅ | ✅ | ✅ | - |
| `/api/databases/:id` | PUT | ✅ | ✅ | ❌ | - |
| `/api/databases/:id` | DELETE | ✅ | ❌ | ❌ | - |

### Table Management Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/tables` | GET | ✅ | ✅ | ✅ | - |
| `/api/tables` | POST | ✅ | ✅ | ❌ | - |
| `/api/tables/:id` | GET | ✅ | ✅ | ✅ | - |
| `/api/tables/:id` | PUT | ✅ | ✅ | ❌ | - |
| `/api/tables/:id` | DELETE | ✅ | ❌ | ❌ | - |

### Element (Column) Management Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/elements` | GET | ✅ | ✅ | ✅ | - |
| `/api/elements` | POST | ✅ | ✅ | ❌ | - |
| `/api/elements/:id` | GET | ✅ | ✅ | ✅ | - |
| `/api/elements/:id` | PUT | ✅ | ✅ | ❌ | - |
| `/api/elements/:id` | DELETE | ✅ | ❌ | ❌ | - |

### Abbreviation Management Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/abbreviations` | GET | ✅ | ✅ | ✅ | - |
| `/api/abbreviations` | POST | ✅ | ✅ | ❌ | - |
| `/api/abbreviations/:id` | GET | ✅ | ✅ | ✅ | - |
| `/api/abbreviations/:id` | PUT | ✅ | ✅ | ❌ | - |
| `/api/abbreviations/:id` | DELETE | ✅ | ❌ | ❌ | - |

### Search & Reports Endpoints
| Endpoint | Method | ADMIN | EDITOR | VIEWER | Public |
|----------|--------|-------|--------|--------|--------|
| `/api/search` | GET | ✅ | ✅ | ✅ | - |
| `/api/reports/element-summary` | GET | ✅ | ✅ | ✅ | - |
| `/api/reports/table-summary` | GET | ✅ | ✅ | ✅ | - |
| `/api/reports/database-details` | GET | ✅ | ✅ | ✅ | - |
| `/api/reports/server-summary` | GET | ✅ | ✅ | ✅ | - |

### Permission Summary by Role

**ADMIN (Red - Full Access):**
- ✅ All GET, POST, PUT, DELETE operations
- ✅ User management (create, deactivate users)
- ✅ Delete servers, databases, tables, elements
- ✅ System-wide audit log access

**EDITOR (Orange - Create/Edit):**
- ✅ All GET operations
- ✅ POST/PUT for servers, databases, tables, elements, abbreviations
- ❌ DELETE operations (except soft delete via PUT status=INACTIVE)
- ❌ User management
- ✅ Own profile management

**VIEWER (Blue - Read-Only):**
- ✅ All GET operations (search, reports, view metadata)
- ❌ No POST, PUT, DELETE operations
- ✅ Own profile management
- ✅ Export reports (read-only data extraction)

---

## Password Security

### Password Hashing
```javascript
// Password hashing with bcrypt
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 10; // Recommended for production

// Hash password during user creation/password reset
async function hashPassword(plainTextPassword: string): Promise<string> {
  const salt = await bcrypt.genSalt(SALT_ROUNDS);
  const hashedPassword = await bcrypt.hash(plainTextPassword, salt);
  return hashedPassword;
}

// Verify password during login
async function verifyPassword(
  plainTextPassword: string,
  hashedPassword: string
): Promise<boolean> {
  return await bcrypt.compare(plainTextPassword, hashedPassword);
}
```

### Password Requirements
| Requirement | Rule |
|-------------|------|
| **Minimum Length** | 8 characters |
| **Maximum Length** | 128 characters |
| **Complexity** | At least 1 uppercase, 1 lowercase, 1 number, 1 special character |
| **Special Characters** | `!@#$%^&*()_+-=[]{}|;:,.<>?` |
| **Forbidden** | Common passwords (e.g., "Password123"), username in password |

**Validation Regex:**
```javascript
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,128}$/;
```

### Password Reset Token
- **Type**: UUID v4 (cryptographically random)
- **Expiry**: 1 hour from generation
- **Storage**: `User.resetToken` and `User.resetTokenExpiry` fields
- **Single Use**: Token cleared after successful password reset
- **Security**: Token never sent in response, only via email

### Brute Force Protection
```javascript
// Rate limiting configuration
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: 'Too many login attempts, please try again after 15 minutes',
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply to login endpoint
app.post('/api/auth/login', loginLimiter, loginController);
```

---

## Middleware Architecture

### Authentication Middleware Stack

```mermaid
graph TD
    Request[Incoming Request] --> RateLimit[Rate Limiting Middleware]
    RateLimit --> CORS[CORS Middleware]
    CORS --> BodyParser[Body Parser Middleware]
    BodyParser --> AuthCheck{Requires Auth?}
    
    AuthCheck -->|Yes| AuthMiddleware[Authentication Middleware]
    AuthCheck -->|No| Controller[Route Controller]
    
    AuthMiddleware --> ValidateToken{Token Valid?}
    ValidateToken -->|Yes| AuthzCheck{Requires Authz?}
    ValidateToken -->|No| 401Error[401 Unauthorized]
    
    AuthzCheck -->|Yes| AuthzMiddleware[Authorization Middleware]
    AuthzCheck -->|No| Controller
    
    AuthzMiddleware --> PermCheck{Has Permission?}
    PermCheck -->|Yes| Controller
    PermCheck -->|No| 403Error[403 Forbidden]
    
    Controller --> Response[Response to Client]
    401Error --> Response
    403Error --> Response
    
    style AuthMiddleware fill:#3498db,color:#fff
    style AuthzMiddleware fill:#e74c3c,color:#fff
    style Controller fill:#2ecc71,color:#fff
```

### 1. Authentication Middleware (`authenticate.ts`)

**Purpose:** Verify JWT token and attach user to request

```typescript
// src/backend/middleware/authenticate.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma';

interface JWTPayload {
  userId: string;
  email: string;
  role: string;
}

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    name: string | null;
    role: string;
  };
}

export async function authenticate(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    // 1. Extract token from Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // 2. Verify JWT signature and expiry
    const payload = jwt.verify(
      token,
      process.env.JWT_SECRET!
    ) as JWTPayload;

    // 3. Fetch user from database (verify user still exists and is active)
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        status: true,
      },
    });

    if (!user || user.status !== 'ACTIVE') {
      res.status(401).json({ error: 'Invalid or expired token' });
      return;
    }

    // 4. Attach user to request object
    req.user = user;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({ error: 'Token expired' });
    } else if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({ error: 'Invalid token' });
    } else {
      res.status(500).json({ error: 'Authentication error' });
    }
  }
}
```

### 2. Authorization Middleware (`authorize.ts`)

**Purpose:** Check user role permissions for specific operations

```typescript
// src/backend/middleware/authorize.ts
import { Response, NextFunction } from 'express';
import { AuthRequest } from './authenticate';

type UserRole = 'ADMIN' | 'EDITOR' | 'VIEWER';

export function authorize(...allowedRoles: UserRole[]) {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    const userRole = req.user.role as UserRole;

    if (!allowedRoles.includes(userRole)) {
      res.status(403).json({ 
        error: 'Insufficient permissions',
        required: allowedRoles,
        current: userRole
      });
      return;
    }

    next();
  };
}

// Helper function for resource ownership check
export function authorizeOwnerOrRole(...allowedRoles: UserRole[]) {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    const userRole = req.user.role as UserRole;
    const userId = req.user.id;
    const resourceUserId = req.params.id; // Assuming :id is user ID

    // Allow if user owns the resource OR has required role
    if (userId === resourceUserId || allowedRoles.includes(userRole)) {
      next();
      return;
    }

    res.status(403).json({ error: 'Insufficient permissions' });
  };
}
```

### 3. Middleware Usage Examples

```typescript
// src/backend/routes/servers.ts
import express from 'express';
import { authenticate } from '../middleware/authenticate';
import { authorize } from '../middleware/authorize';
import { serverController } from '../controllers/serverController';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// GET /api/servers - All authenticated users can list servers
router.get('/', serverController.list);

// POST /api/servers - Only ADMIN and EDITOR can create
router.post('/', authorize('ADMIN', 'EDITOR'), serverController.create);

// PUT /api/servers/:id - Only ADMIN and EDITOR can update
router.put('/:id', authorize('ADMIN', 'EDITOR'), serverController.update);

// DELETE /api/servers/:id - Only ADMIN can delete
router.delete('/:id', authorize('ADMIN'), serverController.delete);

export default router;
```

```typescript
// src/backend/routes/users.ts
import express from 'express';
import { authenticate } from '../middleware/authenticate';
import { authorize, authorizeOwnerOrRole } from '../middleware/authorize';
import { userController } from '../controllers/userController';

const router = express.Router();

router.use(authenticate);

// GET /api/users - Only ADMIN can list all users
router.get('/', authorize('ADMIN'), userController.list);

// POST /api/users - Only ADMIN can create users
router.post('/', authorize('ADMIN'), userController.create);

// GET /api/users/:id - User can view own profile, or ADMIN can view any
router.get('/:id', authorizeOwnerOrRole('ADMIN'), userController.get);

// PUT /api/users/:id - User can update own profile, or ADMIN can update any
router.put('/:id', authorizeOwnerOrRole('ADMIN'), userController.update);

// DELETE /api/users/:id - Only ADMIN can delete users
router.delete('/:id', authorize('ADMIN'), userController.delete);

export default router;
```

---

## Session Management

### Token Versioning
Each user has a `tokenVersion` field (integer) that increments when:
- Password is reset
- User explicitly logs out from all devices
- Admin deactivates user account

**Implementation:**
```typescript
// Increment token version (invalidates all existing tokens)
await prisma.user.update({
  where: { id: userId },
  data: { tokenVersion: { increment: 1 } }
});
```

When validating refresh tokens, the `tokenVersion` in the JWT payload must match the current `tokenVersion` in the database.

### Logout from All Devices
```typescript
// Force logout from all devices
async function logoutAllDevices(userId: string): Promise<void> {
  await prisma.user.update({
    where: { id: userId },
    data: { tokenVersion: { increment: 1 } }
  });
  
  await prisma.auditLog.create({
    data: {
      action: 'LOGOUT_ALL_DEVICES',
      entityType: 'User',
      entityId: userId,
      userId: userId,
      metadata: { reason: 'User requested logout from all devices' }
    }
  });
}
```

### Token Refresh Strategy (Client-Side)
```typescript
// Automatic token refresh in React app
import { useEffect } from 'react';
import { refreshAccessToken } from './api/authService';

export function useTokenRefresh() {
  useEffect(() => {
    // Refresh token every 14 minutes (1 minute before expiry)
    const interval = setInterval(async () => {
      try {
        const { accessToken } = await refreshAccessToken();
        localStorage.setItem('accessToken', accessToken);
      } catch (error) {
        // Refresh failed - redirect to login
        localStorage.removeItem('accessToken');
        window.location.href = '/login';
      }
    }, 14 * 60 * 1000); // 14 minutes

    return () => clearInterval(interval);
  }, []);
}
```

---

## Future Enhancements

### OAuth2 / Single Sign-On (SSO)
**Timeline:** Phase 2 (Post-MVP)

**Planned Integrations:**
1. **Microsoft Azure AD / Entra ID**
   - Corporate SSO for enterprise deployments
   - Integration via OAuth2 PKCE flow
   - Map Azure AD groups to SchemaJeli roles

2. **Google Workspace**
   - OAuth2 authentication
   - Email-based user provisioning

3. **Generic SAML 2.0**
   - Support for enterprise identity providers
   - JIT (Just-In-Time) user provisioning

**Architecture:**
```mermaid
graph LR
    User[User] --> Choice{Auth Method}
    Choice -->|Local| LocalAuth[Email/Password Login]
    Choice -->|SSO| OAuth2[OAuth2 Provider]
    
    LocalAuth --> JWT[Issue JWT Token]
    OAuth2 --> Callback[OAuth Callback Handler]
    Callback --> Provision{User Exists?}
    Provision -->|Yes| JWT
    Provision -->|No| CreateUser[Create User Record]
    CreateUser --> JWT
    
    JWT --> AccessGranted[Access Granted]
```

### Multi-Factor Authentication (MFA)
**Timeline:** Phase 2 (Post-MVP)

**Planned Methods:**
- **TOTP (Time-based One-Time Password)**: Google Authenticator, Authy
- **SMS-based OTP**: Twilio integration
- **Email-based OTP**: Backup method

**Implementation:**
- Optional MFA enrollment per user
- Backup codes for recovery
- Remember device for 30 days (optional)

### API Key Authentication
**Timeline:** Phase 2 (Post-MVP)

**Use Case:** Machine-to-machine API access, CI/CD integrations

**Features:**
- Generate long-lived API keys
- Scope API keys to specific permissions
- Rate limiting per API key
- Audit log all API key usage

---

## Security Best Practices

### 1. Token Storage

| Storage Type | Access Token | Refresh Token |
|--------------|--------------|---------------|
| **Location** | localStorage | HTTP-only cookie |
| **Why** | Accessible to JavaScript for API calls | Protected from XSS attacks |
| **Risk** | Vulnerable to XSS | Vulnerable to CSRF |
| **Mitigation** | Short expiry (15min), CSP headers | SameSite=Strict, Secure flag |

### 2. HTTPS Only
- ✅ **Production**: Enforce HTTPS for all endpoints
- ✅ **Cookie Flags**: `Secure` flag on all cookies (HTTPS only)
- ✅ **HSTS Header**: `Strict-Transport-Security: max-age=31536000`

### 3. CORS Configuration
```javascript
// Strict CORS policy
const corsOptions = {
  origin: process.env.FRONTEND_URL, // e.g., https://schemajeli.example.com
  credentials: true, // Allow cookies
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400 // 24 hours
};

app.use(cors(corsOptions));
```

### 4. Input Validation
```javascript
import { body, validationResult } from 'express-validator';

// Validate login request
const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Invalid email format'),
  body('password')
    .isLength({ min: 8, max: 128 })
    .withMessage('Password must be 8-128 characters'),
];

app.post('/api/auth/login', validateLogin, (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  // Proceed with authentication
});
```

### 5. SQL Injection Prevention
- ✅ Use Prisma ORM (parameterized queries by default)
- ✅ Never concatenate user input into raw SQL
- ✅ Validate and sanitize all input

### 6. XSS Prevention
- ✅ Set `Content-Security-Policy` header
- ✅ Sanitize user-generated content before display
- ✅ Use React (auto-escapes by default)
- ✅ Avoid `dangerouslySetInnerHTML`

**CSP Header:**
```javascript
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;"
  );
  next();
});
```

### 7. CSRF Prevention
- ✅ Use `SameSite=Strict` on cookies
- ✅ Verify `Origin` and `Referer` headers
- ✅ CSRF tokens for state-changing operations (optional with SameSite)

### 8. Audit Logging
Log all authentication events to `AuditLog` table:
- ✅ Login attempts (success and failure)
- ✅ Password resets
- ✅ Logout events
- ✅ Token refresh operations
- ✅ Account deactivations
- ✅ Role changes

**Example:**
```typescript
await prisma.auditLog.create({
  data: {
    action: 'LOGIN_SUCCESS',
    entityType: 'User',
    entityId: user.id,
    userId: user.id,
    metadata: {
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      timestamp: new Date().toISOString()
    }
  }
});
```

### 9. Environment Variables
**Required secrets (never commit to git):**
```bash
JWT_SECRET=<256-bit-random-string>
JWT_REFRESH_SECRET=<256-bit-random-string>
DATABASE_URL=postgresql://user:pass@localhost:5432/schemajeli
FRONTEND_URL=https://schemajeli.example.com
NODE_ENV=production
```

**Generate secure secrets:**
```bash
# Generate 256-bit random secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 10. Account Lockout (Future Enhancement)
- Lock account after 10 failed login attempts
- Unlock after 30 minutes or manual admin unlock
- Email notification on lockout

---

## Implementation Checklist

### Phase 1.3 - Backend Implementation
- [ ] Install dependencies: `jsonwebtoken`, `bcrypt`, `express-validator`, `express-rate-limit`
- [ ] Create `.env` file with `JWT_SECRET` and `JWT_REFRESH_SECRET`
- [ ] Implement authentication middleware (`src/backend/middleware/authenticate.ts`)
- [ ] Implement authorization middleware (`src/backend/middleware/authorize.ts`)
- [ ] Create auth controller (`src/backend/controllers/authController.ts`)
  - [ ] `POST /api/auth/login` - Login endpoint
  - [ ] `POST /api/auth/refresh` - Refresh token endpoint
  - [ ] `POST /api/auth/logout` - Logout endpoint
  - [ ] `POST /api/auth/forgot-password` - Password reset request
  - [ ] `POST /api/auth/reset-password` - Password reset confirmation
- [ ] Add rate limiting to login endpoint
- [ ] Implement CORS with credentials support
- [ ] Add security headers (CSP, HSTS, X-Frame-Options)
- [ ] Create audit logging for all auth events
- [ ] Add password validation regex
- [ ] Write unit tests for auth middleware
- [ ] Write integration tests for auth endpoints

### Phase 1.4 - Frontend Implementation
- [ ] Create login page (`src/frontend/pages/LoginPage.tsx`)
- [ ] Implement AuthContext provider (`src/frontend/contexts/AuthContext.tsx`)
- [ ] Create PrivateRoute component for protected routes
- [ ] Implement token refresh hook (`useTokenRefresh`)
- [ ] Add axios interceptor for attaching access token
- [ ] Create forgot password flow UI
- [ ] Add logout functionality
- [ ] Display user role in navigation
- [ ] Show/hide UI elements based on permissions
- [ ] Handle 401/403 errors globally (redirect to login)

---

## Appendix

### A. JWT Debugging
Use [jwt.io](https://jwt.io) to decode and debug JWT tokens during development.

**Example Decoded Token:**
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "email": "admin@example.com",
    "role": "ADMIN",
    "iat": 1706659200,
    "exp": 1706660100
  },
  "signature": "HMACSHA256(base64UrlEncode(header) + '.' + base64UrlEncode(payload), JWT_SECRET)"
}
```

### B. Common HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful request |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid input, validation error |
| 401 | Unauthorized | Authentication required or token invalid |
| 403 | Forbidden | Authenticated but lacks permission |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource (e.g., email exists) |
| 422 | Unprocessable Entity | Validation error with details |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

### C. Security Headers Reference

```javascript
// Helmet.js configuration (recommended)
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  frameguard: { action: 'deny' },
  noSniff: true,
  xssFilter: true,
}));
```

---

**Document Status:** ✅ Complete  
**Next Step:** Proceed to P-1.2.5 (Legacy System Assessment)
