import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/lunar_date.dart';
import '../models/solar_term.dart';
import '../services/calendar_service.dart';
import 'base_provider.dart';

part 'calendar_provider.freezed.dart';
part 'calendar_provider.g.dart';

@freezed
class CalendarState with _$CalendarState implements ErrorHandlingState {
  const factory CalendarState({
    required String lunarDate,
    required String solarTerm,
    required List<String> goodActivities,
    required List<String> badActivities,
    required List<String> luckyHours,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
    @JsonKey(ignore: true) AppError? error,
  }) = _CalendarState;

  factory CalendarState.initial() => const CalendarState(
    lunarDate: '',
    solarTerm: '',
    goodActivities: [],
    badActivities: [],
    luckyHours: [],
  );

  factory CalendarState.fromJson(Map<String, dynamic> json) =>
      _$CalendarStateFromJson(json);
}

final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

final calendarProvider = FutureProvider<LunarDate>((ref) async {
  final calendarService = ref.watch(calendarServiceProvider);
  return calendarService.getLunarDate(DateTime.now());
});

class CalendarNotifier extends BaseStateNotifier<CalendarState> {
  final CalendarService _calendarService;

  CalendarNotifier(
    this._calendarService,
    ErrorService errorService,
  ) : super(errorService, CalendarState.initial()) {
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    await handleAsync(
      () async {
        final today = DateTime.now();
        
        final lunarDate = await _calendarService.getLunarDate(today);
        final solarTerm = await _calendarService.getSolarTerm(today);
        final activities = await _calendarService.getDailyActivities(today);
        final luckyHours = await _calendarService.getLuckyHours(today);

        state = state.copyWith(
          lunarDate: lunarDate.toString(),
          solarTerm: solarTerm.name,
          goodActivities: activities.good,
          badActivities: activities.bad,
          luckyHours: luckyHours,
          isLoading: false,
          errorMessage: null,
          hasError: false,
        );
      },
      onStart: () {
        state = state.copyWith(isLoading: true);
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
          hasError: true,
        );
      },
    );
  }

  Future<void> updateDate(DateTime date) async {
    await handleAsync(
      () async {
        final lunarDate = await _calendarService.getLunarDate(date);
        final solarTerm = await _calendarService.getSolarTerm(date);
        final activities = await _calendarService.getDailyActivities(date);
        final luckyHours = await _calendarService.getLuckyHours(date);

        state = state.copyWith(
          lunarDate: lunarDate.toString(),
          solarTerm: solarTerm.name,
          goodActivities: activities.good,
          badActivities: activities.bad,
          luckyHours: luckyHours,
          isLoading: false,
          errorMessage: null,
          hasError: false,
        );
      },
      onStart: () {
        state = state.copyWith(isLoading: true);
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
          hasError: true,
        );
      },
    );
  }
} 