import type { User } from '../types';
import { getCurrentUser, loginRequest, msalInstance } from '../config/auth';

export const authService = {
  /**
   * Login with Microsoft Entra ID (MSAL redirect)
   */
  async login(): Promise<void> {
    await msalInstance.loginRedirect(loginRequest);
  },

  /**
   * Logout current user (MSAL redirect)
   */
  async logout(): Promise<void> {
    await msalInstance.logoutRedirect();
  },

  /**
   * Get current user profile from MSAL
   */
  async getCurrentUser(): Promise<User | null> {
    return getCurrentUser();
  },

  /**
   * Change password (Not supported - handled by Entra ID)
   */
  async changePassword(oldPassword: string, newPassword: string): Promise<void> {
    void oldPassword;
    void newPassword;
    throw new Error('Password changes are handled by Microsoft Entra ID');
  },
};
