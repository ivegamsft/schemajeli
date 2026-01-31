import { Router } from 'express';
import { ElementController } from '../controllers/element.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All element routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/elements/stats
 * @desc    Get element statistics
 * @access  Protected (read permission)
 */
router.get('/stats', authorize('read'), ElementController.getElementStats);

/**
 * @route   POST /api/v1/elements
 * @desc    Create a new element (column)
 * @access  Protected (write permission)
 */
router.post('/', authorize('write'), ElementController.createElement);

/**
 * @route   GET /api/v1/elements
 * @desc    Get all elements with pagination and filtering
 * @access  Protected (read permission)
 */
router.get('/', authorize('read'), ElementController.getAllElements);

/**
 * @route   GET /api/v1/elements/:id
 * @desc    Get element by ID
 * @access  Protected (read permission)
 */
router.get('/:id', authorize('read'), ElementController.getElementById);

/**
 * @route   PUT /api/v1/elements/:id
 * @desc    Update element
 * @access  Protected (write permission)
 */
router.put('/:id', authorize('write'), ElementController.updateElement);

/**
 * @route   DELETE /api/v1/elements/:id
 * @desc    Delete element (soft delete)
 * @access  Protected (delete permission)
 */
router.delete('/:id', authorize('delete'), ElementController.deleteElement);

export default router;
