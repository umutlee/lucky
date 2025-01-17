import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_fortune.dart';
import '../models/study_fortune.dart';
import '../models/career_fortune.dart';
import '../models/love_fortune.dart';
import '../models/api_response.dart';
import 'api_provider.dart';

/// 運勢數據 Provider
class FortuneNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ApiClient _apiClient;
  final String? _zodiacSign;

  FortuneNotifier(this._apiClient, [this._zodiacSign])
      : super(const AsyncValue.loading());

  // 獲取所有運勢數據
  Future<void> fetchAllFortunes(DateTime date) async {
    state = const AsyncValue.loading();

    try {
      final results = await Future.wait([
        _apiClient.getDailyFortune(date, 'general'),
        _apiClient.getStudyFortune(date),
        _apiClient.getCareerFortune(date),
        if (_zodiacSign != null) _apiClient.getLoveFortune(date, _zodiacSign!),
      ]);

      final Map<String, dynamic> fortunes = {
        'daily': results[0].data,
        'study': results[1].data,
        'career': results[2].data,
        if (_zodiacSign != null) 'love': results[3].data,
      };

      state = AsyncValue.data(fortunes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 刷新運勢數據
  Future<void> refresh() async {
    await fetchAllFortunes(DateTime.now());
  }
}

/// 運勢數據 Provider
final fortuneProvider = StateNotifierProvider<FortuneNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // TODO: 從用戶設置中獲取星座
  const zodiacSign = null;
  return FortuneNotifier(apiClient, zodiacSign);
});

/// 每日運勢 Provider
final dailyFortuneProvider = Provider<AsyncValue<DailyFortune?>>((ref) {
  final fortunes = ref.watch(fortuneProvider);
  return fortunes.whenData((data) => data['daily'] as DailyFortune?);
});

/// 學業運勢 Provider
final studyFortuneProvider = Provider<AsyncValue<StudyFortune?>>((ref) {
  final fortunes = ref.watch(fortuneProvider);
  return fortunes.whenData((data) => data['study'] as StudyFortune?);
});

/// 事業運勢 Provider
final careerFortuneProvider = Provider<AsyncValue<CareerFortune?>>((ref) {
  final fortunes = ref.watch(fortuneProvider);
  return fortunes.whenData((data) => data['career'] as CareerFortune?);
});

/// 愛情運勢 Provider
final loveFortuneProvider = Provider<AsyncValue<LoveFortune?>>((ref) {
  final fortunes = ref.watch(fortuneProvider);
  return fortunes.whenData((data) => data['love'] as LoveFortune?);
}); 