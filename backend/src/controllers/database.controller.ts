import { Response } from 'express';
import { DatabaseService } from '../services/database.service.js';
import { AuthRequest } from '../middleware/authenticate.js';
import { EntityStatus } from '@prisma/client';

export class DatabaseController {
  /**
   * POST /databases
   * Create a new database
   */
  static async createDatabase(req: AuthRequest, res: Response) {
    const { serverId, name, description, purpose, status } = req.body;

    if (!serverId || !name) {
      return res.status(400).json({
        status: 'error',
        message: 'Server ID and database name are required',
      });
    }

    const database = await DatabaseService.createDatabase(
      { serverId, name, description, purpose, status },
      req.user!.id
    );

    return res.status(201).json({
      status: 'success',
      data: { database },
    });
  }

  /**
   * GET /databases
   * Get all databases with pagination and filtering
   */
  static async getAllDatabases(req: AuthRequest, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const filter = {
      search: req.query.search as string,
      status: req.query.status as EntityStatus,
      serverId: req.query.serverId as string,
    };

    const result = await DatabaseService.getAllDatabases(page, limit, filter);

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /servers/:serverId/databases
   * Get all databases for a specific server
   */
  static async getDatabasesByServerId(req: AuthRequest, res: Response) {
    const { serverId } = req.params;

    const databases = await DatabaseService.getDatabasesByServerId(serverId);

    return res.status(200).json({
      status: 'success',
      data: { databases },
    });
  }

  /**
   * GET /databases/:id
   * Get database by ID
   */
  static async getDatabaseById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const database = await DatabaseService.getDatabaseById(id);

    return res.status(200).json({
      status: 'success',
      data: { database },
    });
  }

  /**
   * PUT /databases/:id
   * Update database
   */
  static async updateDatabase(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, description, purpose, status } = req.body;

    const database = await DatabaseService.updateDatabase(
      id,
      { name, description, purpose, status },
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: { database },
    });
  }

  /**
   * DELETE /databases/:id
   * Delete database (soft delete)
   */
  static async deleteDatabase(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const database = await DatabaseService.deleteDatabase(id, req.user!.id);

    return res.status(200).json({
      status: 'success',
      data: { database },
    });
  }
}
