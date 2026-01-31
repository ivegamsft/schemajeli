import { Router } from 'express';
import { TableController } from '../controllers/table.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All table routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/tables/stats
 * @desc    Get table statistics
 * @access  Protected (read permission)
 */
router.get('/stats', authorize('read'), TableController.getTableStats);

/**
 * @route   POST /api/v1/tables
 * @desc    Create a new table
 * @access  Protected (write permission)
 */
router.post('/', authorize('write'), TableController.createTable);

/**
 * @route   GET /api/v1/tables
 * @desc    Get all tables with pagination and filtering
 * @access  Protected (read permission)
 */
router.get('/', authorize('read'), TableController.getAllTables);

/**
 * @route   GET /api/v1/tables/:id
 * @desc    Get table by ID
 * @access  Protected (read permission)
 */
router.get('/:id', authorize('read'), TableController.getTableById);

/**
 * @route   PUT /api/v1/tables/:id
 * @desc    Update table
 * @access  Protected (write permission)
 */
router.put('/:id', authorize('write'), TableController.updateTable);

/**
 * @route   DELETE /api/v1/tables/:id
 * @desc    Delete table (soft delete)
 * @access  Protected (delete permission)
 */
router.delete('/:id', authorize('delete'), TableController.deleteTable);

export default router;
