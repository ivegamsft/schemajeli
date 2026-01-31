import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service.js';
import { AuthRequest } from '../middleware/authenticate.js';

export class AuthController {
  /**
   * POST /auth/login
   * Authenticate user and return tokens
   */
  static async login(req: Request, res: Response) {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Username/email and password are required',
      });
    }

    const ipAddress = req.ip;
    const userAgent = req.get('user-agent');

    const result = await AuthService.login(
      identifier,
      password,
      ipAddress,
      userAgent
    );

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * POST /auth/refresh
   * Refresh access token using refresh token
   */
  static async refreshToken(req: Request, res: Response) {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        status: 'error',
        message: 'Refresh token is required',
      });
    }

    const result = await AuthService.refreshToken(refreshToken);

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * POST /auth/logout
   * Logout user (client-side token removal)
   */
  static async logout(req: AuthRequest, res: Response) {
    // In a stateless JWT setup, logout is primarily client-side
    // We just log the event for audit purposes
    if (req.user) {
      // Could add token to blacklist here if needed
      // For now, just return success
    }

    return res.status(200).json({
      status: 'success',
      message: 'Logged out successfully',
    });
  }

  /**
   * GET /auth/me
   * Get current authenticated user info
   */
  static async getCurrentUser(req: AuthRequest, res: Response) {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Not authenticated',
      });
    }

    return res.status(200).json({
      status: 'success',
      data: {
        user: req.user,
      },
    });
  }
}
