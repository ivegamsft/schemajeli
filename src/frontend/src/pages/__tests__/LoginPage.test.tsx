import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import LoginPage from '../LoginPage';
import { useAuth } from '../../hooks/useAuth';

vi.mock('../../hooks/useAuth');

describe('LoginPage', () => {
  const mockLogin = vi.fn();
  const mockClearError = vi.fn();

  beforeEach(() => {
    vi.mocked(useAuth).mockReturnValue({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
      login: mockLogin,
      logout: vi.fn(),
      hasPermission: vi.fn(),
      clearError: mockClearError,
    });
  });

  const renderLoginPage = () => {
    return render(
      <BrowserRouter>
        <LoginPage />
      </BrowserRouter>
    );
  };

  it('should render login form', () => {
    renderLoginPage();

    expect(screen.getByLabelText(/email address/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
  });

  it('should display test credentials', () => {
    renderLoginPage();

    expect(screen.getByText(/test accounts/i)).toBeInTheDocument();
    expect(screen.getByText(/admin@schemajeli.com/)).toBeInTheDocument();
  });

  it('should update input values', () => {
    renderLoginPage();

    const emailInput = screen.getByLabelText(/email address/i) as HTMLInputElement;
    const passwordInput = screen.getByLabelText(/password/i) as HTMLInputElement;

    fireEvent.change(emailInput, { target: { value: 'test@test.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });

    expect(emailInput.value).toBe('test@test.com');
    expect(passwordInput.value).toBe('password123');
  });

  it('should call login on form submit', async () => {
    renderLoginPage();

    const emailInput = screen.getByLabelText(/email address/i);
    const passwordInput = screen.getByLabelText(/password/i);
    const submitButton = screen.getByRole('button', { name: /sign in/i });

    fireEvent.change(emailInput, { target: { value: 'test@test.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'test@test.com',
        password: 'password123',
      });
    });
  });

  it('should show loading state', () => {
    vi.mocked(useAuth).mockReturnValue({
      user: null,
      isAuthenticated: false,
      isLoading: true,
      error: null,
      login: mockLogin,
      logout: vi.fn(),
      hasPermission: vi.fn(),
      clearError: mockClearError,
    });

    renderLoginPage();

    expect(screen.getByText(/signing in/i)).toBeInTheDocument();
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('should display error message', () => {
    vi.mocked(useAuth).mockReturnValue({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: 'Invalid credentials',
      login: mockLogin,
      logout: vi.fn(),
      hasPermission: vi.fn(),
      clearError: mockClearError,
    });

    renderLoginPage();

    expect(screen.getByText('Invalid credentials')).toBeInTheDocument();
  });
});
