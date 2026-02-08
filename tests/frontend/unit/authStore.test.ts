import { describe, it, expect } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from '../../../src/frontend/src/store/authStore';
import type { User } from '../../../src/frontend/src/types';

describe('authStore', () => {
  const mockUser: User = {
    id: '1',
    email: 'test@test.com',
    firstName: 'Test',
    lastName: 'User',
    role: 'Maintainer',
    isActive: true,
    lastLogin: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  beforeEach(() => {
    localStorage.clear();
  });

  it('should initialize with null user and unauthenticated state', () => {
    const { result } = renderHook(() => useAuthStore());

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('should login user and set authenticated state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.login(mockUser);
    });

    expect(result.current.user).toEqual(mockUser);
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.error).toBeNull();
  });

  it('should logout user and clear state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.login(mockUser);
    });

    act(() => {
      result.current.logout();
    });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
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
      result.current.login(mockUser);
    });

    // Check that state is persisted
    const persistedState = localStorage.getItem('auth-storage');
    expect(persistedState).toBeTruthy();

    const parsed = JSON.parse(persistedState!);
    expect(parsed.state.user).toEqual(mockUser);
    expect(parsed.state.isAuthenticated).toBe(true);
  });
});
