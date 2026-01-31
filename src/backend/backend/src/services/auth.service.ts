import bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { config } from '../config/config.js';
import prisma from '../config/database.js';
import { AppError } from '../middleware/errorHandler.js';
import { logger } from '../utils/logger.js';

interface TokenPayload {
  userId: string;
  username: string;
  role: string;
}

export class AuthService {
  /**
   * Generate access token (short-lived)
   */
  static generateAccessToken(payload: TokenPayload): string {
    // @ts-expect-error - JWT types have issues with expiresIn in newer versions
    return jwt.sign(
      payload,
      config.jwt.secret,
      { expiresIn: config.jwt.accessTokenExpiry }
    );
  }

  /**
   * Generate refresh token (long-lived)
   */
  static generateRefreshToken(payload: TokenPayload): string {
    // @ts-expect-error - JWT types have issues with expiresIn in newer versions
    return jwt.sign(
      payload,
      config.jwt.secret,
      { expiresIn: config.jwt.refreshTokenExpiry }
    );
  }

  /**
   * Authenticate user with username/email and password
   */
  static async login(
    identifier: string,
    password: string,
    ipAddress?: string,
    userAgent?: string
  ) {
    // Find user by username or email
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ username: identifier }, { email: identifier }],
      },
    });

    if (!user || !user.isActive) {
      logger.warn('Login attempt failed', { identifier, ipAddress });
      throw new AppError(401, 'Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      logger.warn('Invalid password attempt', {
        userId: user.id,
        ipAddress,
      });
      throw new AppError(401, 'Invalid credentials');
    }

    // Update last login timestamp
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    // Create audit log
    await prisma.auditLog.create({
      data: {
        entityType: 'USER',
        entityId: user.id,
        action: 'UPDATE',
        userId: user.id,
        changes: { action: 'login' },
        ipAddress,
        userAgent,
      },
    });

    const tokenPayload: TokenPayload = {
      userId: user.id,
      username: user.username,
      role: user.role,
    };

    const accessToken = this.generateAccessToken(tokenPayload);
    const refreshToken = this.generateRefreshToken(tokenPayload);

    logger.info('User logged in successfully', {
      userId: user.id,
      username: user.username,
    });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      },
    };
  }

  /**
   * Refresh access token using refresh token
   */
  static async refreshToken(refreshToken: string) {
    try {
      const decoded = jwt.verify(refreshToken, config.jwt.secret) as TokenPayload;

      // Verify user still exists and is active
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: { id: true, username: true, role: true, isActive: true },
      });

      if (!user || !user.isActive) {
        throw new AppError(401, 'User no longer active');
      }

      const tokenPayload: TokenPayload = {
        userId: user.id,
        username: user.username,
        role: user.role,
      };

      const newAccessToken = this.generateAccessToken(tokenPayload);

      logger.info('Access token refreshed', { userId: user.id });

      return { accessToken: newAccessToken };
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AppError(401, 'Refresh token expired');
      }
      if (error instanceof jwt.JsonWebTokenError) {
        throw new AppError(401, 'Invalid refresh token');
      }
      throw error;
    }
  }

  /**
   * Validate token and return payload
   */
  static async validateToken(token: string): Promise<TokenPayload> {
    try {
      const decoded = jwt.verify(token, config.jwt.secret) as TokenPayload;
      return decoded;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AppError(401, 'Token expired');
      }
      if (error instanceof jwt.JsonWebTokenError) {
        throw new AppError(401, 'Invalid token');
      }
      throw error;
    }
  }
}
