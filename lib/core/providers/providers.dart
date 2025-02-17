import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../services/cache_service.dart';
import '../services/storage_service.dart';
import '../services/user_settings_service.dart';
import '../services/zodiac_fortune_service.dart';
import '../utils/logger.dart';
import '../database/database_helper.dart';
import '../services/key_management_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

final loggerProvider = Provider<Logger>((ref) {
  return Logger('App');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final logger = ref.read(loggerProvider);
  return StorageService(logger);
});

final keyManagementServiceProvider = Provider<KeyManagementService>((ref) {
  final storage = ref.read(storageServiceProvider);
  return KeyManagementServiceFactory.create(storage);
});

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  final keyManagementService = ref.read(keyManagementServiceProvider);
  return DatabaseHelperFactory.create(keyManagementService);
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  final logger = ref.read(loggerProvider);
  final databaseHelper = ref.read(databaseHelperProvider);
  return CacheServiceImpl(databaseHelper, logger);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(storageServiceProvider);
  final cacheService = ref.read(cacheServiceProvider);
  return ApiClient(storage, cacheService: cacheService);
});

final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  final storage = ref.read(storageServiceProvider);
  return UserSettingsService(storage);
});

final zodiacFortuneServiceProvider = Provider<ZodiacFortuneService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ZodiacFortuneService(apiClient);
}); 