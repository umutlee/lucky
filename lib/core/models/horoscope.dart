import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'horoscope.freezed.dart';
part 'horoscope.g.dart';

enum Horoscope {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces;

  @override
  String toString() {
    switch (this) {
      case Horoscope.aries:
        return '白羊座';
      case Horoscope.taurus:
        return '金牛座';
      case Horoscope.gemini:
        return '雙子座';
      case Horoscope.cancer:
        return '巨蟹座';
      case Horoscope.leo:
        return '獅子座';
      case Horoscope.virgo:
        return '處女座';
      case Horoscope.libra:
        return '天秤座';
      case Horoscope.scorpio:
        return '天蠍座';
      case Horoscope.sagittarius:
        return '射手座';
      case Horoscope.capricorn:
        return '摩羯座';
      case Horoscope.aquarius:
        return '水瓶座';
      case Horoscope.pisces:
        return '雙魚座';
    }
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
        return '細心謹慎，追求完美';
      case Horoscope.libra:
        return '優雅和諧，追求公平';
      case Horoscope.scorpio:
        return '神秘深邃，意志堅定';
      case Horoscope.sagittarius:
        return '樂觀開朗，追求自由';
      case Horoscope.capricorn:
        return '務實穩重，目標明確';
      case Horoscope.aquarius:
        return '獨特創新，人道主義';
      case Horoscope.pisces:
        return '浪漫多情，富有同理心';
    }
  }

  static Horoscope fromDate(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return Horoscope.aries;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return Horoscope.taurus;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return Horoscope.gemini;
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return Horoscope.cancer;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return Horoscope.leo;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return Horoscope.virgo;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return Horoscope.libra;
    if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) return Horoscope.scorpio;
    if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) return Horoscope.sagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return Horoscope.capricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return Horoscope.aquarius;
    return Horoscope.pisces;
  }
}

@immutable
class HoroscopeState {
  final Horoscope userHoroscope;
  final String? fortuneDescription;
  final List<String>? luckyElements;
  final bool isLoading;
  final String? error;

  const HoroscopeState({
    required this.userHoroscope,
    this.fortuneDescription,
    this.luckyElements,
    this.isLoading = false,
    this.error,
  });

  HoroscopeState copyWith({
    Horoscope? userHoroscope,
    String? fortuneDescription,
    List<String>? luckyElements,
    bool? isLoading,
    String? error,
  }) {
    return HoroscopeState(
      userHoroscope: userHoroscope ?? this.userHoroscope,
      fortuneDescription: fortuneDescription ?? this.fortuneDescription,
      luckyElements: luckyElements ?? this.luckyElements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HoroscopeState &&
        other.userHoroscope == userHoroscope &&
        other.fortuneDescription == fortuneDescription &&
        listEquals(other.luckyElements, luckyElements) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      userHoroscope,
      fortuneDescription,
      Object.hashAll(luckyElements ?? []),
      isLoading,
      error,
    );
  }
} 