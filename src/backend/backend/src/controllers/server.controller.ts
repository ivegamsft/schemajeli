import { Response } from 'express';
import { ServerService } from '../services/server.service.js';
import { AuthRequest } from '../middleware/authenticate.js';
import { RdbmsType, EntityStatus } from '@prisma/client';

export class ServerController {
  /**
   * POST /servers
   * Create a new server
   */
  static async createServer(req: AuthRequest, res: Response) {
    const { name, description, host, port, rdbmsType, location, status } =
      req.body;

    if (!name || !host || !rdbmsType) {
      return res.status(400).json({
        status: 'error',
        message: 'Name, host, and RDBMS type are required',
      });
    }

    const server = await ServerService.createServer(
      { name, description, host, port, rdbmsType, location, status },
      req.user!.id
    );

    return res.status(201).json({
      status: 'success',
      data: { server },
    });
  }

  /**
   * GET /servers
   * Get all servers with pagination and filtering
   */
  static async getAllServers(req: AuthRequest, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const filter = {
      search: req.query.search as string,
      rdbmsType: req.query.rdbmsType as RdbmsType,
      status: req.query.status as EntityStatus,
      location: req.query.location as string,
    };

    const result = await ServerService.getAllServers(page, limit, filter);

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /servers/:id
   * Get server by ID
   */
  static async getServerById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const server = await ServerService.getServerById(id);

    return res.status(200).json({
      status: 'success',
      data: { server },
    });
  }

  /**
   * PUT /servers/:id
   * Update server
   */
  static async updateServer(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { name, description, host, port, rdbmsType, location, status } =
      req.body;

    const server = await ServerService.updateServer(
      id,
      { name, description, host, port, rdbmsType, location, status },
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: { server },
    });
  }

  /**
   * DELETE /servers/:id
   * Delete server (soft delete)
   */
  static async deleteServer(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const server = await ServerService.deleteServer(id, req.user!.id);

    return res.status(200).json({
      status: 'success',
      data: { server },
    });
  }

  /**
   * GET /servers/stats
   * Get server statistics
   */
  static async getServerStats(_req: AuthRequest, res: Response) {
    const stats = await ServerService.getServerStats();

    return res.status(200).json({
      status: 'success',
      data: { stats },
    });
  }
}
