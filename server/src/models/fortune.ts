export interface BaseFortune {
  date: string;
  timestamp: number;
}

export interface DailyFortune extends BaseFortune {
  overall: string;
  description: string;
  lucky_color: string;
  lucky_numbers: number[];
}

export interface StudyFortune extends BaseFortune {
  study: string;
  focus_level: number;
  suitable_subjects: string[];
}

export interface CareerFortune extends BaseFortune {
  career: string;
  cooperation: string;
  investment: string;
}

export interface LoveFortune extends BaseFortune {
  love: string;
  relationship: string;
  suitable_activities: string[];
} 