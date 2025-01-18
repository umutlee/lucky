import { logger } from '../utils/logger';

export class StorageService {
  private static instance: StorageService;
  private cache: Map<string, any>;
  private cacheExpiry: Map<string, number>;
  private readonly defaultTTL: number = 12 * 60 * 60 * 1000; // 12 hours in milliseconds

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