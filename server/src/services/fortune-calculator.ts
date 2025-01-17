import { DateUtils } from '../utils/date-utils';

export interface FortuneFactors {
  solarTerm: string | null;  // 節氣
  weekday: number;          // 星期幾（0-6）
  lunarDay: number;         // 農曆日期
  zodiac: string;          // 生肖
  constellation: string;    // 星座
}

export interface FortuneScore {
  overall: number;         // 總運（0-100）
  study: number;          // 學業運（0-100）
  career: number;         // 事業運（0-100）
  love: number;           // 愛情運（0-100）
}

export class FortuneCalculator {
  private static readonly BASE_SCORE = 60;  // 基礎分數
  private static readonly FACTOR_WEIGHTS = {
    solarTerm: 0.3,      // 節氣權重
    weekday: 0.1,        // 星期權重
    lunarDay: 0.2,       // 農曆日期權重
    zodiac: 0.2,         // 生肖權重
    constellation: 0.2    // 星座權重
  };

  // 計算總運勢
  public calculateOverallFortune(factors: FortuneFactors): FortuneScore {
    const baseScore = this.calculateBaseScore(factors);
    
    return {
      overall: this.adjustScore(baseScore),
      study: this.adjustScore(this.calculateStudyFortune(baseScore, factors)),
      career: this.adjustScore(this.calculateCareerFortune(baseScore, factors)),
      love: this.adjustScore(this.calculateLoveFortune(baseScore, factors))
    };
  }

  // 計算基礎分數
  private calculateBaseScore(factors: FortuneFactors): number {
    let score = FortuneCalculator.BASE_SCORE;

    // 節氣影響
    if (factors.solarTerm) {
      score += this.getSolarTermEffect(factors.solarTerm) * FortuneCalculator.FACTOR_WEIGHTS.solarTerm;
    }

    // 星期影響
    score += this.getWeekdayEffect(factors.weekday) * FortuneCalculator.FACTOR_WEIGHTS.weekday;

    // 農曆日期影響
    score += this.getLunarDayEffect(factors.lunarDay) * FortuneCalculator.FACTOR_WEIGHTS.lunarDay;

    // 生肖影響
    score += this.getZodiacEffect(factors.zodiac) * FortuneCalculator.FACTOR_WEIGHTS.zodiac;

    // 星座影響
    score += this.getConstellationEffect(factors.constellation) * FortuneCalculator.FACTOR_WEIGHTS.constellation;

    return score;
  }

  // 計算學業運
  private calculateStudyFortune(baseScore: number, factors: FortuneFactors): number {
    let score = baseScore;
    
    // 特定節氣對學業運的影響
    if (factors.solarTerm) {
      score += this.getStudySolarTermEffect(factors.solarTerm);
    }

    // 星期對學業運的影響（週一到週五較好）
    if (factors.weekday >= 1 && factors.weekday <= 5) {
      score += 5;
    }

    return score;
  }

  // 計算事業運
  private calculateCareerFortune(baseScore: number, factors: FortuneFactors): number {
    let score = baseScore;
    
    // 特定節氣對事業運的影響
    if (factors.solarTerm) {
      score += this.getCareerSolarTermEffect(factors.solarTerm);
    }

    // 星期對事業運的影響（週二、週四較好）
    if (factors.weekday === 2 || factors.weekday === 4) {
      score += 5;
    }

    return score;
  }

  // 計算愛情運
  private calculateLoveFortune(baseScore: number, factors: FortuneFactors): number {
    let score = baseScore;
    
    // 特定節氣對愛情運的影響
    if (factors.solarTerm) {
      score += this.getLoveSolarTermEffect(factors.solarTerm);
    }

    // 星期對愛情運的影響（週末較好）
    if (factors.weekday === 0 || factors.weekday === 6) {
      score += 5;
    }

    return score;
  }

  // 調整分數確保在 0-100 範圍內
  private adjustScore(score: number): number {
    return Math.min(Math.max(Math.round(score), 0), 100);
  }

  // 以下是各種影響因素的具體計算方法
  private getSolarTermEffect(solarTerm: string): number {
    // 根據不同節氣返回不同的影響值
    const effects: { [key: string]: number } = {
      '立春': 10,
      '雨水': 5,
      '驚蟄': 8,
      '春分': 9,
      '清明': 7,
      '穀雨': 6,
      '立夏': 8,
      '小滿': 5,
      '芒種': 7,
      '夏至': 9,
      '小暑': 6,
      '大暑': 8,
      '立秋': 9,
      '處暑': 6,
      '白露': 7,
      '秋分': 8,
      '寒露': 5,
      '霜降': 6,
      '立冬': 7,
      '小雪': 5,
      '大雪': 6,
      '冬至': 8,
      '小寒': 5,
      '大寒': 7
    };
    return effects[solarTerm] || 0;
  }

  private getWeekdayEffect(weekday: number): number {
    // 根據星期返回影響值
    const effects = [5, 8, 10, 8, 10, 8, 5];  // 週日到週六
    return effects[weekday] || 0;
  }

  private getLunarDayEffect(lunarDay: number): number {
    // 根據農曆日期返回影響值（1-30）
    return Math.sin(lunarDay * Math.PI / 30) * 10;
  }

  private getZodiacEffect(zodiac: string): number {
    // 根據生肖返回影響值
    const effects: { [key: string]: number } = {
      '鼠': 8,
      '牛': 7,
      '虎': 9,
      '兔': 6,
      '龍': 10,
      '蛇': 7,
      '馬': 8,
      '羊': 6,
      '猴': 9,
      '雞': 7,
      '狗': 8,
      '豬': 6
    };
    return effects[zodiac] || 0;
  }

  private getConstellationEffect(constellation: string): number {
    // 根據星座返回影響值
    const effects: { [key: string]: number } = {
      '白羊座': 8,
      '金牛座': 7,
      '雙子座': 9,
      '巨蟹座': 6,
      '獅子座': 10,
      '處女座': 7,
      '天秤座': 8,
      '天蠍座': 9,
      '射手座': 8,
      '摩羯座': 7,
      '水瓶座': 9,
      '雙魚座': 6
    };
    return effects[constellation] || 0;
  }

  private getStudySolarTermEffect(solarTerm: string): number {
    // 特定節氣對學業運的影響
    const effects: { [key: string]: number } = {
      '立春': 8,
      '春分': 5,
      '立秋': 10,
      '秋分': 8
    };
    return effects[solarTerm] || 0;
  }

  private getCareerSolarTermEffect(solarTerm: string): number {
    // 特定節氣對事業運的影響
    const effects: { [key: string]: number } = {
      '立春': 10,
      '立夏': 8,
      '立秋': 5,
      '立冬': 8
    };
    return effects[solarTerm] || 0;
  }

  private getLoveSolarTermEffect(solarTerm: string): number {
    // 特定節氣對愛情運的影響
    const effects: { [key: string]: number } = {
      '春分': 10,
      '夏至': 8,
      '秋分': 5,
      '冬至': 8
    };
    return effects[solarTerm] || 0;
  }
} 