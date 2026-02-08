import { useCallback, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import { authService } from '../services/authService';
import { toast } from 'sonner';

export function useAuth() {
  const navigate = useNavigate();
  const {
    user,
    isAuthenticated,
    isLoading,
    error,
    logout: logoutStore,
    setLoading,
    setError,
    clearError,
    setUser,
  } = useAuthStore();

  useEffect(() => {
    const hydrateUser = async () => {
      try {
        const currentUser = await authService.getCurrentUser();
        if (currentUser) {
          setUser(currentUser);
        }
      } catch (err) {
        // Ignore hydration errors
      }
    };

    if (!user) {
      void hydrateUser();
    }
  }, [setUser, user]);

  const login = useCallback(async () => {
    try {
      setLoading(true);
      clearError();

      await authService.login();
      toast.success('Redirecting to Microsoft login');
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Login failed';
      setError(message);
      toast.error(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [setLoading, setError, clearError]);

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
    (requiredRole: 'Admin' | 'Maintainer' | 'Viewer'): boolean => {
      if (!user) return false;
      
      const roleHierarchy = { Admin: 3, Maintainer: 2, Viewer: 1 };
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
