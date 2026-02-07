import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

interface EntraIdTokenPayload {
  oid: string; // User object ID
  sub: string; // Subject (user ID)
  name: string; // User display name
  email?: string;
  preferred_username?: string;
  roles?: string[]; // App roles assigned to user
  aud: string; // Audience
  iss: string; // Issuer
  exp: number; // Expiration
  iat: number; // Issued at
}

// Configure JWKS client to fetch public keys from Microsoft
const client = jwksClient({
  jwksUri: process.env.JWT_JWKS_URI || `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}/discovery/v2.0/keys`,
  cache: true,
  rateLimit: true,
  jwksRequestsPerMinute: 5,
});

// Helper to get signing key
function getKey(header: any, callback: any) {
  client.getSigningKey(header.kid, (err, key) => {
    if (err) {
      callback(err);
      return;
    }
    const signingKey = key?.getPublicKey();
    callback(null, signingKey);
  });
}

// Extend Express Request to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        name: string;
        email?: string;
        roles: string[];
        token?: string;
      };
    }
  }
}

/**
 * Middleware to authenticate requests using Azure Entra ID JWT tokens
 */
export function authenticateJWT(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'error',
      message: 'No authorization token provided',
    });
  }

  const token = authHeader.substring(7);

  // Verify JWT token using Microsoft's public keys
  jwt.verify(
    token,
    getKey,
    {
      audience: process.env.JWT_AUDIENCE,
      issuer: process.env.JWT_ISSUER,
      algorithms: ['RS256'],
    },
    (err, decoded) => {
      if (err) {
        console.error('JWT verification failed:', err.message);
        return res.status(401).json({
          status: 'error',
          message: 'Invalid or expired token',
          details: process.env.NODE_ENV === 'development' ? err.message : undefined,
        });
      }

      const payload = decoded as EntraIdTokenPayload;

      // Attach user info to request
      req.user = {
        id: payload.oid || payload.sub,
        name: payload.name,
        email: payload.email || payload.preferred_username,
        roles: payload.roles || [],
        token,
      };

      next();
    }
  );
}

/**
 * Middleware to require specific roles (RBAC)
 * Usage: app.get('/admin', authenticateJWT, requireRole('Admin'), handler)
 */
export function requireRole(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required',
      });
    }

    const userRoles = req.user.roles || [];
    const hasPermission = allowedRoles.some((role) => userRoles.includes(role));

    if (!hasPermission) {
      console.warn(`User ${req.user.id} denied access. Required: ${allowedRoles.join(', ')}, Has: ${userRoles.join(', ')}`);
      
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions',
        required: allowedRoles,
        current: userRoles,
      });
    }

    next();
  };
}

/**
 * Middleware to check if user has ANY of the specified roles
 */
export function requireAnyRole(...allowedRoles: string[]) {
  return requireRole(...allowedRoles);
}

/**
 * Middleware to check if user has ALL of the specified roles
 */
export function requireAllRoles(...requiredRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required',
      });
    }

    const userRoles = req.user.roles || [];
    const hasAllRoles = requiredRoles.every((role) => userRoles.includes(role));

    if (!hasAllRoles) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions - all roles required',
        required: requiredRoles,
        current: userRoles,
      });
    }

    next();
  };
}

/**
 * Optional authentication - doesn't fail if no token, just doesn't set req.user
 * Useful for endpoints that have public + authenticated views
 */
export function optionalAuth(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(); // No auth provided, continue without user
  }

  // Try to authenticate, but don't fail
  authenticateJWT(req, res, (err) => {
    if (err) {
      console.warn('Optional auth failed, continuing without user');
    }
    next();
  });
}

/**
 * Helper function to check if current user has a specific role
 */
export function hasRole(req: Request, role: string): boolean {
  return req.user?.roles?.includes(role) ?? false;
}

/**
 * Helper function to check if current user is an admin
 */
export function isAdmin(req: Request): boolean {
  return hasRole(req, 'Admin');
}

/**
 * Helper function to check if current user can edit (Admin or Maintainer)
 */
export function canEdit(req: Request): boolean {
  return hasRole(req, 'Admin') || hasRole(req, 'Maintainer');
}
