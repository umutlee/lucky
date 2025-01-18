import crypto from 'crypto';
import { StorageService } from './storage-service';
import { logger } from '../utils/logger';

export interface ApiKeyInfo {
  key: string;           // API 密鑰
  createdAt: Date;       // 創建時間
  expiresAt: Date;       // 過期時間
  isActive: boolean;     // 是否啟用
  allowedOrigins: string[]; // 允許的來源域名
  rateLimit: {           // 請求限制
    windowMs: number;    // 時間窗口（毫秒）
    maxRequests: number; // 最大請求數
  };
}

export class ApiKeyService {
  private static instance: ApiKeyService;
  private readonly keyPrefix: string;
  private readonly keyLength: number;
  private readonly defaultRateLimit: { windowMs: number; maxRequests: number };

  private constructor(
    private readonly storageService: StorageService
  ) {
    this.keyPrefix = process.env.API_KEY_PREFIX || 'lucky_';
    this.keyLength = 32;
    this.defaultRateLimit = {
      windowMs: 60 * 1000, // 1 分鐘
      maxRequests: 60      // 60 次請求
    };
  }

  public static getInstance(): ApiKeyService {
    if (!ApiKeyService.instance) {
      const storageService = StorageService.getInstance();
      ApiKeyService.instance = new ApiKeyService(storageService);
    }
    return ApiKeyService.instance;
  }

  /**
   * 生成新的 API 密鑰
   * @param allowedOrigins 允許的來源域名
   * @param expiresIn 過期時間（毫秒），默認 30 天
   * @param rateLimit 自定義請求限制
   */
  public async generateApiKey(
    allowedOrigins: string[] = ['*'],
    expiresIn: number = 30 * 24 * 60 * 60 * 1000,
    rateLimit = this.defaultRateLimit
  ): Promise<ApiKeyInfo> {
    try {
      const randomBytes = crypto.randomBytes(this.keyLength);
      const key = this.keyPrefix + randomBytes.toString('hex');
      
      const apiKeyInfo: ApiKeyInfo = {
        key,
        createdAt: new Date(),
        expiresAt: new Date(Date.now() + expiresIn),
        isActive: true,
        allowedOrigins,
        rateLimit
      };

      await this.storageService.cacheApiKey(key, apiKeyInfo);
      logger.info(`Generated new API key: ${key}`);
      
      return apiKeyInfo;
    } catch (error) {
      logger.error(`Error generating API key: ${error}`);
      throw new Error('無法生成 API 密鑰');
    }
  }

  /**
   * 驗證 API 密鑰
   * @param key API 密鑰
   * @param origin 請求來源
   */
  public async validateApiKey(key: string, origin?: string): Promise<ApiKeyInfo> {
    try {
      const apiKeyInfo = await this.storageService.getCachedApiKey(key);
      
      if (!apiKeyInfo) {
        throw new Error('無效的 API 密鑰');
      }

      if (!apiKeyInfo.isActive) {
        throw new Error('API 密鑰已停用');
      }

      if (Date.now() > apiKeyInfo.expiresAt.getTime()) {
        throw new Error('API 密鑰已過期');
      }

      if (origin && !this.isOriginAllowed(origin, apiKeyInfo.allowedOrigins)) {
        throw new Error('請求來源未授權');
      }

      return apiKeyInfo;
    } catch (error) {
      logger.error(`API key validation error: ${error}`);
      throw error;
    }
  }

  /**
   * 停用 API 密鑰
   * @param key API 密鑰
   */
  public async deactivateApiKey(key: string): Promise<void> {
    try {
      const apiKeyInfo = await this.storageService.getCachedApiKey(key);
      
      if (!apiKeyInfo) {
        throw new Error('無效的 API 密鑰');
      }

      apiKeyInfo.isActive = false;
      await this.storageService.cacheApiKey(key, apiKeyInfo);
      logger.info(`Deactivated API key: ${key}`);
    } catch (error) {
      logger.error(`Error deactivating API key: ${error}`);
      throw error;
    }
  }

  /**
   * 更新 API 密鑰的請求限制
   * @param key API 密鑰
   * @param rateLimit 新的請求限制
   */
  public async updateRateLimit(
    key: string,
    rateLimit: { windowMs: number; maxRequests: number }
  ): Promise<ApiKeyInfo> {
    try {
      const apiKeyInfo = await this.storageService.getCachedApiKey(key);
      
      if (!apiKeyInfo) {
        throw new Error('無效的 API 密鑰');
      }

      apiKeyInfo.rateLimit = rateLimit;
      await this.storageService.cacheApiKey(key, apiKeyInfo);
      logger.info(`Updated rate limit for API key: ${key}`);
      
      return apiKeyInfo;
    } catch (error) {
      logger.error(`Error updating rate limit: ${error}`);
      throw error;
    }
  }

  /**
   * 更新允許的來源域名
   * @param key API 密鑰
   * @param allowedOrigins 新的允許來源域名列表
   */
  public async updateAllowedOrigins(
    key: string,
    allowedOrigins: string[]
  ): Promise<ApiKeyInfo> {
    try {
      const apiKeyInfo = await this.storageService.getCachedApiKey(key);
      
      if (!apiKeyInfo) {
        throw new Error('無效的 API 密鑰');
      }

      apiKeyInfo.allowedOrigins = allowedOrigins;
      await this.storageService.cacheApiKey(key, apiKeyInfo);
      logger.info(`Updated allowed origins for API key: ${key}`);
      
      return apiKeyInfo;
    } catch (error) {
      logger.error(`Error updating allowed origins: ${error}`);
      throw error;
    }
  }

  /**
   * 檢查來源是否被允許
   * @param origin 請求來源
   * @param allowedOrigins 允許的來源列表
   */
  private isOriginAllowed(origin: string, allowedOrigins: string[]): boolean {
    return allowedOrigins.includes('*') || allowedOrigins.includes(origin);
  }
} 