import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'core/services/notification_service.dart';
import 'core/utils/logger.dart';

final _logger = Logger('Main');

Future<void> main() async {
  try {
    // 確保 Flutter 綁定初始化
    WidgetsFlutterBinding.ensureInitialized();

    // 並行初始化所有必要服務
    final futures = await Future.wait([
      // 初始化時區數據
      Future(() => tz.initializeTimeZones()),
      // 初始化 SharedPreferences
      SharedPreferences.getInstance(),
      // 預加載資源
      _preloadResources(),
      // 預加載系統字體
      _loadSystemFonts(),
      // 優化圖片緩存
      _optimizeImageCache(),
    ]);

    final prefs = futures[1] as SharedPreferences;

    // 運行應用
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    _logger.error('應用程序啟動失敗', e, stack);
    rethrow;
  }
}

Future<void> _preloadResources() async {
  try {
    // 使用 compute 在後台線程加載資源
    await compute(_loadResources, null);
  } catch (e) {
    _logger.warning('資源預加載失敗: $e');
  }
}

Future<void> _loadResources(void _) async {
  // 預加載圖片
  final imageFutures = [
    precacheImage(const AssetImage('assets/images/logo.png'), null),
    precacheImage(const AssetImage('assets/images/background.png'), null),
  ];
  await Future.wait(imageFutures);
}

Future<void> _loadSystemFonts() async {
  try {
    // 預加載自定義字體
    final fontLoader = FontLoader('CustomFont')
      ..addFont(rootBundle.load('assets/fonts/custom_font.ttf'));
    await fontLoader.load();
  } catch (e) {
    _logger.warning('字體加載失敗: $e');
  }
}

Future<void> _optimizeImageCache() async {
  try {
    // 設置圖片緩存參數
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  } catch (e) {
    _logger.warning('圖片緩存優化失敗: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '運勢預測',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        platform: Theme.of(context).platform,
        // 優化主題設置
        applyElevationOverlayColor: false,
        visualDensity: VisualDensity.standard,
      ),
      home: const HomeScreen(),
      // 使用路由緩存
      onGenerateRoute: onGenerateRoute,
      // 優化路由生成
      routerDelegate: _CustomRouterDelegate(),
      // 禁用調試橫幅
      debugShowCheckedModeBanner: false,
    );
  }
}

// 自定義路由委託
class _CustomRouterDelegate extends RouterDelegate<RouteSettings> {
  @override
  Widget build(BuildContext context) => const HomeScreen();
  
  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {}
  
  @override
  Future<bool> popRoute() async => true;
  
  @override
  RouteInformationProvider? get routeInformationProvider => null;
  
  @override
  RouteInformationParser<Object>? get routeInformationParser => null;
}

// 路由緩存
final _routeCache = <String, Route<dynamic>>{};

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  // 檢查緩存
  if (_routeCache.containsKey(settings.name)) {
    return _routeCache[settings.name];
  }

  // 生成新路由
  final route = MaterialPageRoute(
    settings: settings,
    builder: (context) {
      switch (settings.name) {
        case '/home':
          return const HomeScreen();
        case '/settings':
          return const SettingsScreen();
        case '/fortune-detail':
          return FortuneDetailScreen(
            fortune: settings.arguments as Fortune,
          );
        default:
          return const HomeScreen();
      }
    },
  );

  // 緩存路由
  _routeCache[settings.name ?? ''] = route;
  return route;
}

// 共享的 SharedPreferences 實例
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
}); 