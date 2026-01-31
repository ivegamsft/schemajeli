import { Router } from 'express';
import { SearchController } from '../controllers/search.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All search routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/search
 * @desc    Search across all entity types
 * @access  Protected (read permission)
 */
router.get('/', authorize('read'), SearchController.searchAll);

/**
 * @route   GET /api/v1/search/servers
 * @desc    Search servers
 * @access  Protected (read permission)
 */
router.get('/servers', authorize('read'), SearchController.searchServers);

/**
 * @route   GET /api/v1/search/databases
 * @desc    Search databases
 * @access  Protected (read permission)
 */
router.get('/databases', authorize('read'), SearchController.searchDatabases);

/**
 * @route   GET /api/v1/search/tables
 * @desc    Search tables
 * @access  Protected (read permission)
 */
router.get('/tables', authorize('read'), SearchController.searchTables);

/**
 * @route   GET /api/v1/search/elements
 * @desc    Search elements (columns)
 * @access  Protected (read permission)
 */
router.get('/elements', authorize('read'), SearchController.searchElements);

/**
 * @route   GET /api/v1/search/abbreviations
 * @desc    Search abbreviations
 * @access  Protected (read permission)
 */
router.get(
  '/abbreviations',
  authorize('read'),
  SearchController.searchAbbreviations
);

export default router;
