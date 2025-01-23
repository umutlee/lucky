import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/love_fortune.dart';
import '../repositories/love_fortune_repository.dart';
import '../services/sqlite_preferences_service.dart';
import '../notifiers/notification_notifier.dart';

/// 愛情運勢倉庫提供者
final loveFortuneRepositoryProvider = Provider<LoveFortuneRepository>((ref) {
  final dio = Dio();
  final prefs = ref.watch(sqlitePreferencesServiceProvider);
  return LoveFortuneRepository(dio, prefs);
});

/// 用戶星座設置提供者
final userZodiacProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sqlitePreferencesServiceProvider);
  return null; // 初始值為空，實際值會在初始化時加載
});

/// 每日愛情運勢提供者
final dailyLoveFortuneProvider = FutureProvider.family<LoveFortune, DateTime>((ref, date) async {
  final repository = ref.watch(loveFortuneRepositoryProvider);
  return repository.getDailyLoveFortune(date);
});

/// 月度愛情運勢提供者
final monthLoveFortunesProvider = FutureProvider.family<Map<DateTime, LoveFortune>, DateTime>((ref, date) async {
  final repository = ref.watch(loveFortuneRepositoryProvider);
  return repository.getMonthLoveFortunes(date);
});

/// 愛情運勢通知開關提供者
final loveFortuneNotificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefs = ref.watch(sqlitePreferencesServiceProvider);
  return NotificationNotifier(prefs, 'love_fortune_notifications');
}); 