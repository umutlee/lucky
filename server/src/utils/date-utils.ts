import calendar from 'lunar-calendar';
import { logger } from './logger';

export interface LunarDateInfo {
  year: number;
  month: number;
  day: number;
  isLeap: boolean;
}

export class DateUtils {
  /**
   * 將陽曆日期轉換為農曆日期
   * @param date 陽曆日期字符串 (YYYY-MM-DD)
   * @returns 農曆日期信息
   */
  async getLunarDate(date: string): Promise<LunarDateInfo> {
    try {
      const [year, month, day] = date.split('-').map(Number);
      const lunar = calendar.solarToLunar(year, month, day);
      
      if (!lunar) {
        throw new Error('無效的日期');
      }

      return {
        year: lunar.year,
        month: lunar.month,
        day: lunar.day,
        isLeap: lunar.isLeap || false
      };
    } catch (error) {
      logger.error(`農曆日期轉換錯誤: ${error}`);
      throw error;
    }
  }

  /**
   * 獲取指定日期的節氣
   * @param date 陽曆日期字符串 (YYYY-MM-DD)
   * @returns 節氣名稱，如果當日不是節氣則返回 null
   */
  async getSolarTerm(date: string): Promise<string | null> {
    try {
      const [year, month, day] = date.split('-').map(Number);
      const lunar = calendar.solarToLunar(year, month, day);
      
      return lunar?.solarTerm || null;
    } catch (error) {
      logger.error(`節氣獲取錯誤: ${error}`);
      throw error;
    }
  }

  /**
   * 獲取指定年份的所有節氣
   * @param year 年份
   * @returns 節氣列表，包含名稱和日期
   */
  async getAllSolarTerms(year: number): Promise<Array<{name: string; date: string}>> {
    try {
      const terms = [];
      for (let month = 1; month <= 12; month++) {
        for (let day = 1; day <= 31; day++) {
          try {
            const lunar = calendar.solarToLunar(year, month, day);
            if (lunar?.solarTerm) {
              terms.push({
                name: lunar.solarTerm,
                date: `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
              });
            }
          } catch {
            // 跳過無效日期
            continue;
          }
        }
      }
      return terms;
    } catch (error) {
      logger.error(`獲取節氣列表錯誤: ${error}`);
      throw error;
    }
  }

  /**
   * 驗證日期格式是否正確
   * @param date 日期字符串 (YYYY-MM-DD)
   * @returns 是否為有效日期
   */
  isValidDate(date: string): boolean {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (!regex.test(date)) {
      return false;
    }

    const [year, month, day] = date.split('-').map(Number);
    const d = new Date(year, month - 1, day);
    return d.getFullYear() === year && 
           d.getMonth() === month - 1 && 
           d.getDate() === day;
  }
} 