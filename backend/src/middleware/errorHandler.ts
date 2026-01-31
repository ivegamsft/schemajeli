import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger.js';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: Error | AppError,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.error('Application Error:', {
      statusCode: err.statusCode,
      message: err.message,
      stack: err.stack,
    });

    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message,
    });
  }

  // Unhandled errors
  logger.error('Unhandled Error:', {
    message: err.message,
    stack: err.stack,
  });

  return res.status(500).json({
    status: 'error',
    message: 'Internal server error',
  });
};
