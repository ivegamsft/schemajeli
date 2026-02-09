# Quick Start Guide: Style Guide Management

**Feature**: Style Guide Management  
**Last Updated**: 2026-02-08  
**Audience**: Developers implementing or extending the style guide feature

---

## Overview

This guide helps you get started with the style guide management implementation. Style guides allow administrators to define and enforce naming conventions across database objects.

### Key Concepts

- **Style Guide**: A collection of naming rules with version control
- **Naming Rule**: A single regex-based pattern for a specific entity type (TABLE, COLUMN, etc.)
- **Version**: Semantic versioned snapshot of a style guide (MAJOR.MINOR.PATCH)
- **Validation**: Process of checking schema elements against style guide rules
- **Usage**: Tracking which databases/tables are using which style guides

---

## Prerequisites

Before starting implementation, ensure:

✅ **Environment Setup**:
- Node.js 18+ LTS installed
- PostgreSQL 15+ running locally or accessible
- Backend and frontend dependencies installed

✅ **Knowledge Required**:
- TypeScript/Node.js/Express.js
- React 19 with TypeScript
- Prisma ORM
- REST API design

✅ **Existing Codebase**:
- SchemaJeli backend at `src/backend`
- SchemaJeli frontend at `src/frontend`
- Prisma schema at `src/backend/prisma/schema.prisma`

---

## Phase 0: Database Setup

### 1. Add Prisma Schema Models

Add the following models to `src/backend/prisma/schema.prisma`:

