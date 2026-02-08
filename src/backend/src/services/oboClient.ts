import { ConfidentialClientApplication } from '@azure/msal-node';

const tenantId = process.env.AZURE_TENANT_ID || '';
const clientId = process.env.AZURE_CLIENT_ID || '';
const clientSecret = process.env.AZURE_CLIENT_SECRET || '';

const msalClient = new ConfidentialClientApplication({
  auth: {
    clientId,
    authority: `https://login.microsoftonline.com/${tenantId}`,
    clientSecret,
  },
});

function parseScopes(): string[] {
  const raw = process.env.AZURE_OBO_SCOPES || 'https://graph.microsoft.com/User.Read';
  return raw
    .split(',')
    .map((scope) => scope.trim())
    .filter(Boolean);
}

export async function acquireOboToken(userAccessToken: string, scopes = parseScopes()) {
  const result = await msalClient.acquireTokenOnBehalfOf({
    oboAssertion: userAccessToken,
    scopes,
  });

  if (!result?.accessToken) {
    throw new Error('Failed to acquire OBO token');
  }

  return result.accessToken;
}

export async function getGraphMe(userAccessToken: string) {
  const accessToken = await acquireOboToken(userAccessToken, parseScopes());

  const response = await fetch('https://graph.microsoft.com/v1.0/me', {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Graph request failed: ${response.status} ${errorText}`);
  }

  return response.json();
}
