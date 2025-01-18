import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routes/app_routes.dart';
import 'core/services/notification_service.dart';
import 'core/providers/fortune_provider.dart';
import 'core/providers/calendar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // 初始化 Providers
  Get.put(FortuneProvider());
  Get.put(CalendarProvider());
  
  // 初始化通知服務
  final notificationService = NotificationService();
  await notificationService.initialize();
  Get.put(notificationService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '諸事大吉',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      getPages: AppRoutes.pages,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      navigatorObservers: [AppRoutes.routeObserver],
      debugShowCheckedModeBanner: false,
    );
  }
} 