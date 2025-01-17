import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/love_fortune.dart';
import '../repositories/love_fortune_repository.dart';
import 'settings_provider.dart';

/// 愛情運勢倉庫提供者
final loveFortuneRepositoryProvider = Provider<LoveFortuneRepository>((ref) {
  final dio = Dio();
  final prefs = ref.watch(sharedPreferencesProvider);
  return LoveFortuneRepository(dio, prefs);
});

/// 用戶星座設置提供者
final userZodiacProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('user_zodiac');
});

/// 每日愛情運勢提供者
final dailyLoveFortuneProvider = FutureProvider.family<LoveFortune, DateTime>((ref, date) async {
  final repository = ref.watch(loveFortuneRepositoryProvider);
  final zodiacSign = ref.watch(userZodiacProvider);
  return repository.getDailyLoveFortune(date, zodiacSign: zodiacSign);
});

/// 月度愛情運勢提供者
final monthLoveFortunesProvider = FutureProvider.family<Map<DateTime, LoveFortune>, DateTime>((ref, date) async {
  final repository = ref.watch(loveFortuneRepositoryProvider);
  final zodiacSign = ref.watch(userZodiacProvider);
  return repository.getMonthLoveFortunes(date, zodiacSign: zodiacSign);
});

/// 愛情運勢通知開關提供者
final loveFortuneNotificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationNotifier(prefs, 'love_fortune_notifications');
});

/// 通知設置管理器
class NotificationNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  final String _key;

  NotificationNotifier(this._prefs, this._key) : super(_prefs.getBool(_key) ?? true);

  void toggle() {
    state = !state;
    _prefs.setBool(_key, state);
  }
} 