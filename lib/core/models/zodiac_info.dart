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
    // ... 其他生肖
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
    // ... 其他星座
  ];
} 