import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { useAuth } from '../useAuth';
import { useAuthStore } from '../../store/authStore';
import { authService } from '../../services/authService';
import type { LoginResponse } from '../../types';

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
    localStorage.clear();
    vi.clearAllMocks();
  });

  it('should initialize with unauthenticated state', () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });

  it('should login successfully', async () => {
    const mockResponse: LoginResponse = {
      user: {
        id: 1,
        email: 'test@test.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'EDITOR',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      tokens: {
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
      },
    };

    vi.mocked(authService.login).mockResolvedValue(mockResponse);

    const { result } = renderHook(() => useAuth(), { wrapper });

    await waitFor(async () => {
      await result.current.login({ email: 'test@test.com', password: 'password' });
    });

    expect(result.current.user).toEqual(mockResponse.user);
    expect(result.current.isAuthenticated).toBe(true);
    expect(mockNavigate).toHaveBeenCalledWith('/dashboard');
  });

  it('should handle login error', async () => {
    vi.mocked(authService.login).mockRejectedValue(new Error('Invalid credentials'));

    const { result } = renderHook(() => useAuth(), { wrapper });

    await expect(
      result.current.login({ email: 'wrong@test.com', password: 'wrong' })
    ).rejects.toThrow();

    expect(result.current.error).toBe('Invalid credentials');
  });

  it('should logout successfully', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    // First login
    const mockResponse: LoginResponse = {
      user: {
        id: 1,
        email: 'test@test.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'EDITOR',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      tokens: {
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
      },
    };

    vi.mocked(authService.login).mockResolvedValue(mockResponse);
    await waitFor(async () => {
      await result.current.login({ email: 'test@test.com', password: 'password' });
    });

    // Then logout
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
    expect(result.current.hasPermission('VIEWER')).toBe(false);

    // Mock user as EDITOR
    const mockStore = useAuthStore.getState();
    mockStore.setUser({
      id: 1,
      email: 'editor@test.com',
      firstName: 'Editor',
      lastName: 'User',
      role: 'EDITOR',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    rerender();

    // EDITOR can access VIEWER and EDITOR
    expect(result.current.hasPermission('VIEWER')).toBe(true);
    expect(result.current.hasPermission('EDITOR')).toBe(true);
    expect(result.current.hasPermission('ADMIN')).toBe(false);
  });
});
