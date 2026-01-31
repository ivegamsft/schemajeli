import { Router } from 'express';
import { ServerController } from '../controllers/server.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All server routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/servers/stats
 * @desc    Get server statistics
 * @access  Protected (read permission)
 */
router.get('/stats', authorize('read'), ServerController.getServerStats);

/**
 * @route   POST /api/v1/servers
 * @desc    Create a new server
 * @access  Protected (write permission)
 */
router.post('/', authorize('write'), ServerController.createServer);

/**
 * @route   GET /api/v1/servers
 * @desc    Get all servers with pagination and filtering
 * @access  Protected (read permission)
 */
router.get('/', authorize('read'), ServerController.getAllServers);

/**
 * @route   GET /api/v1/servers/:id
 * @desc    Get server by ID
 * @access  Protected (read permission)
 */
router.get('/:id', authorize('read'), ServerController.getServerById);

/**
 * @route   PUT /api/v1/servers/:id
 * @desc    Update server
 * @access  Protected (write permission)
 */
router.put('/:id', authorize('write'), ServerController.updateServer);

/**
 * @route   DELETE /api/v1/servers/:id
 * @desc    Delete server (soft delete)
 * @access  Protected (delete permission)
 */
router.delete('/:id', authorize('delete'), ServerController.deleteServer);

export default router;
