import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';

export interface CreateElementDto {
  tableId: string;
  name: string;
  description?: string;
  dataType: string;
  length?: number;
  precision?: number;
  scale?: number;
  isNullable?: boolean;
  isPrimaryKey?: boolean;
  isForeignKey?: boolean;
  defaultValue?: string;
  position: number;
}

export interface UpdateElementDto {
  name?: string;
  description?: string;
  dataType?: string;
  length?: number;
  precision?: number;
  scale?: number;
  isNullable?: boolean;
  isPrimaryKey?: boolean;
  isForeignKey?: boolean;
  defaultValue?: string;
  position?: number;
}

export interface ElementFilter {
  search?: string;
  dataType?: string;
  tableId?: string;
  isPrimaryKey?: boolean;
  isForeignKey?: boolean;
}

export class ElementService {
  /**
   * Create a new element (column)
   */
  static async createElement(data: CreateElementDto, createdById: string) {
    // Verify table exists
    const table = await prisma.table.findFirst({
      where: { id: data.tableId, deletedAt: null },
      include: { database: { include: { server: true } } },
    });

    if (!table) {
      throw new AppError(404, 'Table not found');
    }

    // Check if element name already exists in this table
    const existing = await prisma.element.findFirst({
      where: {
        tableId: data.tableId,
        name: data.name,
        deletedAt: null,
      },
    });

    if (existing) {
      throw new AppError(
        409,
        'Element with this name already exists in this table'
      );
    }

    const element = await prisma.element.create({
      data: {
        ...data,
        isNullable: data.isNullable ?? true,
        isPrimaryKey: data.isPrimaryKey ?? false,
        isForeignKey: data.isForeignKey ?? false,
        createdById,
      },
      include: {
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
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'ELEMENT',
        entityId: element.id,
        action: 'CREATE',
        userId: createdById,
        changes: { created: element },
      },
    });

    return element;
  }

  /**
   * Get all elements with pagination and filtering
   */
  static async getAllElements(
    page = 1,
    limit = 10,
    filter: ElementFilter = {}
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
        { dataType: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.dataType) {
      where.dataType = { contains: filter.dataType, mode: 'insensitive' };
    }

    if (filter.tableId) {
      where.tableId = filter.tableId;
    }

    if (filter.isPrimaryKey !== undefined) {
      where.isPrimaryKey = filter.isPrimaryKey;
    }

    if (filter.isForeignKey !== undefined) {
      where.isForeignKey = filter.isForeignKey;
    }

    const [elements, total] = await Promise.all([
      prisma.element.findMany({
        where,
        skip,
        take: limit,
        include: {
          table: {
            select: {
              id: true,
              name: true,
              database: {
                select: {
                  id: true,
                  name: true,
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
        },
        orderBy: [{ tableId: 'asc' }, { position: 'asc' }],
      }),
      prisma.element.count({ where }),
    ]);

    return {
      elements,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get elements by table ID
   */
  static async getElementsByTableId(tableId: string) {
    const table = await prisma.table.findFirst({
      where: { id: tableId, deletedAt: null },
    });

    if (!table) {
      throw new AppError(404, 'Table not found');
    }

    const elements = await prisma.element.findMany({
      where: {
        tableId,
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
      },
      orderBy: { position: 'asc' },
    });

    return elements;
  }

  /**
   * Get element by ID
   */
  static async getElementById(id: string) {
    const element = await prisma.element.findFirst({
      where: { id, deletedAt: null },
      include: {
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
                    rdbmsType: true,
                  },
                },
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
      },
    });

    if (!element) {
      throw new AppError(404, 'Element not found');
    }

    return element;
  }

  /**
   * Update element
   */
  static async updateElement(
    id: string,
    data: UpdateElementDto,
    updatedById: string
  ) {
    const existing = await prisma.element.findFirst({
      where: { id, deletedAt: null },
      include: { table: true },
    });

    if (!existing) {
      throw new AppError(404, 'Element not found');
    }

    // Check name uniqueness in table if updating name
    if (data.name && data.name !== existing.name) {
      const nameExists = await prisma.element.findFirst({
        where: {
          tableId: existing.tableId,
          name: data.name,
          deletedAt: null,
        },
      });
      if (nameExists) {
        throw new AppError(
          409,
          'Element name already exists in this table'
        );
      }
    }

    const updatedElement = await prisma.element.update({
      where: { id },
      data,
      include: {
        table: {
          select: {
            id: true,
            name: true,
            database: {
              select: {
                id: true,
                name: true,
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
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'ELEMENT',
        entityId: id,
        action: 'UPDATE',
        userId: updatedById,
        changes: {
          before: existing,
          after: updatedElement,
        },
      },
    });

    return updatedElement;
  }

  /**
   * Delete element (soft delete)
   */
  static async deleteElement(id: string, deletedById: string) {
    const existing = await prisma.element.findFirst({
      where: { id, deletedAt: null },
    });

    if (!existing) {
      throw new AppError(404, 'Element not found');
    }

    const deletedElement = await prisma.element.update({
      where: { id },
      data: {
        deletedAt: new Date(),
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
        entityType: 'ELEMENT',
        entityId: id,
        action: 'DELETE',
        userId: deletedById,
        changes: { deleted: true },
      },
    });

    return deletedElement;
  }

  /**
   * Get element statistics
   */
  static async getElementStats() {
    const total = await prisma.element.count({ where: { deletedAt: null } });

    const byDataType = await prisma.element.groupBy({
      by: ['dataType'],
      where: { deletedAt: null },
      _count: true,
      orderBy: { _count: { dataType: 'desc' } },
      take: 10,
    });

    const primaryKeys = await prisma.element.count({
      where: { deletedAt: null, isPrimaryKey: true },
    });

    const foreignKeys = await prisma.element.count({
      where: { deletedAt: null, isForeignKey: true },
    });

    return {
      total,
      primaryKeys,
      foreignKeys,
      topDataTypes: byDataType.map((item) => ({
        dataType: item.dataType,
        count: item._count,
      })),
    };
  }
}
