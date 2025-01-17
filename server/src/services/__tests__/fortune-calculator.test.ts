import { FortuneCalculator, FortuneFactors } from '../fortune-calculator';

describe('FortuneCalculator', () => {
  let calculator: FortuneCalculator;
  let defaultFactors: FortuneFactors;

  beforeEach(() => {
    calculator = new FortuneCalculator();
    defaultFactors = {
      solarTerm: '立春',
      weekday: 1,  // 週一
      lunarDay: 1,
      zodiac: '龍',
      constellation: '獅子座'
    };
  });

  describe('calculateOverallFortune', () => {
    it('應該返回包含所有運勢類型的結果', () => {
      const result = calculator.calculateOverallFortune(defaultFactors);

      expect(result).toHaveProperty('overall');
      expect(result).toHaveProperty('study');
      expect(result).toHaveProperty('career');
      expect(result).toHaveProperty('love');
    });

    it('所有分數應該在 0-100 範圍內', () => {
      const result = calculator.calculateOverallFortune(defaultFactors);

      expect(result.overall).toBeGreaterThanOrEqual(0);
      expect(result.overall).toBeLessThanOrEqual(100);
      expect(result.study).toBeGreaterThanOrEqual(0);
      expect(result.study).toBeLessThanOrEqual(100);
      expect(result.career).toBeGreaterThanOrEqual(0);
      expect(result.career).toBeLessThanOrEqual(100);
      expect(result.love).toBeGreaterThanOrEqual(0);
      expect(result.love).toBeLessThanOrEqual(100);
    });
  });

  describe('節氣影響', () => {
    it('立春應該有正面影響', () => {
      const withSpring = calculator.calculateOverallFortune({
        ...defaultFactors,
        solarTerm: '立春'
      });

      const withoutSolarTerm = calculator.calculateOverallFortune({
        ...defaultFactors,
        solarTerm: null
      });

      expect(withSpring.overall).toBeGreaterThan(withoutSolarTerm.overall);
    });

    it('不同節氣應該有不同影響', () => {
      const springScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        solarTerm: '立春'
      }).overall;

      const summerScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        solarTerm: '立夏'
      }).overall;

      expect(springScore).not.toBe(summerScore);
    });
  });

  describe('星期影響', () => {
    it('工作日對學業運應該有正面影響', () => {
      const weekdayScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        weekday: 3  // 週三
      }).study;

      const weekendScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        weekday: 0  // 週日
      }).study;

      expect(weekdayScore).toBeGreaterThan(weekendScore);
    });

    it('週末對愛情運應該有正面影響', () => {
      const weekendScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        weekday: 6  // 週六
      }).love;

      const weekdayScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        weekday: 3  // 週三
      }).love;

      expect(weekendScore).toBeGreaterThan(weekdayScore);
    });
  });

  describe('生肖影響', () => {
    it('龍的運勢應該高於兔', () => {
      const dragonScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        zodiac: '龍'
      }).overall;

      const rabbitScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        zodiac: '兔'
      }).overall;

      expect(dragonScore).toBeGreaterThan(rabbitScore);
    });
  });

  describe('星座影響', () => {
    it('獅子座的運勢應該高於巨蟹座', () => {
      const leoScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        constellation: '獅子座'
      }).overall;

      const cancerScore = calculator.calculateOverallFortune({
        ...defaultFactors,
        constellation: '巨蟹座'
      }).overall;

      expect(leoScore).toBeGreaterThan(cancerScore);
    });
  });

  describe('農曆日期影響', () => {
    it('不同農曆日期應該有不同影響', () => {
      const day1Score = calculator.calculateOverallFortune({
        ...defaultFactors,
        lunarDay: 1
      }).overall;

      const day15Score = calculator.calculateOverallFortune({
        ...defaultFactors,
        lunarDay: 15
      }).overall;

      expect(day1Score).not.toBe(day15Score);
    });

    it('農曆日期應該在有效範圍內（1-30）', () => {
      const invalidDay = calculator.calculateOverallFortune({
        ...defaultFactors,
        lunarDay: 31
      }).overall;

      const validDay = calculator.calculateOverallFortune({
        ...defaultFactors,
        lunarDay: 15
      }).overall;

      expect(invalidDay).not.toBe(validDay);
    });
  });

  describe('邊界情況', () => {
    it('應該處理無效的節氣', () => {
      const result = calculator.calculateOverallFortune({
        ...defaultFactors,
        solarTerm: '無效節氣'
      });

      expect(result.overall).toBeGreaterThanOrEqual(0);
      expect(result.overall).toBeLessThanOrEqual(100);
    });

    it('應該處理無效的星期', () => {
      const result = calculator.calculateOverallFortune({
        ...defaultFactors,
        weekday: 7
      });

      expect(result.overall).toBeGreaterThanOrEqual(0);
      expect(result.overall).toBeLessThanOrEqual(100);
    });

    it('應該處理無效的生肖', () => {
      const result = calculator.calculateOverallFortune({
        ...defaultFactors,
        zodiac: '無效生肖'
      });

      expect(result.overall).toBeGreaterThanOrEqual(0);
      expect(result.overall).toBeLessThanOrEqual(100);
    });

    it('應該處理無效的星座', () => {
      const result = calculator.calculateOverallFortune({
        ...defaultFactors,
        constellation: '無效星座'
      });

      expect(result.overall).toBeGreaterThanOrEqual(0);
      expect(result.overall).toBeLessThanOrEqual(100);
    });
  });
}); 