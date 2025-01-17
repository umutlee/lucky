import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_fortune.dart';
import '../repositories/study_fortune_repository.dart';
import 'settings_provider.dart';

/// 學業運勢倉庫提供者
final studyFortuneRepositoryProvider = Provider<StudyFortuneRepository>((ref) {
  final dio = Dio();
  final prefs = ref.watch(sharedPreferencesProvider);
  return StudyFortuneRepository(dio, prefs);
});

/// 每日學業運勢提供者
final dailyStudyFortuneProvider = FutureProvider.family<StudyFortune, DateTime>((ref, date) async {
  final repository = ref.watch(studyFortuneRepositoryProvider);
  return repository.getDailyStudyFortune(date);
});

/// 月度學業運勢提供者
final monthStudyFortunesProvider = FutureProvider.family<Map<DateTime, StudyFortune>, DateTime>((ref, date) async {
  final repository = ref.watch(studyFortuneRepositoryProvider);
  return repository.getMonthStudyFortunes(date);
});

/// 學業運勢通知開關提供者
final studyFortuneNotificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationNotifier(prefs, 'study_fortune_notifications');
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