import prisma from '../config/database.js';

export interface SearchQuery {
  query: string;
  limit?: number;
}

export class SearchService {
  /**
   * Search across all entity types
   */
  static async searchAll(searchQuery: string, limit = 10) {
    const query = searchQuery.toLowerCase();

    const [servers, databases, tables, elements, abbreviations] =
      await Promise.all([
        this.searchServers(query, limit),
        this.searchDatabases(query, limit),
        this.searchTables(query, limit),
        this.searchElements(query, limit),
        this.searchAbbreviations(query, limit),
      ]);

    return {
      servers,
      databases,
      tables,
      elements,
      abbreviations,
      totalResults:
        servers.length +
        databases.length +
        tables.length +
        elements.length +
        abbreviations.length,
    };
  }

  /**
   * Search servers
   */
  static async searchServers(query: string, limit = 10) {
    const servers = await prisma.server.findMany({
      where: {
        deletedAt: null,
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
          { host: { contains: query, mode: 'insensitive' } },
          { location: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        name: true,
        description: true,
        host: true,
        rdbmsType: true,
        location: true,
        status: true,
        createdAt: true,
      },
      take: limit,
      orderBy: { name: 'asc' },
    });

    return servers;
  }

  /**
   * Search databases
   */
  static async searchDatabases(query: string, limit = 10) {
    const databases = await prisma.database.findMany({
      where: {
        deletedAt: null,
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
          { purpose: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        name: true,
        description: true,
        purpose: true,
        status: true,
        createdAt: true,
        server: {
          select: {
            id: true,
            name: true,
            rdbmsType: true,
          },
        },
      },
      take: limit,
      orderBy: { name: 'asc' },
    });

    return databases;
  }

  /**
   * Search tables
   */
  static async searchTables(query: string, limit = 10) {
    const tables = await prisma.table.findMany({
      where: {
        deletedAt: null,
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        name: true,
        description: true,
        tableType: true,
        status: true,
        rowCountEstimate: true,
        createdAt: true,
        database: {
          select: {
            id: true,
            name: true,
            server: {
              select: {
                id: true,
                name: true,
                rdbmsType: true,
              },
            },
          },
        },
      },
      take: limit,
      orderBy: { name: 'asc' },
    });

    return tables;
  }

  /**
   * Search elements (columns)
   */
  static async searchElements(query: string, limit = 10) {
    const elements = await prisma.element.findMany({
      where: {
        deletedAt: null,
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
          { dataType: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        name: true,
        description: true,
        dataType: true,
        length: true,
        isPrimaryKey: true,
        isForeignKey: true,
        position: true,
        createdAt: true,
        table: {
          select: {
            id: true,
            name: true,
            database: {
              select: {
                id: true,
                name: true,
                server: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
      take: limit,
      orderBy: { name: 'asc' },
    });

    return elements;
  }

  /**
   * Search abbreviations
   */
  static async searchAbbreviations(query: string, limit = 10) {
    const abbreviations = await prisma.abbreviation.findMany({
      where: {
        OR: [
          { source: { contains: query, mode: 'insensitive' } },
          { abbreviation: { contains: query, mode: 'insensitive' } },
          { definition: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        source: true,
        abbreviation: true,
        definition: true,
        isPrimeClass: true,
        category: true,
        createdAt: true,
      },
      take: limit,
      orderBy: { abbreviation: 'asc' },
    });

    return abbreviations;
  }

  /**
   * Advanced search with wildcard support
   */
  static async advancedSearch(
    entityType: 'server' | 'database' | 'table' | 'element' | 'abbreviation',
    query: string,
    filters: any = {},
    limit = 10
  ) {
    switch (entityType) {
      case 'server':
        return this.advancedSearchServers(query, filters, limit);
      case 'database':
        return this.advancedSearchDatabases(query, filters, limit);
      case 'table':
        return this.advancedSearchTables(query, filters, limit);
      case 'element':
        return this.advancedSearchElements(query, filters, limit);
      case 'abbreviation':
        return this.searchAbbreviations(query, limit);
      default:
        return [];
    }
  }

  private static async advancedSearchServers(
    query: string,
    filters: any,
    limit: number
  ) {
    const where: any = {
      deletedAt: null,
      OR: [
        { name: { contains: query, mode: 'insensitive' } },
        { description: { contains: query, mode: 'insensitive' } },
        { host: { contains: query, mode: 'insensitive' } },
      ],
    };

    if (filters.rdbmsType) {
      where.rdbmsType = filters.rdbmsType;
    }
    if (filters.status) {
      where.status = filters.status;
    }

    return prisma.server.findMany({
      where,
      include: {
        _count: { select: { databases: true } },
      },
      take: limit,
    });
  }

  private static async advancedSearchDatabases(
    query: string,
    filters: any,
    limit: number
  ) {
    const where: any = {
      deletedAt: null,
      OR: [
        { name: { contains: query, mode: 'insensitive' } },
        { description: { contains: query, mode: 'insensitive' } },
      ],
    };

    if (filters.serverId) {
      where.serverId = filters.serverId;
    }
    if (filters.status) {
      where.status = filters.status;
    }

    return prisma.database.findMany({
      where,
      include: {
        server: { select: { id: true, name: true, rdbmsType: true } },
        _count: { select: { tables: true } },
      },
      take: limit,
    });
  }

  private static async advancedSearchTables(
    query: string,
    filters: any,
    limit: number
  ) {
    const where: any = {
      deletedAt: null,
      OR: [
        { name: { contains: query, mode: 'insensitive' } },
        { description: { contains: query, mode: 'insensitive' } },
      ],
    };

    if (filters.databaseId) {
      where.databaseId = filters.databaseId;
    }
    if (filters.tableType) {
      where.tableType = filters.tableType;
    }
    if (filters.status) {
      where.status = filters.status;
    }

    return prisma.table.findMany({
      where,
      include: {
        database: {
          select: {
            id: true,
            name: true,
            server: { select: { id: true, name: true } },
          },
        },
        _count: { select: { elements: true } },
      },
      take: limit,
    });
  }

  private static async advancedSearchElements(
    query: string,
    filters: any,
    limit: number
  ) {
    const where: any = {
      deletedAt: null,
      OR: [
        { name: { contains: query, mode: 'insensitive' } },
        { description: { contains: query, mode: 'insensitive' } },
        { dataType: { contains: query, mode: 'insensitive' } },
      ],
    };

    if (filters.tableId) {
      where.tableId = filters.tableId;
    }
    if (filters.isPrimaryKey !== undefined) {
      where.isPrimaryKey = filters.isPrimaryKey;
    }
    if (filters.dataType) {
      where.dataType = { contains: filters.dataType, mode: 'insensitive' };
    }

    return prisma.element.findMany({
      where,
      include: {
        table: {
          select: {
            id: true,
            name: true,
            database: { select: { id: true, name: true } },
          },
        },
      },
      take: limit,
      orderBy: { position: 'asc' },
    });
  }
}
