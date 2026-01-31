import { Response } from 'express';
import { SearchService } from '../services/search.service.js';
import { AuthRequest } from '../middleware/authenticate.js';

export class SearchController {
  /**
   * GET /search
   * Search across all entity types
   */
  static async searchAll(req: AuthRequest, res: Response) {
    const query = req.query.q as string;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query must be at least 2 characters',
      });
    }

    const results = await SearchService.searchAll(query, limit);

    return res.status(200).json({
      status: 'success',
      data: results,
    });
  }

  /**
   * GET /search/servers
   * Search servers
   */
  static async searchServers(req: AuthRequest, res: Response) {
    const query = req.query.q as string;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query must be at least 2 characters',
      });
    }

    const filters = {
      rdbmsType: req.query.rdbmsType,
      status: req.query.status,
    };

    const results = await SearchService.advancedSearch(
      'server',
      query,
      filters,
      limit
    );

    return res.status(200).json({
      status: 'success',
      data: { servers: results },
    });
  }

  /**
   * GET /search/databases
   * Search databases
   */
  static async searchDatabases(req: AuthRequest, res: Response) {
    const query = req.query.q as string;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query must be at least 2 characters',
      });
    }

    const filters = {
      serverId: req.query.serverId,
      status: req.query.status,
    };

    const results = await SearchService.advancedSearch(
      'database',
      query,
      filters,
      limit
    );

    return res.status(200).json({
      status: 'success',
      data: { databases: results },
    });
  }

  /**
   * GET /search/tables
   * Search tables
   */
  static async searchTables(req: AuthRequest, res: Response) {
    const query = req.query.q as string;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query must be at least 2 characters',
      });
    }

    const filters = {
      databaseId: req.query.databaseId,
      tableType: req.query.tableType,
      status: req.query.status,
    };

    const results = await SearchService.advancedSearch(
      'table',
      query,
      filters,
      limit
    );

    return res.status(200).json({
      status: 'success',
      data: { tables: results },
    });
  }

  /**
   * GET /search/elements
   * Search elements
   */
  static async searchElements(req: AuthRequest, res: Response) {
    const query = req.query.q as string;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query must be at least 2 characters',
      });
    }

    const filters = {
      tableId: req.query.tableId,
      dataType: req.query.dataType,
      isPrimaryKey: req.query.isPrimaryKey === 'true' ? true : undefined,
    };

    const results = await SearchService.advancedSearch(
      'element',
      query,
      filters,
      limit
    );

    return res.status(200).json({
      status: 'success',
      data: { elements: results },
    });
  }

  /**
   * GET /search/abbreviations
   * Search abbreviations
   */
  static async searchAbbreviations(req: AuthRequest, res: Response) {
    const query = req.query.q as string;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query must be at least 2 characters',
      });
    }

    const results = await SearchService.searchAbbreviations(query, limit);

    return res.status(200).json({
      status: 'success',
      data: { abbreviations: results },
    });
  }
}
