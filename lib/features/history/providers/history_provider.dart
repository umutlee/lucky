import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/history_record.dart';
import '../../../core/services/history_service.dart';

final historyProvider = Provider.autoDispose<AsyncValue<List<HistoryRecord>>>((ref) {
  // 模擬一些測試數據
  final records = [
    HistoryRecord(
      id: '1',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      fortuneType: '今日運勢',
      fortuneResult: '大吉',
      notes: '今天心情特別好',
      isFavorite: true,
    ),
    HistoryRecord(
      id: '2',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      fortuneType: '方位指引',
      fortuneResult: '東南方',
      notes: '適合外出旅遊',
      isFavorite: false,
    ),
    HistoryRecord(
      id: '3',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      fortuneType: '今日運勢',
      fortuneResult: '中吉',
      notes: '平靜的一天',
      isFavorite: true,
    ),
  ];

  return AsyncValue.data(records);
});

class HistoryNotifier extends StateNotifier<AsyncValue<List<HistoryRecord>>> {
  final HistoryService _historyService;
  
  HistoryNotifier(this._historyService) : super(const AsyncValue.loading()) {
    loadRecords();
  }

  Future<void> loadRecords({bool favoritesOnly = false}) async {
    try {
      state = const AsyncValue.loading();
      final records = await _historyService.getRecords(favoritesOnly: favoritesOnly);
      state = AsyncValue.data(records);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addRecord(HistoryRecord record) async {
    try {
      await _historyService.addRecord(record);
      await loadRecords();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRecord(HistoryRecord record) async {
    try {
      await _historyService.updateRecord(record);
      await loadRecords();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _historyService.deleteRecord(id);
      await loadRecords();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(HistoryRecord record) async {
    try {
      final updatedRecord = record.copyWith(isFavorite: !record.isFavorite);
      await _historyService.updateRecord(updatedRecord);
      await loadRecords();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearHistory() async {
    try {
      await _historyService.clear();
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
} 