import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/daily_fortune.dart';
import '../models/study_fortune.dart';
import '../models/career_fortune.dart';
import '../models/love_fortune.dart';
import '../models/api_response.dart';
import '../services/fortune_service.dart';
import '../services/storage_service.dart';
import '../utils/cache_manager.dart';
import '../services/sqlite_preferences_service.dart';
import '../network/api_client.dart';

/// 運勢數據 Provider
class FortuneNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ApiClient _apiClient;
  final StorageService _storage;

  FortuneNotifier(this._apiClient, this._storage) : super(const AsyncValue.loading()) {
    _fetchAllFortunes(DateTime.now());
  }

  Future<void> _fetchAllFortunes(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final basicResponse = await _apiClient.get<Map<String, dynamic>>(
        '/fortune/daily',
        queryParameters: {
          'date': date.toIso8601String(),
        },
      );
      final studyResponse = await _apiClient.get<Map<String, dynamic>>(
        '/fortune/study',
        queryParameters: {
          'date': date.toIso8601String(),
        },
      );
      final careerResponse = await _apiClient.get<Map<String, dynamic>>(
        '/fortune/career',
        queryParameters: {
          'date': date.toIso8601String(),
        },
      );

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
  final storage = ref.watch(storageServiceProvider);
  return FortuneNotifier(apiClient, storage);
});

/// 每日運勢 Provider
final dailyFortuneProvider = FutureProvider.family<Fortune, DateTime>((ref, date) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  return repository.getDailyFortune(date);
});

/// 學業運勢 Provider
final studyFortuneProvider = FutureProvider.family<StudyFortune, DateTime>((ref, date) async {
  final cacheManager = ref.read(fortuneCacheManagerProvider);
  final cacheKey = 'study_fortune_${date.toIso8601String()}';
  
  // 嘗試從緩存獲取
  final cachedData = await cacheManager.get<StudyFortune>(cacheKey);
  if (cachedData != null) {
    return cachedData;
  }

  // 從服務獲取新數據
  final service = ref.read(fortuneServiceProvider);
  final fortune = await service.getStudyFortune(date);
  
  // 緩存數據
  await cacheManager.set(cacheKey, fortune, const Duration(hours: 24));
  
  return fortune;
});

/// 事業運勢 Provider
final careerFortuneProvider = FutureProvider.family<CareerFortune, DateTime>((ref, date) async {
  final cacheManager = ref.read(fortuneCacheManagerProvider);
  final cacheKey = 'career_fortune_${date.toIso8601String()}';
  
  // 嘗試從緩存獲取
  final cachedData = await cacheManager.get<CareerFortune>(cacheKey);
  if (cachedData != null) {
    return cachedData;
  }

  // 從服務獲取新數據
  final service = ref.read(fortuneServiceProvider);
  final fortune = await service.getCareerFortune(date);
  
  // 緩存數據
  await cacheManager.set(cacheKey, fortune, const Duration(hours: 24));
  
  return fortune;
});

/// 愛情運勢 Provider
final loveFortuneProvider = FutureProvider.family<LoveFortune, DateTime>((ref, date) async {
  final cacheManager = ref.read(fortuneCacheManagerProvider);
  final cacheKey = 'love_fortune_${date.toIso8601String()}';
  
  // 嘗試從緩存獲取
  final cachedData = await cacheManager.get<LoveFortune>(cacheKey);
  if (cachedData != null) {
    return cachedData;
  }

  // 從服務獲取新數據
  final service = ref.read(fortuneServiceProvider);
  final fortune = await service.getLoveFortune(date);
  
  // 緩存數據
  await cacheManager.set(cacheKey, fortune, const Duration(hours: 24));
  
  return fortune;
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

final fortuneServiceProvider = Provider<FortuneService>((ref) {
  return FortuneService();
});

final fortuneCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

// 預加載下一天的運勢數據
final fortunePreloader = Provider((ref) {
  return FortunePreloader(ref);
});

class FortunePreloader {
  final Ref _ref;

  FortunePreloader(this._ref);

  Future<void> preloadNextDay() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    
    await Future.wait([
      _ref.read(studyFortuneProvider(tomorrow).future),
      _ref.read(careerFortuneProvider(tomorrow).future),
      _ref.read(loveFortuneProvider(tomorrow).future),
    ]);
  }

  Future<void> preloadRange(DateTime startDate, DateTime endDate) async {
    for (var date = startDate;
         date.isBefore(endDate);
         date = date.add(const Duration(days: 1))) {
      await Future.wait([
        _ref.read(studyFortuneProvider(date).future),
        _ref.read(careerFortuneProvider(date).future),
        _ref.read(loveFortuneProvider(date).future),
      ]);
    }
  }
}

/// 運勢倉庫提供者
final fortuneRepositoryProvider = Provider<FortuneRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sqlitePreferencesServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return FortuneRepository(apiClient, prefs, storage);
});

/// 運勢倉庫
class FortuneRepository {
  final ApiClient _apiClient;
  final SQLitePreferencesService _prefs;
  final StorageService _storage;

  FortuneRepository(this._apiClient, this._prefs, this._storage);

  /// 獲取每日運勢
  Future<Fortune> getDailyFortune(DateTime date) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/fortune/daily',
      queryParameters: {
        'date': date.toIso8601String(),
      },
    );
    return Fortune.fromJson(response.data!);
  }

  /// 獲取月度運勢
  Future<Map<DateTime, Fortune>> getMonthFortunes(DateTime date) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/fortune/month',
      queryParameters: {
        'year': date.year,
        'month': date.month,
      },
    );

    final Map<DateTime, Fortune> result = {};
    for (final item in response.data!) {
      final fortune = Fortune.fromJson(item as Map<String, dynamic>);
      result[DateTime.parse(item['date'] as String)] = fortune;
    }
    return result;
  }
}

/// 月度運勢提供者
final monthFortunesProvider = FutureProvider.family<Map<DateTime, Fortune>, DateTime>((ref, date) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  return repository.getMonthFortunes(date);
}); 