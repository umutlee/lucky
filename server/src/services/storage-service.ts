export interface StorageService {
  getCachedFortune<T>(key: string): Promise<T | null>;
  cacheFortune<T>(key: string, data: T): Promise<void>;
  clearCache(): Promise<void>;
} 