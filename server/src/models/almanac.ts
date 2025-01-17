export interface DailyAlmanac {
  date: string;
  lunar_date: string;
  zodiac: string;
  stem_branch: string;
  suitable: string[];
  unsuitable: string[];
}

export interface MonthlyAlmanac {
  year: string;
  month: string;
  days: DailyAlmanac[];
}

export interface SolarTerm {
  name: string;
  date: string;
  time: string;
}

export interface SolarTerms {
  year: string;
  terms: SolarTerm[];
}

export interface LunarDate {
  solar_date: string;
  lunar_date: string;
  zodiac: string;
  stem_branch: string;
} 