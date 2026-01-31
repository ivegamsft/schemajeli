import { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import { authService } from '../services/authService';
import type { LoginCredentials } from '../types';
import { toast } from 'sonner';

export function useAuth() {
  const navigate = useNavigate();
  const {
    user,
    isAuthenticated,
    isLoading,
    error,
    login: loginStore,
    logout: logoutStore,
    setLoading,
    setError,
    clearError,
  } = useAuthStore();

  const login = useCallback(
    async (credentials: LoginCredentials) => {
      try {
        setLoading(true);
        clearError();
        
        const response = await authService.login(credentials);
        loginStore(response.user, response.tokens);
        
        toast.success('Login successful');
        navigate('/dashboard');
      } catch (err) {
        const message = err instanceof Error ? err.message : 'Login failed';
        setError(message);
        toast.error(message);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [loginStore, navigate, setLoading, setError, clearError]
  );

  const logout = useCallback(async () => {
    try {
      setLoading(true);
      await authService.logout();
      logoutStore();
      toast.success('Logged out successfully');
      navigate('/login');
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Logout failed';
      toast.error(message);
      logoutStore(); // Force logout even if API call fails
      navigate('/login');
    } finally {
      setLoading(false);
    }
  }, [logoutStore, navigate, setLoading]);

  const hasPermission = useCallback(
    (requiredRole: 'ADMIN' | 'EDITOR' | 'VIEWER'): boolean => {
      if (!user) return false;
      
      const roleHierarchy = { ADMIN: 3, EDITOR: 2, VIEWER: 1 };
      return roleHierarchy[user.role] >= roleHierarchy[requiredRole];
    },
    [user]
  );

  return {
    user,
    isAuthenticated,
    isLoading,
    error,
    login,
    logout,
    hasPermission,
    clearError,
  };
}
