import { DateUtils } from '../utils/date-utils';
import { logger } from '../utils/logger';

export interface FortuneFactors {
  solarTerm: string | null;  // 節氣
  weekday: number;          // 星期幾（0-6）
  lunarDay: number;         // 農曆日期
}

export interface FortuneScore {
  overall: number;         // 整體運（0-100）
  activity: number;       // 活動建議（0-100）
  timing: number;         // 時機參考（0-100）
  details: {              
    positive: string[];   // 正面提示
    negative: string[];   // 需要注意
    advice: string[];     // 建議
  };
}

export class FortuneCalculator {
  private static readonly BASE_SCORE = 70;  // 基礎分數
  private static readonly FACTOR_WEIGHTS = {
    solarTerm: 0.4,      // 節氣權重
    weekday: 0.3,        // 星期權重
    lunarDay: 0.3,       // 農曆日期權重
  };

  // 節氣活動建議
  private static readonly SOLAR_TERM_ACTIVITIES: { [key: string]: string[] } = {
    '立春': ['戶外活動', '春季大掃除', '計劃新目標'],
    '雨水': ['室內活動', '讀書學習', '保養身體'],
    '驚蟄': ['運動健身', '開始新計劃', '社交聚會'],
    '春分': ['踏青郊遊', '園藝活動', '健康檢查'],
    '清明': ['掃墓追思', '親友聚會', '戶外活動'],
    '穀雨': ['室內活動', '學習充電', '保健養生'],
    '立夏': ['戶外運動', '游泳戲水', '防曬護理'],
    '小滿': ['規劃行程', '整理環境', '健康飲食'],
    '芒種': ['室內活動', '學習進修', '保養身體'],
    '夏至': ['避暑活動', '游泳戲水', '清淡飲食'],
    '小暑': ['室內運動', '防暑降溫', '作息規律'],
    '大暑': ['避暑休息', '室內活動', '補充水分'],
    '立秋': ['秋季旅行', '收心學習', '養生保健'],
    '處暑': ['戶外活動', '運動健身', '飲食調理'],
    '白露': ['秋遊踏青', '讀書學習', '早睡早起'],
    '秋分': ['郊遊賞月', '親友聚會', '保養身體'],
    '寒露': ['室內活動', '保暖禦寒', '養生保健'],
    '霜降': ['秋季旅行', '整理環境', '注意保暖'],
    '立冬': ['室內活動', '保暖禦寒', '養生進補'],
    '小雪': ['冬季旅行', '室內運動', '保暖防寒'],
    '大雪': ['室內活動', '讀書學習', '保養身體'],
    '冬至': ['家庭聚會', '室內活動', '養生保健'],
    '小寒': ['室內運動', '保暖禦寒', '早睡早起'],
    '大寒': ['室內活動', '保養身體', '注意保暖']
  };

  // 星期活動建議
  private static readonly WEEKDAY_ACTIVITIES: { [key: number]: string[] } = {
    0: ['休息放鬆', '家庭活動', '規劃新一週'],
    1: ['開展計劃', '重要會議', '學習進修'],
    2: ['執行任務', '團隊合作', '健身運動'],
    3: ['溝通交流', '創意工作', '社交活動'],
    4: ['檢視進度', '完成任務', '放鬆身心'],
    5: ['總結工作', '聚會交友', '購物休閒'],
    6: ['休閒娛樂', '戶外活動', '家庭時光']
  };

  // 計算整體運勢
  public calculateOverallFortune(factors: FortuneFactors): FortuneScore {
    const baseScore = this.calculateBaseScore(factors);
    const details = this.analyzeFactors(factors);
    
    return {
      overall: this.adjustScore(baseScore),
      activity: this.adjustScore(this.calculateActivityScore(factors)),
      timing: this.adjustScore(this.calculateTimingScore(factors)),
      details
    };
  }

  // 分析影響因素
  private analyzeFactors(factors: FortuneFactors): FortuneScore['details'] {
    const positive: string[] = [];
    const negative: string[] = [];
    const advice: string[] = [];

    // 節氣建議
    if (factors.solarTerm && FortuneCalculator.SOLAR_TERM_ACTIVITIES[factors.solarTerm]) {
      const activities = FortuneCalculator.SOLAR_TERM_ACTIVITIES[factors.solarTerm];
      positive.push(`${factors.solarTerm}適合：${activities.join('、')}`);
    }

    // 星期建議
    const weekdayActivities = FortuneCalculator.WEEKDAY_ACTIVITIES[factors.weekday];
    if (weekdayActivities) {
      advice.push(`今天適合：${weekdayActivities.join('、')}`);
    }

    // 農曆日期建議
    if (factors.lunarDay === 1 || factors.lunarDay === 15) {
      advice.push('農曆月初或月中，適合：規劃新目標、整理環境、保養身心');
    }

    return { positive, negative, advice };
  }

  // 計算基礎分數
  private calculateBaseScore(factors: FortuneFactors): number {
    let score = FortuneCalculator.BASE_SCORE;

    // 根據節氣調整
    if (factors.solarTerm) {
      score += this.getSolarTermEffect(factors.solarTerm) * FortuneCalculator.FACTOR_WEIGHTS.solarTerm;
    }

    // 根據星期調整
    score += this.getWeekdayEffect(factors.weekday) * FortuneCalculator.FACTOR_WEIGHTS.weekday;

    // 根據農曆日期調整
    score += this.getLunarDayEffect(factors.lunarDay) * FortuneCalculator.FACTOR_WEIGHTS.lunarDay;

    return score;
  }

  // 計算活動指數
  private calculateActivityScore(factors: FortuneFactors): number {
    let score = FortuneCalculator.BASE_SCORE;
    
    // 根據節氣和星期調整活動建議
    if (factors.solarTerm) {
      score += this.getSolarTermEffect(factors.solarTerm) * 0.5;
    }
    score += this.getWeekdayEffect(factors.weekday) * 0.5;

    return score;
  }

  // 計算時機指數
  private calculateTimingScore(factors: FortuneFactors): number {
    let score = FortuneCalculator.BASE_SCORE;
    
    // 根據農曆日期和星期調整時機判斷
    score += this.getLunarDayEffect(factors.lunarDay) * 0.5;
    score += this.getWeekdayEffect(factors.weekday) * 0.5;

    return score;
  }

  // 調整分數確保在 0-100 範圍內
  private adjustScore(score: number): number {
    return Math.min(Math.max(Math.round(score), 0), 100);
  }

  // 獲取節氣影響
  private getSolarTermEffect(solarTerm: string): number {
    const effects: { [key: string]: number } = {
      '立春': 8, '春分': 7, '立夏': 8, '夏至': 7,
      '立秋': 8, '秋分': 7, '立冬': 8, '冬至': 7
    };
    return effects[solarTerm] || 5;
  }

  // 獲取星期影響
  private getWeekdayEffect(weekday: number): number {
    const effects = [6, 8, 7, 8, 7, 8, 6];  // 週日到週六
    return effects[weekday] || 5;
  }

  // 獲取農曆日期影響
  private getLunarDayEffect(lunarDay: number): number {
    // 使用簡單的週期變化
    return Math.sin(lunarDay * Math.PI / 15) * 5 + 5;
  }
} 