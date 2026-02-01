import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

type PaginationResult<T> = {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
};

const nowIso = () => new Date().toISOString();

const servers = [
  {
    id: '1',
    name: 'Primary PostgreSQL',
    host: 'postgres.local',
    port: 5432,
    rdbmsType: 'POSTGRESQL',
    description: 'Primary application database server',
    purpose: 'Production data',
    location: 'West Europe',
    adminContact: 'admin@schemajeli.com',
    isActive: true,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    deletedAt: null,
  },
];

const databases = [
  {
    id: '1',
    serverId: '1',
    name: 'schemajeli_dev',
    description: 'Development database',
    purpose: 'Dev/test data',
    isActive: true,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    deletedAt: null,
  },
];

const tables = [
  {
    id: '1',
    databaseId: '1',
    name: 'users',
    tableType: 'TABLE',
    description: 'Application users',
    rowCount: 3,
    isActive: true,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    deletedAt: null,
  },
];

const elements = [
  {
    id: '1',
    tableId: '1',
    name: 'email',
    dataType: 'varchar',
    length: 255,
    precision: null,
    scale: null,
    position: 1,
    isPrimaryKey: false,
    isForeignKey: false,
    isNullable: false,
    defaultValue: null,
    description: 'User email address',
    createdAt: nowIso(),
    updatedAt: nowIso(),
    deletedAt: null,
  },
];

const abbreviations = [
  {
    id: '1',
    abbreviation: 'DB',
    sourceWord: 'Database',
    primeClass: 'GENERAL',
    category: 'Data',
    definition: 'A structured collection of data',
    isPrimeClass: true,
    createdAt: nowIso(),
    updatedAt: nowIso(),
  },
];

const paginate = <T>(items: T[], page: number, limit: number): PaginationResult<T> => {
  const safePage = Number.isFinite(page) && page > 0 ? page : 1;
  const safeLimit = Number.isFinite(limit) && limit > 0 ? limit : 10;
  const start = (safePage - 1) * safeLimit;
  const data = items.slice(start, start + safeLimit);
  return {
    data,
    total: items.length,
    page: safePage,
    limit: safeLimit,
    totalPages: Math.max(1, Math.ceil(items.length / safeLimit)),
  };
};

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json());

// Health check endpoint
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.get('/api/v1', (_req, res) => {
  res.json({ message: 'SchemaJeli API v1', version: '1.0.0' });
});

// Statistics Routes
app.get('/api/v1/statistics/dashboard', (_req, res) => {
  return res.json({
    status: 'success',
    data: {
      totalServers: servers.length,
      totalDatabases: databases.length,
      totalTables: tables.length,
      totalElements: elements.length,
      serversByType: {
        POSTGRESQL: servers.filter((s) => s.rdbmsType === 'POSTGRESQL').length,
      },
    },
  });
});

// Servers Routes
app.get('/api/v1/servers', (req, res) => {
  const page = Number(req.query.page || 1);
  const limit = Number(req.query.limit || 10);
  return res.json({ status: 'success', data: paginate(servers, page, limit) });
});

app.get('/api/v1/servers/:id', (req, res) => {
  const server = servers.find((s) => s.id === req.params.id);
  if (!server) {
    return res.status(404).json({ status: 'error', message: 'Server not found' });
  }
  return res.json({ status: 'success', data: server });
});

app.post('/api/v1/servers', (req, res) => {
  const now = nowIso();
  const newServer = {
    id: String(servers.length + 1),
    isActive: true,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...req.body,
  };
  servers.push(newServer);
  return res.status(201).json({ status: 'success', data: newServer });
});

app.put('/api/v1/servers/:id', (req, res) => {
  const index = servers.findIndex((s) => s.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ status: 'error', message: 'Server not found' });
  }
  const updated = { ...servers[index], ...req.body, updatedAt: nowIso() };
  servers[index] = updated;
  return res.json({ status: 'success', data: updated });
});

app.delete('/api/v1/servers/:id', (req, res) => {
  const index = servers.findIndex((s) => s.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ status: 'error', message: 'Server not found' });
  }
  servers.splice(index, 1);
  return res.status(204).send();
});

