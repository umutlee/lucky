import 'package:freezed_annotation/freezed_annotation.dart';

part 'solar_term.freezed.dart';
part 'solar_term.g.dart';

@freezed
class SolarTerm with _$SolarTerm {
  const factory SolarTerm({
    required String name,
    required DateTime date,
    @Default('') String description,
    @Default('') String element,
  }) = _SolarTerm;

  factory SolarTerm.fromJson(Map<String, dynamic> json) =>
      _$SolarTermFromJson(json);

  const SolarTerm._();

  String get displayName => name;

  String get elementDescription {
    switch (element) {
      case '木':
        return '生機勃勃，適合開展新事物';
      case '火':
        return '熱情活力，適合社交活動';
      case '土':
        return '穩重踏實，適合務實工作';
      case '金':
        return '剛毅堅定，適合果斷決策';
      case '水':
        return '智慧靈活，適合學習思考';
      default:
        return '';
    }
  }

  @override
  String toString() => '$name ($date)';
} 