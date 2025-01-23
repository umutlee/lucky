import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_config.dart';
import '../services/sqlite_preferences_service.dart';

final fortuneConfigProvider = StateNotifierProvider<FortuneConfigNotifier, FortuneConfig>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return FortuneConfigNotifier(prefsService);
});

class FortuneConfigNotifier extends StateNotifier<FortuneConfig> {
  final SQLitePreferencesService _prefsService;

  FortuneConfigNotifier(this._prefsService) : super(FortuneConfig.initial()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final showLuckyTime = await _prefsService.getValue<bool>('show_lucky_time') ?? true;
      final showLuckyDirection = await _prefsService.getValue<bool>('show_lucky_direction') ?? true;
      final showLuckyColor = await _prefsService.getValue<bool>('show_lucky_color') ?? true;
      final showLuckyNumber = await _prefsService.getValue<bool>('show_lucky_number') ?? true;
      final showDetailedAnalysis = await _prefsService.getValue<bool>('show_detailed_analysis') ?? true;

      state = FortuneConfig(
        showLuckyTime: showLuckyTime,
        showLuckyDirection: showLuckyDirection,
        showLuckyColor: showLuckyColor,
        showLuckyNumber: showLuckyNumber,
        showDetailedAnalysis: showDetailedAnalysis,
      );
    } catch (e) {
      print('加載運勢配置失敗: $e');
    }
  }

  Future<void> updateConfig({
    bool? showLuckyTime,
    bool? showLuckyDirection,
    bool? showLuckyColor,
    bool? showLuckyNumber,
    bool? showDetailedAnalysis,
  }) async {
    try {
      if (showLuckyTime != null) {
        await _prefsService.setValue('show_lucky_time', showLuckyTime);
      }
      if (showLuckyDirection != null) {
        await _prefsService.setValue('show_lucky_direction', showLuckyDirection);
      }
      if (showLuckyColor != null) {
        await _prefsService.setValue('show_lucky_color', showLuckyColor);
      }
      if (showLuckyNumber != null) {
        await _prefsService.setValue('show_lucky_number', showLuckyNumber);
      }
      if (showDetailedAnalysis != null) {
        await _prefsService.setValue('show_detailed_analysis', showDetailedAnalysis);
      }

      state = FortuneConfig(
        showLuckyTime: showLuckyTime ?? state.showLuckyTime,
        showLuckyDirection: showLuckyDirection ?? state.showLuckyDirection,
        showLuckyColor: showLuckyColor ?? state.showLuckyColor,
        showLuckyNumber: showLuckyNumber ?? state.showLuckyNumber,
        showDetailedAnalysis: showDetailedAnalysis ?? state.showDetailedAnalysis,
      );
    } catch (e) {
      print('更新運勢配置失敗: $e');
    }
  }
}