// Databases Routes
app.get('/api/v1/databases', (req, res) => {
  const page = Number(req.query.page || 1);
  const limit = Number(req.query.limit || 10);
  const serverId = req.query.serverId ? String(req.query.serverId) : undefined;
  const filtered = serverId ? databases.filter((d) => d.serverId === serverId) : databases;
  return res.json({ status: 'success', data: paginate(filtered, page, limit) });
});

app.get('/api/v1/databases/:id', (req, res) => {
  const database = databases.find((d) => d.id === req.params.id);
  if (!database) {
    return res.status(404).json({ status: 'error', message: 'Database not found' });
  }
  return res.json({ status: 'success', data: database });
});

app.get('/api/v1/servers/:id/databases', (req, res) => {
  const serverDatabases = databases.filter((d) => d.serverId === req.params.id);
  return res.json({ status: 'success', data: serverDatabases });
});

app.post('/api/v1/databases', (req, res) => {
  const now = nowIso();
  const newDatabase = {
    id: String(databases.length + 1),
    isActive: true,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...req.body,
  };
  databases.push(newDatabase);
  return res.status(201).json({ status: 'success', data: newDatabase });
});

app.put('/api/v1/databases/:id', (req, res) => {
  const index = databases.findIndex((d) => d.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ status: 'error', message: 'Database not found' });
  }
  const updated = { ...databases[index], ...req.body, updatedAt: nowIso() };
  databases[index] = updated;
  return res.json({ status: 'success', data: updated });
});

app.delete('/api/v1/databases/:id', (req, res) => {
  const index = databases.findIndex((d) => d.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ status: 'error', message: 'Database not found' });
  }
  databases.splice(index, 1);
  return res.status(204).send();
});

// Tables Routes
app.get('/api/v1/tables', (req, res) => {
  const page = Number(req.query.page || 1);
  const limit = Number(req.query.limit || 10);
  const databaseId = req.query.databaseId ? String(req.query.databaseId) : undefined;
  const filtered = databaseId ? tables.filter((t) => t.databaseId === databaseId) : tables;
  return res.json({ status: 'success', data: paginate(filtered, page, limit) });
});

app.get('/api/v1/tables/:id', (req, res) => {
  const table = tables.find((t) => t.id === req.params.id);
  if (!table) {
    return res.status(404).json({ status: 'error', message: 'Table not found' });
  }
  return res.json({ status: 'success', data: table });
});

app.get('/api/v1/databases/:id/tables', (req, res) => {
  const databaseTables = tables.filter((t) => t.databaseId === req.params.id);
  return res.json({ status: 'success', data: databaseTables });
});

app.post('/api/v1/tables', (req, res) => {
  const now = nowIso();
  const newTable = {
    id: String(tables.length + 1),
    isActive: true,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...req.body,
  };
  tables.push(newTable);
  return res.status(201).json({ status: 'success', data: newTable });
});

app.put('/api/v1/tables/:id', (req, res) => {
  const index = tables.findIndex((t) => t.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ status: 'error', message: 'Table not found' });
  }
  const updated = { ...tables[index], ...req.body, updatedAt: nowIso() };
  tables[index] = updated;
  return res.json({ status: 'success', data: updated });
});

app.delete('/api/v1/tables/:id', (req, res) => {
  const index = tables.findIndex((t) => t.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ status: 'error', message: 'Table not found' });
  }
  tables.splice(index, 1);
  return res.status(204).send();
});

// Search Routes
app.get('/api/v1/search', (req, res) => {
  const q = String(req.query.q || '').toLowerCase();
  const matchedTables = tables.filter((t) => t.name.toLowerCase().includes(q));
  const matchedElements = elements.filter((e) => e.name.toLowerCase().includes(q));
  const matchedAbbreviations = abbreviations.filter((a) =>
    a.abbreviation.toLowerCase().includes(q)
  );
  return res.json({
    status: 'success',
    data: {
      elements: matchedElements,
      tables: matchedTables,
      abbreviations: matchedAbbreviations,
      totalResults: matchedElements.length + matchedTables.length + matchedAbbreviations.length,
    },
  });
});

app.get('/api/v1/elements/search', (req, res) => {
  const q = String(req.query.q || '').toLowerCase();
  const matched = elements.filter((e) => e.name.toLowerCase().includes(q));
  return res.json({ status: 'success', data: matched });
});

