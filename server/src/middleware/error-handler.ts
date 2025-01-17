import { Request, Response, NextFunction } from 'express';
import { Logger } from '../utils/logger';

const logger = Logger.getInstance();

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (err instanceof AppError) {
    if (err.statusCode >= 500) {
      logger.error('操作錯誤', err, {
        url: req.url,
        method: req.method,
        body: req.body
      });
    } else {
      logger.warn(err.message, {
        url: req.url,
        method: req.method,
        statusCode: err.statusCode
      });
    }

    res.status(err.statusCode).json({
      error: err.message,
      isOperational: err.isOperational
    });
    return;
  }

  // 處理未知錯誤
  logger.error('未知錯誤', err, {
    url: req.url,
    method: req.method,
    body: req.body
  });

  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
};

export const notFoundHandler = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  logger.warn('路徑不存在', {
    url: req.url,
    method: req.method
  });

  res.status(404).json({
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.url}`
  });
}; 