import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/settings_provider.dart';
import 'router.dart';
import 'theme.dart';

/// 應用主入口
/// 配置主題、路由等全局設置
class App extends ConsumerWidget {
  /// 構造函數
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // 應用標題
      title: '吉時萬事通',
      
      // 主題配置
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // 路由配置
      routerConfig: router,
      
      // 調試標籤
      debugShowCheckedModeBanner: false,
    );
  }
} 