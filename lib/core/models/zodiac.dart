import 'package:freezed_annotation/freezed_annotation.dart';

part 'zodiac.freezed.dart';
part 'zodiac.g.dart';

/// 生肖枚舉
enum Zodiac {
  rat('鼠'),
  ox('牛'),
  tiger('虎'),
  rabbit('兔'),
  dragon('龍'),
  snake('蛇'),
  horse('馬'),
  goat('羊'),
  monkey('猴'),
  rooster('雞'),
  dog('狗'),
  pig('豬');

  final String displayName;
  const Zodiac(this.displayName);

  static Zodiac fromYear(int year) {
    return Zodiac.values[year % 12];
  }

  static Zodiac fromString(String value) {
    return Zodiac.values.firstWhere(
      (z) => z.toString().split('.').last == value,
      orElse: () => Zodiac.rat,
    );
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

  String get earthlyBranch {
    switch (this) {
      case Zodiac.rat:
        return '子';
      case Zodiac.ox:
        return '丑';
      case Zodiac.tiger:
        return '寅';
      case Zodiac.rabbit:
        return '卯';
      case Zodiac.dragon:
        return '辰';
      case Zodiac.snake:
        return '巳';
      case Zodiac.horse:
        return '午';
      case Zodiac.goat:
        return '未';
      case Zodiac.monkey:
        return '申';
      case Zodiac.rooster:
        return '酉';
      case Zodiac.dog:
        return '戌';
      case Zodiac.pig:
        return '亥';
    }
  }
}

/// 生肖狀態
@freezed
class ZodiacState with _$ZodiacState {
  const factory ZodiacState({
    required Zodiac userZodiac,
    String? fortuneDescription,
    @Default([]) List<String> luckyElements,
    @Default(false) bool isLoading,
    String? error,
  }) = _ZodiacState;

  factory ZodiacState.initial() => const ZodiacState(
        userZodiac: Zodiac.rat,
        luckyElements: [],
      );

  factory ZodiacState.fromJson(Map<String, dynamic> json) => _$ZodiacStateFromJson(json);
} 