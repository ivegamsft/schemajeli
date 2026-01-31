import { Router } from 'express';
import { UserController } from '../controllers/user.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All user routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/v1/users
 * @desc    Create a new user
 * @access  Protected (ADMIN only)
 */
router.post('/', authorize('admin'), UserController.createUser);

/**
 * @route   GET /api/v1/users
 * @desc    Get all users with pagination
 * @access  Protected (ADMIN only)
 */
router.get('/', authorize('admin'), UserController.getAllUsers);

/**
 * @route   GET /api/v1/users/:id
 * @desc    Get user by ID
 * @access  Protected (ADMIN only)
 */
router.get('/:id', authorize('admin'), UserController.getUserById);

/**
 * @route   PUT /api/v1/users/:id
 * @desc    Update user
 * @access  Protected (ADMIN only)
 */
router.put('/:id', authorize('admin'), UserController.updateUser);

/**
 * @route   DELETE /api/v1/users/:id
 * @desc    Delete (deactivate) user
 * @access  Protected (ADMIN only)
 */
router.delete('/:id', authorize('admin'), UserController.deleteUser);

/**
 * @route   POST /api/v1/users/change-password
 * @desc    Change current user's password
 * @access  Protected
 */
router.post('/change-password', UserController.changePassword);

export default router;
