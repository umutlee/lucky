declare module 'lunar-calendar' {
  interface LunarDate {
    year: number;
    month: number;
    day: number;
    isLeap: boolean;
  }

  interface SolarDate {
    year: number;
    month: number;
    day: number;
  }

  interface LunarCalendar {
    solarToLunar(year: number, month: number, day: number): LunarDate;
    lunarToSolar(year: number, month: number, day: number, isLeap?: boolean): SolarDate;
  }

  const calendar: LunarCalendar;
  export default calendar;
} 