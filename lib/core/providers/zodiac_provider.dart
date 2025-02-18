import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/zodiac.dart';
import '../services/zodiac_service.dart';
import '../services/error_service.dart';
import 'base_provider.dart';
import 'user_provider.dart';

part 'zodiac_provider.freezed.dart';
part 'zodiac_provider.g.dart';

@freezed
class ZodiacState with _$ZodiacState implements ErrorHandlingState {
  const factory ZodiacState({
    required Zodiac userZodiac,
    String? fortuneDescription,
    @Default([]) List<String> luckyElements,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _ZodiacState;

  factory ZodiacState.initial() => const ZodiacState(
        userZodiac: Zodiac.rat,
        luckyElements: [],
      );

  factory ZodiacState.fromJson(Map<String, dynamic> json) =>
      _$ZodiacStateFromJson(json);
}

final zodiacServiceProvider = Provider<ZodiacService>((ref) {
  return ZodiacService();
});

final zodiacProvider = FutureProvider<Zodiac>((ref) async {
  final zodiacService = ref.watch(zodiacServiceProvider);
  return zodiacService.calculateZodiac(DateTime.now());
});

class ZodiacNotifier extends BaseStateNotifier<ZodiacState> {
  final ZodiacService _zodiacService;
  final DateTime _birthDate;

  ZodiacNotifier(
    this._zodiacService,
    ErrorService errorService,
    this._birthDate,
  ) : super(
          errorService,
          ZodiacState.initial(),
        ) {
    _init();
  }

  void _init() async {
    await handleAsync(
      () async {
        final zodiac = _zodiacService.calculateZodiac(_birthDate);
        
        state = state.copyWith(
          userZodiac: zodiac,
          isLoading: true,
        );

        final description = await _zodiacService.getFortuneDescription(zodiac);
        final luckyElements = await _zodiacService.getLuckyElements(zodiac);
        
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
        final description = await _zodiacService.getFortuneDescription(state.userZodiac);
        final luckyElements = await _zodiacService.getLuckyElements(state.userZodiac);
        
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