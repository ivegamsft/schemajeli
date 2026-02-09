# SchemaJeli Azure Entra ID Setup - Configuration Summary

**Created:** February 7, 2026
**Status:** App registrations created, environment files configured, ready for secret generation

## App Registrations Created

### 1. SchemaJeli Backend API
- **Display Name:** SchemaJeli Backend API
- **Client ID (Application ID):** `<backend-app-registration-id>`
- **Object ID:** `<backend-object-id>`
- **Service Principal ID:** `<backend-service-principal-id>`
- **Tenant:** <tenant-domain> (<tenant-id>)
- **Purpose:** Backend API authentication and OBO token exchange for Graph API access

**Status:** ✅ Created | ⏳ Needs Client Secret | ⏳ Needs API Permissions

### 2. SchemaJeli Frontend
- **Display Name:** SchemaJeli Frontend
- **Client ID (Application ID):** `<frontend-app-registration-id>`
- **Object ID:** `<frontend-object-id>`
- **Service Principal ID:** `<frontend-service-principal-id>`
- **Tenant:** <tenant-domain> (<tenant-id>)
- **Redirect URIs:** http://localhost:5173, http://localhost:5173/auth/callback
- **Purpose:** Frontend SPA authentication (MSAL)

**Status:** ✅ Created | ✅ Redirect URIs Configured | ⏳ Needs Permissions

## Environment Files Configured

### Backend (.env)
**Location:** `src/backend/.env`

```env
AZURE_TENANT_ID=<tenant-id>
AZURE_CLIENT_ID=<backend-app-registration-id>
AZURE_CLIENT_SECRET=                    # ⏳ TODO: Add secret from app registration
JWT_AUDIENCE=api://<backend-app-registration-id>
JWT_ISSUER=https://sts.windows.net/<tenant-id>/
JWT_JWKS_URI=https://login.microsoftonline.com/<tenant-id>/discovery/v2.0/keys
AZURE_OBO_SCOPES=https://graph.microsoft.com/User.Read
RBAC_GROUP_ADMIN=                       # ⏳ TODO: Add Azure AD group ID
RBAC_GROUP_MAINTAINER=                  # ⏳ TODO: Add Azure AD group ID
RBAC_GROUP_VIEWER=                       # ⏳ TODO: Add Azure AD group ID
RBAC_MOCK_ROLES=Viewer                  # Development fallback
```

### Frontend (.env)
**Location:** `src/frontend/.env`

```env
VITE_AZURE_TENANT_ID=<tenant-id>
VITE_AZURE_CLIENT_ID=<frontend-app-registration-id>
VITE_AZURE_REDIRECT_URI=http://localhost:5173/auth/callback
VITE_API_URL=http://localhost:3000
VITE_API_PREFIX=/api/v1
VITE_MSAL_LOG_LEVEL=Verbose
VITE_ENABLE_MOCK_AUTH=false
VITE_ENABLE_LOGGING=true
```

## Next Steps

### 1. ⏳ Generate Backend Client Secret
```bash
# Using Azure Portal (Recommended):
# 1. Navigate to Azure AD > App registrations > SchemaJeli Backend API
# 2. Go to Certificates & secrets
# 3. Click "+ New client secret"
# 4. Set expiration to 24 months
# 5. Copy the secret value (only visible once!)
# 6. Paste into src/backend/.env: AZURE_CLIENT_SECRET="<secret>"

# OR using Azure CLI:
# az ad app credential new --id "<backend-app-registration-id>" --years 2
```

**⚠️ CRITICAL:** The secret is only shown once. Copy it immediately and store securely.

### 2. ⏳ Configure API Permissions

**Backend API (SchemaJeli Backend API):**
1. Navigate to Azure AD > App registrations > SchemaJeli Backend API
2. Go to API permissions
3. Click "+ Add a permission"
4. Select "Microsoft Graph" > "Application permissions"
5. Search for and add: **User.Read**
6. Click "Grant admin consent for <tenant-domain>"

This allows the OBO flow to read user profile data from Graph API.

### 3. ⏳ Grant Delegated Permissions to Frontend

**Frontend SPA (SchemaJeli Frontend):**
1. Navigate to Azure AD > App registrations > SchemaJeli Frontend
2. Go to API permissions
3. Click "+ Add a permission"
4. Select "My APIs" > "SchemaJeli Backend API"
5. Select "Delegated permissions"
6. Add: **User.Read** (for reading delegated user data)
7. Click "Grant admin consent for <tenant-domain>"

This allows the frontend to request tokens scoped to the backend API.

### 4. ⏳ Create/Map Security Groups (Optional but Recommended)

To use group-based RBAC instead of mock roles:
1. Navigate to Azure AD > Groups
2. Create three groups:
   - SchemaJeli-Admins
   - SchemaJeli-Maintainers
   - SchemaJeli-Viewers
3. Note the Object ID for each group
4. Update `.env` with the group IDs:
   ```env
   RBAC_GROUP_ADMIN=<SchemaJeli-Admins Object ID>
   RBAC_GROUP_MAINTAINER=<SchemaJeli-Maintainers Object ID>
   RBAC_GROUP_VIEWER=<SchemaJeli-Viewers Object ID>
   ```
5. Add users to appropriate groups
6. Set `RBAC_MOCK_ROLES=""` in `.env` to disable mock fallback

### 5. 🔄 Install Dependencies

```bash
# Backend
cd src/backend
npm install

# Frontend
cd src/frontend
npm install --force  # React 19 peer dependency workaround
```

### 6. ✅ Test Authentication

```bash
# Terminal 1: Start backend
cd src/backend
npm run dev

# Terminal 2: Start frontend
cd src/frontend
npm run dev

# Browser: Navigate to http://localhost:5173
# Click "Sign in with Microsoft"
# Should redirect to Entra ID login
```

## Configuration References

- **Tenant ID:** <tenant-id>
- **Tenant Domain:** <tenant-domain>
- **Azure Portal:** https://portal.azure.com
- **Entra ID Admin:** https://entra.microsoft.com

## Code Files Updated

- ✅ `src/backend/.env` - Azure Entra authentication
- ✅ `src/frontend/.env` - MSAL configuration
- ✅ `src/frontend/src/config/auth.ts` - MSAL setup with Client ID
- ✅ `src/backend/src/middleware/auth.ts` - JWT validation + RBAC
- ✅ `src/backend/src/services/oboClient.ts` - OBO token exchange

## Authentication Flow

```
Frontend (MSAL)
  ↓ (Sign in with Microsoft)
Entra ID
  ↓ (Access Token)
Frontend (stores token)
  ↓ (API request with Bearer token)
Backend (JWT validation)
  ↓ (Check roles from token/groups)
Authorized Route
  ↓ (OBO request if needed)
Microsoft Graph
```

## Development vs Production

**Development Mode:**
- Frontend: Uses environment variables from `.env`
- Backend: Falls back to RBAC_MOCK_ROLES="Viewer" if no roles in token
- No valid Graph API access (needs real Microsoft Graph permission grant)

**Production Mode:**
- Must generate actual client secrets
- Must configure RBAC group mappings
- Must enable API permissions in Entra ID
- Must use HTTPS for redirect URIs
- Must update CORS_ORIGIN in backend

---

**Last Updated:** 2026-02-08 02:48:38 UTC  
**Created By:** GitHub Copilot
