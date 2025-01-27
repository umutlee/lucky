import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/horoscope.dart';
import '../services/horoscope_service.dart';
import '../services/error_service.dart';
import 'base_provider.dart';
import 'user_provider.dart';

class HoroscopeState with ErrorHandlingState, LoadingState {
  final Horoscope userHoroscope;
  final String? fortuneDescription;
  final List<String>? luckyElements;

  HoroscopeState({
    required this.userHoroscope,
    this.fortuneDescription,
    this.luckyElements,
    this.error,
    this.isLoading = false,
  });

  HoroscopeState copyWith({
    Horoscope? userHoroscope,
    String? fortuneDescription,
    List<String>? luckyElements,
    AppError? error,
    bool? isLoading,
  }) {
    return HoroscopeState(
      userHoroscope: userHoroscope ?? this.userHoroscope,
      fortuneDescription: fortuneDescription ?? this.fortuneDescription,
      luckyElements: luckyElements ?? this.luckyElements,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final horoscopeProvider = StateNotifierProvider<HoroscopeNotifier, HoroscopeState>((ref) {
  final birthDate = ref.watch(userProvider.select((user) => user.birthDate));
  final errorService = ref.watch(errorServiceProvider);
  return HoroscopeNotifier(
    HoroscopeService(),
    errorService,
    birthDate,
  );
});

class HoroscopeNotifier extends BaseStateNotifier<HoroscopeState> {
  final HoroscopeService _horoscopeService;
  final DateTime _birthDate;

  HoroscopeNotifier(
    this._horoscopeService,
    ErrorService errorService,
    this._birthDate,
  ) : super(
          errorService,
          HoroscopeState(
            userHoroscope: Horoscope.fromDate(_birthDate),
            isLoading: true,
          ),
        ) {
    _init();
  }

  void _init() async {
    await handleAsync(
      () async {
        final horoscope = Horoscope.fromDate(_birthDate);
        
        state = state.copyWith(
          userHoroscope: horoscope,
          isLoading: true,
        );

        final description = await _horoscopeService.getFortuneDescription(horoscope);
        final luckyElements = await _horoscopeService.getLuckyElements(horoscope);
        
        state = state.copyWith(
          fortuneDescription: description,
          luckyElements: luckyElements,
          isLoading: false,
        );
      },
      onStart: () {
        state = state.copyWith(isLoading: true);
      },
      onError: (error) {
        state = state.copyWith(
          error: error,
          isLoading: false,
        );
      },
    );
  }

  Future<void> refreshFortune() async {
    await handleAsync(
      () async {
        final description = await _horoscopeService.getFortuneDescription(state.userHoroscope);
        final luckyElements = await _horoscopeService.getLuckyElements(state.userHoroscope);
        
        state = state.copyWith(
          fortuneDescription: description,
          luckyElements: luckyElements,
          isLoading: false,
          error: null,
        );
      },
      onStart: () {
        state = state.copyWith(isLoading: true);
      },
      onError: (error) {
        state = state.copyWith(
          error: error,
          isLoading: false,
        );
      },
    );
  }
} 