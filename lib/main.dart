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
import 'core/services/cache_cleanup_service.dart';
import 'core/initialization/app_initializer.dart';

final _logger = Logger('Main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();

  try {
    // 初始化應用
    await container.read(appInitializerProvider).initialize();
    
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
  } catch (e, stack) {
    _logger.error('應用初始化失敗', e, stack);
    // 在這裡可以顯示錯誤界面或者重試選項
    runApp(const ErrorApp());
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

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Lucky',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '應用初始化失敗',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // 重新啟動應用
                  main();
                },
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 