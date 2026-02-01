import { describe, it, expect, vi } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from '../../../src/frontend/src/store/authStore';
import type { User, AuthTokens } from '../../../src/frontend/src/types';

describe('authStore', () => {
  const mockUser: User = {
    id: 1,
    email: 'test@test.com',
    firstName: 'Test',
    lastName: 'User',
    role: 'EDITOR',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const mockTokens: AuthTokens = {
    accessToken: 'access-token-123',
    refreshToken: 'refresh-token-456',
  };

  beforeEach(() => {
    localStorage.clear();
  });

  it('should initialize with null user and unauthenticated state', () => {
    const { result } = renderHook(() => useAuthStore());
    
    expect(result.current.user).toBeNull();
    expect(result.current.tokens).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('should login user and set authenticated state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.login(mockUser, mockTokens);
    });

    expect(result.current.user).toEqual(mockUser);
    expect(result.current.tokens).toEqual(mockTokens);
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.error).toBeNull();
    expect(localStorage.getItem('accessToken')).toBe(mockTokens.accessToken);
    expect(localStorage.getItem('refreshToken')).toBe(mockTokens.refreshToken);
  });

  it('should logout user and clear state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.login(mockUser, mockTokens);
    });

    act(() => {
      result.current.logout();
    });

    expect(result.current.user).toBeNull();
    expect(result.current.tokens).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(localStorage.getItem('accessToken')).toBeNull();
    expect(localStorage.getItem('refreshToken')).toBeNull();
  });

  it('should set and clear error', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.setError('Login failed');
    });

    expect(result.current.error).toBe('Login failed');

    act(() => {
      result.current.clearError();
    });

    expect(result.current.error).toBeNull();
  });

  it('should set loading state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.setLoading(true);
    });

    expect(result.current.isLoading).toBe(true);

    act(() => {
      result.current.setLoading(false);
    });

    expect(result.current.isLoading).toBe(false);
  });

  it('should persist user state to localStorage', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.login(mockUser, mockTokens);
    });

    // Check that state is persisted
    const persistedState = localStorage.getItem('auth-storage');
    expect(persistedState).toBeTruthy();
    
    const parsed = JSON.parse(persistedState!);
    expect(parsed.state.user).toEqual(mockUser);
    expect(parsed.state.isAuthenticated).toBe(true);
  });
});
