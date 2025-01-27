import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zodiac.dart';
import '../services/zodiac_service.dart';
import '../services/error_service.dart';
import 'base_provider.dart';
import 'user_provider.dart';

class ZodiacState with ErrorHandlingState, LoadingState {
  final ChineseZodiac userZodiac;
  final String? fortuneDescription;
  final List<String>? luckyElements;

  ZodiacState({
    required this.userZodiac,
    this.fortuneDescription,
    this.luckyElements,
    this.error,
    this.isLoading = false,
  });

  ZodiacState copyWith({
    ChineseZodiac? userZodiac,
    String? fortuneDescription,
    List<String>? luckyElements,
    AppError? error,
    bool? isLoading,
  }) {
    return ZodiacState(
      userZodiac: userZodiac ?? this.userZodiac,
      fortuneDescription: fortuneDescription ?? this.fortuneDescription,
      luckyElements: luckyElements ?? this.luckyElements,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final zodiacProvider = StateNotifierProvider<ZodiacNotifier, ZodiacState>((ref) {
  final birthDate = ref.watch(userProvider.select((user) => user.birthDate));
  final errorService = ref.watch(errorServiceProvider);
  return ZodiacNotifier(
    ZodiacService(),
    errorService,
    birthDate,
  );
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
          ZodiacState(
            userZodiac: ChineseZodiac.rat,
            isLoading: true,
          ),
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
          error: error,
          isLoading: false,
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