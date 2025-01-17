import { DailyAlmanac, MonthlyAlmanac, SolarTerms, LunarDate } from '../models/almanac';

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

  async getMonthlyAlmanac(year: string, month: string): Promise<MonthlyAlmanac> {
    return {
      year,
      month,
      days: [
        {
          date: `${year}-${month}-01`,
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

  async getSolarTerms(year: string): Promise<SolarTerms> {
    return {
      year,
      terms: [
        {
          name: '立春',
          date: `${year}-02-04`,
          time: '16:27',
        },
        // ... 其他節氣數據
      ],
    };
  }

  async getLunarDate(date: string): Promise<LunarDate> {
    return {
      solar_date: date,
      lunar_date: '三月初一',
      zodiac: '兔',
      stem_branch: '癸卯',
    };
  }
} 