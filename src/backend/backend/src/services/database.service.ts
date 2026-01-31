import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';
import { EntityStatus } from '@prisma/client';

export interface CreateDatabaseDto {
  serverId: string;
  name: string;
  description?: string;
  purpose?: string;
  status?: EntityStatus;
}

export interface UpdateDatabaseDto {
  name?: string;
  description?: string;
  purpose?: string;
  status?: EntityStatus;
}

export interface DatabaseFilter {
  search?: string;
  status?: EntityStatus;
  serverId?: string;
}

export class DatabaseService {
  /**
   * Create a new database
   */
  static async createDatabase(data: CreateDatabaseDto, createdById: string) {
    // Verify server exists
    const server = await prisma.server.findFirst({
      where: { id: data.serverId, deletedAt: null },
    });

    if (!server) {
      throw new AppError(404, 'Server not found');
    }

    // Check if database name already exists on this server
    const existing = await prisma.database.findFirst({
      where: {
        serverId: data.serverId,
        name: data.name,
        deletedAt: null,
      },
    });

    if (existing) {
      throw new AppError(
        409,
        'Database with this name already exists on this server'
      );
    }

    const database = await prisma.database.create({
      data: {
        ...data,
        status: data.status || EntityStatus.ACTIVE,
        createdById,
      },
      include: {
        server: {
          select: {
            id: true,
            name: true,
            rdbmsType: true,
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
          select: { tables: true },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'DATABASE',
        entityId: database.id,
        action: 'CREATE',
        userId: createdById,
        changes: { created: database },
      },
    });

    return database;
  }

  /**
   * Get all databases with pagination and filtering
   */
  static async getAllDatabases(
    page = 1,
    limit = 10,
    filter: DatabaseFilter = {}
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
        { purpose: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.status) {
      where.status = filter.status;
    }

    if (filter.serverId) {
      where.serverId = filter.serverId;
    }

    const [databases, total] = await Promise.all([
      prisma.database.findMany({
        where,
        skip,
        take: limit,
        include: {
          server: {
            select: {
              id: true,
              name: true,
              rdbmsType: true,
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
            select: { tables: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.database.count({ where }),
    ]);

    return {
      databases,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get databases by server ID
   */
  static async getDatabasesByServerId(serverId: string) {
    const server = await prisma.server.findFirst({
      where: { id: serverId, deletedAt: null },
    });

    if (!server) {
      throw new AppError(404, 'Server not found');
    }

    const databases = await prisma.database.findMany({
      where: {
        serverId,
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
          select: { tables: true },
        },
      },
      orderBy: { name: 'asc' },
    });

    return databases;
  }

  /**
   * Get database by ID
   */
  static async getDatabaseById(id: string) {
    const database = await prisma.database.findFirst({
      where: { id, deletedAt: null },
      include: {
        server: {
          select: {
            id: true,
            name: true,
            host: true,
            rdbmsType: true,
          },
        },
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        tables: {
          where: { deletedAt: null },
          select: {
            id: true,
            name: true,
            description: true,
            tableType: true,
            status: true,
            createdAt: true,
          },
        },
        _count: {
          select: { tables: true },
        },
      },
    });

    if (!database) {
      throw new AppError(404, 'Database not found');
    }

    return database;
  }

  /**
   * Update database
   */
  static async updateDatabase(
    id: string,
    data: UpdateDatabaseDto,
    updatedById: string
  ) {
    const existing = await prisma.database.findFirst({
      where: { id, deletedAt: null },
      include: { server: true },
    });

    if (!existing) {
      throw new AppError(404, 'Database not found');
    }

    // Check name uniqueness on server if updating name
    if (data.name && data.name !== existing.name) {
      const nameExists = await prisma.database.findFirst({
        where: {
          serverId: existing.serverId,
          name: data.name,
          deletedAt: null,
        },
      });
      if (nameExists) {
        throw new AppError(
          409,
          'Database name already exists on this server'
        );
      }
    }

    const updatedDatabase = await prisma.database.update({
      where: { id },
      data,
      include: {
        server: {
          select: {
            id: true,
            name: true,
            rdbmsType: true,
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
          select: { tables: true },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'DATABASE',
        entityId: id,
        action: 'UPDATE',
        userId: updatedById,
        changes: {
          before: existing,
          after: updatedDatabase,
        },
      },
    });

    return updatedDatabase;
  }

  /**
   * Delete database (soft delete)
   */
  static async deleteDatabase(id: string, deletedById: string) {
    const existing = await prisma.database.findFirst({
      where: { id, deletedAt: null },
      include: {
        _count: {
          select: { tables: true },
        },
      },
    });

    if (!existing) {
      throw new AppError(404, 'Database not found');
    }

    // Check if database has active tables
    if (existing._count.tables > 0) {
      throw new AppError(
        400,
        'Cannot delete database with existing tables. Delete tables first.'
      );
    }

    const deletedDatabase = await prisma.database.update({
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
        entityType: 'DATABASE',
        entityId: id,
        action: 'DELETE',
        userId: deletedById,
        changes: { deleted: true },
      },
    });

    return deletedDatabase;
  }
}
