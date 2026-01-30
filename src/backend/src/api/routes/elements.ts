import { Router } from 'express';

const router = Router();

// Placeholder routes for servers, databases, tables, elements, search, abbreviations, reports
router.get('/', (req, res) => {
  res.status(501).json({ message: 'Endpoint - to be implemented' });
});

export default router;
