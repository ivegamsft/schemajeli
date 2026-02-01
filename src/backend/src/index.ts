import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

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
