import { Response } from 'express';
import { TableService } from '../services/table.service.js';
import { AuthRequest } from '../middleware/authenticate.js';
import { TableType, EntityStatus } from '@prisma/client';

export class TableController {
  /**
   * POST /tables
   * Create a new table
   */
  static async createTable(req: AuthRequest, res: Response) {
    const { databaseId, name, description, tableType, rowCountEstimate, status } = req.body;

    if (!databaseId || !name) {
      return res.status(400).json({
        status: 'error',
        message: 'Database ID and table name are required',
      });
    }

    const table = await TableService.createTable(
      { databaseId, name, description, tableType, rowCountEstimate, status },
      req.user!.id
    );

    return res.status(201).json({
      status: 'success',
      data: { table },
    });
  }

  /**
   * GET /tables
   * Get all tables with pagination and filtering
   */
  static async getAllTables(req: AuthRequest, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const filter = {
      search: req.query.search as string,
      tableType: req.query.tableType as TableType,
      status: req.query.status as EntityStatus,
      databaseId: req.query.databaseId as string,
    };

    const result = await TableService.getAllTables(page, limit, filter);

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /databases/:databaseId/tables
   * Get all tables for a specific database
   */
  static async getTablesByDatabaseId(req: AuthRequest, res: Response) {
    const { databaseId } = req.params;

    const tables = await TableService.getTablesByDatabaseId(databaseId);

    return res.status(200).json({
      status: 'success',
      data: { tables },
    });
  }

  /**
   * GET /tables/:id
   * Get table by ID
   */
  static async getTableById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const table = await TableService.getTableById(id);

    return res.status(200).json({
      status: 'success',
      data: { table },
    });
  }

  /**
   * PUT /tables/:id
   * Update table
   */
  static async updateTable(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, description, tableType, rowCountEstimate, status } = req.body;

    const table = await TableService.updateTable(
      id,
      { name, description, tableType, rowCountEstimate, status },
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: { table },
    });
  }

  /**
   * DELETE /tables/:id
   * Delete table (soft delete)
   */
  static async deleteTable(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const table = await TableService.deleteTable(id, req.user!.id);

    return res.status(200).json({
      status: 'success',
      data: { table },
    });
  }

  /**
   * GET /tables/stats
   * Get table statistics
   */
  static async getTableStats(_req: AuthRequest, res: Response) {
    const stats = await TableService.getTableStats();

    return res.status(200).json({
      status: 'success',
      data: { stats },
    });
  }
}
