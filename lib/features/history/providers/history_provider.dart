import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/history_record.dart';
import '../../../core/services/history_service.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<HistoryRecord>>>((ref) {
  final historyService = ref.watch(historyServiceProvider);
  return HistoryNotifier(historyService);
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