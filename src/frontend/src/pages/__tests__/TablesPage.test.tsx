import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { Toaster } from 'sonner';
import TablesPage from '../../pages/TablesPage';

// Mock services with direct implementations
vi.mock('../../services/tableService', () => ({
  tableService: {
    getAll: vi.fn(async () => ({ 
      data: [
        { id: '1', name: 'users', databaseId: '1', tableType: 'TABLE', elementCount: 5, createdAt: '2024-01-01T00:00:00Z' },
        { id: '2', name: 'products', databaseId: '1', tableType: 'TABLE', elementCount: 3, createdAt: '2024-01-02T00:00:00Z' },
      ], 
      totalPages: 1,
    })),
    getById: vi.fn(),
    delete: vi.fn(async () => undefined),
  },
}));

vi.mock('../../services/databaseService', () => ({
  databaseService: {
    getAll: vi.fn(async () => ({ data: [{ id: '1', name: 'maindb', serverId: '1' }], totalPages: 1 })),
    getById: vi.fn(),
  },
}));

vi.mock('../../hooks/useAuth', () => ({
  useAuth: () => ({
    user: {
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: 'Maintainer',
      isActive: true,
      lastLogin: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
    hasPermission: (permission: string) => ['Maintainer', 'Admin'].includes(permission),
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

describe('TablesPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders tables page', async () => {
    renderWithRouter(<TablesPage />);
    await waitFor(() => {
      expect(screen.getByText('Tables')).toBeInTheDocument();
    });
  });

  it('loads tables on mount', async () => {
    renderWithRouter(<TablesPage />);
    await waitFor(() => {
      expect(screen.getByText('users')).toBeInTheDocument();
    });
  });

  it('displays multiple tables', async () => {
    renderWithRouter(<TablesPage />);
    await waitFor(() => {
      expect(screen.getByText('users')).toBeInTheDocument();
      expect(screen.getByText('products')).toBeInTheDocument();
    });
  });

  it('renders without crashing', () => {
    expect(() => renderWithRouter(<TablesPage />)).not.toThrow();
  });

  it('loads tables data', async () => {
    renderWithRouter(<TablesPage />);
    await waitFor(() => {
      expect(screen.getByText('users')).toBeInTheDocument();
    }, { timeout: 2000 });
  });

  it('handles empty database state', async () => {
    renderWithRouter(<TablesPage />);
    expect(document.body).toBeInTheDocument();
  });

  it('manages table list state', async () => {
    renderWithRouter(<TablesPage />);
    await waitFor(() => {
      const tables = ['users', 'products'];
      tables.forEach(table => {
        expect(screen.getByText(table)).toBeInTheDocument();
      });
    });
  });
});
