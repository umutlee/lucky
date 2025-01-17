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

  FortuneNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    _fetchAllFortunes(DateTime.now());
  }

  Future<void> _fetchAllFortunes(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final basicResponse = await _apiClient.getBasicFortune(date);
      final studyResponse = await _apiClient.getStudyFortune(date);
      final careerResponse = await _apiClient.getCareerFortune(date);

      if (!basicResponse.success || !studyResponse.success || !careerResponse.success) {
        state = AsyncValue.error('獲取運勢數據失敗', StackTrace.current);
        return;
      }

      final Map<String, dynamic> allFortunes = {
        'basic': basicResponse.data,
        'study': studyResponse.data,
        'career': careerResponse.data,
      };

      state = AsyncValue.data(allFortunes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _fetchAllFortunes(DateTime.now());
  }
}

/// 運勢數據 Provider
final fortuneProvider = StateNotifierProvider<FortuneNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FortuneNotifier(apiClient);
});

/// 每日運勢 Provider
final dailyFortuneProvider = Provider<AsyncValue<DailyFortune?>>((ref) {
  final fortunes = ref.watch(fortuneProvider);
  return fortunes.whenData((data) => data['daily'] as DailyFortune?);
});

/// 學業運勢 Provider
final studyFortuneProvider = Provider.family<AsyncValue<Map<String, dynamic>>, DateTime>((ref, date) {
  return ref.watch(fortuneProvider).whenData((data) => data['study'] as Map<String, dynamic>);
});

/// 事業運勢 Provider
final careerFortuneProvider = Provider.family<AsyncValue<Map<String, dynamic>>, DateTime>((ref, date) {
  return ref.watch(fortuneProvider).whenData((data) => data['career'] as Map<String, dynamic>);
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

/// 基礎運勢 Provider
final basicFortuneProvider = Provider.family<AsyncValue<Map<String, dynamic>>, DateTime>((ref, date) {
  return ref.watch(fortuneProvider).whenData((data) => data['basic'] as Map<String, dynamic>);
}); 