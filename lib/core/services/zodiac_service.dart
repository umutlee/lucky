import '../models/zodiac.dart';
import 'package:lunar/lunar.dart';

class ZodiacService {
  Zodiac calculateZodiac(DateTime birthDate) {
    // 使用農曆曆法計算生肖
    final lunar = Lunar.fromDate(birthDate);
    final year = lunar.getYear();
    
    // 計算生肖，鼠年為0
    final index = (year - 4) % 12;
    return Zodiac.values[index];
  }

  Future<String> getFortuneDescription(Zodiac zodiac) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (zodiac) {
      case Zodiac.rat:
        return '今日宜：社交活動、商業談判\n忌：獨處、猶豫不決';
      case Zodiac.ox:
        return '今日宜：務實工作、長期規劃\n忌：衝動決策、過度操勞';
      case Zodiac.tiger:
        return '今日宜：創新嘗試、展現才能\n忌：保守固執、意氣用事';
      case Zodiac.rabbit:
        return '今日宜：藝術創作、感情交流\n忌：過度敏感、優柔寡斷';
      case Zodiac.dragon:
        return '今日宜：領導決策、開拓事業\n忌：驕傲自滿、獨斷專行';
      case Zodiac.snake:
        return '今日宜：思考謀劃、學習進修\n忌：輕信他人、過度猜疑';
      case Zodiac.horse:
        return '今日宜：外出活動、拓展人脈\n忌：待在原地、缺乏耐心';
      case Zodiac.goat:
        return '今日宜：藝術欣賞、休閒放鬆\n忌：強出頭、與人爭執';
      case Zodiac.monkey:
        return '今日宜：創意發想、技能學習\n忌：投機取巧、言語輕率';
      case Zodiac.rooster:
        return '今日宜：整理規劃、完善細節\n忌：過度完美、吹毛求疵';
      case Zodiac.dog:
        return '今日宜：助人行善、建立信任\n忌：多疑固執、鑽牛角尖';
      case Zodiac.pig:
        return '今日宜：享受生活、投資理財\n忌：過度消費、意志不堅';
    }
  }

  Future<List<String>> getLuckyElements(Zodiac zodiac) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (zodiac) {
      case Zodiac.rat:
        return ['幸運數字：2、8', '幸運顏色：藍色、金色', '幸運方位：北方'];
      case Zodiac.ox:
        return ['幸運數字：1、9', '幸運顏色：白色、黃色', '幸運方位：東北'];
      case Zodiac.tiger:
        return ['幸運數字：3、7', '幸運顏色：橙色、灰色', '幸運方位：東'];
      case Zodiac.rabbit:
        return ['幸運數字：4、6', '幸運顏色：綠色、紫色', '幸運方位：東南'];
      case Zodiac.dragon:
        return ['幸運數字：1、7', '幸運顏色：金色、銀色', '幸運方位：東南'];
      case Zodiac.snake:
        return ['幸運數字：2、8', '幸運顏色：紅色、黑色', '幸運方位：南'];
      case Zodiac.horse:
        return ['幸運數字：3、9', '幸運顏色：棕色、黃色', '幸運方位：南'];
      case Zodiac.goat:
        return ['幸運數字：5、8', '幸運顏色：綠色、紫色', '幸運方位：西南'];
      case Zodiac.monkey:
        return ['幸運數字：1、6', '幸運顏色：白色、藍色', '幸運方位：西'];
      case Zodiac.rooster:
        return ['幸運數字：7、9', '幸運顏色：金色、棕色', '幸運方位：西'];
      case Zodiac.dog:
        return ['幸運數字：3、8', '幸運顏色：紅色、綠色', '幸運方位：西北'];
      case Zodiac.pig:
        return ['幸運數字：2、5', '幸運顏色：黃色、灰色', '幸運方位：北'];
    }
  }
} 