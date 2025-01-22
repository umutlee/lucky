import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/history_record.dart';
import '../utils/logger.dart';
import 'database_service.dart';

final historyServiceProvider = Provider((ref) {
  final database = ref.watch(databaseServiceProvider);
  return HistoryService(database);
});

class HistoryService {
  final DatabaseService _db;
  final _logger = Logger('HistoryService');
  static const _tableName = 'history_records';

  HistoryService(this._db);

  Future<void> init() async {
    try {
      final db = await _db.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          timestamp INTEGER NOT NULL,
          fortune_type TEXT NOT NULL,
          fortune_result TEXT NOT NULL,
          notes TEXT,
          is_favorite INTEGER NOT NULL DEFAULT 0
        )
      ''');
      _logger.info('歷史記錄表初始化成功');
    } catch (e, stackTrace) {
      _logger.error('歷史記錄表初始化失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<String> addRecord(HistoryRecord record) async {
    try {
      final db = await _db.database;
      final id = const Uuid().v4();
      await db.insert(_tableName, {
        'id': id,
        'timestamp': record.timestamp.millisecondsSinceEpoch,
        'fortune_type': record.fortuneType,
        'fortune_result': record.fortuneResult,
        'notes': record.notes,
        'is_favorite': record.isFavorite ? 1 : 0,
      });
      _logger.info('添加歷史記錄成功: $id');
      return id;
    } catch (e, stackTrace) {
      _logger.error('添加歷史記錄失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<List<HistoryRecord>> getRecords({
    int? limit,
    int? offset,
    bool favoritesOnly = false,
  }) async {
    try {
      final db = await _db.database;
      final where = favoritesOnly ? 'is_favorite = 1' : null;
      final records = await db.query(
        _tableName,
        where: where,
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
      
      return records.map((record) => HistoryRecord(
        id: record['id'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(record['timestamp'] as int),
        fortuneType: record['fortune_type'] as String,
        fortuneResult: record['fortune_result'] as String,
        notes: record['notes'] as String?,
        isFavorite: (record['is_favorite'] as int) == 1,
      )).toList();
    } catch (e, stackTrace) {
      _logger.error('獲取歷史記錄失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> updateRecord(HistoryRecord record) async {
    try {
      final db = await _db.database;
      final count = await db.update(
        _tableName,
        {
          'notes': record.notes,
          'is_favorite': record.isFavorite ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [record.id],
      );
      _logger.info('更新歷史記錄成功: ${record.id}');
      return count > 0;
    } catch (e, stackTrace) {
      _logger.error('更新歷史記錄失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final db = await _db.database;
      final count = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.info('刪除歷史記錄成功: $id');
      return count > 0;
    } catch (e, stackTrace) {
      _logger.error('刪除歷史記錄失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      final db = await _db.database;
      await db.delete(_tableName);
      _logger.info('清空歷史記錄成功');
    } catch (e, stackTrace) {
      _logger.error('清空歷史記錄失敗', e, stackTrace);
      rethrow;
    }
  }
} 