```prisma
// Style Guide Management Models

enum ChangeType {
  MAJOR
  MINOR
  PATCH
}

enum RuleChangeAction {
  ADDED
  MODIFIED
  REMOVED
}

enum StyleGuideSource {
  MANUAL
  IMPORTED
}

model StyleGuide {
  id              String    @id @default(uuid())
  name            String    @unique @db.VarChar(255)
  description     String?   @db.Text
  currentVersion  String    @db.VarChar(20) @default("1.0.0")
  isActive        Boolean   @default(true)
  source          StyleGuideSource @default(MANUAL)
  createdById     String    @map("created_by_id")
  createdAt       DateTime  @default(now()) @map("created_at")
  updatedAt       DateTime  @updatedAt @map("updated_at")
  deletedAt       DateTime? @map("deleted_at")

  createdBy       User      @relation("StyleGuideCreator", fields: [createdById], references: [id])
  rules           NamingRule[]
  versions        StyleGuideVersion[]
  usage           StyleGuideUsage[]
  auditLog        StyleGuideAuditLog[]

  @@index([name])
  @@index([isActive])
  @@map("style_guides")
}

model NamingRule {
  id              String    @id @default(uuid())
  styleGuideId    String    @map("style_guide_id")
  name            String    @db.VarChar(255)
  entityType      String    @db.VarChar(50)
  pattern         String    @db.Text
  caseConvention  String    @db.VarChar(50)
  description     String?   @db.Text
  exampleValid    String[]  @default([])
  exampleInvalid  String[]  @default([])
  isRequired      Boolean   @default(false)
  ruleOrder       Int       @default(0)
  createdById     String    @map("created_by_id")
  createdAt       DateTime  @default(now()) @map("created_at")
  updatedAt       DateTime  @updatedAt @map("updated_at")

  styleGuide      StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Cascade)
  createdBy       User       @relation("NamingRuleCreator", fields: [createdById], references: [id])

  @@unique([styleGuideId, name])
  @@index([styleGuideId])
  @@index([entityType])
  @@map("naming_rules")
}

model StyleGuideVersion {
  id              String    @id @default(uuid())
  styleGuideId    String    @map("style_guide_id")
  version         String    @db.VarChar(20)
  changeType      ChangeType
  changelog       String?   @db.Text
  ruleSnapshot    Json
  createdById     String    @map("created_by_id")
  createdAt       DateTime  @default(now()) @map("created_at")

  styleGuide      StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Cascade)
  createdBy       User       @relation("StyleGuideVersionCreator", fields: [createdById], references: [id])
  ruleDiffs       RuleDiff[]

  @@unique([styleGuideId, version])
  @@index([styleGuideId, createdAt])
  @@map("style_guide_versions")
}

model RuleDiff {
  id              String    @id @default(uuid())
  versionId       String    @map("version_id")
  ruleId          String    @map("rule_id")
  action          RuleChangeAction
  oldValue        Json?
  newValue        Json?
  fieldChanged    String?   @db.VarChar(100)

  version         StyleGuideVersion @relation(fields: [versionId], references: [id], onDelete: Cascade)

  @@index([versionId])
  @@index([ruleId])
  @@map("rule_diffs")
}

model StyleGuideUsage {
  id              String    @id @default(uuid())
  styleGuideId    String    @map("style_guide_id")
  resourceType    String    @db.VarChar(50)
  resourceId      String    @map("resource_id")
  appliedById     String    @map("applied_by_id")
  appliedAt       DateTime  @default(now()) @map("applied_at")
  violationCount  Int       @default(0)

  styleGuide      StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Restrict)
  appliedBy       User       @relation("StyleGuideUsageCreator", fields: [appliedById], references: [id])

  @@unique([styleGuideId, resourceType, resourceId])
  @@index([styleGuideId])
  @@index([resourceId])
  @@map("style_guide_usage")
}

model StyleGuideAuditLog {
  id                String    @id @default(uuid())
  styleGuideId      String    @map("style_guide_id")
  action            String    @db.VarChar(50)
  versionBefore     String?   @db.VarChar(20)
  versionAfter      String?   @db.VarChar(20)
  changeDescription String?   @db.Text
  userId            String    @map("user_id")
  createdAt         DateTime  @default(now()) @map("created_at")

  styleGuide        StyleGuide @relation(fields: [styleGuideId], references: [id], onDelete: Cascade)
  user              User       @relation("StyleGuideAuditUser", fields: [userId], references: [id])

  @@index([styleGuideId])
  @@index([userId])
  @@index([createdAt])
  @@map("style_guide_audit_logs")
}

// Add to User model:
model User {
  // ... existing fields ...
  
  styleGuidesCreated       StyleGuide[] @relation("StyleGuideCreator")
  namingRulesCreated       NamingRule[] @relation("NamingRuleCreator")
  styleGuideVersionsCreated StyleGuideVersion[] @relation("StyleGuideVersionCreator")
  styleGuideUsageCreated   StyleGuideUsage[] @relation("StyleGuideUsageCreator")
  styleGuideAudits         StyleGuideAuditLog[] @relation("StyleGuideAuditUser")
}
```

### 2. Create and Run Migration

```bash
# Navigate to backend directory
cd src/backend

# Generate Prisma client
npm run prisma:generate

# Create migration
npx prisma migrate dev --name add-style-guides

# Apply migration
npm run prisma:migrate
```

### 3. (Optional) Seed Sample Data

