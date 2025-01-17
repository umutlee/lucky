export interface LunarDate {
  year: number;
  month: number;
  day: number;
  isLeap: boolean;
}

export class DateUtils {
  private readonly solarTerms2024: { [key: string]: string } = {
    '2024-02-04': '立春',
    '2024-02-19': '雨水',
    '2024-03-05': '驚蟄',
    '2024-03-20': '春分',
    '2024-04-04': '清明',
    '2024-04-20': '穀雨',
    '2024-05-05': '立夏',
    '2024-05-21': '小滿',
    '2024-06-05': '芒種',
    '2024-06-21': '夏至',
    '2024-07-07': '小暑',
    '2024-07-22': '大暑',
    '2024-08-07': '立秋',
    '2024-08-23': '處暑',
    '2024-09-07': '白露',
    '2024-09-22': '秋分',
    '2024-10-08': '寒露',
    '2024-10-23': '霜降',
    '2024-11-07': '立冬',
    '2024-11-22': '小雪',
    '2024-12-07': '大雪',
    '2024-12-21': '冬至',
    '2024-01-06': '小寒',
    '2024-01-20': '大寒'
  };

  async getSolarTerm(date: string): Promise<string | null> {
    // 簡化版：直接查表
    return this.solarTerms2024[date] || null;
  }

  async getLunarDate(date: string): Promise<LunarDate> {
    // 簡化版：使用固定偏移
    const timestamp = new Date(date).getTime();
    const baseTimestamp = new Date('2024-02-10').getTime(); // 農曆正月初一
    const dayDiff = Math.floor((timestamp - baseTimestamp) / (24 * 60 * 60 * 1000));
    
    // 簡單的月份計算（每月30天）
    const month = Math.floor(dayDiff / 30) + 1;
    const day = (dayDiff % 30) + 1;

    return {
      year: 2024,
      month: month > 0 ? month : 12,
      day: day > 0 ? day : 30,
      isLeap: false
    };
  }

  formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }

  parseDate(dateString: string): Date {
    return new Date(dateString);
  }

  isValidDate(dateString: string): boolean {
    const date = new Date(dateString);
    return date instanceof Date && !isNaN(date.getTime());
  }
} 