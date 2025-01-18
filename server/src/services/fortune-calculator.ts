import { DateUtils } from '../utils/date-utils';
import { logger } from '../utils/logger';

export interface FortuneFactors {
  solarTerm: string | null;  // 節氣
  weekday: number;          // 星期幾（0-6）
  lunarDay: number;         // 農曆日期
  zodiac: string;          // 生肖
  constellation: string;    // 星座
  stemBranch: string;      // 天干地支
}

export interface FortuneScore {
  overall: number;         // 總運（0-100）
  study: number;          // 學業運（0-100）
  career: number;         // 事業運（0-100）
  love: number;           // 愛情運（0-100）
  details: {              // 詳細分析
    positive: string[];   // 正面因素
    negative: string[];   // 負面因素
    advice: string[];     // 建議
  };
}

export class FortuneCalculator {
  private static readonly BASE_SCORE = 60;  // 基礎分數
  private static readonly FACTOR_WEIGHTS = {
    solarTerm: 0.25,      // 節氣權重
    weekday: 0.15,        // 星期權重
    lunarDay: 0.20,       // 農曆日期權重
    zodiac: 0.20,         // 生肖權重
    constellation: 0.20    // 星座權重
  };

  // 節氣對運勢的影響
  private static readonly SOLAR_TERM_EFFECTS: { [key: string]: number } = {
    '立春': 10, '雨水': 5, '驚蟄': 8, '春分': 9,
    '清明': 7, '穀雨': 6, '立夏': 8, '小滿': 5,
    '芒種': 7, '夏至': 9, '小暑': 6, '大暑': 8,
    '立秋': 9, '處暑': 6, '白露': 7, '秋分': 8,
    '寒露': 5, '霜降': 6, '立冬': 7, '小雪': 5,
    '大雪': 6, '冬至': 8, '小寒': 5, '大寒': 7
  };

  // 星座相性
  private static readonly CONSTELLATION_COMPATIBILITY: { [key: string]: { [key: string]: number } } = {
    '白羊座': { '獅子座': 2, '射手座': 2, '天秤座': -1 },
    '金牛座': { '處女座': 2, '摩羯座': 2, '天蠍座': -1 },
    '雙子座': { '天秤座': 2, '水瓶座': 2, '處女座': -1 },
    '巨蟹座': { '天蠍座': 2, '雙魚座': 2, '摩羯座': -1 },
    '獅子座': { '白羊座': 2, '射手座': 2, '天蠍座': -1 },
    '處女座': { '金牛座': 2, '摩羯座': 2, '雙魚座': -1 },
    '天秤座': { '雙子座': 2, '水瓶座': 2, '巨蟹座': -1 },
    '天蠍座': { '巨蟹座': 2, '雙魚座': 2, '獅子座': -1 },
    '射手座': { '白羊座': 2, '獅子座': 2, '處女座': -1 },
    '摩羯座': { '金牛座': 2, '處女座': 2, '巨蟹座': -1 },
    '水瓶座': { '雙子座': 2, '天秤座': 2, '金牛座': -1 },
    '雙魚座': { '巨蟹座': 2, '天蠍座': 2, '雙子座': -1 }
  };

  // 生肖相性
  private static readonly ZODIAC_COMPATIBILITY: { [key: string]: { [key: string]: number } } = {
    '鼠': { '龍': 2, '猴': 2, '馬': -1 },
    '牛': { '蛇': 2, '雞': 2, '羊': -1 },
    '虎': { '馬': 2, '狗': 2, '猴': -1 },
    '兔': { '羊': 2, '豬': 2, '雞': -1 },
    '龍': { '鼠': 2, '猴': 2, '狗': -1 },
    '蛇': { '牛': 2, '雞': 2, '豬': -1 },
    '馬': { '虎': 2, '狗': 2, '鼠': -1 },
    '羊': { '兔': 2, '豬': 2, '牛': -1 },
    '猴': { '鼠': 2, '龍': 2, '虎': -1 },
    '雞': { '牛': 2, '蛇': 2, '兔': -1 },
    '狗': { '虎': 2, '馬': 2, '龍': -1 },
    '豬': { '兔': 2, '羊': 2, '蛇': -1 }
  };

  // 計算總運勢
  public calculateOverallFortune(factors: FortuneFactors): FortuneScore {
    const baseScore = this.calculateBaseScore(factors);
    const details = this.analyzeFactors(factors);
    
    return {
      overall: this.adjustScore(baseScore),
      study: this.adjustScore(this.calculateStudyFortune(baseScore, factors)),
      career: this.adjustScore(this.calculateCareerFortune(baseScore, factors)),
      love: this.adjustScore(this.calculateLoveFortune(baseScore, factors)),
      details
    };
  }

