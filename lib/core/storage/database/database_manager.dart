import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/utils/error_handler.dart';

/// 數據庫管理器提供者
final databaseManagerProvider = Provider<DatabaseManager>((ref) {
  return DatabaseManager();
});

/// 數據庫管理器
/// 統一管理所有數據庫操作，提供事務支持和錯誤處理
class DatabaseManager {
  static const String _tag = 'DatabaseManager';
  final _logger = Logger(_tag);
  Database? _database;

  /// 獲取數據庫實例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化數據庫
  Future<bool> init() async {
    try {
      await database;
      return true;
    } catch (e, stackTrace) {
      _logger.error('初始化數據庫失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '初始化數據庫失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 初始化數據庫
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'all_lucky.db');
      
      _logger.info('初始化數據庫: $path');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stackTrace) {
      _logger.error('初始化數據庫失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '初始化數據庫失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 創建數據庫表
  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.info('創建數據庫表');
      
      // 創建偏好設置表
      await db.execute('''
        CREATE TABLE preferences (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          type TEXT NOT NULL,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 創建用戶設置表
      await db.execute('''
        CREATE TABLE user_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          zodiac TEXT,
          birth_year INTEGER,
          notifications_enabled INTEGER NOT NULL DEFAULT 1,
          location_permission_granted INTEGER NOT NULL DEFAULT 0,
          onboarding_completed INTEGER NOT NULL DEFAULT 0,
          terms_accepted INTEGER NOT NULL DEFAULT 0,
          privacy_accepted INTEGER NOT NULL DEFAULT 0,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 創建運勢歷史記錄表
      await db.execute('''
        CREATE TABLE fortune_history (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          date TEXT NOT NULL,
          score INTEGER NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 創建緩存表
      await db.execute('''
        CREATE TABLE cache (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    } catch (e, stackTrace) {
      _logger.error('創建數據庫表失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '創建數據庫表失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 升級數據庫
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      _logger.info('升級數據庫: $oldVersion -> $newVersion');
      // TODO: 實現數據庫升級邏輯
    } catch (e, stackTrace) {
      _logger.error('升級數據庫失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '升級數據庫失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 在事務中執行操作
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      final db = await database;
      return await db.transaction(action);
    } catch (e, stackTrace) {
      _logger.error('事務執行失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '事務執行失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 插入數據
  Future<int> insert(String table, Map<String, dynamic> values) async {
    try {
      final db = await database;
      values['updated_at'] = DateTime.now().toIso8601String();
      return await db.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      _logger.error('插入數據失敗: $table', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '插入數據失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 批量插入數據
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> valuesList,
  ) async {
    try {
      await transaction((txn) async {
        final batch = txn.batch();
        for (final values in valuesList) {
          values['updated_at'] = DateTime.now().toIso8601String();
          batch.insert(
            table,
            values,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });
    } catch (e, stackTrace) {
      _logger.error('批量插入數據失敗: $table', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '批量插入數據失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 查詢數據
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
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
    } catch (e, stackTrace) {
      _logger.error('查詢數據失敗: $table', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '查詢數據失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 更新數據
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final db = await database;
      values['updated_at'] = DateTime.now().toIso8601String();
      return await db.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, stackTrace) {
      _logger.error('更新數據失敗: $table', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '更新數據失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 刪除數據
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, stackTrace) {
      _logger.error('刪除數據失敗: $table', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '刪除數據失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 清空表
  Future<void> clearTable(String table) async {
    try {
      await delete(table);
      _logger.info('清空表成功: $table');
    } catch (e, stackTrace) {
      _logger.error('清空表失敗: $table', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '清空表失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 關閉數據庫
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _logger.info('數據庫已關閉');
      }
    } catch (e, stackTrace) {
      _logger.error('關閉數據庫失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '關閉數據庫失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 