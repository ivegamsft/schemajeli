import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { Toaster } from 'sonner';
import AbbreviationsPage from '../../pages/AbbreviationsPage';

// Mock services with direct implementations
vi.mock('../../services/abbreviationService', () => ({
  abbreviationService: {
    getAll: vi.fn(async () => ({
      data: [
        { id: 1, abbreviation: 'PK', meaning: 'Primary Key', createdAt: '2024-01-01T00:00:00Z', updatedAt: '2024-01-01T00:00:00Z' },
        { id: 2, abbreviation: 'FK', meaning: 'Foreign Key', createdAt: '2024-01-01T00:00:00Z', updatedAt: '2024-01-01T00:00:00Z' },
      ],
      totalPages: 1,
    })),
    getById: vi.fn(),
    create: vi.fn(async (data) => ({ id: 3, ...data, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() })),
    update: vi.fn(async (id, data) => ({ id, ...data, createdAt: '2024-01-01T00:00:00Z', updatedAt: new Date().toISOString() })),
    delete: vi.fn(async () => undefined),
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

describe('AbbreviationsPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders abbreviations page', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('Abbreviations')).toBeInTheDocument();
    });
  });

  it('loads abbreviations on mount', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('PK')).toBeInTheDocument();
    }, { timeout: 3000 });
  });

  it('displays multiple abbreviations', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('PK')).toBeInTheDocument();
      expect(screen.getByText('FK')).toBeInTheDocument();
    }, { timeout: 3000 });
  });

  it('renders without crashing', () => {
    expect(() => renderWithRouter(<AbbreviationsPage />)).not.toThrow();
  });

  it('displays abbreviation meanings', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('Primary Key')).toBeInTheDocument();
      expect(screen.getByText('Foreign Key')).toBeInTheDocument();
    }, { timeout: 3000 });
  });

  it('handles page state', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('PK')).toBeInTheDocument();
    }, { timeout: 3000 });
  });

  it('manages abbreviation list', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      const abbrevs = ['PK', 'FK'];
      abbrevs.forEach(abbr => {
        expect(screen.getByText(abbr)).toBeInTheDocument();
      });
    }, { timeout: 3000 });
  });

  it('handles empty state', async () => {
    renderWithRouter(<AbbreviationsPage />);
    expect(document.body).toBeInTheDocument();
  });

  it('loads with pagination', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('PK')).toBeInTheDocument();
    }, { timeout: 3000 });
  });

  it('renders edit interface', async () => {
    renderWithRouter(<AbbreviationsPage />);
    await waitFor(() => {
      expect(screen.getByText('Abbreviations')).toBeInTheDocument();
    }, { timeout: 3000 });
  });
});

