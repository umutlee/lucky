import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_day.freezed.dart';
part 'calendar_day.g.dart';

@freezed
class CalendarDay with _$CalendarDay {
  const factory CalendarDay({
    required DateTime date,
    required String lunarDay,
    @Default('') String solarTerm,
    String? festival,
    required bool isCurrentMonth,
    required bool isWeekend,
    required bool isHoliday,
    required List<String> dayYi,
    required List<String> dayJi,
    @Default([]) List<String> timeZhi,
    @Default('') String wuXing,
    required List<String> positions,
    @Default('') String ganZhi,
  }) = _CalendarDay;

  factory CalendarDay.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayFromJson(json);
} 