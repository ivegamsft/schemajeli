import { Router } from 'express';
import authRoutes from './routes/auth';
import userRoutes from './routes/users';
import serverRoutes from './routes/servers';
import databaseRoutes from './routes/databases';
import tableRoutes from './routes/tables';
import elementRoutes from './routes/elements';
import searchRoutes from './routes/search';
import abbreviationRoutes from './routes/abbreviations';
import reportRoutes from './routes/reports';

const router = Router();

// API status endpoint
router.get('/status', (req, res) => {
  res.json({
    name: 'SchemaJeli API',
    version: '1.0.0',
    status: 'operational',
    timestamp: new Date().toISOString()
  });
});

// Mount route modules
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/servers', serverRoutes);
router.use('/databases', databaseRoutes);
router.use('/tables', tableRoutes);
router.use('/elements', elementRoutes);
router.use('/search', searchRoutes);
router.use('/abbreviations', abbreviationRoutes);
router.use('/reports', reportRoutes);

export default router;
