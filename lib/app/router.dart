import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 應用路由配置
/// 使用 go_router 實現導航管理
class AppRouter {
  AppRouter._();

  /// 路由名稱常量
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String settings = '/settings';

  /// 創建路由配置
  static final router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // TODO: 實現各頁面後替換這些佔位組件
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('首頁 - 待實現')),
        ),
      ),
      GoRoute(
        path: calendar,
        name: 'calendar',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('月曆 - 待實現')),
        ),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('設置 - 待實現')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          '找不到頁面: ${state.uri}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
} 