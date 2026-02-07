# Backend Authentication Configuration

## Environment Variables

Add these to your `.env` file for Azure Entra ID authentication:

```dotenv
# Azure Entra ID Configuration
AZURE_TENANT_ID="your-tenant-id-here"
AZURE_CLIENT_ID="your-client-id-here"
AZURE_CLIENT_SECRET="your-client-secret-here"

# JWT Configuration (for Entra ID tokens)
JWT_AUDIENCE="api://your-client-id-here"
JWT_ISSUER="https://sts.windows.net/your-tenant-id-here/"

# JWT Validation
JWT_JWKS_URI="https://login.microsoftonline.com/your-tenant-id-here/discovery/v2.0/keys"
```

## Setup Steps

### 1. Register Application in Azure Portal

1. Go to [Azure Portal](https://portal.azure.com) → **Azure Active Directory** → **App registrations**
2. Click **New registration**
   - Name: `SchemaJeli API`
   - Supported account types: **Accounts in this organizational directory only**
   - Redirect URI: Leave blank for now
3. Click **Register**
4. Copy the following values to your `.env`:
   - **Application (client) ID** → `AZURE_CLIENT_ID`
   - **Directory (tenant) ID** → `AZURE_TENANT_ID`

### 2. Create Client Secret

1. In your app registration, go to **Certificates & secrets**
2. Click **New client secret**
   - Description: `SchemaJeli Backend`
   - Expires: **24 months** (or as per your policy)
3. Copy the **Value** (not the Secret ID) → `AZURE_CLIENT_SECRET`
   - ⚠️ **Important:** Save this immediately, you won't see it again!

### 3. Configure App Roles

1. Go to **App roles** → **Create app role** (create 3 roles)

**Admin Role:**
```json
{
  "displayName": "Admin",
  "description": "Full system access - manage all resources",
  "value": "Admin",
  "allowedMemberTypes": ["User"],
  "isEnabled": true
}
```

**Maintainer Role:**
```json
{
  "displayName": "Maintainer",
  "description": "Create and edit metadata, cannot delete",
  "value": "Maintainer",
  "allowedMemberTypes": ["User"],
  "isEnabled": true
}
```

**Viewer Role:**
```json
{
  "displayName": "Viewer",
  "description": "Read-only access to all metadata",
  "value": "Viewer",
  "allowedMemberTypes": ["User"],
  "isEnabled": true
}
```

### 4. Expose API Scopes

1. Go to **Expose an API**
2. Set **Application ID URI**: `api://{your-client-id}`
3. Click **Add a scope**:
   - Scope name: `access_as_user`
   - Who can consent: **Admins and users**
   - Admin consent display name: `Access SchemaJeli API`
   - Admin consent description: `Allows the app to access SchemaJeli API on behalf of the signed-in user`
   - State: **Enabled**

### 5. Configure API Permissions

1. Go to **API permissions**
2. Click **Add a permission** → **Microsoft Graph**
3. Add these **Delegated permissions**:
   - `User.Read` (to read user profile)
   - `profile`
   - `openid`
   - `email`

### 6. Create and Assign Azure AD Groups

1. Go to **Azure Active Directory** → **Groups**
2. Create three groups:
   - `SchemaJeli-Admins`
   - `SchemaJeli-Maintainers`
   - `SchemaJeli-Viewers`
3. Go back to your **App registration** → **Enterprise Application**
4. Go to **Users and groups** → **Add user/group**
5. For each group:
   - Select the group
   - Assign the corresponding app role
   - Click **Assign**

### 7. Add Test Users to Groups

1. Go to **Azure Active Directory** → **Groups**
2. Select each group and add users as members

## Testing Authentication

### Test JWT Token Locally

```bash
# Get an access token using curl
curl -X POST "https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id={client-id}" \
  -d "client_secret={client-secret}" \
  -d "scope=api://{client-id}/.default" \
  -d "grant_type=client_credentials"
```

### Decode JWT Token

Use [jwt.io](https://jwt.io) to decode and verify token claims:
- `aud` (audience) should match your `JWT_AUDIENCE`
- `iss` (issuer) should match your `JWT_ISSUER`
- `roles` array should contain user's assigned roles

## Troubleshooting

### Token Validation Fails
- Verify `AZURE_TENANT_ID` and `AZURE_CLIENT_ID` are correct
- Check that `JWT_AUDIENCE` matches the token's `aud` claim
- Ensure token hasn't expired

### No Roles in Token
- Verify user is assigned to a group in Azure AD
- Check that the group is assigned to an app role in the Enterprise Application
- User may need to sign out and sign in again for role changes to take effect

### 403 Forbidden Errors
- Check user has the required role for the endpoint
- Verify RBAC middleware is correctly reading roles from token
- Check API logs for role enforcement details

## Security Best Practices

1. **Never commit secrets to Git** - Use Azure Key Vault for production
2. **Rotate client secrets regularly** - Set expiry to 12-24 months
3. **Use managed identities** - For Azure-hosted resources
4. **Enable conditional access** - Require MFA for admin users
5. **Monitor audit logs** - Track authentication and authorization events
