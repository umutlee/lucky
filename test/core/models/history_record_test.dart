import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/history_record.dart';

void main() {
  group('HistoryRecord', () {
    test('應該正確創建記錄', () {
      final timestamp = DateTime.now();
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: timestamp,
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        notes: '測試備註',
        isFavorite: true,
      );

      expect(record.id, 'test-id');
      expect(record.timestamp, timestamp);
      expect(record.fortuneType, '今日運勢');
      expect(record.fortuneResult, '大吉');
      expect(record.notes, '測試備註');
      expect(record.isFavorite, true);
    });

    test('應該使用默認值創建記錄', () {
      final timestamp = DateTime.now();
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: timestamp,
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
      );

      expect(record.notes, null);
      expect(record.isFavorite, false);
    });

    test('應該正確序列化為JSON', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0);
      final record = HistoryRecord(
        id: 'test-id',
        timestamp: timestamp,
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        notes: '測試備註',
        isFavorite: true,
      );

      final json = record.toJson();
      
      expect(json['id'], 'test-id');
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['fortuneType'], '今日運勢');
      expect(json['fortuneResult'], '大吉');
      expect(json['notes'], '測試備註');
      expect(json['isFavorite'], true);
    });

    test('應該正確從JSON反序列化', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0);
      final json = {
        'id': 'test-id',
        'timestamp': timestamp.toIso8601String(),
        'fortuneType': '今日運勢',
        'fortuneResult': '大吉',
        'notes': '測試備註',
        'isFavorite': true,
      };

      final record = HistoryRecord.fromJson(json);

      expect(record.id, 'test-id');
      expect(record.timestamp, timestamp);
      expect(record.fortuneType, '今日運勢');
      expect(record.fortuneResult, '大吉');
      expect(record.notes, '測試備註');
      expect(record.isFavorite, true);
    });

    test('相同內容的記錄應該相等', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0);
      final record1 = HistoryRecord(
        id: 'test-id',
        timestamp: timestamp,
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        notes: '測試備註',
        isFavorite: true,
      );

      final record2 = HistoryRecord(
        id: 'test-id',
        timestamp: timestamp,
        fortuneType: '今日運勢',
        fortuneResult: '大吉',
        notes: '測試備註',
        isFavorite: true,
      );

      expect(record1, record2);
      expect(record1.hashCode, record2.hashCode);
    });
  });
} 