Create `src/backend/prisma/seeds/style-guides.ts`:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedStyleGuides() {
  const adminUser = await prisma.user.findFirst({
    where: { role: 'ADMIN' }
  });

  if (!adminUser) {
    console.log('No admin user found, skipping style guide seeding');
    return;
  }

  const sampleGuide = await prisma.styleGuide.create({
    data: {
      name: 'Corporate Naming Standards',
      description: 'Standard naming conventions for all database objects',
      currentVersion: '1.0.0',
      source: 'MANUAL',
      createdById: adminUser.id,
      rules: {
        create: [
          {
            name: 'Table Names',
            entityType: 'TABLE',
            pattern: '^[A-Z][a-zA-Z0-9]*$',
            caseConvention: 'PascalCase',
            description: 'Tables must use PascalCase',
            exampleValid: ['UserProfile', 'OrderHistory', 'ProductCatalog'],
            exampleInvalid: ['user_profile', 'USERS', 'order-history'],
            ruleOrder: 1,
            createdById: adminUser.id,
          },
          {
            name: 'Column Names',
            entityType: 'COLUMN',
            pattern: '^[a-z][a-zA-Z0-9]*$',
            caseConvention: 'camelCase',
            description: 'Columns must use camelCase',
            exampleValid: ['userId', 'createdAt', 'firstName'],
            exampleInvalid: ['user_id', 'UserID', 'CREATED_AT'],
            ruleOrder: 2,
            createdById: adminUser.id,
          },
        ],
      },
    },
  });

  // Create initial version
  await prisma.styleGuideVersion.create({
    data: {
      styleGuideId: sampleGuide.id,
      version: '1.0.0',
      changeType: 'MAJOR',
      changelog: 'Initial version',
      ruleSnapshot: [], // Would contain serialized rules
      createdById: adminUser.id,
    },
  });

  console.log('✅ Seeded sample style guide:', sampleGuide.name);
}
```

Run seed:

```bash
npm run prisma:seed
```

---

## Phase 1: Backend Implementation

### 1. Create Service Layer

**File**: `src/backend/src/services/styleGuideService.ts`

```typescript
import { PrismaClient, StyleGuide, NamingRule } from '@prisma/client';

export class StyleGuideService {
  constructor(private prisma: PrismaClient) {}

  async create(data: {
    name: string;
    description?: string;
    rules: Array<{
      name: string;
      entityType: string;
      pattern: string;
      caseConvention: string;
      description?: string;
      exampleValid?: string[];
      exampleInvalid?: string[];
    }>;
    userId: string;
  }): Promise<StyleGuide> {
    return await this.prisma.$transaction(async (tx) => {
      const guide = await tx.styleGuide.create({
        data: {
          name: data.name,
          description: data.description,
          currentVersion: '1.0.0',
          createdById: data.userId,
          rules: {
            create: data.rules.map((rule, idx) => ({
              ...rule,
              ruleOrder: idx,
              createdById: data.userId,
            })),
          },
        },
        include: { rules: true },
      });

      // Create initial version
      await tx.styleGuideVersion.create({
        data: {
          styleGuideId: guide.id,
          version: '1.0.0',
          changeType: 'MAJOR',
          changelog: 'Initial version',
          ruleSnapshot: guide.rules,
          createdById: data.userId,
        },
      });

      // Audit log
      await tx.styleGuideAuditLog.create({
        data: {
          styleGuideId: guide.id,
          action: 'CREATE',
          versionAfter: '1.0.0',
          changeDescription: 'Style guide created',
          userId: data.userId,
        },
      });

      return guide;
    });
  }

