import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

/// 應用程序入口點
void main() {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 啟動應用
  runApp(
    // 使用 ProviderScope 包裝應用，啟用狀態管理
    const ProviderScope(
      child: App(),
    ),
  );
} 