import { FortuneService } from '../fortune-service';
import { StorageService } from '../storage-service';
import { DateUtils } from '../../utils/date-utils';

// Mock StorageService
class MockStorageService implements StorageService {
  private cache: Map<string, any> = new Map();

  async getCachedFortune<T>(key: string): Promise<T | null> {
    return this.cache.get(key) || null;
  }

  async cacheFortune<T>(key: string, data: T): Promise<void> {
    this.cache.set(key, data);
  }

  async clearCache(): Promise<void> {
    this.cache.clear();
  }
}

describe('FortuneService', () => {
  let service: FortuneService;
  let storageService: StorageService;

  beforeEach(() => {
    storageService = new MockStorageService();
    service = new FortuneService(storageService);
  });

  describe('getDailyFortune', () => {
    it('應該返回包含所有運勢類型的結果', async () => {
      const result = await service.getDailyFortune('2024-01-01', '龍', '獅子座');

      expect(result).toHaveProperty('overall');
      expect(result).toHaveProperty('study');
      expect(result).toHaveProperty('career');
      expect(result).toHaveProperty('love');
    });

    it('應該使用緩存的結果', async () => {
      const date = '2024-01-01';
      const zodiac = '龍';
      const constellation = '獅子座';
      
      // 第一次調用
      const firstResult = await service.getDailyFortune(date, zodiac, constellation);
      
      // 第二次調用應該返回相同的結果
      const secondResult = await service.getDailyFortune(date, zodiac, constellation);
      
      expect(secondResult).toEqual(firstResult);
    });
  });

  describe('getStudyFortune', () => {
    it('應該只返回學業運', async () => {
      const result = await service.getStudyFortune('2024-01-01', '龍', '獅子座');

      expect(result).toHaveProperty('study');
      expect(Object.keys(result)).toHaveLength(1);
    });
  });

  describe('getCareerFortune', () => {
    it('應該只返回事業運', async () => {
      const result = await service.getCareerFortune('2024-01-01', '龍', '獅子座');

      expect(result).toHaveProperty('career');
      expect(Object.keys(result)).toHaveLength(1);
    });
  });

  describe('getLoveFortune', () => {
    it('應該只返回愛情運', async () => {
      const result = await service.getLoveFortune('2024-01-01', '龍', '獅子座');

      expect(result).toHaveProperty('love');
      expect(Object.keys(result)).toHaveLength(1);
    });
  });

  describe('緩存機制', () => {
    it('不同的參數組合應該產生不同的緩存鍵', async () => {
      const result1 = await service.getDailyFortune('2024-02-04', '龍', '獅子座'); // 立春
      const result2 = await service.getDailyFortune('2024-03-20', '龍', '獅子座'); // 春分
      const result3 = await service.getDailyFortune('2024-02-04', '虎', '獅子座'); // 立春，不同生肖
      const result4 = await service.getDailyFortune('2024-02-04', '龍', '處女座'); // 立春，不同星座

      expect(result1).not.toEqual(result2); // 不同日期（不同節氣）
      expect(result1).not.toEqual(result3); // 不同生肖
      expect(result1).not.toEqual(result4); // 不同星座
    });
  });
}); 