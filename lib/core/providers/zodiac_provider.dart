import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/zodiac.dart';
import '../services/zodiac_service.dart';
import '../services/error_service.dart';
import '../models/app_error.dart';
import 'base_provider.dart';
import 'user_provider.dart';

part 'zodiac_provider.freezed.dart';
part 'zodiac_provider.g.dart';

class AppErrorConverter implements JsonConverter<AppError?, Map<String, dynamic>?> {
  const AppErrorConverter();

  @override
  AppError? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AppError.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AppError? error) {
    if (error == null) return null;
    return error.toJson();
  }
}

@freezed
class ZodiacState with _$ZodiacState implements BaseState {
  const factory ZodiacState({
    required Zodiac userZodiac,
    String? fortuneDescription,
    @Default([]) List<String> luckyElements,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
    @AppErrorConverter() AppError? error,
  }) = _ZodiacState;

  factory ZodiacState.initial() => const ZodiacState(
        userZodiac: Zodiac.rat,
        luckyElements: [],
      );

  factory ZodiacState.fromJson(Map<String, dynamic> json) =>
      _$ZodiacStateFromJson(json);
}

@riverpod
ZodiacService zodiacService(ZodiacServiceRef ref) {
  return ZodiacService();
}

@riverpod
class ZodiacNotifier extends _$ZodiacNotifier {
  late final ZodiacService _zodiacService;
  late final ErrorService _errorService;
  late final DateTime _birthDate;

  @override
  FutureOr<ZodiacState> build() async {
    _zodiacService = ref.watch(zodiacServiceProvider);
    _errorService = ref.watch(errorServiceProvider);
    _birthDate = DateTime.now(); // TODO: 從用戶設置獲取
    return _init();
  }

  Future<ZodiacState> _init() async {
    try {
      final zodiac = _zodiacService.calculateZodiac(_birthDate);
      final description = await _zodiacService.getFortuneDescription(zodiac);
      final luckyElements = await _zodiacService.getLuckyElements(zodiac);
      
      return ZodiacState(
        userZodiac: zodiac,
        fortuneDescription: description,
        luckyElements: luckyElements,
        isLoading: false,
        errorMessage: null,
        hasError: false,
        error: null,
      );
    } catch (error, stackTrace) {
      final appError = await _errorService.handleError(error, stackTrace);
      return ZodiacState(
        userZodiac: Zodiac.rat,
        fortuneDescription: null,
        luckyElements: [],
        isLoading: false,
        errorMessage: appError.userMessage,
        hasError: true,
        error: appError,
      );
    }
  }

  Future<void> refreshFortune() async {
    state = const AsyncLoading();
    
    try {
      final zodiac = _zodiacService.calculateZodiac(_birthDate);
      final description = await _zodiacService.getFortuneDescription(zodiac);
      final luckyElements = await _zodiacService.getLuckyElements(zodiac);
      
      state = AsyncData(ZodiacState(
        userZodiac: zodiac,
        fortuneDescription: description,
        luckyElements: luckyElements,
        isLoading: false,
        errorMessage: null,
        hasError: false,
        error: null,
      ));
    } catch (error, stackTrace) {
      final appError = await _errorService.handleError(error, stackTrace);
      state = AsyncError(error, stackTrace);
      state = AsyncData(ZodiacState(
        userZodiac: Zodiac.rat,
        fortuneDescription: null,
        luckyElements: [],
        isLoading: false,
        errorMessage: appError.userMessage,
        hasError: true,
        error: appError,
      ));
    }
  }
} 