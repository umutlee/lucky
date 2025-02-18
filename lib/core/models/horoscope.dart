import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'horoscope.freezed.dart';
part 'horoscope.g.dart';

enum Horoscope {
  aries('白羊座'),
  taurus('金牛座'),
  gemini('雙子座'),
  cancer('巨蟹座'),
  leo('獅子座'),
  virgo('處女座'),
  libra('天秤座'),
  scorpio('天蠍座'),
  sagittarius('射手座'),
  capricorn('摩羯座'),
  aquarius('水瓶座'),
  pisces('雙魚座');

  final String displayName;
  const Horoscope(this.displayName);

  static Horoscope fromDate(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return aries;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return taurus;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return gemini;
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return cancer;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return leo;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return virgo;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return libra;
    if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) return scorpio;
    if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) return sagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return capricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return aquarius;
    return pisces;
  }

  String get description {
    switch (this) {
      case Horoscope.aries:
        return '熱情活力，勇於冒險';
      case Horoscope.taurus:
        return '穩重務實，享受生活';
      case Horoscope.gemini:
        return '靈活多變，善於溝通';
      case Horoscope.cancer:
        return '敏感細膩，重視家庭';
      case Horoscope.leo:
        return '自信魅力，天生領袖';
      case Horoscope.virgo:
        return '細心完美，實事求是';
      case Horoscope.libra:
        return '優雅和諧，追求平衡';
      case Horoscope.scorpio:
        return '神秘深邃，意志堅定';
      case Horoscope.sagittarius:
        return '樂觀開朗，追求自由';
      case Horoscope.capricorn:
        return '踏實穩重，目標明確';
      case Horoscope.aquarius:
        return '獨特創新，人道主義';
      case Horoscope.pisces:
        return '浪漫多情，富有同理心';
    }
  }

  String get element {
    switch (this) {
      case Horoscope.aries:
      case Horoscope.leo:
      case Horoscope.sagittarius:
        return '火';
      case Horoscope.taurus:
      case Horoscope.virgo:
      case Horoscope.capricorn:
        return '土';
      case Horoscope.gemini:
      case Horoscope.libra:
      case Horoscope.aquarius:
        return '風';
      case Horoscope.cancer:
      case Horoscope.scorpio:
      case Horoscope.pisces:
        return '水';
    }
  }
}

@freezed
class HoroscopeState with _$HoroscopeState {
  const factory HoroscopeState({
    required Horoscope userHoroscope,
    String? fortuneDescription,
    @Default([]) List<String> luckyElements,
    @Default(false) bool isLoading,
    String? error,
  }) = _HoroscopeState;

  factory HoroscopeState.fromJson(Map<String, dynamic> json) =>
      _$HoroscopeStateFromJson(json);
} 