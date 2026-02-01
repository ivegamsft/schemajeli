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
  const { email, password } = req.body;
  
  // Basic validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  
  // Mock authentication - in production, verify against database
  if (email === 'admin@schemajeli.com' && password === 'Admin@123') {
    const token = 'mock-jwt-token-' + Date.now();
    return res.json({ 
      accessToken: token,
      user: { email, id: '1', role: 'admin' }
    });
  }
  
  res.status(401).json({ error: 'Invalid credentials' });
  return;
});

app.post('/api/v1/auth/logout', (_req, res) => {
  res.json({ message: 'Logged out successfully' });
  return;
});

app.get('/api/v1/auth/verify', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  // Mock verification
  res.json({ valid: true, user: { email: 'admin@schemajeli.com' } });
  return;
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
