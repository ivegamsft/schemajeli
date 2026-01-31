import { Response } from 'express';
import { AbbreviationService } from '../services/abbreviation.service.js';
import { AuthRequest } from '../middleware/authenticate.js';

export class AbbreviationController {
  /**
   * POST /abbreviations
   * Create a new abbreviation
   */
  static async createAbbreviation(req: AuthRequest, res: Response) {
    const { source, abbreviation, definition, isPrimeClass, category } =
      req.body;

    if (!source || !abbreviation) {
      return res.status(400).json({
        status: 'error',
        message: 'Source and abbreviation are required',
      });
    }

    const result = await AbbreviationService.createAbbreviation(
      { source, abbreviation, definition, isPrimeClass, category },
      req.user!.id
    );

    return res.status(201).json({
      status: 'success',
      data: { abbreviation: result },
    });
  }

  /**
   * GET /abbreviations
   * Get all abbreviations with pagination and filtering
   */
  static async getAllAbbreviations(req: AuthRequest, res: Response) {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    const filter = {
      search: req.query.search as string,
      category: req.query.category as string,
      isPrimeClass:
        req.query.isPrimeClass === 'true'
          ? true
          : req.query.isPrimeClass === 'false'
            ? false
            : undefined,
    };

    const result = await AbbreviationService.getAllAbbreviations(
      page,
      limit,
      filter
    );

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /abbreviations/search/:abbr
   * Search abbreviation by abbreviation string
   */
  static async searchByAbbreviation(req: AuthRequest, res: Response) {
    const { abbr } = req.params;

    const abbreviation =
      await AbbreviationService.searchByAbbreviation(abbr);

    return res.status(200).json({
      status: 'success',
      data: { abbreviation },
    });
  }

  /**
   * GET /abbreviations/:id
   * Get abbreviation by ID
   */
  static async getAbbreviationById(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const abbreviation = await AbbreviationService.getAbbreviationById(id);

    return res.status(200).json({
      status: 'success',
      data: { abbreviation },
    });
  }

  /**
   * PUT /abbreviations/:id
   * Update abbreviation
   */
  static async updateAbbreviation(req: AuthRequest, res: Response) {
    const { id } = req.params;
    const { source, abbreviation, definition, isPrimeClass, category } =
      req.body;

    const result = await AbbreviationService.updateAbbreviation(
      id,
      { source, abbreviation, definition, isPrimeClass, category },
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: { abbreviation: result },
    });
  }

  /**
   * DELETE /abbreviations/:id
   * Delete abbreviation
   */
  static async deleteAbbreviation(req: AuthRequest, res: Response) {
    const { id } = req.params;

    const result = await AbbreviationService.deleteAbbreviation(
      id,
      req.user!.id
    );

    return res.status(200).json({
      status: 'success',
      data: result,
    });
  }

  /**
   * GET /abbreviations/stats
   * Get abbreviation statistics
   */
  static async getAbbreviationStats(_req: AuthRequest, res: Response) {
    const stats = await AbbreviationService.getAbbreviationStats();

    return res.status(200).json({
      status: 'success',
      data: { stats },
    });
  }
}