  async findAll(filters?: {
    search?: string;
    source?: string;
    isActive?: boolean;
    page?: number;
    limit?: number;
  }) {
    const where = {
      ...(filters?.search && {
        OR: [
          { name: { contains: filters.search, mode: 'insensitive' as const } },
          { description: { contains: filters.search, mode: 'insensitive' as const } },
        ],
      }),
      ...(filters?.source && { source: filters.source }),
      ...(filters?.isActive !== undefined && { isActive: filters.isActive }),
      deletedAt: null,
    };

    const page = filters?.page || 1;
    const limit = filters?.limit || 50;
    const skip = (page - 1) * limit;

    const [data, totalCount] = await Promise.all([
      this.prisma.styleGuide.findMany({
        where,
        include: {
          rules: { orderBy: { ruleOrder: 'asc' } },
          createdBy: { select: { id: true, username: true, email: true } },
          _count: { select: { usage: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.styleGuide.count({ where }),
    ]);

    return {
      data,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
        hasNextPage: page * limit < totalCount,
        hasPrevPage: page > 1,
      },
    };
  }

  async findById(id: string) {
    return await this.prisma.styleGuide.findUnique({
      where: { id },
      include: {
        rules: { orderBy: { ruleOrder: 'asc' } },
        createdBy: { select: { id: true, username: true, email: true } },
        versions: {
          orderBy: { createdAt: 'desc' },
          take: 10,
          include: { createdBy: { select: { username: true } } },
        },
        usage: {
          include: {
            appliedBy: { select: { username: true } },
          },
        },
      },
    });
  }

  async delete(id: string, userId: string) {
    // Check if in use
    const usage = await this.prisma.styleGuideUsage.findFirst({
      where: { styleGuideId: id },
    });

    if (usage) {
      throw new Error(
        'Cannot delete style guide that is currently in use. Remove from all resources first.'
      );
    }

    return await this.prisma.$transaction(async (tx) => {
      const guide = await tx.styleGuide.update({
        where: { id },
        data: { deletedAt: new Date(), isActive: false },
      });

      await tx.styleGuideAuditLog.create({
        data: {
          styleGuideId: id,
          action: 'DELETE',
          versionBefore: guide.currentVersion,
          changeDescription: 'Style guide deleted',
          userId,
        },
      });

      return guide;
    });
  }
}
```

### 2. Create Versioning Service

**File**: `src/backend/src/services/versioningService.ts`

See detailed implementation in `research.md` section 2 (Version Control & History).

### 3. Create API Routes

**File**: `src/backend/src/api/styleGuides.ts`

```typescript
import { Router } from 'express';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';
import { StyleGuideService } from '../services/styleGuideService.js';
import { prisma } from '../config/database.js';

const router = Router();
const styleGuideService = new StyleGuideService(prisma);

// List all style guides (all authenticated users)
router.get('/', authenticate, async (req, res) => {
  const { search, source, isActive, page, limit } = req.query;
  
  const result = await styleGuideService.findAll({
    search: search as string,
    source: source as string,
    isActive: isActive === 'true',
    page: page ? parseInt(page as string) : undefined,
    limit: limit ? parseInt(limit as string) : undefined,
  });

  res.json(result);
});

// Get style guide by ID (all authenticated users)
router.get('/:id', authenticate, async (req, res) => {
  const guide = await styleGuideService.findById(req.params.id);
  if (!guide) {
    return res.status(404).json({ error: 'NOT_FOUND', message: 'Style guide not found' });
  }
  res.json({ data: guide });
});

// Create style guide (ADMIN only)
router.post('/', authenticate, requireRole('ADMIN'), async (req, res) => {
  const { name, description, rules } = req.body;
  const userId = req.user.id;

  const guide = await styleGuideService.create({
    name,
    description,
    rules,
    userId,
  });

  res.status(201).json({
    data: guide,
    message: 'Style guide created successfully',
  });
});

// Delete style guide (ADMIN only)
router.delete('/:id', authenticate, requireRole('ADMIN'), async (req, res) => {
  const userId = req.user.id;
  await styleGuideService.delete(req.params.id, userId);
  res.json({ message: 'Style guide deleted successfully' });
});

export default router;
```

### 4. Register Routes

Add to `src/backend/src/app.ts`:

```typescript
import styleGuidesRouter from './api/styleGuides.js';

// ... existing routes ...
app.use('/api/style-guides', styleGuidesRouter);
```

---

## Phase 2: Frontend Implementation

### 1. Create API Client

**File**: `src/frontend/src/services/styleGuideApi.ts`

```typescript
import axios from 'axios';
import { StyleGuide, NamingRule } from '../types/styleGuide';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

export const styleGuideApi = {
  async getAll(params?: {
    search?: string;
    source?: string;
    isActive?: boolean;
    page?: number;
    limit?: number;
  }) {
    const response = await axios.get<{
      data: StyleGuide[];
      pagination: any;
    }>(`${API_BASE}/style-guides`, { params });
    return response.data;
  },

  async getById(id: string) {
    const response = await axios.get<{ data: StyleGuide }>(
      `${API_BASE}/style-guides/${id}`
    );
    return response.data.data;
  },

  async create(data: {
    name: string;
    description?: string;
    rules: Partial<NamingRule>[];
  }) {
    const response = await axios.post<{ data: StyleGuide }>(
      `${API_BASE}/style-guides`,
      data
    );
    return response.data.data;
  },

  async delete(id: string) {
    await axios.delete(`${API_BASE}/style-guides/${id}`);
  },
};
```

### 2. Create Zustand Store

**File**: `src/frontend/src/store/styleGuideStore.ts`

```typescript
import { create } from 'zustand';
import { StyleGuide } from '../types/styleGuide';
import { styleGuideApi } from '../services/styleGuideApi';

interface StyleGuideStore {
  guides: StyleGuide[];
  currentGuide: StyleGuide | null;
  isLoading: boolean;
  error: string | null;
  
  fetchGuides: (filters?: any) => Promise<void>;
  fetchGuideById: (id: string) => Promise<void>;
  createGuide: (data: any) => Promise<void>;
  deleteGuide: (id: string) => Promise<void>;
}

export const useStyleGuideStore = create<StyleGuideStore>((set) => ({
  guides: [],
  currentGuide: null,
  isLoading: false,
  error: null,

  fetchGuides: async (filters) => {
    set({ isLoading: true, error: null });
    try {
      const result = await styleGuideApi.getAll(filters);
      set({ guides: result.data, isLoading: false });
    } catch (error) {
      set({ error: (error as Error).message, isLoading: false });
    }
  },

  fetchGuideById: async (id) => {
    set({ isLoading: true, error: null });
    try {
      const guide = await styleGuideApi.getById(id);
      set({ currentGuide: guide, isLoading: false });
    } catch (error) {
      set({ error: (error as Error).message, isLoading: false });
    }
  },

  createGuide: async (data) => {
    set({ isLoading: true, error: null });
    try {
      await styleGuideApi.create(data);
      set({ isLoading: false });
    } catch (error) {
      set({ error: (error as Error).message, isLoading: false });
      throw error;
    }
  },

  deleteGuide: async (id) => {
    set({ isLoading: true, error: null });
    try {
      await styleGuideApi.delete(id);
      set((state) => ({
        guides: state.guides.filter((g) => g.id !== id),
        isLoading: false,
      }));
    } catch (error) {
      set({ error: (error as Error).message, isLoading: false });
      throw error;
    }
  },
}));
```

### 3. Create List Component

**File**: `src/frontend/src/components/StyleGuideList.tsx`

```typescript
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStyleGuideStore } from '../store/styleGuideStore';

export function StyleGuideList() {
  const navigate = useNavigate();
  const { guides, isLoading, error, fetchGuides, deleteGuide } =
    useStyleGuideStore();

  useEffect(() => {
    fetchGuides();
  }, [fetchGuides]);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="container mx-auto p-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Style Guides</h1>
        <button
          onClick={() => navigate('/style-guides/new')}
          className="btn btn-primary"
        >
          Create New
        </button>
      </div>

      <div className="grid gap-4">
        {guides.map((guide) => (
          <div
            key={guide.id}
            className="card border p-4 hover:shadow-lg cursor-pointer"
            onClick={() => navigate(`/style-guides/${guide.id}`)}
          >
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-lg font-semibold">{guide.name}</h3>
                <p className="text-gray-600">{guide.description}</p>
                <div className="flex gap-2 mt-2">
                  <span className="badge">v{guide.currentVersion}</span>
                  <span className="badge">{guide.source}</span>
                  <span className="badge">{guide.rules?.length || 0} rules</span>
                </div>
              </div>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  if (confirm('Delete this style guide?')) {
                    deleteGuide(guide.id);
                  }
                }}
                className="btn btn-sm btn-danger"
              >
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### 4. Add Routes

**File**: `src/frontend/src/App.tsx`

```typescript
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { StyleGuideList } from './components/StyleGuideList';
import { StyleGuideDetail } from './components/StyleGuideDetail';
import { StyleGuideForm } from './components/StyleGuideForm';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* ... existing routes ... */}
        <Route path="/style-guides" element={<StyleGuideList />} />
        <Route path="/style-guides/new" element={<StyleGuideForm />} />
        <Route path="/style-guides/:id" element={<StyleGuideDetail />} />
      </Routes>
    </BrowserRouter>
  );
}
```

---

## Phase 3: Testing

### 1. Unit Tests

**File**: `src/backend/tests/unit/styleGuideService.test.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { PrismaClient } from '@prisma/client';
import { StyleGuideService } from '../../src/services/styleGuideService';

describe('StyleGuideService', () => {
  let service: StyleGuideService;
  let prisma: PrismaClient;

  beforeEach(() => {
    prisma = new PrismaClient();
    service = new StyleGuideService(prisma);
  });

  it('should create a style guide', async () => {
    const data = {
      name: 'Test Guide',
      description: 'Test description',
      rules: [
        {
          name: 'Table Rule',
          entityType: 'TABLE',
          pattern: '^[A-Z][a-zA-Z0-9]*$',
          caseConvention: 'PascalCase',
        },
      ],
      userId: 'test-user-id',
    };

    const guide = await service.create(data);

    expect(guide.name).toBe('Test Guide');
    expect(guide.currentVersion).toBe('1.0.0');
    expect(guide.rules).toHaveLength(1);
  });

  it('should list style guides with pagination', async () => {
    const result = await service.findAll({ page: 1, limit: 10 });

    expect(result.data).toBeInstanceOf(Array);
    expect(result.pagination).toHaveProperty('page');
    expect(result.pagination).toHaveProperty('totalCount');
  });
});
```

### 2. Integration Tests

**File**: `src/backend/tests/integration/styleGuides.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { app } from '../../src/app';

describe('Style Guides API', () => {
  let authToken: string;

  beforeAll(async () => {
    // Get auth token
    const response = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'password' });
    authToken = response.body.token;
  });

  it('should create a style guide', async () => {
    const response = await request(app)
      .post('/api/style-guides')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        name: 'API Test Guide',
        description: 'Created via API test',
        rules: [
          {
            name: 'Test Rule',
            entityType: 'TABLE',
            pattern: '^[A-Z][a-zA-Z0-9]*$',
            caseConvention: 'PascalCase',
          },
        ],
      });

    expect(response.status).toBe(201);
    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data.name).toBe('API Test Guide');
  });

  it('should list style guides', async () => {
    const response = await request(app)
      .get('/api/style-guides')
      .set('Authorization', `Bearer ${authToken}`);

    expect(response.status).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
  });
});
```

---

## Next Steps

After completing this quick start:

1. **Implement versioning** - Add version control logic from `research.md`
2. **Add import/export** - Implement file upload and download
3. **Build validation** - Create schema validation service
4. **Enhance UI** - Add version history, diff viewer, validation reports

Refer to:
- `data-model.md` for complete database schema
- `contracts/openapi.yaml` for full API specification
- `research.md` for detailed implementation patterns

---

## Troubleshooting

### Database Migration Fails

```bash
# Reset database (⚠️ development only)
npx prisma migrate reset

# Regenerate client
npx prisma generate
```

### Type Errors in Frontend

```bash
# Regenerate Prisma client types
cd src/backend
npm run prisma:generate

# Update frontend types from API
cd src/frontend
npm run type-check
```

### API Returns 403 Forbidden

- Ensure user has ADMIN role for create/update/delete operations
- Check JWT token is valid and not expired
- Verify `roleCheck` middleware is working

---

## Additional Resources

- [Prisma Documentation](https://www.prisma.io/docs/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [React Router](https://reactrouter.com/)
- [Zustand State Management](https://docs.pmnd.rs/zustand/getting-started/introduction)
- [OpenAPI Specification](https://swagger.io/specification/)

---

**Status**: Ready for implementation  
**Estimated Time**: 2-3 weeks (full feature with all phases)
