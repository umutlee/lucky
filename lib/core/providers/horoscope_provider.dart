import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/horoscope.dart';
import '../services/horoscope_service.dart';
import '../services/error_service.dart';
import 'base_provider.dart';
import 'user_provider.dart';

part 'horoscope_provider.freezed.dart';
part 'horoscope_provider.g.dart';

@freezed
class HoroscopeState with _$HoroscopeState implements ErrorHandlingState {
  const factory HoroscopeState({
    required String userHoroscope,
    required List<String> luckyElements,
    required String fortuneDescription,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _HoroscopeState;

  factory HoroscopeState.fromJson(Map<String, dynamic> json) =>
      _$HoroscopeStateFromJson(json);

  factory HoroscopeState.initial() => const HoroscopeState(
        userHoroscope: '',
        luckyElements: [],
        fortuneDescription: '',
        isLoading: false,
        hasError: false,
      );
}

final horoscopeProvider =
    StateNotifierProvider<HoroscopeNotifier, HoroscopeState>((ref) {
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
          HoroscopeState.initial(),
        ) {
    _init();
  }

  void _init() async {
    await handleAsync(
      () async {
        final horoscope = _horoscopeService.calculateHoroscope(_birthDate);
        
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
          errorMessage: error.toString(),
          isLoading: false,
          hasError: true,
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