app.get('/api/v1/tables/search', (req, res) => {
  const q = String(req.query.q || '').toLowerCase();
  const matched = tables.filter((t) => t.name.toLowerCase().includes(q));
  return res.json({ status: 'success', data: matched });
});

app.get('/api/v1/abbreviations/search', (req, res) => {
  const q = String(req.query.q || '').toLowerCase();
  const matched = abbreviations.filter((a) =>
    a.abbreviation.toLowerCase().includes(q)
  );
  return res.json({ status: 'success', data: matched });
});

// Abbreviations Routes (raw responses expected by frontend)
app.get('/api/v1/abbreviations', (req, res) => {
  const page = Number(req.query.page || 1);
  const limit = Number(req.query.limit || 10);
  const paged = paginate(abbreviations, page, limit);
  return res.json({ data: paged.data, totalPages: paged.totalPages });
});

app.get('/api/v1/abbreviations/:id', (req, res) => {
  const abbreviation = abbreviations.find((a) => a.id === req.params.id);
  if (!abbreviation) {
    return res.status(404).json({ message: 'Abbreviation not found' });
  }
  return res.json(abbreviation);
});

app.post('/api/v1/abbreviations', (req, res) => {
  const now = nowIso();
  const newAbbreviation = {
    id: String(abbreviations.length + 1),
    sourceWord: req.body?.meaning || req.body?.sourceWord || 'N/A',
    primeClass: req.body?.primeClass || 'GENERAL',
    category: req.body?.category || 'General',
    definition: req.body?.meaning || req.body?.definition || '',
    isPrimeClass: false,
    createdAt: now,
    updatedAt: now,
    ...req.body,
  };
  abbreviations.push(newAbbreviation);
  return res.status(201).json(newAbbreviation);
});

app.put('/api/v1/abbreviations/:id', (req, res) => {
  const index = abbreviations.findIndex((a) => a.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Abbreviation not found' });
  }
  const updated = { ...abbreviations[index], ...req.body, updatedAt: nowIso() };
  abbreviations[index] = updated;
  return res.json(updated);
});

app.delete('/api/v1/abbreviations/:id', (req, res) => {
  const index = abbreviations.findIndex((a) => a.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Abbreviation not found' });
  }
  abbreviations.splice(index, 1);
  return res.status(204).send();
});

// Auth Routes
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body as { email?: string; password?: string };

  // Basic validation
  if (!email || !password) {
    return res.status(400).json({ status: 'error', message: 'Email and password are required' });
  }

  // Mock authentication - in production, verify against database
  if (email === 'admin@schemajeli.com' && password === 'Admin@123') {
    const now = new Date().toISOString();
    const accessToken = `mock-jwt-token-${Date.now()}`;
    const refreshToken = `mock-refresh-token-${Date.now()}`;
    return res.json({
      status: 'success',
      data: {
        user: {
          id: '1',
          email,
          firstName: 'Admin',
          lastName: 'User',
          role: 'ADMIN',
          isActive: true,
          lastLogin: now,
          createdAt: now,
          updatedAt: now,
        },
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  }

  return res.status(401).json({ status: 'error', message: 'Invalid credentials' });
});

app.post('/api/v1/auth/logout', (_req, res) => {
  return res.json({ status: 'success', data: { message: 'Logged out successfully' } });
});

app.get('/api/v1/auth/verify', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ status: 'error', message: 'No token provided' });
  }

  // Mock verification
  return res.json({
    status: 'success',
    data: {
      valid: true,
      user: { email: 'admin@schemajeli.com' },
    },
  });
});

app.post('/api/v1/auth/refresh', (req, res) => {
  const { refreshToken } = req.body as { refreshToken?: string };
  if (!refreshToken) {
    return res.status(400).json({ status: 'error', message: 'Refresh token required' });
  }

  const accessToken = `mock-jwt-token-${Date.now()}`;
  return res.json({ status: 'success', data: { accessToken } });
});

app.get('/api/v1/auth/me', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ status: 'error', message: 'No token provided' });
  }

  const now = new Date().toISOString();
  return res.json({
    status: 'success',
    data: {
      id: '1',
      email: 'admin@schemajeli.com',
      firstName: 'Admin',
      lastName: 'User',
      role: 'ADMIN',
      isActive: true,
      lastLogin: now,
      createdAt: now,
      updatedAt: now,
    },
  });
});

// Error handling middleware
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Backend server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
});

export default app;
