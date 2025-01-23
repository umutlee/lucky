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
      
      final studyVisible = await _prefsService.getValue<bool>('visible_study') ?? true;
      final careerVisible = await _prefsService.getValue<bool>('visible_career') ?? true;
      final loveVisible = await _prefsService.getValue<bool>('visible_love') ?? true;

      state = FortuneConfig(
        showLuckyTime: showLuckyTime,
        showLuckyDirection: showLuckyDirection,
        showLuckyColor: showLuckyColor,
        showLuckyNumber: showLuckyNumber,
        showDetailedAnalysis: showDetailedAnalysis,
        visibleTypes: {
          'study': studyVisible,
          'career': careerVisible,
          'love': loveVisible,
        },
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
        visibleTypes: state.visibleTypes,
      );
    } catch (e) {
      print('更新運勢配置失敗: $e');
    }
  }

  Future<void> toggleVisibility(String type) async {
    try {
      final currentValue = state.isVisible(type);
      await _prefsService.setValue('visible_$type', !currentValue);
      
      final newVisibleTypes = Map<String, bool>.from(state.visibleTypes);
      newVisibleTypes[type] = !currentValue;

      state = state.copyWith(visibleTypes: newVisibleTypes);
    } catch (e) {
      print('切換運勢類型可見性失敗: $e');
    }
  }
}