import { DateUtils } from '../utils/date-utils';
import { FortuneCalculator, FortuneFactors } from './fortune-calculator';
import { StorageService } from './storage-service';
import { logger } from '../utils/logger';

export class FortuneService {
  private static instance: FortuneService;
  private calculator: FortuneCalculator;
  private dateUtils: DateUtils;

  private constructor(
    private readonly storageService: StorageService
  ) {
    this.calculator = new FortuneCalculator();
    this.dateUtils = new DateUtils();
  }

  public static getInstance(): FortuneService {
    if (!FortuneService.instance) {
      const storageService = StorageService.getInstance();
      FortuneService.instance = new FortuneService(storageService);
    }
    return FortuneService.instance;
  }

  async getDailyFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:daily:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      logger.info(`Cache hit for daily fortune: ${cacheKey}`);
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    await this.storageService.cacheFortune(cacheKey, fortune);
    logger.info(`Calculated and cached daily fortune for: ${cacheKey}`);
    return fortune;
  }

  async getStudyFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:study:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      logger.info(`Cache hit for study fortune: ${cacheKey}`);
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    const studyFortune = { study: fortune.study };
    await this.storageService.cacheFortune(cacheKey, studyFortune);
    logger.info(`Calculated and cached study fortune for: ${cacheKey}`);
    return studyFortune;
  }

  async getCareerFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:career:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      logger.info(`Cache hit for career fortune: ${cacheKey}`);
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    const careerFortune = { career: fortune.career };
    await this.storageService.cacheFortune(cacheKey, careerFortune);
    logger.info(`Calculated and cached career fortune for: ${cacheKey}`);
    return careerFortune;
  }

  async getLoveFortune(date: string, zodiac: string, constellation: string) {
    const cacheKey = `fortune:love:${date}:${zodiac}:${constellation}`;
    const cached = await this.storageService.getCachedFortune(cacheKey);
    if (cached) {
      logger.info(`Cache hit for love fortune: ${cacheKey}`);
      return cached;
    }

    const factors = await this.getFortuneFactors(date, zodiac, constellation);
    const fortune = this.calculator.calculateOverallFortune(factors);
    
    const loveFortune = { love: fortune.love };
    await this.storageService.cacheFortune(cacheKey, loveFortune);
    logger.info(`Calculated and cached love fortune for: ${cacheKey}`);
    return loveFortune;
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