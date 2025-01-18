import { logger } from '../utils/logger';
import { ApiKeyInfo } from './api-key-service';

export class StorageService {
  private static instance: StorageService;
  private cache: Map<string, any>;
  private cacheExpiry: Map<string, number>;
  private readonly defaultTTL: number = 12 * 60 * 60 * 1000; // 12 hours in milliseconds
  private readonly apiKeyTTL: number = 30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds

  private constructor() {
    this.cache = new Map();
    this.cacheExpiry = new Map();
  }

  public static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  async getCachedFortune(key: string): Promise<any | null> {
    const value = this.cache.get(key);
    const expiry = this.cacheExpiry.get(key);

    if (!value || !expiry || Date.now() > expiry) {
      if (value) {
        logger.info(`Cache expired for key: ${key}`);
        this.cache.delete(key);
        this.cacheExpiry.delete(key);
      }
      return null;
    }

    return value;
  }

  async cacheFortune(key: string, value: any, ttl: number = this.defaultTTL): Promise<void> {
    this.cache.set(key, value);
    this.cacheExpiry.set(key, Date.now() + ttl);
    logger.debug(`Cached fortune for key: ${key}, TTL: ${ttl}ms`);
  }

  async getCachedApiKey(key: string): Promise<ApiKeyInfo | null> {
    const value = this.cache.get(`apikey:${key}`);
    const expiry = this.cacheExpiry.get(`apikey:${key}`);

    if (!value || !expiry || Date.now() > expiry) {
      if (value) {
        logger.info(`API key cache expired for key: ${key}`);
        this.cache.delete(`apikey:${key}`);
        this.cacheExpiry.delete(`apikey:${key}`);
      }
      return null;
    }

    return value;
  }

  async cacheApiKey(key: string, value: ApiKeyInfo): Promise<void> {
    this.cache.set(`apikey:${key}`, value);
    this.cacheExpiry.set(`apikey:${key}`, Date.now() + this.apiKeyTTL);
    logger.debug(`Cached API key: ${key}, TTL: ${this.apiKeyTTL}ms`);
  }

  async clearExpiredCache(): Promise<void> {
    const now = Date.now();
    for (const [key, expiry] of this.cacheExpiry.entries()) {
      if (now > expiry) {
        this.cache.delete(key);
        this.cacheExpiry.delete(key);
        logger.info(`Cleared expired cache for key: ${key}`);
      }
    }
  }

  async getCacheStats(): Promise<{
    totalEntries: number;
    expiredEntries: number;
    memoryUsage: number;
  }> {
    const now = Date.now();
    let expiredEntries = 0;

    for (const expiry of this.cacheExpiry.values()) {
      if (now > expiry) {
        expiredEntries++;
      }
    }

    // 估算記憶體使用量（粗略計算）
    const memoryUsage = Array.from(this.cache.entries()).reduce((total, [key, value]) => {
      return total + key.length * 2 + JSON.stringify(value).length * 2;
    }, 0);

    return {
      totalEntries: this.cache.size,
      expiredEntries,
      memoryUsage
    };
  }
} 