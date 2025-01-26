import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';
import '../services/storage_service.dart';
import '../services/user_settings_service.dart';
import '../services/zodiac_fortune_service.dart';
import '../services/api_client.dart';
import '../services/cache_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final apiClientProvider = Provider<ApiClient>((ref) {
  final cacheService = ref.read(cacheServiceProvider);
  return ApiClient(cacheService: cacheService);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefsService = ref.read(sqlitePreferencesServiceProvider);
  return StorageService(prefsService);
});

final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  final prefsService = ref.read(sqlitePreferencesServiceProvider);
  return UserSettingsService(prefsService);
});

final zodiacFortuneServiceProvider = Provider<ZodiacFortuneService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ZodiacFortuneService(apiClient);
}); 