import { ApiClient } from './api-client';

export interface ChineseZodiacData {
  sign: string;
  year: number;
  fortune: {
    overall: number;
    wealth: number;
    love: number;
    career: number;
    health: number;
  };
  elements: {
    lucky_colors: string[];
    lucky_numbers: string[];
    lucky_directions: string[];
  };
  compatibility: {
    best: string[];
    worst: string[];
  };
}

/**
 * 生肖運勢 API 客戶端
 */
export class ChineseZodiacApi extends ApiClient {
  constructor(apiKey: string) {
    super('https://chinese-zodiac.p.rapidapi.com', apiKey);
  }

  /**
   * 獲取生肖運勢
   * @param year 年份
   */
  async getZodiacFortune(year: number): Promise<ChineseZodiacData> {
    try {
      const response = await this.get<ChineseZodiacData>(`/zodiac/year/${year}`);
      return response;
    } catch (error) {
      logger.error(`Failed to get zodiac fortune for year ${year}: ${error}`);
      throw new Error(`無法獲取生肖運勢：${error.message}`);
    }
  }

  /**
   * 獲取生肖配對
   * @param sign1 第一個生肖
   * @param sign2 第二個生肖
   */
  async getCompatibility(sign1: string, sign2: string): Promise<any> {
    try {
      const response = await this.get('/compatibility', {
        sign1: this.getSignInEnglish(sign1),
        sign2: this.getSignInEnglish(sign2)
      });
      return response;
    } catch (error) {
      logger.error(`Failed to get compatibility for ${sign1} and ${sign2}: ${error}`);
      throw new Error(`無法獲取生肖配對：${error.message}`);
    }
  }

  /**
   * 轉換生肖名稱為英文
   */
  private getSignInEnglish(sign: string): string {
    const signMap: { [key: string]: string } = {
      '鼠': 'rat',
      '牛': 'ox',
      '虎': 'tiger',
      '兔': 'rabbit',
      '龍': 'dragon',
      '蛇': 'snake',
      '馬': 'horse',
      '羊': 'goat',
      '猴': 'monkey',
      '雞': 'rooster',
      '狗': 'dog',
      '豬': 'pig'
    };
    
    return signMap[sign] || sign.toLowerCase();
  }
} 