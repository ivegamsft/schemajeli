import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';
import { RdbmsType, EntityStatus } from '@prisma/client';

export interface CreateServerDto {
  name: string;
  description?: string;
  host: string;
  port?: number;
  rdbmsType: RdbmsType;
  location?: string;
  status?: EntityStatus;
}

export interface UpdateServerDto {
  name?: string;
  description?: string;
  host?: string;
  port?: number;
  rdbmsType?: RdbmsType;
  location?: string;
  status?: EntityStatus;
}

export interface ServerFilter {
  search?: string;
  rdbmsType?: RdbmsType;
  status?: EntityStatus;
  location?: string;
}

export class ServerService {
  /**
   * Create a new server
   */
  static async createServer(data: CreateServerDto, createdById: string) {
    // Check if server name already exists
    const existing = await prisma.server.findUnique({
      where: { name: data.name },
    });

    if (existing) {
      throw new AppError(409, 'Server with this name already exists');
    }

    // Validate RDBMS type
    if (!Object.values(RdbmsType).includes(data.rdbmsType)) {
      throw new AppError(400, 'Invalid RDBMS type');
    }

    const server = await prisma.server.create({
      data: {
        ...data,
        status: data.status || EntityStatus.ACTIVE,
        createdById,
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
          select: { databases: true },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'SERVER',
        entityId: server.id,
        action: 'CREATE',
        userId: createdById,
        changes: { created: server },
      },
    });

    return server;
  }

  /**
   * Get all servers with pagination and filtering
   */
  static async getAllServers(
    page = 1,
    limit = 10,
    filter: ServerFilter = {}
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
        { host: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.rdbmsType) {
      where.rdbmsType = filter.rdbmsType;
    }

    if (filter.status) {
      where.status = filter.status;
    }

    if (filter.location) {
      where.location = { contains: filter.location, mode: 'insensitive' };
    }

    const [servers, total] = await Promise.all([
      prisma.server.findMany({
        where,
        skip,
        take: limit,
        include: {
          createdBy: {
            select: {
              id: true,
              username: true,
              fullName: true,
            },
          },
          _count: {
            select: { databases: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.server.count({ where }),
    ]);

    return {
      servers,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get server by ID
   */
  static async getServerById(id: string) {
    const server = await prisma.server.findFirst({
      where: { id, deletedAt: null },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        databases: {
          where: { deletedAt: null },
          select: {
            id: true,
            name: true,
            description: true,
            status: true,
            createdAt: true,
          },
        },
        _count: {
          select: { databases: true },
        },
      },
    });

    if (!server) {
      throw new AppError(404, 'Server not found');
    }

    return server;
  }

  /**
   * Update server
   */
  static async updateServer(
    id: string,
    data: UpdateServerDto,
    updatedById: string
  ) {
    const existing = await prisma.server.findFirst({
      where: { id, deletedAt: null },
    });

    if (!existing) {
      throw new AppError(404, 'Server not found');
    }

    // Check name uniqueness if updating name
    if (data.name && data.name !== existing.name) {
      const nameExists = await prisma.server.findUnique({
        where: { name: data.name },
      });
      if (nameExists) {
        throw new AppError(409, 'Server name already exists');
      }
    }

    const updatedServer = await prisma.server.update({
      where: { id },
      data,
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
        _count: {
          select: { databases: true },
        },
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'SERVER',
        entityId: id,
        action: 'UPDATE',
        userId: updatedById,
        changes: {
          before: existing,
          after: updatedServer,
        },
      },
    });

    return updatedServer;
  }

  /**
   * Delete server (soft delete)
   */
  static async deleteServer(id: string, deletedById: string) {
    const existing = await prisma.server.findFirst({
      where: { id, deletedAt: null },
      include: {
        _count: {
          select: { databases: true },
        },
      },
    });

    if (!existing) {
      throw new AppError(404, 'Server not found');
    }

    // Check if server has active databases
    if (existing._count.databases > 0) {
      throw new AppError(
        400,
        'Cannot delete server with existing databases. Delete databases first.'
      );
    }

    const deletedServer = await prisma.server.update({
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
        entityType: 'SERVER',
        entityId: id,
        action: 'DELETE',
        userId: deletedById,
        changes: { deleted: true },
      },
    });

    return deletedServer;
  }

  /**
   * Get server statistics
   */
  static async getServerStats() {
    const [total, byRdbms, byStatus] = await Promise.all([
      prisma.server.count({ where: { deletedAt: null } }),
      prisma.server.groupBy({
        by: ['rdbmsType'],
        where: { deletedAt: null },
        _count: true,
      }),
      prisma.server.groupBy({
        by: ['status'],
        where: { deletedAt: null },
        _count: true,
      }),
    ]);

    return {
      total,
      byRdbmsType: byRdbms.map((item) => ({
        type: item.rdbmsType,
        count: item._count,
      })),
      byStatus: byStatus.map((item) => ({
        status: item.status,
        count: item._count,
      })),
    };
  }
}
