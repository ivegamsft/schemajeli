import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';

export interface CreateAbbreviationDto {
  source: string;
  abbreviation: string;
  definition?: string;
  isPrimeClass?: boolean;
  category?: string;
}

export interface UpdateAbbreviationDto {
  source?: string;
  abbreviation?: string;
  definition?: string;
  isPrimeClass?: boolean;
  category?: string;
}

export interface AbbreviationFilter {
  search?: string;
  category?: string;
  isPrimeClass?: boolean;
}

export class AbbreviationService {
  /**
   * Create a new abbreviation
   */
  static async createAbbreviation(
    data: CreateAbbreviationDto,
    createdById: string
  ) {
    // Check if abbreviation already exists
    const existing = await prisma.abbreviation.findUnique({
      where: { abbreviation: data.abbreviation },
    });

    if (existing) {
      throw new AppError(409, 'Abbreviation already exists');
    }

    const abbreviation = await prisma.abbreviation.create({
      data: {
        ...data,
        isPrimeClass: data.isPrimeClass ?? false,
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
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'ABBREVIATION',
        entityId: abbreviation.id,
        action: 'CREATE',
        userId: createdById,
        changes: { created: abbreviation },
      },
    });

    return abbreviation;
  }

  /**
   * Get all abbreviations with pagination and filtering
   */
  static async getAllAbbreviations(
    page = 1,
    limit = 10,
    filter: AbbreviationFilter = {}
  ) {
    const skip = (page - 1) * limit;

    const where: any = {};

    // Apply filters
    if (filter.search) {
      where.OR = [
        { source: { contains: filter.search, mode: 'insensitive' } },
        { abbreviation: { contains: filter.search, mode: 'insensitive' } },
        { definition: { contains: filter.search, mode: 'insensitive' } },
      ];
    }

    if (filter.category) {
      where.category = { contains: filter.category, mode: 'insensitive' };
    }

    if (filter.isPrimeClass !== undefined) {
      where.isPrimeClass = filter.isPrimeClass;
    }

    const [abbreviations, total] = await Promise.all([
      prisma.abbreviation.findMany({
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
        },
        orderBy: { abbreviation: 'asc' },
      }),
      prisma.abbreviation.count({ where }),
    ]);

    return {
      abbreviations,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get abbreviation by ID
   */
  static async getAbbreviationById(id: string) {
    const abbreviation = await prisma.abbreviation.findUnique({
      where: { id },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
      },
    });

    if (!abbreviation) {
      throw new AppError(404, 'Abbreviation not found');
    }

    return abbreviation;
  }

  /**
   * Search abbreviation by abbreviation string
   */
  static async searchByAbbreviation(abbr: string) {
    const abbreviation = await prisma.abbreviation.findUnique({
      where: { abbreviation: abbr },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            fullName: true,
          },
        },
      },
    });

    if (!abbreviation) {
      throw new AppError(404, 'Abbreviation not found');
    }

    return abbreviation;
  }

  /**
   * Update abbreviation
   */
  static async updateAbbreviation(
    id: string,
    data: UpdateAbbreviationDto,
    updatedById: string
  ) {
    const existing = await prisma.abbreviation.findUnique({
      where: { id },
    });

    if (!existing) {
      throw new AppError(404, 'Abbreviation not found');
    }

    // Check abbreviation uniqueness if updating abbreviation
    if (data.abbreviation && data.abbreviation !== existing.abbreviation) {
      const abbrExists = await prisma.abbreviation.findUnique({
        where: { abbreviation: data.abbreviation },
      });
      if (abbrExists) {
        throw new AppError(409, 'Abbreviation already exists');
      }
    }

    const updatedAbbreviation = await prisma.abbreviation.update({
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
      },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'ABBREVIATION',
        entityId: id,
        action: 'UPDATE',
        userId: updatedById,
        changes: {
          before: existing,
          after: updatedAbbreviation,
        },
      },
    });

    return updatedAbbreviation;
  }

  /**
   * Delete abbreviation
   */
  static async deleteAbbreviation(id: string, deletedById: string) {
    const existing = await prisma.abbreviation.findUnique({
      where: { id },
    });

    if (!existing) {
      throw new AppError(404, 'Abbreviation not found');
    }

    await prisma.abbreviation.delete({
      where: { id },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'ABBREVIATION',
        entityId: id,
        action: 'DELETE',
        userId: deletedById,
        changes: { deleted: existing },
      },
    });

    return { id, abbreviation: existing.abbreviation };
  }

  /**
   * Get abbreviation statistics
   */
  static async getAbbreviationStats() {
    const [total, primeClass, byCategory] = await Promise.all([
      prisma.abbreviation.count(),
      prisma.abbreviation.count({ where: { isPrimeClass: true } }),
      prisma.abbreviation.groupBy({
        by: ['category'],
        _count: true,
        orderBy: { _count: { category: 'desc' } },
        take: 10,
      }),
    ]);

    return {
      total,
      primeClass,
      byCategory: byCategory
        .filter((item) => item.category)
        .map((item) => ({
          category: item.category,
          count: item._count,
        })),
    };
  }
}
