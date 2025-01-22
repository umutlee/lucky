import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/history_service.dart';
import 'package:all_lucky/core/models/history_record.dart';
import 'package:all_lucky/features/history/providers/history_provider.dart';
import 'history_provider_test.mocks.dart';

@GenerateMocks([HistoryService])
void main() {
  late MockHistoryService mockHistoryService;
  late ProviderContainer container;

  setUp(() {
    mockHistoryService = MockHistoryService();
    container = ProviderContainer(
      overrides: [
        historyServiceProvider.overrideWithValue(mockHistoryService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('HistoryProvider', () {
    test('初始狀態應該是加載中', () {
      when(mockHistoryService.getRecords()).thenAnswer((_) async => []);
      
      final initialState = container.read(historyProvider);
      expect(initialState, const AsyncValue<List<HistoryRecord>>.loading());
    });

    test('加載記錄應該更新狀態', () async {
      final records = [
        HistoryRecord(
          id: 'test-id',
          timestamp: DateTime.now(),
          fortuneType: '今日運勢',
          fortuneResult: '大吉',
        ),
      ];

      when(mockHistoryService.getRecords(favoritesOnly: false))
          .thenAnswer((_) async => records);

      // 等待初始加載完成
      await container.read(historyProvider.notifier).loadRecords();

      final state = container.read(historyProvider);
      expect(state.value, records);
    });

    test('添加記錄應該重新加載數據', () async {
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: DateTime.now(),
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
      );

      when(mockHistoryService.addRecord(record))
          .thenAnswer((_) async => 'new-id');
      when(mockHistoryService.getRecords(favoritesOnly: false))
          .thenAnswer((_) async => [record]);

      await container.read(historyProvider.notifier).addRecord(record);

      verify(mockHistoryService.addRecord(record)).called(1);
      verify(mockHistoryService.getRecords(favoritesOnly: false)).called(2);
    });

    test('更新記錄應該重新加載數據', () async {
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: DateTime.now(),
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        notes: '更新的備註',
      );

      when(mockHistoryService.updateRecord(record))
          .thenAnswer((_) async => true);
      when(mockHistoryService.getRecords(favoritesOnly: false))
          .thenAnswer((_) async => [record]);

      await container.read(historyProvider.notifier).updateRecord(record);

      verify(mockHistoryService.updateRecord(record)).called(1);
      verify(mockHistoryService.getRecords(favoritesOnly: false)).called(2);
    });

    test('刪除記錄應該重新加載數據', () async {
      when(mockHistoryService.deleteRecord('test-id'))
          .thenAnswer((_) async => true);
      when(mockHistoryService.getRecords(favoritesOnly: false))
          .thenAnswer((_) async => []);

      await container.read(historyProvider.notifier).deleteRecord('test-id');

      verify(mockHistoryService.deleteRecord('test-id')).called(1);
      verify(mockHistoryService.getRecords(favoritesOnly: false)).called(2);
    });

    test('切換收藏應該更新記錄', () async {
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: DateTime.now(),
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        isFavorite: false,
      );

      final updatedRecord = record.copyWith(isFavorite: true);

      when(mockHistoryService.updateRecord(updatedRecord))
          .thenAnswer((_) async => true);
      when(mockHistoryService.getRecords(favoritesOnly: false))
          .thenAnswer((_) async => [updatedRecord]);

      await container.read(historyProvider.notifier).toggleFavorite(record);

      verify(mockHistoryService.updateRecord(updatedRecord)).called(1);
      verify(mockHistoryService.getRecords(favoritesOnly: false)).called(2);
    });

    test('清空歷史應該更新狀態為空列表', () async {
      when(mockHistoryService.clear()).thenAnswer((_) async => {});

      await container.read(historyProvider.notifier).clearHistory();

      verify(mockHistoryService.clear()).called(1);
      final state = container.read(historyProvider);
      expect(state.value, isEmpty);
    });

    test('服務錯誤應該更新錯誤狀態', () async {
      final error = Exception('測試錯誤');
      when(mockHistoryService.getRecords(favoritesOnly: false))
          .thenThrow(error);

      await container.read(historyProvider.notifier).loadRecords();

      final state = container.read(historyProvider);
      expect(state.hasError, true);
      expect(state.error, error);
    });
  });
} 