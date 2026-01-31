import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller.js';
import { authenticate } from '../middleware/authenticate.js';

const router = Router();

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login with username/email and password
 * @access  Public
 */
router.post('/login', AuthController.login);

/**
 * @route   POST /api/v1/auth/refresh
 * @desc    Refresh access token
 * @access  Public
 */
router.post('/refresh', AuthController.refreshToken);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout current user
 * @access  Protected
 */
router.post('/logout', authenticate, AuthController.logout);

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current user information
 * @access  Protected
 */
router.get('/me', authenticate, AuthController.getCurrentUser);

export default router;
