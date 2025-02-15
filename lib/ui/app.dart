import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_router.dart';
import '../core/providers/theme_provider.dart';
import 'screens/home/home_screen.dart';

/// 應用程序主類
class App extends ConsumerWidget {
  /// 構造函數
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: '運勢預測',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
} 