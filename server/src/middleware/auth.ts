import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';

export interface AuthenticatedRequest extends Request {
  apiKey?: string;
  environment?: string;
}

export const validateApiKey = (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  const apiKey = req.headers['x-api-key'];

  if (!apiKey || typeof apiKey !== 'string') {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing API key'
    });
  }

  // 驗證 API 密鑰格式
  const [env, key] = apiKey.split('_');
  if (!env || !key || !['DEV', 'TEST', 'PROD'].includes(env)) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Invalid API key format'
    });
  }

  // 驗證 API 密鑰
  const secret = process.env.API_KEY_SECRET;
  if (!secret) {
    console.error('API_KEY_SECRET is not set');
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'Server configuration error'
    });
  }

  // 在請求對象中保存 API 密鑰信息
  req.apiKey = apiKey;
  req.environment = env;

  next();
}; 