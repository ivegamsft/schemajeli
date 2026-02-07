# Frontend Authentication Configuration

## Environment Variables

Create/update `src/frontend/.env.local`:

```dotenv
# Azure Entra ID Configuration
VITE_AZURE_TENANT_ID="your-tenant-id-here"
VITE_AZURE_CLIENT_ID="your-client-id-here"
VITE_AZURE_REDIRECT_URI="http://localhost:8081"

# API Configuration
VITE_API_BASE_URL="http://localhost:8080/api/v1"

# Optional: Enable MSAL logging
VITE_MSAL_LOG_LEVEL="Info"
```

## Setup Steps

### 1. Update App Registration for Frontend

1. Go to [Azure Portal](https://portal.azure.com) → Your App Registration
2. Go to **Authentication** → **Add a platform**
3. Select **Single-page application**
4. Add Redirect URIs:
   - `http://localhost:8081` (development)
   - `http://localhost:5173` (Vite dev server)
   - `https://your-production-domain.com` (production)
5. Under **Implicit grant and hybrid flows**, enable:
   - ✅ **Access tokens** (for implicit flow)
   - ✅ **ID tokens** (for implicit flow)
6. Click **Save**

### 2. Install Required Packages

```bash
cd src/frontend
npm install @azure/msal-browser @azure/msal-react
```

### 3. Update CORS on Backend

Ensure your backend allows the frontend origin:

```typescript
// src/backend/src/index.ts
app.use(cors({
  origin: [
    'http://localhost:8081',
    'http://localhost:5173',
    'https://your-production-domain.com'
  ],
  credentials: true,
}));
```

## Testing Authentication

### Test Login Flow

1. Start backend: `cd src/backend && npm run dev`
2. Start frontend: `cd src/frontend && npm run dev`
3. Navigate to `http://localhost:8081`
4. Click **Sign In**
5. You should be redirected to Microsoft login
6. After login, you should be redirected back to the app

### Verify Token

Open browser DevTools → Console:
```javascript
// Check localStorage for MSAL tokens
console.log(localStorage);

// Should see keys like:
// msal.{client-id}.idtoken
// msal.{client-id}.client.info
```

### Check User Roles

After login, check the network tab for API calls. The `Authorization` header should contain:
```
Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

Decode the token at [jwt.io](https://jwt.io) and verify:
- `aud` matches your client ID
- `roles` array contains your assigned roles

## Common Issues

### "AADSTS50011: The reply URL does not match"
- Solution: Add the exact URL to Redirect URIs in Azure Portal

### "AADSTS700016: Application not found"
- Solution: Verify `VITE_AZURE_CLIENT_ID` matches your App Registration

### "No roles in token"
- Solution: Ensure user is in an Azure AD group assigned to an app role

### CORS errors
- Solution: Update backend CORS configuration to allow frontend origin

### Token expired errors
- Solution: MSAL handles token refresh automatically. If persists, clear localStorage and re-login

## Development vs Production

### Development
- Uses `http://localhost:8081` redirect URI
- Logs detailed MSAL events to console
- No token caching restrictions

### Production
- Uses `https://` redirect URI
- Minimal logging
- Secure token storage
- Enable SameSite cookie attributes
