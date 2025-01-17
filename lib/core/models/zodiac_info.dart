import 'package:flutter/material.dart';

/// 生肖資訊
class ChineseZodiac {
  final String name;        // 生肖名稱
  final String imagePath;   // 圖片路徑
  final String description; // 描述
  final List<String> traits;// 特質
  final Color color;       // 主題色

  const ChineseZodiac({
    required this.name,
    required this.imagePath,
    required this.description,
    required this.traits,
    required this.color,
  });

  /// 根據年份獲取生肖
  static ChineseZodiac fromYear(int year) {
    final index = (year - 4) % 12;
    return _zodiacList[index];
  }

  /// 生肖列表
  static const List<ChineseZodiac> _zodiacList = [
    ChineseZodiac(
      name: '鼠',
      imagePath: 'assets/images/zodiac/rat.png',
      description: '機靈聰慧，善於社交',
      traits: ['聰明', '機敏', '適應力強'],
      color: Color(0xFF8C8C8C),
    ),
    ChineseZodiac(
      name: '牛',
      imagePath: 'assets/images/zodiac/ox.png',
      description: '勤勉踏實，性格溫和',
      traits: ['耐心', '可靠', '堅持'],
      color: Color(0xFF8B4513),
    ),
    ChineseZodiac(
      name: '虎',
      imagePath: 'assets/images/zodiac/tiger.png',
      description: '勇敢威嚴，充滿活力',
      traits: ['勇氣', '領導', '魄力'],
      color: Color(0xFFFF8C00),
    ),
    ChineseZodiac(
      name: '兔',
      imagePath: 'assets/images/zodiac/rabbit.png',
      description: '溫柔優雅，善解人意',
      traits: ['優雅', '敏感', '藝術'],
      color: Color(0xFFFFB6C1),
    ),
    ChineseZodiac(
      name: '龍',
      imagePath: 'assets/images/zodiac/dragon.png',
      description: '充滿魅力，志向遠大',
      traits: ['自信', '幸運', '成功'],
      color: Color(0xFFDC143C),
    ),
    ChineseZodiac(
      name: '蛇',
      imagePath: 'assets/images/zodiac/snake.png',
      description: '智慧優雅，神秘深邃',
      traits: ['智慧', '直覺', '神秘'],
      color: Color(0xFF556B2F),
    ),
    ChineseZodiac(
      name: '馬',
      imagePath: 'assets/images/zodiac/horse.png',
      description: '活潑開朗，不拘小節',
      traits: ['自由', '熱情', '速度'],
      color: Color(0xFFB8860B),
    ),
    ChineseZodiac(
      name: '羊',
      imagePath: 'assets/images/zodiac/goat.png',
      description: '溫順善良，富有同情心',
      traits: ['善良', '藝術', '和平'],
      color: Color(0xFFE6E6FA),
    ),
    ChineseZodiac(
      name: '猴',
      imagePath: 'assets/images/zodiac/monkey.png',
      description: '聰明靈活，創意十足',
      traits: ['機智', '創意', '活力'],
      color: Color(0xFFFFD700),
    ),
    ChineseZodiac(
      name: '雞',
      imagePath: 'assets/images/zodiac/rooster.png',
      description: '勤奮務實，注重細節',
      traits: ['勤勞', '準時', '自信'],
      color: Color(0xFFFF6347),
    ),
    ChineseZodiac(
      name: '狗',
      imagePath: 'assets/images/zodiac/dog.png',
      description: '忠誠可靠，正直善良',
      traits: ['忠誠', '友善', '正義'],
      color: Color(0xFFA0522D),
    ),
    ChineseZodiac(
      name: '豬',
      imagePath: 'assets/images/zodiac/pig.png',
      description: '真誠善良，樂觀開朗',
      traits: ['誠實', '善良', '富貴'],
      color: Color(0xFFFF69B4),
    ),
  ];
}

/// 星座資訊
class Horoscope {
  final String name;        // 星座名稱
  final String imagePath;   // 圖片路徑
  final String description; // 描述
  final List<String> traits;// 特質
  final Color color;       // 主題色
  final DateTime startDate; // 起始日期
  final DateTime endDate;   // 結束日期

  const Horoscope({
    required this.name,
    required this.imagePath,
    required this.description,
    required this.traits,
    required this.color,
    required this.startDate,
    required this.endDate,
  });

  /// 根據日期獲取星座
  static Horoscope fromDate(DateTime date) {
    return _horoscopeList.firstWhere(
      (horoscope) => date.isAfter(horoscope.startDate) && 
                     date.isBefore(horoscope.endDate),
      orElse: () => _horoscopeList[0],
    );
  }

