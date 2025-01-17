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
final studyFortuneProvider = FutureProvider.family<StudyFortune?, DateTime>((ref, date) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.getStudyFortune(date);
  
  if (response.isSuccess && response.data != null) {
    return response.data;
  }
  
  return null;
});

/// 事業運勢 Provider
final careerFortuneProvider = FutureProvider.family<CareerFortune?, DateTime>((ref, date) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.getCareerFortune(date);
  
  if (response.isSuccess && response.data != null) {
    return response.data;
  }
  
  return null;
});

/// 愛情運勢 Provider
final loveFortuneProvider = Provider<AsyncValue<LoveFortune?>>((ref) {
  final fortunes = ref.watch(fortuneProvider);
  return fortunes.whenData((data) => data['love'] as LoveFortune?);
});

/// 學業運勢通知設置提供者
final studyFortuneNotificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return NotificationNotifier(storage, 'study_fortune_notification');
});

/// 事業運勢通知設置提供者
final careerFortuneNotificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return NotificationNotifier(storage, 'career_fortune_notification');
});

/// 通知設置管理器
class NotificationNotifier extends StateNotifier<bool> {
  final StorageService _storage;
  final String _key;

  NotificationNotifier(this._storage, this._key) : super(false) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    state = await _storage.getSettings<bool>(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    await _storage.saveSettings(_key, state);
  }
} 