import { Response, NextFunction } from 'express';
import { AppError } from './errorHandler.js';
import { AuthRequest } from './authenticate.js';

type Permission = 'read' | 'write' | 'delete' | 'admin';

const rolePermissions: Record<string, Permission[]> = {
  ADMIN: ['read', 'write', 'delete', 'admin'],
  EDITOR: ['read', 'write'],
  VIEWER: ['read'],
};

export const authorize = (...requiredPermissions: Permission[]) => {
  return (req: AuthRequest, _res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AppError(401, 'User not authenticated');
    }

    const userPermissions = rolePermissions[req.user.role] || [];

    const hasPermission = requiredPermissions.every((permission) =>
      userPermissions.includes(permission)
    );

    if (!hasPermission) {
      throw new AppError(
        403,
        'Insufficient permissions to perform this action'
      );
    }

    next();
  };
};
