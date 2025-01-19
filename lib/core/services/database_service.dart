import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:all_lucky/core/utils/logger.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  static const String _databaseName = 'all_lucky.db';
  static const int _databaseVersion = 1;
  
  Database? _database;
  final _logger = Logger('DatabaseService');

  Future<void> init() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: onDatabaseDowngradeDelete,
      );

      _logger.info('數據庫初始化成功');
    } catch (e, stack) {
      _logger.error('數據庫初始化失敗', e, stack);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.transaction((txn) async {
        // 創建運勢記錄表
        await txn.execute('''
          CREATE TABLE fortune_records (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            type TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // 創建通知記錄表
        await txn.execute('''
          CREATE TABLE notification_records (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            type TEXT NOT NULL,
            created_at TEXT NOT NULL,
            scheduled_at TEXT,
            is_read INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // 創建緩存表
        await txn.execute('''
          CREATE TABLE cache_records (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            created_at TEXT NOT NULL,
            expires_at TEXT
          )
        ''');
      });

      _logger.info('數據庫表創建成功');
    } catch (e, stack) {
      _logger.error('數據庫表創建失敗', e, stack);
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      await db.transaction((txn) async {
        if (oldVersion < 2) {
          // 版本 1 到 2 的遷移
          await txn.execute('''
            ALTER TABLE fortune_records 
            ADD COLUMN extra_data TEXT
          ''');
        }
      });

      _logger.info('數據庫升級成功');
    } catch (e, stack) {
      _logger.error('數據庫升級失敗', e, stack);
      rethrow;
    }
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      final db = _database;
      if (db == null) throw Exception('數據庫未初始化');

      return await db.transaction(action);
    } catch (e, stack) {
      _logger.error('事務執行失敗', e, stack);
      rethrow;
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = _database;
      if (db == null) throw Exception('數據庫未初始化');

      return await db.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      _logger.error('插入數據失敗', e, stack);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = _database;
      if (db == null) throw Exception('數據庫未初始化');

      return await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e, stack) {
      _logger.error('查詢數據失敗', e, stack);
      rethrow;
    }
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = _database;
      if (db == null) throw Exception('數據庫未初始化');

      return await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      _logger.error('更新數據失敗', e, stack);
      rethrow;
    }
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = _database;
      if (db == null) throw Exception('數據庫未初始化');

      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, stack) {
      _logger.error('刪除數據失敗', e, stack);
      rethrow;
    }
  }

  Future<void> clearTable(String table) async {
    try {
      final db = _database;
      if (db == null) throw Exception('數據庫未初始化');

      await db.execute('DELETE FROM $table');
    } catch (e, stack) {
      _logger.error('清空表失敗', e, stack);
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _database?.close();
      _database = null;
    } catch (e, stack) {
      _logger.error('關閉數據庫失敗', e, stack);
      rethrow;
    }
  }
} 