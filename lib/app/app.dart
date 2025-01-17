import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

/// 應用主入口
/// 配置主題、路由等全局設置
class App extends ConsumerWidget {
  /// 構造函數
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 從 provider 獲取主題模式
    final isDarkMode = false;

    return MaterialApp.router(
      // 應用標題
      title: '諸事大吉',
      
      // 主題配置
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // 路由配置
      routerConfig: AppRouter.router,
      
      // 調試標籤
      debugShowCheckedModeBanner: false,
      
      // 本地化配置
      // TODO: 實現多語言支持
      locale: const Locale('zh', 'TW'),
      
      // 全局捕獲錯誤
      builder: (context, child) {
        return _ErrorBoundary(child: child!);
      },
    );
  }
}

/// 錯誤邊界組件
/// 用於捕獲和展示全局錯誤
class _ErrorBoundary extends StatelessWidget {
  final Widget child;

  const _ErrorBoundary({required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '發生錯誤',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    };
    
    return child;
  }
} 