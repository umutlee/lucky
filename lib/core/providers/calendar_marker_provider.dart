import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_marker.dart';
import '../services/calendar_marker_service.dart';

/// 當前月份的日曆標記提供者
final monthlyMarkersProvider = FutureProvider.family<List<CalendarMarker>, DateTime>((ref, date) async {
  final service = ref.watch(calendarMarkerServiceProvider);
  final start = DateTime(date.year, date.month, 1);
  final end = DateTime(date.year, date.month + 1, 0);
  return service.getMarkersInRange(start, end);
});

/// 日曆標記狀態提供者
final calendarMarkerNotifierProvider = StateNotifierProvider<CalendarMarkerNotifier, AsyncValue<List<CalendarMarker>>>((ref) {
  final service = ref.watch(calendarMarkerServiceProvider);
  return CalendarMarkerNotifier(service);
});

/// 日曆標記狀態管理器
class CalendarMarkerNotifier extends StateNotifier<AsyncValue<List<CalendarMarker>>> {
  final CalendarMarkerService _service;

  CalendarMarkerNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadInitialMarkers();
  }

  /// 加載初始標記
  Future<void> _loadInitialMarkers() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    await loadMarkers(start, end);
  }

  /// 加載指定日期範圍的標記
  Future<void> loadMarkers(DateTime start, DateTime end) async {
    try {
      state = const AsyncValue.loading();
      final markers = await _service.getMarkersInRange(start, end);
      state = AsyncValue.data(markers);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 添加自定義標記
  Future<void> addCustomMarker(CalendarMarker marker) async {
    try {
      await _service.addCustomMarker(marker);
      state.whenData((markers) {
        state = AsyncValue.data([...markers, marker]);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 刪除自定義標記
  Future<void> removeCustomMarker(DateTime date) async {
    try {
      await _service.removeCustomMarker(date);
      state.whenData((markers) {
        state = AsyncValue.data(
          markers.where((marker) =>
            marker.date.year != date.year ||
            marker.date.month != date.month ||
            marker.date.day != date.day
          ).toList(),
        );
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
} 