  /// 星座列表
  static final List<Horoscope> _horoscopeList = [
    Horoscope(
      name: '白羊座',
      imagePath: 'assets/images/horoscope/aries.png',
      description: '充滿活力，勇於冒險',
      traits: ['熱情', '勇敢', '領導力'],
      color: Color(0xFFFF4D4D),
      startDate: DateTime(2024, 3, 21),
      endDate: DateTime(2024, 4, 19),
    ),
    Horoscope(
      name: '金牛座',
      imagePath: 'assets/images/horoscope/taurus.png',
      description: '務實穩重，享受生活',
      traits: ['耐心', '可靠', '感性'],
      color: Color(0xFF98FB98),
      startDate: DateTime(2024, 4, 20),
      endDate: DateTime(2024, 5, 20),
    ),
    Horoscope(
      name: '雙子座',
      imagePath: 'assets/images/horoscope/gemini.png',
      description: '靈活多變，思維敏捷',
      traits: ['聰明', '適應力', '交際'],
      color: Color(0xFFFFFF00),
      startDate: DateTime(2024, 5, 21),
      endDate: DateTime(2024, 6, 21),
    ),
    Horoscope(
      name: '巨蟹座',
      imagePath: 'assets/images/horoscope/cancer.png',
      description: '情感豐富，重視家庭',
      traits: ['敏感', '保護', '同理心'],
      color: Color(0xFFE6E6FA),
      startDate: DateTime(2024, 6, 22),
      endDate: DateTime(2024, 7, 22),
    ),
    Horoscope(
      name: '獅子座',
      imagePath: 'assets/images/horoscope/leo.png',
      description: '自信魅力，天生領袖',
      traits: ['自信', '慷慨', '創造力'],
      color: Color(0xFFFFD700),
      startDate: DateTime(2024, 7, 23),
      endDate: DateTime(2024, 8, 22),
    ),
    Horoscope(
      name: '處女座',
      imagePath: 'assets/images/horoscope/virgo.png',
      description: '完美主義，注重細節',
      traits: ['細心', '分析', '實際'],
      color: Color(0xFF98FB98),
      startDate: DateTime(2024, 8, 23),
      endDate: DateTime(2024, 9, 22),
    ),
    Horoscope(
      name: '天秤座',
      imagePath: 'assets/images/horoscope/libra.png',
      description: '優雅和諧，追求平衡',
      traits: ['公平', '外交', '藝術'],
      color: Color(0xFF87CEEB),
      startDate: DateTime(2024, 9, 23),
      endDate: DateTime(2024, 10, 23),
    ),
    Horoscope(
      name: '天蠍座',
      imagePath: 'assets/images/horoscope/scorpio.png',
      description: '神秘熱情，意志堅定',
      traits: ['洞察力', '決心', '神秘'],
      color: Color(0xFF800000),
      startDate: DateTime(2024, 10, 24),
      endDate: DateTime(2024, 11, 21),
    ),
    Horoscope(
      name: '射手座',
      imagePath: 'assets/images/horoscope/sagittarius.png',
      description: '樂觀開朗，追求自由',
      traits: ['冒險', '誠實', '樂觀'],
      color: Color(0xFF4169E1),
      startDate: DateTime(2024, 11, 22),
      endDate: DateTime(2024, 12, 21),
    ),
    Horoscope(
      name: '摩羯座',
      imagePath: 'assets/images/horoscope/capricorn.png',
      description: '務實負責，目標明確',
      traits: ['野心', '紀律', '耐心'],
      color: Color(0xFF2F4F4F),
      startDate: DateTime(2024, 12, 22),
      endDate: DateTime(2025, 1, 19),
    ),
    Horoscope(
      name: '水瓶座',
      imagePath: 'assets/images/horoscope/aquarius.png',
      description: '獨特創新，人道主義',
      traits: ['創新', '獨立', '友善'],
      color: Color(0xFF00BFFF),
      startDate: DateTime(2024, 1, 20),
      endDate: DateTime(2024, 2, 18),
    ),
    Horoscope(
      name: '雙魚座',
      imagePath: 'assets/images/horoscope/pisces.png',
      description: '浪漫夢幻，富有同情心',
      traits: ['直覺', '藝術', '同理心'],
      color: Color(0xFF9370DB),
      startDate: DateTime(2024, 2, 19),
      endDate: DateTime(2024, 3, 20),
    ),
  ];
} 