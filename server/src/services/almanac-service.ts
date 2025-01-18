import { DailyAlmanac, MonthlyAlmanac, SolarTerms, LunarDate } from '../models/almanac';
import { logger } from '../utils/logger';

export class AlmanacService {
  private static instance: AlmanacService;

  private constructor() {}

  static getInstance(): AlmanacService {
    if (!AlmanacService.instance) {
      AlmanacService.instance = new AlmanacService();
    }
    return AlmanacService.instance;
  }

  async getDailyAlmanac(date: string): Promise<DailyAlmanac> {
    logger.info(`Calculating daily almanac for date: ${date}`);
    // TODO: 實現黃曆查詢邏輯
    return {
      date,
      lunar_date: '癸卯年三月初一',
      zodiac: '兔',
      stem_branch: '癸卯',
      suitable: ['祭祀', '開市', '求財'],
      unsuitable: ['動土', '安葬'],
    };
  }

  async getMonthlyAlmanac(year: number, month: number): Promise<MonthlyAlmanac> {
    logger.info(`Calculating monthly almanac for year: ${year}, month: ${month}`);
    
    // 確保月份在有效範圍內
    if (month < 1 || month > 12) {
      throw new Error('Month must be between 1 and 12');
    }

    // 格式化年月以保持一致的字符串格式
    const yearStr = year.toString();
    const monthStr = month.toString().padStart(2, '0');

    return {
      year: yearStr,
      month: monthStr,
      days: [
        {
          date: `${yearStr}-${monthStr}-01`,
          lunar_date: '三月初一',
          zodiac: '兔',
          stem_branch: '癸卯',
          suitable: ['祭祀'],
          unsuitable: ['動土'],
        },
        // ... 其他日期數據
      ],
    };
  }

  async getSolarTerms(year: number): Promise<SolarTerms> {
    logger.info(`Calculating solar terms for year: ${year}`);
    
    const yearStr = year.toString();
    
    return {
      year: yearStr,
      terms: [
        {
          name: '立春',
          date: `${yearStr}-02-04`,
          time: '16:27',
        },
        // ... 其他節氣數據
      ],
    };
  }

  async getLunarDate(date: string): Promise<LunarDate> {
    logger.info(`Converting to lunar date: ${date}`);
    
    return {
      solar_date: date,
      lunar_date: '三月初一',
      zodiac: '兔',
      stem_branch: '癸卯',
    };
  }
} 