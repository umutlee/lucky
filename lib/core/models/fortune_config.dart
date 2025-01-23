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
  }) = _FortuneConfig;

  factory FortuneConfig.fromJson(Map<String, dynamic> json) => _$FortuneConfigFromJson(json);

  factory FortuneConfig.initial() => const FortuneConfig(
    showLuckyTime: true,
    showLuckyDirection: true,
    showLuckyColor: true,
    showLuckyNumber: true,
    showDetailedAnalysis: true,
  );
} 