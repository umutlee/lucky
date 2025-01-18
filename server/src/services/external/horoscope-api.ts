import { ApiClient } from './api-client';

export interface HoroscopeData {
  date_range: string;
  current_date: string;
  description: string;
  compatibility: string;
  mood: string;
  color: string;
  lucky_number: string;
  lucky_time: string;
}

/**
 * 星座運勢 API 客戶端
 */
export class HoroscopeApi extends ApiClient {
  constructor() {
    super('https://aztro.sameerkumar.website');
  }

  /**
   * 獲取星座運勢
   * @param sign 星座名稱
   * @param day 日期類型（today, tomorrow, yesterday）
   */
  async getDailyHoroscope(sign: string, day: string = 'today'): Promise<HoroscopeData> {
    try {
      const response = await this.post<HoroscopeData>('/', {
        sign,
        day
      });
      
      return response;
    } catch (error) {
      logger.error(`Failed to get horoscope for ${sign}: ${error}`);
      throw new Error(`無法獲取星座運勢：${error.message}`);
    }
  }

  /**
   * 轉換星座名稱為英文
   */
  private getSignInEnglish(sign: string): string {
    const signMap: { [key: string]: string } = {
      '白羊座': 'aries',
      '金牛座': 'taurus',
      '雙子座': 'gemini',
      '巨蟹座': 'cancer',
      '獅子座': 'leo',
      '處女座': 'virgo',
      '天秤座': 'libra',
      '天蠍座': 'scorpio',
      '射手座': 'sagittarius',
      '摩羯座': 'capricorn',
      '水瓶座': 'aquarius',
      '雙魚座': 'pisces'
    };
    
    return signMap[sign] || sign.toLowerCase();
  }
} 