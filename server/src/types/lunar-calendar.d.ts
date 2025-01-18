declare module 'lunar-calendar' {
  export interface LunarDate {
    year: number;
    month: number;
    day: number;
    isLeap?: boolean;
    solarTerm?: string;
  }

  export interface LunarCalendar {
    solarToLunar(year: number, month: number, day: number): LunarDate;
    lunarToSolar(year: number, month: number, day: number, isLeap?: boolean): Date;
  }

  const calendar: LunarCalendar;
  export default calendar;
} 