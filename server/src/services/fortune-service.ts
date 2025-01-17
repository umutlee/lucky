import { DateUtils } from '../utils/date-utils';
import { FortuneCalculator, FortuneFactors } from './fortune-calculator';
import { StorageService } from './storage-service';

export class FortuneService {
  private calculator: FortuneCalculator;
  private dateUtils: DateUtils;

  constructor(
    private readonly storageService: StorageService
  ) {
    this.calculator = new FortuneCalculator();
    this.dateUtils = new DateUtils();
  }

  async getDailyFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:daily:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    await this.storageService.cacheFortune(cacheKey, fortune);
    return fortune;
  }

  async getStudyFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:study:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    await this.storageService.cacheFortune(cacheKey, { study: fortune.study });
    return { study: fortune.study };
  }

  async getCareerFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:career:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    await this.storageService.cacheFortune(cacheKey, { career: fortune.career });
    return { career: fortune.career };
  }

  async getLoveFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:love:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    await this.storageService.cacheFortune(cacheKey, { love: fortune.love });
    return { love: fortune.love };
  }

  private async getFortuneFactors(
    date: string,
    zodiac: string,
    constellation: string
  ): Promise<FortuneFactors> {
    const dateObj = new Date(date);
    const solarTerm = await this.dateUtils.getSolarTerm(date);
    const weekday = dateObj.getDay();
    const lunarDate = await this.dateUtils.getLunarDate(date);

    return {
      solarTerm,
      weekday,
      lunarDay: lunarDate.day,
      zodiac,
      constellation
    };
  }
} 