import 'package:flutter/foundation.dart';

/// 生肖枚舉
enum Zodiac {
  rat,
  ox,
  tiger,
  rabbit,
  dragon,
  snake,
  horse,
  goat,
  monkey,
  rooster,
  dog,
  pig;

  static Zodiac fromYear(int year) {
    return Zodiac.values[year % 12];
  }

  static Zodiac fromString(String value) {
    return Zodiac.values.firstWhere(
      (z) => z.toString().split('.').last == value,
      orElse: () => Zodiac.rat,
    );
  }

  String get displayName {
    switch (this) {
      case Zodiac.rat:
        return '鼠';
      case Zodiac.ox:
        return '牛';
      case Zodiac.tiger:
        return '虎';
      case Zodiac.rabbit:
        return '兔';
      case Zodiac.dragon:
        return '龍';
      case Zodiac.snake:
        return '蛇';
      case Zodiac.horse:
        return '馬';
      case Zodiac.goat:
        return '羊';
      case Zodiac.monkey:
        return '猴';
      case Zodiac.rooster:
        return '雞';
      case Zodiac.dog:
        return '狗';
      case Zodiac.pig:
        return '豬';
    }
  }

  String get description {
    switch (this) {
      case Zodiac.rat:
        return '機靈活潑，善於社交';
      case Zodiac.ox:
        return '勤勞踏實，性格穩重';
      case Zodiac.tiger:
        return '勇敢無畏，充滿活力';
      case Zodiac.rabbit:
        return '溫和善良，優雅細心';
      case Zodiac.dragon:
        return '充滿魅力，雄心壯志';
      case Zodiac.snake:
        return '智慧敏銳，神秘優雅';
      case Zodiac.horse:
        return '活力四射，追求自由';
      case Zodiac.goat:
        return '溫順善良，富有同情心';
      case Zodiac.monkey:
        return '聰明靈活，創意十足';
      case Zodiac.rooster:
        return '勤奮自信，注重細節';
      case Zodiac.dog:
        return '忠誠可靠，正直善良';
      case Zodiac.pig:
        return '真誠厚道，樂觀開朗';
    }
  }

  String get element {
    switch (this) {
      case Zodiac.rat:
      case Zodiac.monkey:
        return '水';
      case Zodiac.ox:
      case Zodiac.rooster:
        return '金';
      case Zodiac.tiger:
      case Zodiac.pig:
        return '木';
      case Zodiac.rabbit:
      case Zodiac.dog:
        return '土';
      case Zodiac.dragon:
      case Zodiac.snake:
      case Zodiac.horse:
      case Zodiac.goat:
        return '火';
    }
  }
}

/// 生肖狀態
@immutable
class ZodiacState {
  final Zodiac userZodiac;
  final String? fortuneDescription;
  final List<String>? luckyElements;
  final bool isLoading;
  final String? error;

  const ZodiacState({
    required this.userZodiac,
    this.fortuneDescription,
    this.luckyElements,
    this.isLoading = false,
    this.error,
  });

  ZodiacState copyWith({
    Zodiac? userZodiac,
    String? fortuneDescription,
    List<String>? luckyElements,
    bool? isLoading,
    String? error,
  }) {
    return ZodiacState(
      userZodiac: userZodiac ?? this.userZodiac,
      fortuneDescription: fortuneDescription ?? this.fortuneDescription,
      luckyElements: luckyElements ?? this.luckyElements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZodiacState &&
        other.userZodiac == userZodiac &&
        other.fortuneDescription == fortuneDescription &&
        listEquals(other.luckyElements, luckyElements) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      userZodiac,
      fortuneDescription,
      Object.hashAll(luckyElements ?? []),
      isLoading,
      error,
    );
  }
} 