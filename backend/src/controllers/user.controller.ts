import { Response } from 'express';
import { UserService } from '../services/user.service.js';
import { AuthRequest } from '../middleware/authenticate.js';

export class UserController {
  /**
   * POST /users
   * Create a new user
   */
  static async createUser(req: AuthRequest, res: Response) {
    const { username, email, password, fullName, role } = req.body;

    if (!username || !email || !password || !fullName) {
      return res.status(400).json({
        status: 'error',
        message: 'Username, email, password, and full name are required',
      });
    }

    const user = await UserService.createUser(
      { username, email, password, fullName, role },
      req.user!.id
    );

    return res.status(201).json({
      status: 'success',
      data: { user },
    });
  }

  /**
   * GET /users
   * Get all users with pagination
   */
  static async getAllUsers(req: AuthRequest, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const result = await UserService.getAllUsers(page, limit);

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /users/:id
   * Get user by ID
   */
  static async getUserById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const user = await UserService.getUserById(id);

    return res.status(200).json({
      status: 'success',
      data: { user },
    });
  }

  /**
   * PUT /users/:id
   * Update user
   */
  static async updateUser(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { email, fullName, role, isActive } = req.body;

    const user = await UserService.updateUser(
      id,
      { email, fullName, role, isActive },
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: { user },
    });
  }

  /**
   * DELETE /users/:id
   * Delete (deactivate) user
   */
  static async deleteUser(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const user = await UserService.deleteUser(id, req.user!.id);

    return res.status(200).json({
      status: 'success',
      data: { user },
    });
  }

  /**
   * POST /users/change-password
   * Change current user's password
   */
  static async changePassword(req: AuthRequest, res: Response) {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({
        status: 'error',
        message: 'Old password and new password are required',
      });
    }

    const result = await UserService.changePassword(
      req.user!.id,
      oldPassword,
      newPassword
    );

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }
}
