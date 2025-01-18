import { DailyAlmanac, MonthlyAlmanac, SolarTerms, LunarDate } from '../models/almanac';
import { DateUtils } from '../utils/date-utils';
import { logger } from '../utils/logger';

export class AlmanacService {
  private static instance: AlmanacService;
  private dateUtils: DateUtils;

  private constructor() {
    this.dateUtils = new DateUtils();
  }

  static getInstance(): AlmanacService {
    if (!AlmanacService.instance) {
      AlmanacService.instance = new AlmanacService();
    }
    return AlmanacService.instance;
  }

  async getDailyAlmanac(date: string): Promise<DailyAlmanac> {
    logger.info(`Calculating daily almanac for date: ${date}`);
    
    try {
      const lunarDate = await this.dateUtils.getLunarDate(date);
      const solarTerm = await this.dateUtils.getSolarTerm(date);
      
      // 根據日期特徵決定宜忌
      const suitable = this.getSuitableActivities(lunarDate.day, solarTerm);
      const unsuitable = this.getUnsuitableActivities(lunarDate.day, solarTerm);

      return {
        date,
        lunar_date: `${lunarDate.year}年${lunarDate.month}月${lunarDate.day}日${lunarDate.isLeap ? '閏' : ''}`,
        zodiac: this.getZodiacByYear(lunarDate.year),
        stem_branch: this.getStemBranchByYear(lunarDate.year),
        suitable,
        unsuitable,
      };
    } catch (error) {
      logger.error(`獲取日曆信息錯誤: ${error}`);
      throw error;
    }
  }

  async getMonthlyAlmanac(year: number, month: number): Promise<MonthlyAlmanac> {
    logger.info(`Calculating monthly almanac for year: ${year}, month: ${month}`);
    
    if (month < 1 || month > 12) {
      throw new Error('月份必須在 1 到 12 之間');
    }

    const yearStr = year.toString();
    const monthStr = month.toString().padStart(2, '0');
    const days = [];

    // 獲取該月的天數
    const daysInMonth = new Date(year, month, 0).getDate();

    for (let day = 1; day <= daysInMonth; day++) {
      const date = `${yearStr}-${monthStr}-${day.toString().padStart(2, '0')}`;
      const dailyAlmanac = await this.getDailyAlmanac(date);
      days.push(dailyAlmanac);
    }

    return {
      year: yearStr,
      month: monthStr,
      days
    };
  }

  async getSolarTerms(year: number): Promise<SolarTerms> {
    logger.info(`Calculating solar terms for year: ${year}`);
    
    try {
      const terms = await this.dateUtils.getAllSolarTerms(year);
      return {
        year: year.toString(),
        terms: terms.map(term => ({
          name: term.name,
          date: term.date,
          time: '00:00' // 暫時使用固定時間，後續可以優化
        }))
      };
    } catch (error) {
      logger.error(`獲取節氣信息錯誤: ${error}`);
      throw error;
    }
  }

  async getLunarDate(date: string): Promise<LunarDate> {
    logger.info(`Converting to lunar date: ${date}`);
    
    try {
      const lunarDate = await this.dateUtils.getLunarDate(date);
      return {
        solar_date: date,
        lunar_date: `${lunarDate.year}年${lunarDate.month}月${lunarDate.day}日${lunarDate.isLeap ? '閏' : ''}`,
        zodiac: this.getZodiacByYear(lunarDate.year),
        stem_branch: this.getStemBranchByYear(lunarDate.year)
      };
    } catch (error) {
      logger.error(`農曆日期轉換錯誤: ${error}`);
      throw error;
    }
  }

  private getZodiacByYear(year: number): string {
    const zodiacList = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
    return zodiacList[(year - 4) % 12];
  }

  private getStemBranchByYear(year: number): string {
    const stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    
    const stemIndex = (year - 4) % 10;
    const branchIndex = (year - 4) % 12;
    
    return `${stems[stemIndex]}${branches[branchIndex]}`;
  }

  private getSuitableActivities(lunarDay: number, solarTerm: string | null): string[] {
    const activities = ['祭祀', '開市', '求財', '出行', '入學', '結婚', '動土', '安葬'];
    const result = [];

    // 根據農曆日期選擇宜做的事情
    if (lunarDay === 1 || lunarDay === 15) {
      result.push('祭祀', '開市');
    }
    if (lunarDay >= 8 && lunarDay <= 12) {
      result.push('求財', '出行');
    }
    if (lunarDay >= 20 && lunarDay <= 25) {
      result.push('入學', '結婚');
    }

    // 根據節氣增加宜做的事情
    if (solarTerm === '立春' || solarTerm === '立夏') {
      result.push('動土');
    }
    if (solarTerm === '清明') {
      result.push('安葬');
    }

    return [...new Set(result)]; // 去重
  }

  private getUnsuitableActivities(lunarDay: number, solarTerm: string | null): string[] {
    const activities = ['動土', '安葬', '結婚', '出行', '開市'];
    const result = [];

    // 根據農曆日期選擇忌做的事情
    if (lunarDay === 5 || lunarDay === 14 || lunarDay === 23) {
      result.push('動土', '安葬');
    }
    if (lunarDay >= 26 && lunarDay <= 29) {
      result.push('結婚', '出行');
    }

    // 根據節氣增加忌做的事情
    if (solarTerm === '冬至' || solarTerm === '夏至') {
      result.push('開市');
    }

    return [...new Set(result)]; // 去重
  }
} 