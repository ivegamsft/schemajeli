import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { useAuth } from '../useAuth';
import { useAuthStore } from '../../store/authStore';
import { authService } from '../../services/authService';

vi.mock('../../services/authService');
vi.mock('sonner', () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

describe('useAuth', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <BrowserRouter>{children}</BrowserRouter>
  );

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(authService.getCurrentUser).mockResolvedValue(null);
  });

  it('should initialize with unauthenticated state', () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });

  it('should trigger login redirect', async () => {
    vi.mocked(authService.login).mockResolvedValue();

    const { result } = renderHook(() => useAuth(), { wrapper });

    await waitFor(async () => {
      await result.current.login();
    });

    expect(authService.login).toHaveBeenCalled();
  });

  it('should handle login error', async () => {
    vi.mocked(authService.login).mockRejectedValue(new Error('Login failed'));

    const { result } = renderHook(() => useAuth(), { wrapper });

    await expect(result.current.login()).rejects.toThrow();

    expect(result.current.error).toBe('Login failed');
  });

  it('should logout successfully', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    vi.mocked(authService.logout).mockResolvedValue();
    await waitFor(async () => {
      await result.current.logout();
    });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(mockNavigate).toHaveBeenCalledWith('/login');
  });

  it('should check permissions correctly', () => {
    const { result, rerender } = renderHook(() => useAuth(), { wrapper });

    // No user - no permission
    expect(result.current.hasPermission('Viewer')).toBe(false);

    // Mock user as Maintainer
    const mockStore = useAuthStore.getState();
    mockStore.setUser({
      id: '1',
      email: 'maintainer@test.com',
      firstName: 'Maintainer',
      lastName: 'User',
      role: 'Maintainer',
      isActive: true,
      lastLogin: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    rerender();

    // Maintainer can access Viewer and Maintainer
    expect(result.current.hasPermission('Viewer')).toBe(true);
    expect(result.current.hasPermission('Maintainer')).toBe(true);
    expect(result.current.hasPermission('Admin')).toBe(false);
  });
});
