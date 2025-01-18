import { HoroscopeApi, HoroscopeData } from './horoscope-api';
import { ChineseZodiacApi, ChineseZodiacData } from './chinese-zodiac-api';
import { StorageService } from '../storage-service';
import { logger } from '../../utils/logger';

export interface IntegratedFortune {
  overall: number;
  study: number;
  career: number;
  love: number;
  details: {
    horoscope?: HoroscopeData;
    zodiac?: ChineseZodiacData;
    advice: string[];
  };
}

/**
 * 運勢整合服務
 */
export class FortuneIntegrationService {
  private static instance: FortuneIntegrationService;
  private readonly horoscopeApi: HoroscopeApi;
  private readonly zodiacApi: ChineseZodiacApi;
  private readonly storageService: StorageService;

  private constructor() {
    this.horoscopeApi = new HoroscopeApi();
    this.zodiacApi = new ChineseZodiacApi(process.env.RAPIDAPI_KEY || '');
    this.storageService = StorageService.getInstance();
  }

  public static getInstance(): FortuneIntegrationService {
    if (!FortuneIntegrationService.instance) {
      FortuneIntegrationService.instance = new FortuneIntegrationService();
    }
    return FortuneIntegrationService.instance;
  }

  /**
   * 獲取綜合運勢
   */
  async getIntegratedFortune(
    date: string,
    zodiacSign?: string,
    constellation?: string
  ): Promise<IntegratedFortune> {
    try {
      // 檢查緩存
      const cacheKey = `fortune:${date}:${zodiacSign}:${constellation}`;
      const cached = await this.storageService.getCachedFortune(cacheKey);
      if (cached) {
        return cached;
      }

      // 獲取星座運勢
      let horoscope: HoroscopeData | undefined;
      if (constellation) {
        horoscope = await this.horoscopeApi.getDailyHoroscope(constellation);
      }

      // 獲取生肖運勢
      let zodiac: ChineseZodiacData | undefined;
      if (zodiacSign) {
        const year = new Date(date).getFullYear();
        zodiac = await this.zodiacApi.getZodiacFortune(year);
      }

      // 整合運勢數據
      const fortune = this.calculateIntegratedFortune(horoscope, zodiac);

      // 緩存結果
      await this.storageService.cacheFortune(cacheKey, fortune);

      return fortune;
    } catch (error) {
      logger.error(`Failed to get integrated fortune: ${error}`);
      throw new Error(`無法獲取運勢：${error.message}`);
    }
  }

  /**
   * 計算綜合運勢
   */
  private calculateIntegratedFortune(
    horoscope?: HoroscopeData,
    zodiac?: ChineseZodiacData
  ): IntegratedFortune {
    const baseScore = 60;
    const horoscopeWeight = 0.6;
    const zodiacWeight = 0.4;

    let overall = baseScore;
    let study = baseScore;
    let career = baseScore;
    let love = baseScore;

    if (horoscope) {
      // 根據星座運勢調整分數
      const moodScore = this.getMoodScore(horoscope.mood);
      overall += moodScore * horoscopeWeight;
      study += moodScore * horoscopeWeight;
      career += moodScore * horoscopeWeight;
      love += moodScore * horoscopeWeight;
    }

    if (zodiac) {
      // 根據生肖運勢調整分數
      overall += zodiac.fortune.overall * zodiacWeight;
      career += zodiac.fortune.career * zodiacWeight;
      love += zodiac.fortune.love * zodiacWeight;
    }

    return {
      overall: Math.min(Math.max(Math.round(overall), 0), 100),
      study: Math.min(Math.max(Math.round(study), 0), 100),
      career: Math.min(Math.max(Math.round(career), 0), 100),
      love: Math.min(Math.max(Math.round(love), 0), 100),
      details: {
        horoscope,
        zodiac,
        advice: this.generateAdvice(horoscope, zodiac)
      }
    };
  }

  /**
   * 根據心情計算分數
   */
  private getMoodScore(mood: string): number {
    const moodScores: { [key: string]: number } = {
      'happy': 20,
      'excited': 15,
      'calm': 10,
      'neutral': 0,
      'anxious': -10,
      'sad': -15
    };
    return moodScores[mood.toLowerCase()] || 0;
  }

  /**
   * 生成建議
   */
  private generateAdvice(
    horoscope?: HoroscopeData,
    zodiac?: ChineseZodiacData
  ): string[] {
    const advice: string[] = [];

    if (horoscope) {
      advice.push(`今日幸運色：${horoscope.color}`);
      advice.push(`幸運時段：${horoscope.lucky_time}`);
    }

    if (zodiac) {
      if (zodiac.elements.lucky_directions.length > 0) {
        advice.push(`吉利方位：${zodiac.elements.lucky_directions.join('、')}`);
      }
      if (zodiac.elements.lucky_numbers.length > 0) {
        advice.push(`幸運數字：${zodiac.elements.lucky_numbers.join('、')}`);
      }
    }

    return advice;
  }
} 