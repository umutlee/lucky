import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'zodiac.freezed.dart';
part 'zodiac.g.dart';

enum ChineseZodiac {
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

  @override
  String toString() {
    switch (this) {
      case ChineseZodiac.rat:
        return '鼠';
      case ChineseZodiac.ox:
        return '牛';
      case ChineseZodiac.tiger:
        return '虎';
      case ChineseZodiac.rabbit:
        return '兔';
      case ChineseZodiac.dragon:
        return '龍';
      case ChineseZodiac.snake:
        return '蛇';
      case ChineseZodiac.horse:
        return '馬';
      case ChineseZodiac.goat:
        return '羊';
      case ChineseZodiac.monkey:
        return '猴';
      case ChineseZodiac.rooster:
        return '雞';
      case ChineseZodiac.dog:
        return '狗';
      case ChineseZodiac.pig:
        return '豬';
    }
  }

  String get description {
    switch (this) {
      case ChineseZodiac.rat:
        return '機靈活潑，善於社交';
      case ChineseZodiac.ox:
        return '勤勞踏實，性格溫和';
      case ChineseZodiac.tiger:
        return '勇敢威嚴，充滿活力';
      case ChineseZodiac.rabbit:
        return '溫柔敏感，優雅善良';
      case ChineseZodiac.dragon:
        return '威嚴尊貴，充滿魅力';
      case ChineseZodiac.snake:
        return '智慧優雅，神秘深邃';
      case ChineseZodiac.horse:
        return '活潑開朗，不拘小節';
      case ChineseZodiac.goat:
        return '溫順善良，富有同情心';
      case ChineseZodiac.monkey:
        return '聰明靈活，機智多變';
      case ChineseZodiac.rooster:
        return '勤奮務實，注重細節';
      case ChineseZodiac.dog:
        return '忠誠可靠，正直善良';
      case ChineseZodiac.pig:
        return '真誠厚道，樂觀開朗';
    }
  }
}

@immutable
class ZodiacState {
  final ChineseZodiac userZodiac;
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
    ChineseZodiac? userZodiac,
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