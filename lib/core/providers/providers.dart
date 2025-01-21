import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import '../services/user_settings_service.dart';
import '../services/zodiac_fortune_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('需要在 main.dart 中初始化 SharedPreferences');
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.read(sharedPreferencesProvider)),
);

final userSettingsServiceProvider = Provider<UserSettingsService>(
  (ref) => UserSettingsService(ref.read(sharedPreferencesProvider)),
);

final zodiacFortuneServiceProvider = Provider<ZodiacFortuneService>(
  (ref) => ZodiacFortuneService(ref.read(apiClientProvider)),
); 