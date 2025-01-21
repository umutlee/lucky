import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/core/services/preferences_service.dart';
import 'package:all_lucky/core/services/database_service.dart';
import 'package:all_lucky/core/services/cache_service.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/ui/app.dart';

final _logger = Logger('Main');

Future<void> main() async {
  try {
    // 確保 Flutter 綁定初始化
    WidgetsFlutterBinding.ensureInitialized();

    // 並行初始化所有必要服務
    final futures = await Future.wait([
      // 初始化時區數據
      Future(() => tz.initializeTimeZones()),
      // 初始化用戶資料服務
      _initUserProfileService(),
      // 初始化偏好設置服務
      _initPreferencesService(),
      // 初始化數據庫服務
      _initDatabaseService(),
      // 預加載資源
      _preloadResources(),
      // 預加載系統字體（僅在非測試環境）
      if (!kIsWeb && !kDebugMode) _loadSystemFonts(),
      // 優化圖片緩存
      _optimizeImageCache(),
    ]);

    final userProfileService = futures[1] as UserProfileService;
    final preferencesService = futures[2] as PreferencesService;
    final databaseService = futures[3] as DatabaseService;
    final cacheService = CacheService(databaseService);

    // 運行應用
    runApp(
      ProviderScope(
        overrides: [
          userProfileServiceProvider.overrideWithValue(userProfileService),
          preferencesServiceProvider.overrideWithValue(preferencesService),
          databaseServiceProvider.overrideWithValue(databaseService),
          cacheServiceProvider.overrideWithValue(cacheService),
        ],
        child: const App(),
      ),
    );
  } catch (e, stack) {
    _logger.error('應用程序啟動失敗', e, stack);
    rethrow;
  }
}

Future<UserProfileService> _initUserProfileService() async {
  try {
    final service = UserProfileService();
    await service.init();
    return service;
  } catch (e, stack) {
    _logger.error('初始化用戶資料服務失敗', e, stack);
    rethrow;
  }
}

Future<PreferencesService> _initPreferencesService() async {
  try {
    final service = PreferencesService();
    await service.init();
    return service;
  } catch (e, stack) {
    _logger.error('初始化偏好設置服務失敗', e, stack);
    rethrow;
  }
}

Future<DatabaseService> _initDatabaseService() async {
  try {
    final service = DatabaseService();
    await service.init();
    return service;
  } catch (e, stack) {
    _logger.error('初始化數據庫服務失敗', e, stack);
    rethrow;
  }
}

Future<void> _preloadResources() async {
  try {
    // 使用 compute 在後台線程加載資源
    await compute(_loadResources, null);
  } catch (e, stack) {
    _logger.warning('資源預加載失敗', e, stack);
  }
}

Future<void> _loadResources(void _) async {
  try {
    // 暫時移除圖片預加載
    await Future.delayed(Duration.zero);
  } catch (e, stack) {
    _logger.warning('資源加載失敗', e, stack);
  }
}

Future<void> _loadSystemFonts() async {
  try {
    // 預加載自定義字體
    final fontLoader = FontLoader('NotoSansTC')
      ..addFont(rootBundle.load('assets/fonts/NotoSansTC-Regular.otf'))
      ..addFont(rootBundle.load('assets/fonts/NotoSansTC-Medium.otf'))
      ..addFont(rootBundle.load('assets/fonts/NotoSansTC-Bold.otf'));
    await fontLoader.load();
  } catch (e, stack) {
    _logger.warning('字體加載失敗', e, stack);
  }
}

Future<void> _optimizeImageCache() async {
  try {
    // 設置圖片緩存參數
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  } catch (e, stack) {
    _logger.warning('圖片緩存優化失敗', e, stack);
  }
} 