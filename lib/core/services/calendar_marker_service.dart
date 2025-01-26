import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_marker.dart';
import 'sqlite_preferences_service.dart';
import 'solar_term_service.dart';
import 'lucky_day_service.dart';
import 'almanac_service.dart';
import '../utils/logger.dart';
import 'dart:convert';

/// 日曆標記服務提供者
final calendarMarkerServiceProvider = Provider<CalendarMarkerService>((ref) {
  final preferencesService = ref.watch(sqlitePreferencesServiceProvider);
  final solarTermService = ref.watch(solarTermServiceProvider);
  final luckyDayService = ref.watch(luckyDayServiceProvider);
  final almanacService = ref.watch(almanacServiceProvider);
  return CalendarMarkerService(
    preferencesService: preferencesService,
    solarTermService: solarTermService,
    luckyDayService: luckyDayService,
    almanacService: almanacService,
  );
});

/// 日曆標記服務
class CalendarMarkerService {
  final SqlitePreferencesService _preferences;
  final SolarTermService _solarTermService;
  final LuckyDayService _luckyDayService;
  final AlmanacService _almanacService;
  final _logger = Logger('CalendarMarkerService');

  static const String _keyCustomMarkers = 'calendar_custom_markers';

  CalendarMarkerService({
    required SqlitePreferencesService preferencesService,
    required SolarTermService solarTermService,
    required LuckyDayService luckyDayService,
    required AlmanacService almanacService,
  })  : _preferences = preferencesService,
        _solarTermService = solarTermService,
        _luckyDayService = luckyDayService,
        _almanacService = almanacService;

  /// 獲取指定日期範圍內的所有標記
  Future<List<CalendarMarker>> getMarkersInRange(DateTime start, DateTime end) async {
    try {
      final markers = <CalendarMarker>[];

      // 1. 獲取節氣標記
      final solarTerms = await _solarTermService.getTermsInRange(start, end);
      markers.addAll(
        solarTerms.map((term) => CalendarMarker(
          date: term.date,
          type: 'solar_term',
          title: term.name,
          description: term.description,
        )),
      );

      // 2. 獲取吉日標記
      final luckyDays = await _luckyDayService.getLuckyDaysInRange(start, end);
      markers.addAll(
        luckyDays.map((day) => CalendarMarker(
          date: day.date,
          type: 'lucky_day',
          title: '吉日',
          description: day.description,
        )),
      );

      // 3. 獲取農曆節日標記
      final lunarFestivals = await _almanacService.getLunarFestivalsInRange(start, end);
      markers.addAll(
        lunarFestivals.map((festival) => CalendarMarker(
          date: festival.date,
          type: 'lunar_festival',
          title: festival.name,
          description: festival.description,
        )),
      );

      // 4. 獲取自定義標記
      final customMarkers = await _getCustomMarkers();
      markers.addAll(
        customMarkers.where((marker) =>
          marker.date.isAfter(start.subtract(const Duration(days: 1))) &&
          marker.date.isBefore(end.add(const Duration(days: 1)))
        ),
      );

      return markers;
    } catch (e) {
      _logger.error('獲取日期標記失敗', e);
      return [];
    }
  }

  /// 添加自定義標記
  Future<void> addCustomMarker(CalendarMarker marker) async {
    try {
      final markers = await _getCustomMarkers();
      markers.add(marker);
      await _saveCustomMarkers(markers);
      _logger.info('添加自定義標記：${marker.title} - ${marker.date}');
    } catch (e) {
      _logger.error('添加自定義標記失敗', e);
    }
  }

  /// 刪除自定義標記
  Future<void> removeCustomMarker(DateTime date) async {
    try {
      final markers = await _getCustomMarkers();
      markers.removeWhere((marker) =>
        marker.date.year == date.year &&
        marker.date.month == date.month &&
        marker.date.day == date.day
      );
      await _saveCustomMarkers(markers);
      _logger.info('刪除自定義標記：$date');
    } catch (e) {
      _logger.error('刪除自定義標記失敗', e);
    }
  }

  /// 獲取自定義標記
  Future<List<CalendarMarker>> _getCustomMarkers() async {
    try {
      final json = await _preferences.getString(_keyCustomMarkers);
      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list
          .map((item) => CalendarMarker.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('獲取自定義標記失敗', e);
      return [];
    }
  }

  /// 保存自定義標記
  Future<void> _saveCustomMarkers(List<CalendarMarker> markers) async {
    try {
      final json = jsonEncode(markers.map((m) => m.toJson()).toList());
      await _preferences.setString(_keyCustomMarkers, json);
    } catch (e) {
      _logger.error('保存自定義標記失敗', e);
    }
  }
} 