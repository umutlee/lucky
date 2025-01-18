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

export type SuitableActivity = 
  | '祭祀'
  | '祈福'
  | '開市'
  | '求財'
  | '開光'
  | '動土'
  | '安床'
  | '入宅'
  | '安葬'
  | '修造'
  | '嫁娶'
  | '出行';

export type StemBranch = 
  | '甲子' | '乙丑' | '丙寅' | '丁卯' | '戊辰' | '己巳'
  | '庚午' | '辛未' | '壬申' | '癸酉' | '甲戌' | '乙亥'
  | '丙子' | '丁丑' | '戊寅' | '己卯' | '庚辰' | '辛巳'
  | '壬午' | '癸未' | '甲申' | '乙酉' | '丙戌' | '丁亥'
  | '戊子' | '己丑' | '庚寅' | '辛卯' | '壬辰' | '癸巳'
  | '甲午' | '乙未' | '丙申' | '丁酉' | '戊戌' | '己亥'
  | '庚子' | '辛丑' | '壬寅' | '癸卯' | '甲辰' | '乙巳'
  | '丙午' | '丁未' | '戊申' | '己酉' | '庚戌' | '辛亥'
  | '壬子' | '癸丑' | '甲寅' | '乙卯' | '丙辰' | '丁巳'
  | '戊午' | '己未' | '庚申' | '辛酉' | '壬戌' | '癸亥';

export type Zodiac = 
  | '鼠' | '牛' | '虎' | '兔' | '龍' | '蛇'
  | '馬' | '羊' | '猴' | '雞' | '狗' | '豬';

export type SolarTermName = 
  | '立春' | '雨水' | '驚蟄' | '春分' | '清明' | '穀雨'
  | '立夏' | '小滿' | '芒種' | '夏至' | '小暑' | '大暑'
  | '立秋' | '處暑' | '白露' | '秋分' | '寒露' | '霜降'
  | '立冬' | '小雪' | '大雪' | '冬至' | '小寒' | '大寒'; 