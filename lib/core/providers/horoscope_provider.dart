import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/horoscope.dart';
import '../models/app_error.dart';
import '../services/horoscope_service.dart';
import '../services/error_service.dart';
import 'base_provider.dart';
import 'user_provider.dart';

part 'horoscope_provider.freezed.dart';
part 'horoscope_provider.g.dart';

@freezed
class HoroscopeState with _$HoroscopeState implements BaseState {
  const factory HoroscopeState({
    required Horoscope userHoroscope,
    String? fortuneDescription,
    @Default([]) List<String> luckyElements,
    @Default(false) bool isLoading,
    @Default(null) AppError? error,
  }) = _HoroscopeState;

  const HoroscopeState._();

  @override
  bool get hasError => error != null;

  @override
  String? get errorMessage => error?.message;

  factory HoroscopeState.initial() => const HoroscopeState(
        userHoroscope: Horoscope.leo,
        fortuneDescription: '',
        luckyElements: [],
      );

  factory HoroscopeState.fromJson(Map<String, dynamic> json) =>
      _$HoroscopeStateFromJson(json);
}

final horoscopeServiceProvider = Provider<HoroscopeService>((ref) {
  return HoroscopeService();
});

final horoscopeProvider = StateNotifierProvider<HoroscopeNotifier, HoroscopeState>((ref) {
  final horoscopeService = ref.watch(horoscopeServiceProvider);
  final errorService = ref.watch(errorServiceProvider);
  final birthDate = DateTime.now(); // TODO: 從用戶設置獲取
  return HoroscopeNotifier(horoscopeService, errorService, birthDate);
});

class HoroscopeNotifier extends StateNotifier<HoroscopeState> {
  final HoroscopeService _horoscopeService;
  final ErrorService _errorService;
  final DateTime _birthDate;

  HoroscopeNotifier(
    this._horoscopeService,
    this._errorService,
    this._birthDate,
  ) : super(HoroscopeState.initial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final horoscope = await _horoscopeService.getHoroscope(_birthDate);
      final fortuneDescription = await _horoscopeService.getFortuneDescription(horoscope);
      final luckyElements = await _horoscopeService.getLuckyElements(horoscope);
      
      state = state.copyWith(
        userHoroscope: horoscope,
        fortuneDescription: fortuneDescription,
        luckyElements: luckyElements,
        isLoading: false,
        error: null,
      );
    } catch (e, stackTrace) {
      final error = await _errorService.handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  Future<void> refreshFortune() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final description = await _horoscopeService.getFortuneDescription(state.userHoroscope);
      final luckyElements = await _horoscopeService.getLuckyElements(state.userHoroscope);
      
      state = state.copyWith(
        fortuneDescription: description,
        luckyElements: luckyElements,
        isLoading: false,
        error: null,
      );
    } catch (e, stackTrace) {
      final error = await _errorService.handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  Future<void> retry() async {
    await _init();
  }

  void setError(AppError error) {
    state = state.copyWith(
      isLoading: false,
      error: error,
    );
  }
} 