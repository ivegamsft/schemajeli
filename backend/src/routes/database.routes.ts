import { Router } from 'express';
import { DatabaseController } from '../controllers/database.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All database routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/v1/databases
 * @desc    Create a new database
 * @access  Protected (write permission)
 */
router.post('/', authorize('write'), DatabaseController.createDatabase);

/**
 * @route   GET /api/v1/databases
 * @desc    Get all databases with pagination and filtering
 * @access  Protected (read permission)
 */
router.get('/', authorize('read'), DatabaseController.getAllDatabases);

/**
 * @route   GET /api/v1/databases/:id
 * @desc    Get database by ID
 * @access  Protected (read permission)
 */
router.get('/:id', authorize('read'), DatabaseController.getDatabaseById);

/**
 * @route   PUT /api/v1/databases/:id
 * @desc    Update database
 * @access  Protected (write permission)
 */
router.put('/:id', authorize('write'), DatabaseController.updateDatabase);

/**
 * @route   DELETE /api/v1/databases/:id
 * @desc    Delete database (soft delete)
 * @access  Protected (delete permission)
 */
router.delete('/:id', authorize('delete'), DatabaseController.deleteDatabase);

export default router;
