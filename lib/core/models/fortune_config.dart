import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune_config.freezed.dart';
part 'fortune_config.g.dart';

@freezed
class FortuneConfig with _$FortuneConfig {
  const factory FortuneConfig({
    required bool showLuckyTime,
    required bool showLuckyDirection,
    required bool showLuckyColor,
    required bool showLuckyNumber,
    required bool showDetailedAnalysis,
    @Default({'study': true, 'career': true, 'love': true}) Map<String, bool> visibleTypes,
  }) = _FortuneConfig;

  factory FortuneConfig.fromJson(Map<String, dynamic> json) => _$FortuneConfigFromJson(json);

  factory FortuneConfig.initial() => const FortuneConfig(
    showLuckyTime: true,
    showLuckyDirection: true,
    showLuckyColor: true,
    showLuckyNumber: true,
    showDetailedAnalysis: true,
    visibleTypes: {'study': true, 'career': true, 'love': true},
  );
}

extension FortuneConfigX on FortuneConfig {
  bool isVisible(String type) => visibleTypes[type] ?? true;
} 