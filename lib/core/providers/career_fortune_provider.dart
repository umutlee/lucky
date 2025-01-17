import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/career_fortune.dart';
import '../repositories/career_fortune_repository.dart';
import 'settings_provider.dart';

/// 事業運勢倉庫提供者
final careerFortuneRepositoryProvider = Provider<CareerFortuneRepository>((ref) {
  final dio = Dio();
  final prefs = ref.watch(sharedPreferencesProvider);
  return CareerFortuneRepository(dio, prefs);
});

/// 每日事業運勢提供者
final dailyCareerFortuneProvider = FutureProvider.family<CareerFortune, DateTime>((ref, date) async {
  final repository = ref.watch(careerFortuneRepositoryProvider);
  return repository.getDailyCareerFortune(date);
});

/// 月度事業運勢提供者
final monthCareerFortunesProvider = FutureProvider.family<Map<DateTime, CareerFortune>, DateTime>((ref, date) async {
  final repository = ref.watch(careerFortuneRepositoryProvider);
  return repository.getMonthCareerFortunes(date);
});

/// 事業運勢通知開關提供者
final careerFortuneNotificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationNotifier(prefs, 'career_fortune_notifications');
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