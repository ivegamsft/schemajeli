import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';
import { TableType, EntityStatus } from '@prisma/client';

export interface CreateTableDto {
  databaseId: string;
  name: string;
  description?: string;
  tableType?: TableType;
  rowCountEstimate?: number;
  status?: EntityStatus;
}

export interface UpdateTableDto {
  name?: string;
  description?: string;
  tableType?: TableType;
  rowCountEstimate?: number;
  status?: EntityStatus;
}

export interface TableFilter {
  search?: string;
  tableType?: TableType;
  status?: EntityStatus;
  databaseId?: string;
}

export class TableService {
  /**
   * Create a new table
   */
  static async createTable(data: CreateTableDto, createdById: string) {
    // Verify database exists
    const database = await prisma.database.findFirst({
      where: { id: data.databaseId, deletedAt: null },
      include: { server: true },
    });

    if (!database) {
      throw new AppError(404, 'Database not found');
    }

    // Check if table name already exists in this database
    const existing = await prisma.table.findFirst({
      where: {
        databaseId: data.databaseId,
        name: data.name,
        deletedAt: null,
      },
    });

    if (existing) {
      throw new AppError(
        409,
        'Table with this name already exists in this database'
      );
    }

    const table = await prisma.table.create({
      data: {
        ...data,
        tableType: data.tableType || TableType.TABLE,
        status: data.status || EntityStatus.ACTIVE,
        createdById,
      },
      include: {
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
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        _count: {
          select: { elements: true },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'TABLE',
        entityId: table.id,
        action: 'CREATE',
        userId: createdById,
        changes: { created: table },
      },
    });

    return table;
  }

  /**
   * Get all tables with pagination and filtering
   */
  static async getAllTables(
    page = 1,
    limit = 10,
    filter: TableFilter = {}
  ) {
    const skip = (page - 1) * limit;

    const where: any = {
      deletedAt: null,
    };

    // Apply filters
    if (filter.search) {
      where.OR = [
        { name: { contains: filter.search, mode: 'insensitive' } },
        { description: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.tableType) {
      where.tableType = filter.tableType;
    }

    if (filter.status) {
      where.status = filter.status;
    }

    if (filter.databaseId) {
      where.databaseId = filter.databaseId;
    }

    const [tables, total] = await Promise.all([
      prisma.table.findMany({
        where,
        skip,
        take: limit,
        include: {
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
          createdBy: {
            select: {
              id: true,
              username: true,
              fullName: true,
            },
          },
          _count: {
            select: { elements: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.table.count({ where }),
    ]);

    return {
      tables,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get tables by database ID
   */
  static async getTablesByDatabaseId(databaseId: string) {
    const database = await prisma.database.findFirst({
      where: { id: databaseId, deletedAt: null },
    });

    if (!database) {
      throw new AppError(404, 'Database not found');
    }

    const tables = await prisma.table.findMany({
      where: {
        databaseId,
        deletedAt: null,
      },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        _count: {
          select: { elements: true },
        },
      },
      orderBy: { name: 'asc' },
    });

    return tables;
  }

  /**
   * Get table by ID
   */
  static async getTableById(id: string) {
    const table = await prisma.table.findFirst({
      where: { id, deletedAt: null },
      include: {
        database: {
          select: {
            id: true,
            name: true,
            server: {
              select: {
                id: true,
                name: true,
                host: true,
                rdbmsType: true,
              },
            },
          },
        },
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        elements: {
          where: { deletedAt: null },
          select: {
            id: true,
            name: true,
            description: true,
            dataType: true,
            length: true,
            isNullable: true,
            isPrimaryKey: true,
            isForeignKey: true,
            position: true,
            createdAt: true,
          },
          orderBy: { position: 'asc' },
        },
        _count: {
          select: { elements: true },
        },
      },
    });

    if (!table) {
      throw new AppError(404, 'Table not found');
    }

    return table;
  }

  /**
   * Update table
   */
  static async updateTable(
    id: string,
    data: UpdateTableDto,
    updatedById: string
  ) {
    const existing = await prisma.table.findFirst({
      where: { id, deletedAt: null },
      include: { database: true },
    });

    if (!existing) {
      throw new AppError(404, 'Table not found');
    }

    // Check name uniqueness in database if updating name
    if (data.name && data.name !== existing.name) {
      const nameExists = await prisma.table.findFirst({
        where: {
          databaseId: existing.databaseId,
          name: data.name,
          deletedAt: null,
        },
      });
      if (nameExists) {
        throw new AppError(
          409,
          'Table name already exists in this database'
        );
      }
    }

    const updatedTable = await prisma.table.update({
      where: { id },
      data,
      include: {
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
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        _count: {
          select: { elements: true },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'TABLE',
        entityId: id,
        action: 'UPDATE',
        userId: updatedById,
        changes: {
          before: existing,
          after: updatedTable,
        },
      },
    });

    return updatedTable;
  }

  /**
   * Delete table (soft delete)
   */
  static async deleteTable(id: string, deletedById: string) {
    const existing = await prisma.table.findFirst({
      where: { id, deletedAt: null },
      include: {
        _count: {
          select: { elements: true },
        },
      },
    });

    if (!existing) {
      throw new AppError(404, 'Table not found');
    }

    // Check if table has active elements
    if (existing._count.elements > 0) {
      throw new AppError(
        400,
        'Cannot delete table with existing elements. Delete elements first.'
      );
    }

    const deletedTable = await prisma.table.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: EntityStatus.ARCHIVED,
      },
      select: {
        id: true,
        name: true,
        deletedAt: true,
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'TABLE',
        entityId: id,
        action: 'DELETE',
        userId: deletedById,
        changes: { deleted: true },
      },
    });

    return deletedTable;
  }

  /**
   * Get table statistics
   */
  static async getTableStats() {
    const [total, byType, byStatus] = await Promise.all([
      prisma.table.count({ where: { deletedAt: null } }),
      prisma.table.groupBy({
        by: ['tableType'],
        where: { deletedAt: null },
        _count: true,
      }),
      prisma.table.groupBy({
        by: ['status'],
        where: { deletedAt: null },
        _count: true,
      }),
    ]);

    return {
      total,
      byTableType: byType.map((item) => ({
        type: item.tableType,
        count: item._count,
      })),
      byStatus: byStatus.map((item) => ({
        status: item.status,
        count: item._count,
      })),
    };
  }
}