  // 分析影響因素
  private analyzeFactors(factors: FortuneFactors): FortuneScore['details'] {
    const positive: string[] = [];
    const negative: string[] = [];
    const advice: string[] = [];

    // 分析節氣影響
    if (factors.solarTerm) {
      const effect = FortuneCalculator.SOLAR_TERM_EFFECTS[factors.solarTerm] || 0;
      if (effect >= 8) {
        positive.push(`今日節氣「${factors.solarTerm}」帶來良好運勢`);
      } else if (effect <= 5) {
        negative.push(`今日節氣「${factors.solarTerm}」運勢較弱`);
        advice.push('建議避免重大決定，專注日常事務');
      }
    }

    // 分析星座相性
    const constellationEffects = FortuneCalculator.CONSTELLATION_COMPATIBILITY[factors.constellation] || {};
    Object.entries(constellationEffects).forEach(([otherSign, effect]) => {
      if (effect > 0) {
        positive.push(`與${otherSign}有良好互動機會`);
      } else if (effect < 0) {
        negative.push(`與${otherSign}可能有分歧`);
        advice.push(`避免與${otherSign}發生衝突`);
      }
    });

    // 分析生肖相性
    const zodiacEffects = FortuneCalculator.ZODIAC_COMPATIBILITY[factors.zodiac] || {};
    Object.entries(zodiacEffects).forEach(([otherZodiac, effect]) => {
      if (effect > 0) {
        positive.push(`與屬${otherZodiac}的人緣分不錯`);
      } else if (effect < 0) {
        negative.push(`與屬${otherZodiac}的人易有摩擦`);
        advice.push(`與屬${otherZodiac}的人相處需要更多包容`);
      }
    });

    // 根據星期提供建議
    switch (factors.weekday) {
      case 1: // 週一
        advice.push('適合開展新計劃');
        break;
      case 3: // 週三
        advice.push('適合進行學習和考試');
        break;
      case 5: // 週五
        advice.push('適合社交活動');
        break;
      case 0: // 週日
        advice.push('適合休息調養');
        break;
    }

    // 根據農曆日期提供建議
    if (factors.lunarDay === 1 || factors.lunarDay === 15) {
      positive.push('農曆吉日，適合祭祀、慶典');
    }

    return { positive, negative, advice };
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

    // 農曆日期對學業的影響
    if (factors.lunarDay === 1 || factors.lunarDay === 15) {
      score += 3; // 初一、十五較適合學習
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

    // 生肖相性對事業的影響
    const zodiacEffects = FortuneCalculator.ZODIAC_COMPATIBILITY[factors.zodiac] || {};
    Object.values(zodiacEffects).forEach(effect => {
      score += effect * 2;
    });

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

    // 星座相性對愛情的影響
    const constellationEffects = FortuneCalculator.CONSTELLATION_COMPATIBILITY[factors.constellation] || {};
    Object.values(constellationEffects).forEach(effect => {
      score += effect * 3;
    });

    return score;
  }

  // 調整分數確保在 0-100 範圍內
  private adjustScore(score: number): number {
    return Math.min(Math.max(Math.round(score), 0), 100);
  }

  // 以下是各種影響因素的具體計算方法
  private getSolarTermEffect(solarTerm: string): number {
    return FortuneCalculator.SOLAR_TERM_EFFECTS[solarTerm] || 0;
  }

  private getWeekdayEffect(weekday: number): number {
    const effects = [5, 8, 10, 8, 10, 8, 5];  // 週日到週六
    return effects[weekday] || 0;
  }

  private getLunarDayEffect(lunarDay: number): number {
    // 使用正弦函數產生週期性變化
    return Math.sin(lunarDay * Math.PI / 15) * 10;
  }

  private getZodiacEffect(zodiac: string): number {
    const effects: { [key: string]: number } = {
      '鼠': 8, '牛': 7, '虎': 9, '兔': 6,
      '龍': 10, '蛇': 7, '馬': 8, '羊': 6,
      '猴': 9, '雞': 7, '狗': 8, '豬': 6
    };
    return effects[zodiac] || 0;
  }

  private getConstellationEffect(constellation: string): number {
    const effects: { [key: string]: number } = {
      '白羊座': 8, '金牛座': 7, '雙子座': 9,
      '巨蟹座': 6, '獅子座': 10, '處女座': 7,
      '天秤座': 8, '天蠍座': 9, '射手座': 8,
      '摩羯座': 7, '水瓶座': 9, '雙魚座': 6
    };
    return effects[constellation] || 0;
  }

  private getStudySolarTermEffect(solarTerm: string): number {
    const effects: { [key: string]: number } = {
      '立春': 8, '春分': 5, '立秋': 10, '秋分': 8,
      '小滿': 6, '大暑': 4, '白露': 7, '小雪': 5
    };
    return effects[solarTerm] || 0;
  }

  private getCareerSolarTermEffect(solarTerm: string): number {
    const effects: { [key: string]: number } = {
      '立春': 10, '立夏': 8, '立秋': 5, '立冬': 8,
      '驚蟄': 7, '芒種': 6, '白露': 9, '大雪': 4
    };
    return effects[solarTerm] || 0;
  }

  private getLoveSolarTermEffect(solarTerm: string): number {
    const effects: { [key: string]: number } = {
      '春分': 10, '夏至': 8, '秋分': 5, '冬至': 8,
      '雨水': 7, '小滿': 9, '處暑': 6, '小寒': 4
    };
    return effects[solarTerm] || 0;
  }
} 