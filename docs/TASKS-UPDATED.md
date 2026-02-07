# SchemaJeli - Updated Task Priorities

## ✅ COMPLETED - Phase 1 Foundation
- [x] Project setup and Docker containerization
- [x] Database schema design with Prisma
- [x] Frontend React + TypeScript setup
- [x] Mock API endpoints (all CRUD operations)
- [x] E2E tests with Playwright
- [x] CI/CD pipeline with GitHub Actions
- [x] Test infrastructure reorganized to root level

---

## 🎯 PRIORITY 1: Backend Database Integration (Week 2)

### P-2.0.1: Connect Backend to PostgreSQL via Prisma
**Status:** 🔴 Not Started | **Priority:** CRITICAL | **Effort:** 2d

**Tasks:**
- [ ] Review and update Prisma schema if needed
- [ ] Configure DATABASE_URL environment variable
- [ ] Run Prisma migrations: `npx prisma migrate dev`
- [ ] Run Prisma seed: `npx prisma db seed`
- [ ] Replace mock data arrays in src/backend/src/index.ts with Prisma client queries
- [ ] Update all GET endpoints to use `prisma.server.findMany()`, etc.
- [ ] Update all POST endpoints to use `prisma.server.create()`
- [ ] Update all PUT endpoints to use `prisma.server.update()`
- [ ] Update all DELETE endpoints to use `prisma.server.delete()`
- [ ] Test all endpoints return real data from PostgreSQL
- [ ] Run backend tests and verify they pass

**Dependencies:**
- PostgreSQL container must be running
- Prisma client must be generated
- Environment variables must be configured

**Acceptance Criteria:**
- ✅ All API endpoints query PostgreSQL instead of mock arrays
- ✅ Data persists across server restarts
- ✅ All existing tests pass with real database
- ✅ Docker Compose includes database connection

---

## 🎯 PRIORITY 2: Entra ID Authentication with OBO (Week 2-3)

### P-2.1.1: Implement Azure Entra ID JWT Authentication
**Status:** 🔴 Not Started | **Priority:** CRITICAL | **Effort:** 3d

**Tasks:**
- [ ] Register SchemaJeli app in Azure Entra ID (App Registration)
- [ ] Configure API permissions and expose API scopes
- [ ] Add required API scopes: `api://schemajeli/Users.Read`, `api://schemajeli/Users.Write`
- [ ] Configure App Roles for RBAC: Admin, Maintainer, Viewer
- [ ] Map Azure AD groups to SchemaJeli roles in app manifest
- [ ] Install `@azure/msal-node` for backend JWT validation
- [ ] Install `@azure/msal-browser` for frontend auth
- [ ] Create middleware to validate Azure AD JWT tokens
- [ ] Extract user roles from token claims (`roles` claim)
- [ ] Create RBAC middleware using token roles
- [ ] Replace mock JWT with real Entra ID tokens
- [ ] Update frontend to use MSAL authentication flow
- [ ] Test authentication flow end-to-end

**Configuration Required:**
```typescript
// Backend: src/backend/src/config/auth.ts
export const msalConfig = {
  auth: {
    clientId: process.env.AZURE_CLIENT_ID,
    authority: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}`,
    clientSecret: process.env.AZURE_CLIENT_SECRET,
  },
  jwt: {
    audience: `api://${process.env.AZURE_CLIENT_ID}`,
    issuer: `https://sts.windows.net/${process.env.AZURE_TENANT_ID}/`,
  }
};

// Frontend: src/frontend/src/config/auth.ts
export const msalConfig = {
  auth: {
    clientId: process.env.VITE_AZURE_CLIENT_ID,
    authority: `https://login.microsoftonline.com/${process.env.VITE_AZURE_TENANT_ID}`,
    redirectUri: window.location.origin,
  },
  cache: {
    cacheLocation: "localStorage",
    storeAuthStateInCookie: false,
  }
};
```

**App Roles Configuration (Azure Portal):**
```json
{
  "appRoles": [
    {
      "allowedMemberTypes": ["User"],
      "displayName": "Admin",
      "id": "{{generate-guid}}",
      "isEnabled": true,
      "description": "Full system access",
      "value": "Admin"
    },
    {
      "allowedMemberTypes": ["User"],
      "displayName": "Maintainer",
      "id": "{{generate-guid}}",
      "isEnabled": true,
      "description": "Create and edit metadata",
      "value": "Maintainer"
    },
    {
      "allowedMemberTypes": ["User"],
      "displayName": "Viewer",
      "id": "{{generate-guid}}",
      "isEnabled": true,
      "description": "Read-only access",
      "value": "Viewer"
    }
  ]
}
```

**Dependencies:**
- Azure Entra ID tenant access
- App Registration completed
- Groups created and assigned to app roles

**Acceptance Criteria:**
- ✅ Users can login via Azure AD SSO
- ✅ JWT tokens are validated using Azure public keys
- ✅ User roles are extracted from token claims
- ✅ RBAC middleware enforces role-based access
- ✅ Users assigned via Azure AD groups, not database
- ✅ No user registration endpoint (out of scope)

### P-2.1.2: Implement Mock RBAC Middleware (Temporary)
**Status:** 🔴 Not Started | **Priority:** HIGH | **Effort:** 1d

**Tasks:**
- [ ] Create RBAC middleware that reads roles from JWT token
- [ ] Mock role enforcement until production-ready
- [ ] Create decorators: `@RequireRole('Admin')`, `@RequireRole('Maintainer')`
- [ ] Apply role checks to sensitive endpoints (delete, update)
- [ ] Log RBAC decisions for audit
- [ ] Write RBAC middleware tests

**Example Middleware:**
```typescript
// src/backend/src/middleware/rbac.ts
export function requireRole(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const userRoles = req.user?.roles || []; // From JWT token
    
    const hasPermission = allowedRoles.some(role => userRoles.includes(role));
    
    if (!hasPermission) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions'
      });
    }
    
    next();
  };
}

