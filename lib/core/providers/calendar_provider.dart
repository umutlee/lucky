import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/lunar_date.dart';
import '../models/solar_term.dart';
import '../models/daily_activities.dart';
import '../services/calendar_service.dart';
import '../services/error_service.dart';
import '../utils/logger.dart';

part 'calendar_provider.freezed.dart';
part 'calendar_provider.g.dart';

@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    required String lunarDate,
    required String solarTerm,
    required List<String> goodActivities,
    required List<String> badActivities,
    required List<String> luckyHours,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
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

final errorServiceProvider = Provider<ErrorService>((ref) {
  return ErrorService(Logger('ErrorService'));
});

final calendarStateProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final calendarService = ref.watch(calendarServiceProvider);
  final errorService = ref.watch(errorServiceProvider);
  return CalendarNotifier(calendarService, errorService);
});

class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarService _calendarService;
  final ErrorService _errorService;

  CalendarNotifier(
    this._calendarService,
    this._errorService,
  ) : super(CalendarState.initial()) {
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final today = DateTime.now();
      final lunarDate = await _calendarService.getLunarDate(today);
      final solarTerm = await _calendarService.getSolarTerm(today);
      final activities = await _calendarService.getDailyActivities(today);
      final luckyHours = await _calendarService.getLuckyHours(today);

      state = state.copyWith(
        lunarDate: lunarDate.toString(),
        solarTerm: solarTerm.name,
        goodActivities: activities.goodActivities,
        badActivities: activities.badActivities,
        luckyHours: luckyHours,
        isLoading: false,
        errorMessage: null,
        hasError: false,
      );
    } catch (e, stackTrace) {
      final error = _errorService.handleError(e, stackTrace);
      state = state.copyWith(
        errorMessage: error.userMessage,
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> updateDate(DateTime date) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final lunarDate = await _calendarService.getLunarDate(date);
      final solarTerm = await _calendarService.getSolarTerm(date);
      final activities = await _calendarService.getDailyActivities(date);
      final luckyHours = await _calendarService.getLuckyHours(date);

      state = state.copyWith(
        lunarDate: lunarDate.toString(),
        solarTerm: solarTerm.name,
        goodActivities: activities.goodActivities,
        badActivities: activities.badActivities,
        luckyHours: luckyHours,
        isLoading: false,
        errorMessage: null,
        hasError: false,
      );
    } catch (e, stackTrace) {
      final error = _errorService.handleError(e, stackTrace);
      state = state.copyWith(
        errorMessage: error.userMessage,
        isLoading: false,
        hasError: true,
      );
    }
  }
} 