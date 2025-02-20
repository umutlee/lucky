import '../models/horoscope.dart';

class HoroscopeService {
  Future<Horoscope> getHoroscope(DateTime birthDate) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    return Horoscope.fromDate(birthDate);
  }

  Future<String> getFortuneDescription(Horoscope horoscope) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (horoscope) {
      case Horoscope.aries:
        return '今日宜：展現領導力、開展新計劃\n忌：急躁衝動、過於直率';
      case Horoscope.taurus:
        return '今日宜：理財規劃、享受生活\n忌：固執己見、過度消費';
      case Horoscope.gemini:
        return '今日宜：社交溝通、學習新知\n忌：優柔寡斷、言語輕率';
      case Horoscope.cancer:
        return '今日宜：關懷他人、整理環境\n忌：情緒化、過度敏感';
      case Horoscope.leo:
        return '今日宜：展現才華、參與表演\n忌：驕傲自大、過度張揚';
      case Horoscope.virgo:
        return '今日宜：處理細節、健康保養\n忌：過度挑剔、鑽牛角尖';
      case Horoscope.libra:
        return '今日宜：藝術創作、社交活動\n忌：猶豫不決、過度依賴';
      case Horoscope.scorpio:
        return '今日宜：深入研究、策略規劃\n忌：過度懷疑、情緒極端';
      case Horoscope.sagittarius:
        return '今日宜：探索冒險、學習成長\n忌：輕率承諾、言語無忌';
      case Horoscope.capricorn:
        return '今日宜：職業發展、制定目標\n忌：過度工作、太過嚴肅';
      case Horoscope.aquarius:
        return '今日宜：創新思考、社會公益\n忌：特立獨行、過於理性';
      case Horoscope.pisces:
        return '今日宜：藝術創作、心靈休憩\n忌：逃避現實、過度理想';
    }
  }

  Future<List<String>> getLuckyElements(Horoscope horoscope) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (horoscope) {
      case Horoscope.aries:
        return ['幸運星座：獅子座', '幸運方位：南方'];
      case Horoscope.taurus:
        return ['幸運星座：處女座', '幸運方位：北方'];
      case Horoscope.gemini:
        return ['幸運星座：天秤座', '幸運方位：東方'];
      case Horoscope.cancer:
        return ['幸運星座：天蠍座', '幸運方位：西方'];
      case Horoscope.leo:
        return ['幸運星座：射手座', '幸運方位：東南'];
      case Horoscope.virgo:
        return ['幸運星座：摩羯座', '幸運方位：西北'];
      case Horoscope.libra:
        return ['幸運星座：水瓶座', '幸運方位：東北'];
      case Horoscope.scorpio:
        return ['幸運星座：雙魚座', '幸運方位：西南'];
      case Horoscope.sagittarius:
        return ['幸運星座：白羊座', '幸運方位：南方'];
      case Horoscope.capricorn:
        return ['幸運星座：金牛座', '幸運方位：北方'];
      case Horoscope.aquarius:
        return ['幸運星座：雙子座', '幸運方位：東方'];
      case Horoscope.pisces:
        return ['幸運星座：巨蟹座', '幸運方位：西方'];
    }
  }
} 