// Usage:
app.delete('/api/v1/servers/:id', 
  authenticateJWT,
  requireRole('Admin'),
  deleteServer
);
```

**Acceptance Criteria:**
- ✅ Endpoints protected by role requirements
- ✅ 403 errors returned for unauthorized access
- ✅ Admin role has full access
- ✅ Maintainer role can create/edit
- ✅ Viewer role is read-only

---

## 🎯 PRIORITY 3: Azure Deployment Fix (Week 3)

### P-4.5.1: Fix Terraform Azure Deployment
**Status:** 🔴 Not Started | **Priority:** HIGH | **Effort:** 2d

**Current Issues (from terminal history):**
- Resource group conflicts and naming issues
- Region capacity constraints (tried eastus, swedencentral, westeurope)
- Key Vault RBAC vs. access policy conflicts
- Static Web App region availability issues
- Long-running terraform apply operations timing out

**Tasks:**
- [ ] Review and simplify Terraform configuration
- [ ] Fix resource group naming with proper random suffix
- [ ] Use stable Azure region (recommend: westeurope or northeurope)
- [ ] Fix Key Vault configuration (use RBAC consistently)
- [ ] Remove Static Web App if causing issues, use App Service instead
- [ ] Configure proper service principal with required permissions
- [ ] Set up remote state in Azure Storage
- [ ] Test terraform plan succeeds
- [ ] Execute terraform apply with proper error handling
- [ ] Verify all resources created successfully
- [ ] Document deployment process

**Terraform Resources Needed:**
```hcl
# infrastructure/terraform/main.tf
resource "azurerm_resource_group" "main" {
  name     = "schemajeli-${var.environment}-rg"
  location = "westeurope"
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "schemajeli-${var.environment}-psql"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  
  administrator_login    = var.db_admin_user
  administrator_password = var.db_admin_password
  
  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768
  version    = "15"
}

resource "azurerm_linux_web_app" "backend" {
  name                = "schemajeli-${var.environment}-api"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  service_plan_id    = azurerm_service_plan.main.id
  
  app_settings = {
    "DATABASE_URL" = "postgresql://${var.db_admin_user}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/schemajeli"
    "AZURE_CLIENT_ID" = var.azure_client_id
    "AZURE_TENANT_ID" = var.azure_tenant_id
  }
  
  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "schemajeli-${var.environment}-web"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  service_plan_id    = azurerm_service_plan.main.id
  
  app_settings = {
    "VITE_API_BASE_URL" = "https://${azurerm_linux_web_app.backend.default_hostname}/api/v1"
    "VITE_AZURE_CLIENT_ID" = var.azure_client_id
    "VITE_AZURE_TENANT_ID" = var.azure_tenant_id
  }
  
  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}
```

**Dependencies:**
- Azure subscription with contributor access
- Service principal created
- Terraform 1.5+ installed

**Acceptance Criteria:**
- ✅ `terraform plan` completes successfully
- ✅ `terraform apply` deploys all resources
- ✅ PostgreSQL database accessible
- ✅ Backend API responds at Azure App Service URL
- ✅ Frontend loads at Azure App Service URL
- ✅ CI/CD pipeline can deploy to Azure

---

## ❌ OUT OF SCOPE

### User Registration (Not Needed)
**Reason:** Users added via Azure AD groups mapped to roles
- No `/auth/register` endpoint required
- No email verification flow
- No password management in app

### Password Reset Flow (Not Needed)
**Reason:** Handled by Azure AD self-service password reset
- Users reset passwords via Azure portal
- No custom password reset logic in app

---

## 📋 Summary of Updated Priorities

| Priority | Task | Status | Effort | Week |
|----------|------|--------|--------|------|
| 1 | Connect Backend to PostgreSQL | 🔴 Not Started | 2d | Week 2 |
| 2 | Implement Entra ID Auth + OBO | 🔴 Not Started | 3d | Week 2-3 |
| 3 | Implement RBAC Middleware | 🔴 Not Started | 1d | Week 3 |
| 4 | Fix Azure Terraform Deployment | 🔴 Not Started | 2d | Week 3 |
| 5 | Update Frontend for MSAL Auth | 🔴 Not Started | 2d | Week 3 |

**Total Estimated Effort:** 10 person-days (2 weeks)

---

## Next Steps

1. **TODAY:** Start P-2.0.1 - Replace mock data with Prisma
2. **Day 2-3:** Complete P-2.1.1 - Implement Entra ID authentication
3. **Day 4:** Complete P-2.1.2 - RBAC middleware
4. **Day 5-6:** Complete P-4.5.1 - Fix Azure deployment
5. **Day 7-8:** Integration testing and documentation

**After these priorities, proceed with remaining Speckit tasks for Phase 2-3 (frontend features, reports, etc.)**
