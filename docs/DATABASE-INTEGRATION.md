# Implementation Guide: Database Integration

## Step 1: Install Dependencies

The required packages are already in package.json, but ensure they're installed:

```bash
cd src/backend
npm install jwks-rsa
npm install --save-dev @types/jwks-rsa
```

## Step 2: Update Docker Compose

Ensure your docker-compose.yml has the correct environment variables:

```yaml
services:
  postgres:
    # ... existing config

  backend:
    # ... existing config
    environment:
      DATABASE_URL: "postgresql://postgres:postgres@postgres:5432/schemajeli"
      AZURE_TENANT_ID: "${AZURE_TENANT_ID}"
      AZURE_CLIENT_ID: "${AZURE_CLIENT_ID}"
      AZURE_CLIENT_SECRET: "${AZURE_CLIENT_SECRET}"
      JWT_AUDIENCE: "api://${AZURE_CLIENT_ID}"
      JWT_ISSUER: "https://sts.windows.net/${AZURE_TENANT_ID}/"
    depends_on:
      postgres:
        condition: service_healthy
```

## Step 3: Initialize Database

```bash
cd src/backend

# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init

# Seed the database with sample data
npx prisma db seed
```

## Step 4: Replace Mock Data with Prisma

### Create Prisma Client Instance

Create `src/backend/src/db/prisma.ts`:

```typescript
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

// Graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});
```

### Update index.ts

Replace the mock data arrays (lines 1-137 in current index.ts) with Prisma imports:

```typescript
import express from 'express';
import cors from 'cors';
import { prisma } from './db/prisma';
import { authenticateJWT, requireRole } from './middleware/auth';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({ origin: process.env.CORS_ORIGIN || 'http://localhost:8081' }));
app.use(express.json());

// Health check
app.get('/health', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ status: 'healthy', database: 'connected' });
  } catch (error) {
    res.status(503).json({ status: 'unhealthy', database: 'disconnected' });
  }
});

// Auth endpoints (login handled by Entra ID)
app.post('/api/v1/auth/login', (req, res) => {
  res.json({
    status: 'success',
    message: 'Use Azure Entra ID authentication',
    authUrl: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}/oauth2/v2.0/authorize?client_id=${process.env.AZURE_CLIENT_ID}&response_type=code&redirect_uri=${process.env.CORS_ORIGIN}&scope=openid%20profile%20email`,
  });
});

app.get('/api/v1/auth/verify', authenticateJWT, (req, res) => {
  res.json({
    status: 'success',
    data: {
      user: req.user,
    },
  });
});

app.get('/api/v1/auth/me', authenticateJWT, (req, res) => {
  res.json({
    status: 'success',
    data: { user: req.user },
  });
});

// Statistics endpoint
app.get('/api/v1/statistics/dashboard', authenticateJWT, async (req, res) => {
  const [serverCount, databaseCount, tableCount, elementCount] = await Promise.all([
    prisma.server.count(),
    prisma.database.count(),
    prisma.table.count(),
    prisma.element.count(),
  ]);

  const serversByType = await prisma.server.groupBy({
    by: ['rdbmsType'],
    _count: true,
  });

  res.json({
    status: 'success',
    data: {
      servers: {
        total: serverCount,
        byType: Object.fromEntries(serversByType.map(s => [s.rdbmsType, s._count])),
      },
      databases: { total: databaseCount },
      tables: { total: tableCount },
      elements: { total: elementCount },
    },
  });
});

// Server endpoints
app.get('/api/v1/servers', authenticateJWT, async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const skip = (page - 1) * limit;

  const [servers, total] = await Promise.all([
    prisma.server.findMany({
      skip,
      take: limit,
      where: { deletedAt: null },
      orderBy: { createdAt: 'desc' },
    }),
    prisma.server.count({ where: { deletedAt: null } }),
  ]);

  res.json({
    status: 'success',
    data: servers,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  });
});

app.get('/api/v1/servers/:id', authenticateJWT, async (req, res) => {
  const server = await prisma.server.findUnique({
    where: { id: req.params.id },
  });

  if (!server || server.deletedAt) {
    return res.status(404).json({
      status: 'error',
      message: 'Server not found',
    });
  }

  res.json({ status: 'success', data: server });
});

app.post('/api/v1/servers', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  const server = await prisma.server.create({
    data: req.body,
  });

  res.status(201).json({ status: 'success', data: server });
});

app.put('/api/v1/servers/:id', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  const server = await prisma.server.update({
    where: { id: req.params.id },
    data: req.body,
  });

  res.json({ status: 'success', data: server });
});

app.delete('/api/v1/servers/:id', authenticateJWT, requireRole('Admin'), async (req, res) => {
  await prisma.server.update({
    where: { id: req.params.id },
    data: { deletedAt: new Date() },
  });

  res.json({ status: 'success', message: 'Server deleted' });
});

// Similar patterns for databases, tables, elements, abbreviations...
// (Continue with all other endpoints following the same pattern)

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
```

## Step 5: Update Tests

Update tests to use Prisma and test database:

```typescript
import { beforeAll, afterAll, beforeEach } from 'vitest';
import { prisma } from '../src/db/prisma';

beforeAll(async () => {
  // Connect to test database
  await prisma.$connect();
});

afterAll(async () => {
  // Cleanup and disconnect
  await prisma.$disconnect();
});

beforeEach(async () => {
  // Clear all data between tests
  await prisma.element.deleteMany();
  await prisma.table.deleteMany();
  await prisma.database.deleteMany();
  await prisma.server.deleteMany();
});
```

## Step 6: Test the Integration

```bash
# Start Docker Compose
docker compose up -d

# Check backend logs
docker compose logs -f backend

# Test API endpoints
curl http://localhost:8080/health
curl http://localhost:8080/api/v1/servers
```

## Step 7: Run Tests

```bash
cd src/backend
npm test
```

## Next Steps

1. ✅ Database connected with Prisma
2. → Implement Entra ID authentication
3. → Add RBAC middleware to all endpoints
4. → Update frontend to use MSAL
5. → Deploy to Azure
