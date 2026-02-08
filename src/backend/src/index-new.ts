import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import { prisma } from './db/prisma.js';
import { authenticateJWT, requireRole } from './middleware/auth.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:8081',
  credentials: true,
}));
app.use(express.json());

// Health check endpoint with database connectivity test
app.get('/health', async (_req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({ 
      status: 'healthy', 
      timestamp: new Date().toISOString(),
      database: 'connected'
    });
  } catch (error) {
    res.status(503).json({ 
      status: 'unhealthy', 
      timestamp: new Date().toISOString(),
      database: 'disconnected'
    });
  }
});

// API Routes
app.get('/api/v1', (_req, res) => {
  res.json({ message: 'SchemaJeli API v1', version: '1.0.0' });
});

// Auth Routes
app.post('/api/v1/auth/login', (_req, res) => {
  // Authentication is handled by Azure Entra ID
  res.json({
    status: 'success',
    message: 'Use Azure Entra ID for authentication',
    authUrl: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}/oauth2/v2.0/authorize`,
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

app.post('/api/v1/auth/logout', (_req, res) => {
  res.json({ status: 'success', message: 'Logged out' });
});

app.post('/api/v1/auth/refresh', (_req, res) => {
  res.json({ status: 'success', message: 'Token refresh handled by MSAL' });
});

// Statistics Routes
app.get('/api/v1/statistics/dashboard', authenticateJWT, async (_req, res) => {
  try {
    const [serverCount, databaseCount, tableCount, elementCount] = await Promise.all([
      prisma.server.count({ where: { deletedAt: null } }),
      prisma.database.count({ where: { deletedAt: null } }),
      prisma.table.count({ where: { deletedAt: null } }),
      prisma.element.count({ where: { deletedAt: null } }),
    ]);

    const serversByType = await prisma.server.groupBy({
      by: ['rdbmsType'],
      where: { deletedAt: null },
      _count: true,
    });

    const stats = {
      totalServers: serverCount,
      totalDatabases: databaseCount,
      totalTables: tableCount,
      totalElements: elementCount,
      serversByType: Object.fromEntries(
        serversByType.map(s => [s.rdbmsType, s._count])
      ),
    };

    return res.json({
      status: 'success',
      data: stats,
    });
  } catch (error) {
    console.error('Statistics error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch statistics',
    });
  }
});

// Servers Routes
app.get('/api/v1/servers', authenticateJWT, async (req, res) => {
  try {
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

    return res.json({
      status: 'success',
      data: servers,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    console.error('Servers fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch servers',
    });
  }
});

app.get('/api/v1/servers/:id', authenticateJWT, async (req, res) => {
  try {
    const server = await prisma.server.findUnique({
      where: { id: req.params.id },
      include: {
        databases: { where: { deletedAt: null } },
      },
    });

    if (!server || server.deletedAt) {
      return res.status(404).json({
        status: 'error',
        message: 'Server not found',
      });
    }

    return res.json({ status: 'success', data: server });
  } catch (error) {
    console.error('Server fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch server',
    });
  }
});

app.post('/api/v1/servers', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  try {
    const server = await prisma.server.create({
      data: req.body,
    });

    return res.status(201).json({ status: 'success', data: server });
  } catch (error) {
    console.error('Server create error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to create server',
    });
  }
});

app.put('/api/v1/servers/:id', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  try {
    const server = await prisma.server.update({
      where: { id: req.params.id },
      data: req.body,
    });

    return res.json({ status: 'success', data: server });
  } catch (error) {
    console.error('Server update error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to update server',
    });
  }
});

app.delete('/api/v1/servers/:id', authenticateJWT, requireRole('Admin'), async (req, res) => {
  try {
    await prisma.server.update({
      where: { id: req.params.id },
      data: { deletedAt: new Date() },
    });

    return res.json({ status: 'success', message: 'Server deleted' });
  } catch (error) {
    console.error('Server delete error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to delete server',
    });
  }
});

// Databases Routes
app.get('/api/v1/databases', authenticateJWT, async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const serverId = req.query.serverId as string | undefined;

    const where = { 
      deletedAt: null,
      ...(serverId && { serverId }),
    };

    const [databases, total] = await Promise.all([
      prisma.database.findMany({
        skip,
        take: limit,
        where,
        include: { server: true },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.database.count({ where }),
    ]);

    return res.json({
      status: 'success',
      data: databases,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    console.error('Databases fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch databases',
    });
  }
});

app.get('/api/v1/databases/:id', authenticateJWT, async (req, res) => {
  try {
    const database = await prisma.database.findUnique({
      where: { id: req.params.id },
      include: {
        server: true,
        tables: { where: { deletedAt: null } },
      },
    });

    if (!database || database.deletedAt) {
      return res.status(404).json({
        status: 'error',
        message: 'Database not found',
      });
    }

    return res.json({ status: 'success', data: database });
  } catch (error) {
    console.error('Database fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch database',
    });
  }
});

app.post('/api/v1/databases', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  try {
    const database = await prisma.database.create({
      data: req.body,
    });

    return res.status(201).json({ status: 'success', data: database });
  } catch (error) {
    console.error('Database create error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to create database',
    });
  }
});

app.put('/api/v1/databases/:id', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  try {
    const database = await prisma.database.update({
      where: { id: req.params.id },
      data: req.body,
    });

    return res.json({ status: 'success', data: database });
  } catch (error) {
    console.error('Database update error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to update database',
    });
  }
});

app.delete('/api/v1/databases/:id', authenticateJWT, requireRole('Admin'), async (req, res) => {
  try {
    await prisma.database.update({
      where: { id: req.params.id },
      data: { deletedAt: new Date() },
    });

    return res.json({ status: 'success', message: 'Database deleted' });
  } catch (error) {
    console.error('Database delete error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to delete database',
    });
  }
});

// Tables Routes
app.get('/api/v1/tables', authenticateJWT, async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const databaseId = req.query.databaseId as string | undefined;

    const where = {
      deletedAt: null,
      ...(databaseId && { databaseId }),
    };

    const [tables, total] = await Promise.all([
      prisma.table.findMany({
        skip,
        take: limit,
        where,
        include: { database: { include: { server: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.table.count({ where }),
    ]);

    return res.json({
      status: 'success',
      data: tables,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    console.error('Tables fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch tables',
    });
  }
});

app.get('/api/v1/tables/:id', authenticateJWT, async (req, res) => {
  try {
    const table = await prisma.table.findUnique({
      where: { id: req.params.id },
      include: {
        database: { include: { server: true } },
        elements: { where: { deletedAt: null } },
      },
    });

    if (!table || table.deletedAt) {
      return res.status(404).json({
        status: 'error',
        message: 'Table not found',
      });
    }

    return res.json({ status: 'success', data: table });
  } catch (error) {
    console.error('Table fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch table',
    });
  }
});

app.post('/api/v1/tables', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  try {
    const table = await prisma.table.create({
      data: req.body,
    });

    return res.status(201).json({ status: 'success', data: table });
  } catch (error) {
    console.error('Table create error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to create table',
    });
  }
});

app.put('/api/v1/tables/:id', authenticateJWT, requireRole('Admin', 'Maintainer'), async (req, res) => {
  try {
    const table = await prisma.table.update({
      where: { id: req.params.id },
      data: req.body,
    });

    return res.json({ status: 'success', data: table });
  } catch (error) {
    console.error('Table update error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to update table',
    });
  }
});

app.delete('/api/v1/tables/:id', authenticateJWT, requireRole('Admin'), async (req, res) => {
  try {
    await prisma.table.update({
      where: { id: req.params.id },
      data: { deletedAt: new Date() },
    });

    return res.json({ status: 'success', message: 'Table deleted' });
  } catch (error) {
    console.error('Table delete error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to delete table',
    });
  }
});

// Abbreviations Routes
app.get('/api/v1/abbreviations', authenticateJWT, async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    const [abbreviations, total] = await Promise.all([
      prisma.abbreviation.findMany({
        skip,
        take: limit,
        orderBy: { abbreviation: 'asc' },
      }),
      prisma.abbreviation.count(),
    ]);

    // Legacy format for frontend compatibility
    return res.json({
      data: abbreviations,
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    console.error('Abbreviations fetch error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch abbreviations',
    });
  }
});

// Search Routes
app.get('/api/v1/search', authenticateJWT, async (req, res) => {
  try {
    const query = req.query.q as string || '';
    const type = req.query.type as string || 'all';

    const results: any = {};

    if (type === 'all' || type === 'servers') {
      results.servers = await prisma.server.findMany({
        where: {
          deletedAt: null,
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: 10,
      });
    }

    if (type === 'all' || type === 'databases') {
      results.databases = await prisma.database.findMany({
        where: {
          deletedAt: null,
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: 10,
        include: { server: true },
      });
    }

    if (type === 'all' || type === 'tables') {
      results.tables = await prisma.table.findMany({
        where: {
          deletedAt: null,
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: 10,
        include: { database: { include: { server: true } } },
      });
    }

    if (type === 'all' || type === 'elements') {
      results.elements = await prisma.element.findMany({
        where: {
          deletedAt: null,
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: 10,
        include: { table: true },
      });
    }

    return res.json({ status: 'success', data: results });
  } catch (error) {
    console.error('Search error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Search failed',
    });
  }
});

app.get('/api/v1/elements/search', authenticateJWT, async (req, res) => {
  try {
    const query = req.query.q as string || '';
    const elements = await prisma.element.findMany({
      where: {
        deletedAt: null,
        name: { contains: query, mode: 'insensitive' },
      },
      take: 20,
      include: { table: { include: { database: { include: { server: true } } } } },
    });

    return res.json({ status: 'success', data: elements });
  } catch (error) {
    console.error('Elements search error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Element search failed',
    });
  }
});

app.get('/api/v1/tables/search', authenticateJWT, async (req, res) => {
  try {
    const query = req.query.q as string || '';
    const tables = await prisma.table.findMany({
      where: {
        deletedAt: null,
        name: { contains: query, mode: 'insensitive' },
      },
      take: 20,
      include: { database: { include: { server: true } } },
    });

    return res.json({ status: 'success', data: tables });
  } catch (error) {
    console.error('Tables search error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Table search failed',
    });
  }
});

app.get('/api/v1/abbreviations/search', authenticateJWT, async (req, res) => {
  try {
    const query = req.query.q as string || '';
    const abbreviations = await prisma.abbreviation.findMany({
      where: {
        OR: [
          { abbreviation: { contains: query, mode: 'insensitive' } },
            { source: { contains: query, mode: 'insensitive' } },
        ],
      },
      take: 20,
    });

    return res.json({ status: 'success', data: abbreviations });
  } catch (error) {
    console.error('Abbreviations search error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Abbreviation search failed',
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 SchemaJeli API server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📚 API v1: http://localhost:${PORT}/api/v1`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});
