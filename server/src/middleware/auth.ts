import { Request, Response, NextFunction } from 'express';
import { ApiKeyService } from '../services/api-key-service';
import { logger } from '../utils/logger';

// 請求計數器
const requestCounts = new Map<string, { count: number; resetTime: number }>();

/**
 * 驗證 API 密鑰
 */
export const validateApiKey = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const apiKey = req.header('X-API-Key');
    
    if (!apiKey) {
      res.status(401).json({
        error: 'Unauthorized',
        message: '缺少 API 密鑰'
      });
      return;
    }

    const apiKeyService = ApiKeyService.getInstance();
    const apiKeyInfo = await apiKeyService.validateApiKey(apiKey, req.header('Origin'));

    // 將 API 密鑰信息添加到請求對象中
    (req as any).apiKeyInfo = apiKeyInfo;
    
    next();
  } catch (error: any) {
    logger.error(`API key validation failed: ${error.message}`);
    res.status(401).json({
      error: 'Unauthorized',
      message: error.message
    });
  }
};

/**
 * 請求限制中間件
 */
export const rateLimit = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const apiKeyInfo = (req as any).apiKeyInfo;
    if (!apiKeyInfo) {
      res.status(500).json({
        error: 'Internal Server Error',
        message: '無法獲取 API 密鑰信息'
      });
      return;
    }

    const { windowMs, maxRequests } = apiKeyInfo.rateLimit;
    const key = `${apiKeyInfo.key}:${req.ip}`;
    const now = Date.now();

    let requestCount = requestCounts.get(key);

    // 如果是新的請求或者重置時間已過
    if (!requestCount || now > requestCount.resetTime) {
      requestCount = {
        count: 1,
        resetTime: now + windowMs
      };
    } else {
      // 增加請求計數
      requestCount.count++;
    }

    requestCounts.set(key, requestCount);

    // 檢查是否超過限制
    if (requestCount.count > maxRequests) {
      res.status(429).json({
        error: 'Too Many Requests',
        message: '請求頻率超過限制',
        resetTime: new Date(requestCount.resetTime)
      });
      return;
    }

    // 添加剩餘請求信息到響應頭
    res.setHeader('X-RateLimit-Limit', maxRequests);
    res.setHeader('X-RateLimit-Remaining', Math.max(0, maxRequests - requestCount.count));
    res.setHeader('X-RateLimit-Reset', new Date(requestCount.resetTime).toISOString());

    next();
  } catch (error: any) {
    logger.error(`Rate limit check failed: ${error.message}`);
    res.status(500).json({
      error: 'Internal Server Error',
      message: '請求限制檢查失敗'
    });
  }
};

/**
 * 定期清理過期的請求計數
 */
setInterval(() => {
  const now = Date.now();
  for (const [key, value] of requestCounts.entries()) {
    if (now > value.resetTime) {
      requestCounts.delete(key);
    }
  }
}, 60000); // 每分鐘清理一次