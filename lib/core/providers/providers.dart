import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/cache_service.dart';
import '../services/storage_service.dart';
import '../services/user_settings_service.dart';
import '../services/zodiac_fortune_service.dart';
import '../utils/logger.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final cacheService = ref.read(cacheServiceProvider);
  return ApiClient(cacheService);
});

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.read(sharedPreferencesProvider)),
);

final userSettingsServiceProvider = Provider<UserSettingsService>(
  (ref) => UserSettingsService(ref.read(sharedPreferencesProvider)),
);

final zodiacFortuneServiceProvider = Provider<ZodiacFortuneService>(
  (ref) => ZodiacFortuneService(ref.read(apiClientProvider)),
);

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final loggerProvider = Provider<Logger>((ref) {
  return Logger('App');
}); 