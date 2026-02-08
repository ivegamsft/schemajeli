import { PublicClientApplication, LogLevel, EventType } from '@azure/msal-browser';
import type { AuthenticationResult } from '@azure/msal-browser';

// MSAL Configuration
export const msalConfig = {
  auth: {
    clientId: import.meta.env.VITE_AZURE_CLIENT_ID || '',
    authority: `https://login.microsoftonline.com/${import.meta.env.VITE_AZURE_TENANT_ID}`,
    redirectUri: import.meta.env.VITE_AZURE_REDIRECT_URI || window.location.origin,
    postLogoutRedirectUri: import.meta.env.VITE_AZURE_REDIRECT_URI || window.location.origin,
  },
  cache: {
    cacheLocation: 'localStorage', // or 'sessionStorage'
    storeAuthStateInCookie: false, // Set to true for IE11
  },
  system: {
    loggerOptions: {
      loggerCallback: (level: LogLevel, message: string, containsPii: boolean) => {
        if (containsPii) return;
        switch (level) {
          case LogLevel.Error:
            console.error(message);
            break;
          case LogLevel.Info:
            if (import.meta.env.DEV) console.info(message);
            break;
          case LogLevel.Verbose:
            if (import.meta.env.VITE_MSAL_LOG_LEVEL === 'Verbose') console.debug(message);
            break;
          case LogLevel.Warning:
            console.warn(message);
            break;
        }
      },
      logLevel: import.meta.env.DEV ? LogLevel.Info : LogLevel.Warning,
    },
  },
};

// Scopes for API access
export const loginRequest = {
  scopes: [
    `api://${import.meta.env.VITE_AZURE_CLIENT_ID}/access_as_user`,
    'openid',
    'profile',
    'email',
  ],
};

// Token request for API calls
export const tokenRequest = {
  scopes: [`api://${import.meta.env.VITE_AZURE_CLIENT_ID}/access_as_user`],
  forceRefresh: false,
};

// Create the MSAL instance
export const msalInstance = new PublicClientApplication(msalConfig);

// Initialize MSAL
export async function initializeMsal(): Promise<void> {
  await msalInstance.initialize();

  // Handle redirect promise
  try {
    const response = await msalInstance.handleRedirectPromise();
    if (response) {
      console.log('Login successful:', response.account?.name);
    }
  } catch (error) {
    console.error('Error handling redirect:', error);
  }

  // Account selection logic
  const accounts = msalInstance.getAllAccounts();
  if (accounts.length > 0) {
    msalInstance.setActiveAccount(accounts[0]);
  }

  // Listen for account changes
  msalInstance.addEventCallback((event) => {
    if (event.eventType === EventType.LOGIN_SUCCESS && event.payload) {
      const payload = event.payload as AuthenticationResult;
      const account = payload.account;
      msalInstance.setActiveAccount(account);
    }
  });
}

// Helper to get access token
export async function getAccessToken(): Promise<string | null> {
  const account = msalInstance.getActiveAccount();
  
  if (!account) {
    console.warn('No active account. User must login.');
    return null;
  }

  try {
    // Try silent token acquisition first
    const response = await msalInstance.acquireTokenSilent({
      ...tokenRequest,
      account,
    });
    return response.accessToken;
  } catch (error) {
    console.warn('Silent token acquisition failed, trying interactive:', error);
    
    try {
      // Fall back to interactive if silent fails
      const response = await msalInstance.acquireTokenPopup(tokenRequest);
      return response.accessToken;
    } catch (interactiveError) {
      console.error('Interactive token acquisition failed:', interactiveError);
      return null;
    }
  }
}

// Helper to get user roles from token
export function getUserRoles(): string[] {
  const account = msalInstance.getActiveAccount();
  if (!account?.idTokenClaims) return [];

  const claims = account.idTokenClaims as any;
  return claims.roles || [];
}

// Helper to check if user has a specific role
export function hasRole(role: string): boolean {
  return getUserRoles().includes(role);
}

// Helper to check if user is admin
export function isAdmin(): boolean {
  return hasRole('Admin');
}

// Helper to check if user can edit
export function canEdit(): boolean {
  return hasRole('Admin') || hasRole('Maintainer');
}

function getPrimaryRole(roles: string[]): 'Admin' | 'Maintainer' | 'Viewer' {
  if (roles.includes('Admin')) return 'Admin';
  if (roles.includes('Maintainer')) return 'Maintainer';
  return 'Viewer';
}

function splitName(fullName: string): { firstName: string; lastName: string } {
  const parts = fullName.trim().split(' ');
  if (parts.length <= 1) {
    return { firstName: fullName || 'User', lastName: '' };
  }
  return { firstName: parts[0], lastName: parts.slice(1).join(' ') };
}

// Helper to get current user info
export function getCurrentUser() {
  const account = msalInstance.getActiveAccount();
  if (!account) return null;

  const roles = getUserRoles();
  const { firstName, lastName } = splitName(account.name || account.username || 'User');

  return {
    id: account.localAccountId,
    email: account.username,
    firstName,
    lastName,
    role: getPrimaryRole(roles),
    isActive: true,
    lastLogin: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}
