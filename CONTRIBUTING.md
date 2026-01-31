# Contributing to SchemaJeli

Thank you for your interest in contributing to SchemaJeli! This document provides guidelines and best practices for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Getting Help](#getting-help)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow:

- **Be respectful**: Treat everyone with respect and consideration
- **Be collaborative**: Work together to improve the project
- **Be inclusive**: Welcome diverse perspectives and backgrounds
- **Be professional**: Keep discussions focused and constructive

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- Node.js ≥18.0.0
- npm ≥9.0.0
- PostgreSQL ≥14.0
- Git ≥2.30
- A GitHub account
- Code editor (VS Code recommended)

### Setting Up Development Environment

1. **Fork the repository**

   Click the "Fork" button on the [SchemaJeli repository](https://github.com/ivegamsft/schemajeli).

2. **Clone your fork**

   ```bash
   git clone https://github.com/YOUR_USERNAME/schemajeli.git
   cd schemajeli
   ```

3. **Add upstream remote**

   ```bash
   git remote add upstream https://github.com/ivegamsft/schemajeli.git
   ```

4. **Install dependencies**

   ```bash
   npm install
   ```

5. **Set up environment**

   ```bash
   cp .env.example .env
   # Edit .env with your local configuration
   ```

6. **Run database migrations**

   ```bash
   npm run db:migrate
   npm run db:seed
   ```

7. **Start development servers**

   ```bash
   npm run dev
   ```

8. **Verify setup**

   - Backend: http://localhost:3000/api/health
   - Frontend: http://localhost:5173

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
# Update your local main branch
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/issue-description
```

### Branch Naming Convention

- `feature/` - New features (e.g., `feature/add-export-csv`)
- `fix/` - Bug fixes (e.g., `fix/login-error`)
- `docs/` - Documentation changes (e.g., `docs/update-readme`)
- `refactor/` - Code refactoring (e.g., `refactor/auth-service`)
- `test/` - Adding or updating tests (e.g., `test/server-controller`)
- `chore/` - Maintenance tasks (e.g., `chore/update-dependencies`)

### 2. Make Your Changes

- Write clean, readable code
- Follow the coding standards (see below)
- Add tests for new functionality
- Update documentation as needed
- Keep commits focused and atomic

### 3. Test Your Changes

Before committing, ensure all tests pass:

```bash
# Run all tests
npm test

# Run specific test suites
npm run test:backend
npm run test:frontend
npm run test:integration

# Check test coverage
npm run test:coverage

# Run linters
npm run lint

# Check formatting
npm run format:check

# Type checking
npm run type-check
```

### 4. Commit Your Changes

Follow the commit guidelines (see below):

```bash
git add .
git commit -m "feat: add CSV export functionality"
```

### 5. Keep Your Branch Updated

Regularly sync with the upstream repository:

```bash
git fetch upstream
git rebase upstream/main
```

### 6. Push Your Branch

```bash
git push origin feature/your-feature-name
```

### 7. Create a Pull Request

Go to your fork on GitHub and click "New Pull Request".

## Coding Standards

### TypeScript

- **Strict mode**: Always enabled
- **Type safety**: Avoid `any` - use specific types or `unknown`
- **Interfaces over types**: Prefer `interface` for object shapes
- **Naming conventions**:
  - PascalCase for types, interfaces, classes
  - camelCase for variables, functions
  - UPPER_CASE for constants

**Example:**

```typescript
// Good
interface UserProfile {
  id: string;
  email: string;
  role: UserRole;
}

const getUserById = async (userId: string): Promise<UserProfile> => {
  // implementation
};

// Bad
type user_profile = {
  id: any;
  email: string;
};

function get_user(id: any) {
  // implementation
}
```

### React/Frontend

- **Functional components**: Always use functional components with hooks
- **TypeScript**: All components must be typed
- **File naming**: PascalCase for components (e.g., `ServerList.tsx`)
- **Prop types**: Always define prop interfaces

**Example:**

```typescript
// Good
interface ServerListProps {
  onServerClick: (serverId: string) => void;
  isLoading?: boolean;
}

export function ServerList({ onServerClick, isLoading = false }: ServerListProps) {
  // implementation
}

// Bad
export function ServerList(props: any) {
  // implementation
}
```

### Backend/API

- **RESTful conventions**: Follow REST principles
- **Error handling**: Always handle errors gracefully
- **Input validation**: Validate all user input
- **Async/await**: Prefer async/await over callbacks

**Example:**

```typescript
// Good
export async function createServer(req: Request, res: Response): Promise<void> {
  try {
    const validatedData = ServerSchema.parse(req.body);
    const server = await serverService.create(validatedData);
    res.status(201).json(server);
  } catch (error) {
    if (error instanceof ValidationError) {
      res.status(400).json({ error: error.message });
    } else {
      logger.error('Server creation failed', { error });
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

// Bad
export function createServer(req, res) {
  serverService.create(req.body, (err, server) => {
    if (err) {
      res.status(500).send(err);
    } else {
      res.json(server);
    }
  });
}
```

### Code Formatting

We use **Prettier** for consistent code formatting:

```bash
# Format all files
npm run format

# Check formatting without making changes
npm run format:check
```

**Prettier Configuration** (`.prettierrc.json`):

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "arrowParens": "always"
}
```

### Linting

We use **ESLint** with Airbnb style guide:

```bash
# Run linter
npm run lint

# Auto-fix issues
npm run lint:fix
```

## Commit Guidelines

We follow **Conventional Commits** specification:

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring without changing functionality
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build, etc.)
- `ci`: CI/CD changes
- `revert`: Revert a previous commit

### Scope (Optional)

The scope specifies the area of change:

- `backend`
- `frontend`
- `api`
- `auth`
- `database`
- `ci`
- `docs`

### Subject

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize the first letter
- No period at the end
- Limit to 72 characters

### Examples

```bash
# Feature
feat(api): add CSV export endpoint for servers

# Bug fix
fix(auth): resolve token refresh race condition

# Documentation
docs(readme): update installation instructions

# Refactor
refactor(backend): extract auth logic into service layer

# Performance
perf(database): add index on servers.name column

# Test
test(api): add integration tests for server endpoints

# Breaking change
feat(api)!: change server response format

BREAKING CHANGE: Server API now returns `createdAt` instead of `created_date`
```

## Pull Request Process

### Before Submitting

Ensure your PR meets these requirements:

- ✅ All tests pass
- ✅ Code coverage maintained or improved
- ✅ Linting passes with no errors
- ✅ Code is formatted with Prettier
- ✅ Commit messages follow conventional commits
- ✅ Documentation updated (if applicable)
- ✅ Branch is up to date with `main`

### PR Title

Use the same format as commit messages:

```
feat(api): add pagination to server list endpoint
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related Issue
Fixes #123

## Changes Made
- Added pagination support to `/api/servers` endpoint
- Updated ServerController to handle page and limit query params
- Added pagination tests

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
[Add screenshots here]

## Checklist
- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my code
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or my feature works
- [ ] New and existing tests pass locally
- [ ] Any dependent changes have been merged
```

### Review Process

1. **Automated checks**: CI pipeline must pass
2. **Code review**: At least one approval required
3. **Address feedback**: Make requested changes
4. **Merge**: Squash and merge to `main`

### PR Best Practices

- **Keep PRs small**: Easier to review (aim for <500 lines changed)
- **One feature per PR**: Don't combine unrelated changes
- **Write clear descriptions**: Explain what and why
- **Link related issues**: Use "Fixes #123" or "Closes #456"
- **Respond to reviews**: Address feedback promptly
- **Keep updated**: Rebase on main if needed

## Testing Requirements

### Test Coverage

All contributions must maintain or improve code coverage:

| Component | Minimum Coverage |
|-----------|------------------|
| Backend | 80% |
| Frontend | 70% |
| Integration | 60% |

### Writing Tests

**Backend Unit Test Example:**

```typescript
// src/backend/services/serverService.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { ServerService } from './serverService';

describe('ServerService', () => {
  let serverService: ServerService;

  beforeEach(() => {
    serverService = new ServerService();
  });

  describe('create', () => {
    it('should create a new server', async () => {
      const serverData = {
        name: 'test-server',
        rdbmsType: 'POSTGRESQL',
      };

      const server = await serverService.create(serverData);

      expect(server).toMatchObject(serverData);
      expect(server.id).toBeDefined();
    });

    it('should throw error for duplicate server name', async () => {
      await serverService.create({ name: 'duplicate', rdbmsType: 'POSTGRESQL' });

      await expect(
        serverService.create({ name: 'duplicate', rdbmsType: 'MYSQL' })
      ).rejects.toThrow('Server already exists');
    });
  });
});
```

**Frontend Component Test Example:**

```typescript
// src/frontend/components/ServerList.test.tsx
import { render, screen } from '@testing-library/react';
import { ServerList } from './ServerList';

describe('ServerList', () => {
  it('should display servers', () => {
    const servers = [
      { id: '1', name: 'server-1', rdbmsType: 'POSTGRESQL' },
      { id: '2', name: 'server-2', rdbmsType: 'MYSQL' },
    ];

    render(<ServerList servers={servers} />);

    expect(screen.getByText('server-1')).toBeInTheDocument();
    expect(screen.getByText('server-2')).toBeInTheDocument();
  });
});
```

## Documentation

### When to Update Documentation

- Adding new features
- Changing API endpoints
- Modifying configuration
- Updating dependencies
- Changing architecture

### Documentation Files

- `README.md` - Project overview and quick start
- `docs/design/` - Architecture and design documents
- `.specify/openapi.yaml` - API specification
- Code comments - For complex logic

### JSDoc Comments

Add JSDoc comments for public APIs:

```typescript
/**
 * Creates a new server in the database
 *
 * @param data - Server creation data
 * @returns The created server object
 * @throws {ValidationError} If server data is invalid
 * @throws {ConflictError} If server name already exists
 *
 * @example
 * const server = await createServer({
 *   name: 'prod-db-01',
 *   rdbmsType: 'POSTGRESQL',
 *   hostname: 'db.example.com',
 *   port: 5432
 * });
 */
export async function createServer(data: CreateServerDto): Promise<Server> {
  // implementation
}
```

## Getting Help

### Questions and Discussions

- **GitHub Discussions**: For general questions and ideas
- **GitHub Issues**: For bug reports and feature requests
- **Documentation**: Check `docs/` directory first

### Issue Templates

When creating an issue, use the appropriate template:

- **Bug Report**: For reporting bugs
- **Feature Request**: For suggesting new features
- **Documentation**: For documentation improvements

### Communication Channels

- **GitHub Issues**: Public discussion
- **Pull Request Comments**: Code-specific discussions
- **GitHub Discussions**: General questions and community help

## Recognition

Contributors will be recognized in:

- Project README
- Release notes
- Contributors page

Thank you for contributing to SchemaJeli! 🎉
