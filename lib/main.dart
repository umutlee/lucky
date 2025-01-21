import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/ui/app.dart';
import 'core/initialization/app_initializer.dart';

final _logger = Logger('Main');

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 初始化時區數據
    tz.initializeTimeZones();
    
    // 設置應用方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 設置字體緩存
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
    
    final container = ProviderContainer();
    
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
    runApp(const ErrorApp());
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '應用初始化失敗',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '請檢查網絡連接後重試',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 