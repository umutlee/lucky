import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:all_lucky/core/database/database_helper.dart';
import 'package:all_lucky/core/services/history_service.dart';
import 'package:all_lucky/core/models/history_record.dart';
import 'history_service_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<DatabaseHelper>(
    as: #MockDatabaseHelper,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late HistoryService historyService;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    historyService = HistoryService(mockDatabaseHelper);
  });

  group('HistoryService', () {
    test('初始化應該創建表', () async {
      when(mockDatabaseHelper.execute(any)).thenAnswer((_) async => {});

      await historyService.init();

      verify(mockDatabaseHelper.execute(argThat(contains('CREATE TABLE IF NOT EXISTS history_records')))).called(1);
    });

    test('添加記錄應該返回新ID', () async {
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: DateTime.now(),
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
      );

      when(mockDatabaseHelper.insert(any, any)).thenAnswer((_) async => 1);

      final id = await historyService.addRecord(record);

      expect(id, isNotEmpty);
      verify(mockDatabaseHelper.insert('history_records', any)).called(1);
    });

    test('獲取記錄應該正確轉換數據', () async {
      final timestamp = DateTime.now();
      final mockData = [{
        'id': 'test-id',
        'timestamp': timestamp.millisecondsSinceEpoch,
        'fortune_type': '今日運勢',
        'fortune_result': '大吉',
        'notes': '測試備註',
        'is_favorite': 1,
      }];

      when(mockDatabaseHelper.query(
        any,
        where: anyNamed('where'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => mockData);

      final records = await historyService.getRecords();

      expect(records.length, 1);
      expect(records.first.id, 'test-id');
      expect(records.first.timestamp.millisecondsSinceEpoch, timestamp.millisecondsSinceEpoch);
      expect(records.first.fortuneType, '今日運勢');
      expect(records.first.fortuneResult, '大吉');
      expect(records.first.notes, '測試備註');
      expect(records.first.isFavorite, true);
    });

    test('更新記錄應該返回成功', () async {
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: DateTime.now(),
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        notes: '更新的備註',
        isFavorite: true,
      );

      when(mockDatabaseHelper.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      final success = await historyService.updateRecord(record);

      expect(success, true);
      verify(mockDatabaseHelper.update(
        'history_records',
        any,
        where: 'id = ?',
        whereArgs: [record.id],
      )).called(1);
    });

    test('刪除記錄應該返回成功', () async {
      when(mockDatabaseHelper.delete(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      final success = await historyService.deleteRecord('test-id');

      expect(success, true);
      verify(mockDatabaseHelper.delete(
        'history_records',
        where: 'id = ?',
        whereArgs: ['test-id'],
      )).called(1);
    });

    test('清空記錄應該執行刪除操作', () async {
      when(mockDatabaseHelper.delete(any)).thenAnswer((_) async => 0);

      await historyService.clear();

      verify(mockDatabaseHelper.delete('history_records')).called(1);
    });

    test('獲取收藏記錄應該使用正確的查詢條件', () async {
      when(mockDatabaseHelper.query(
        any,
        where: anyNamed('where'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => []);

      await historyService.getRecords(favoritesOnly: true);

      verify(mockDatabaseHelper.query(
        'history_records',
        where: 'is_favorite = 1',
        orderBy: 'timestamp DESC',
        limit: null,
        offset: null,
      )).called(1);
    });
  });
} 