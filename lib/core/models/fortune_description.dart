import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune_description.freezed.dart';
part 'fortune_description.g.dart';

@freezed
class FortuneDescription with _$FortuneDescription {
  const factory FortuneDescription({
    required List<String> luckyElements,
    required String description,
  }) = _FortuneDescription;

  factory FortuneDescription.fromJson(Map<String, dynamic> json) =>
      _$FortuneDescriptionFromJson(json);
} 