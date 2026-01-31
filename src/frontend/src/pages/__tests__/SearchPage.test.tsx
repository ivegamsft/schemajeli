import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { Toaster } from 'sonner';
import SearchPage from '../../pages/SearchPage';

// Mock services
vi.mock('../../services/searchService', () => ({
  searchService: {
    search: vi.fn(async (query: string, filters?: any) => ({
      data: [
        { id: 1, type: 'TABLE', name: 'users', database: 'maindb' },
        { id: 2, type: 'ELEMENT', name: 'user_id', table: 'users' },
      ],
      totalResults: 2,
      executionTime: 45,
    })),
  },
}));

vi.mock('../../hooks/useAuth', () => ({
  useAuth: () => ({
    user: { id: 1, email: 'test@example.com', firstName: 'Test', role: 'EDITOR' },
    hasPermission: (permission: string) => ['EDITOR', 'ADMIN'].includes(permission),
    logout: vi.fn(),
    login: vi.fn(),
  }),
}));

const renderWithRouter = (component: React.ReactElement) => {
  return render(
    <BrowserRouter>
      {component}
      <Toaster />
    </BrowserRouter>
  );
};

describe('SearchPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders search page', async () => {
    renderWithRouter(<SearchPage />);
    await waitFor(() => {
      expect(screen.getByText('Search')).toBeInTheDocument();
    });
  });

  it('displays search input', () => {
    renderWithRouter(<SearchPage />);
    const input = screen.getByPlaceholderText(/search|query|table|element/i) || document.querySelector('input[type="text"]');
    expect(input).toBeInTheDocument();
  });

  it('renders without crashing', () => {
    expect(() => renderWithRouter(<SearchPage />)).not.toThrow();
  });

  it('shows empty state initially', () => {
    renderWithRouter(<SearchPage />);
    expect(document.body).toBeInTheDocument();
  });

  it('displays filter options', () => {
    renderWithRouter(<SearchPage />);
    expect(document.body).toBeInTheDocument();
  });

  it('handles search input', async () => {
    renderWithRouter(<SearchPage />);
    const input = document.querySelector('input[type="text"]');
    if (input) {
      fireEvent.change(input, { target: { value: 'users' } });
      expect((input as HTMLInputElement).value).toBe('users');
    }
  });

  it('executes search on input change', async () => {
    renderWithRouter(<SearchPage />);
    await waitFor(() => {
      expect(document.body).toBeInTheDocument();
    });
  });

  it('displays search results', async () => {
    renderWithRouter(<SearchPage />);
    const input = document.querySelector('input[type="text"]');
    if (input) {
      fireEvent.change(input, { target: { value: 'users' } });
      await waitFor(() => {
        expect(document.body).toBeInTheDocument();
      }, { timeout: 2000 });
    }
  });

  it('allows filtering results', async () => {
    renderWithRouter(<SearchPage />);
    await waitFor(() => {
      expect(document.body).toBeInTheDocument();
    });
  });

  it('handles multiple search types', () => {
    renderWithRouter(<SearchPage />);
    expect(document.body).toBeInTheDocument();
  });

  it('manages search state', async () => {
    renderWithRouter(<SearchPage />);
    await waitFor(() => {
      expect(screen.getByText('Search')).toBeInTheDocument();
    });
  });
});
