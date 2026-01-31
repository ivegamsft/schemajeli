import { Response } from 'express';
import { ElementService } from '../services/element.service.js';
import { AuthRequest } from '../middleware/authenticate.js';

export class ElementController {
  /**
   * POST /elements
   * Create a new element (column)
   */
  static async createElement(req: AuthRequest, res: Response) {
    const {
      tableId,
      name,
      description,
      dataType,
      length,
      precision,
      scale,
      isNullable,
      isPrimaryKey,
      isForeignKey,
      defaultValue,
      position,
    } = req.body;

    if (!tableId || !name || !dataType || position === undefined) {
      return res.status(400).json({
        status: 'error',
        message: 'Table ID, name, data type, and position are required',
      });
    }

    const element = await ElementService.createElement(
      {
        tableId,
        name,
        description,
        dataType,
        length,
        precision,
        scale,
        isNullable,
        isPrimaryKey,
        isForeignKey,
        defaultValue,
        position,
      },
      req.user!.id
    );

    return res.status(201).json({
      status: 'success',
      data: { element },
    });
  }

  /**
   * GET /elements
   * Get all elements with pagination and filtering
   */
  static async getAllElements(req: AuthRequest, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const filter = {
      search: req.query.search as string,
      dataType: req.query.dataType as string,
      tableId: req.query.tableId as string,
      isPrimaryKey:
        req.query.isPrimaryKey === 'true'
          ? true
          : req.query.isPrimaryKey === 'false'
            ? false
            : undefined,
      isForeignKey:
        req.query.isForeignKey === 'true'
          ? true
          : req.query.isForeignKey === 'false'
            ? false
            : undefined,
    };

    const result = await ElementService.getAllElements(page, limit, filter);

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /tables/:tableId/elements
   * Get all elements for a specific table
   */
  static async getElementsByTableId(req: AuthRequest, res: Response) {
    const { tableId } = req.params;

    const elements = await ElementService.getElementsByTableId(tableId);

    return res.status(200).json({
      status: 'success',
      data: { elements },
    });
  }

  /**
   * GET /elements/:id
   * Get element by ID
   */
  static async getElementById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const element = await ElementService.getElementById(id);

    return res.status(200).json({
      status: 'success',
      data: { element },
    });
  }

  /**
   * PUT /elements/:id
   * Update element
   */
  static async updateElement(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const {
      name,
      description,
      dataType,
      length,
      precision,
      scale,
      isNullable,
      isPrimaryKey,
      isForeignKey,
      defaultValue,
      position,
    } = req.body;

    const element = await ElementService.updateElement(
      id,
      {
        name,
        description,
        dataType,
        length,
        precision,
        scale,
        isNullable,
        isPrimaryKey,
        isForeignKey,
        defaultValue,
        position,
      },
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: { element },
    });
  }

  /**
   * DELETE /elements/:id
   * Delete element (soft delete)
   */
  static async deleteElement(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const element = await ElementService.deleteElement(id, req.user!.id);

    return res.status(200).json({
      status: 'success',
      data: { element },
    });
  }

  /**
   * GET /elements/stats
   * Get element statistics
   */
  static async getElementStats(_req: AuthRequest, res: Response) {
    const stats = await ElementService.getElementStats();

    return res.status(200).json({
      status: 'success',
      data: { stats },
    });
  }
}
