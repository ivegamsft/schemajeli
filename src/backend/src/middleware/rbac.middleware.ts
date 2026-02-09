/**
 * Role-Based Access Control (RBAC) Middleware
 * 
 * Enforces role-based permissions for API endpoints.
 * Supports ADMIN, MAINTAINER, and VIEWER roles.
 */

import { Request, Response, NextFunction } from 'express';
import { Role } from '../models/user.model.js';
import { db } from '../db/prisma.client.js';

/**
 * Role hierarchy (higher roles include lower role permissions)
 */
const roleHierarchy: Record<Role, number> = {
  ADMIN: 3,
  MAINTAINER: 2,
  VIEWER: 1,
};

/**
 * Check if user has required role or higher
 */
function hasRequiredRole(userRole: Role, requiredRole: Role): boolean {
  return roleHierarchy[userRole] >= roleHierarchy[requiredRole];
}

/**
 * RBAC middleware factory
 * Creates middleware that enforces minimum role requirement
 * 
 * @param requiredRole - Minimum role required to access the endpoint
 */
export function requireRole(requiredRole: Role) {
  return async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      // Check if user is authenticated
      if (!req.user || !req.user.id) {
        res.status(401).json({ error: 'Authentication required' });
        return;
      }

      // Lookup user in database to get role
      const user = await db.user.findUnique({
        where: { id: req.user.id },
        select: { id: true, role: true, isActive: true, deletedAt: true },
      });

      // Check if user exists
      if (!user) {
        res.status(403).json({ error: 'User not found in system' });
        return;
      }

      // Check if user is active
      if (!user.isActive) {
        res.status(403).json({ error: 'User account is inactive' });
        return;
      }

      // Check if user is soft-deleted
      if (user.deletedAt) {
        res.status(403).json({ error: 'User account has been deleted' });
        return;
      }

      // Check if user has required role
      if (!hasRequiredRole(user.role, requiredRole)) {
        res.status(403).json({ 
          error: 'Insufficient permissions',
          required: requiredRole,
          current: user.role,
        });
        return;
      }

      // Attach user ID and role to request for use in handlers
      if (req.user) {
        req.user.roles = [user.role];
      }
      
      next();
    } catch (error) {
      console.error('RBAC middleware error:', error);
      res.status(500).json({ error: 'Internal authorization error' });
    }
  };
}

/**
 * Convenience middlewares for common role requirements
 */

// Admin only
export const requireAdmin = requireRole('ADMIN');

// Maintainer or Admin
export const requireMaintainer = requireRole('MAINTAINER');

// Any authenticated user (Viewer, Maintainer, or Admin)
export const requireViewer = requireRole('VIEWER');

/**
 * Check if user owns a resource or has admin/maintainer role
 * Used for operations that should be restricted to resource owners
 */
export function requireOwnerOrRole(resourceUserId: string, requiredRole: Role = 'ADMIN') {
  return async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      if (!req.user || !req.user.id) {
        res.status(401).json({ error: 'Authentication required' });
        return;
      }

      // Get user from database
      const user = await db.user.findUnique({
        where: { id: req.user.id },
        select: { id: true, role: true },
      });

      if (!user) {
        res.status(403).json({ error: 'User not found' });
        return;
      }

      // Check if user owns the resource OR has required role
      const isOwner = user.id === resourceUserId;
      const hasRole = hasRequiredRole(user.role, requiredRole);

      if (!isOwner && !hasRole) {
        res.status(403).json({ error: 'Insufficient permissions' });
        return;
      }

      next();
    } catch (error) {
      console.error('Ownership check error:', error);
      res.status(500).json({ error: 'Internal authorization error' });
    }
  };
}
