import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

class DatabaseHelper {
  static const _databaseName = "all_lucky.db";
  static const _databaseVersion = 1;
  
  final _logger = Logger('DatabaseHelper');
  Database? _database;

  // 獲取數據庫實例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // 初始化數據庫
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);
      
      _logger.info('初始化數據庫: $path');
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, stack) {
      _logger.error('數據庫初始化失敗', e, stack);
      rethrow;
    }
  }

  // 創建數據庫表
  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.info('創建數據庫表');
      
      // 創建 preferences 表
      await db.execute('''
        CREATE TABLE preferences (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 創建 user_settings 表
      await db.execute('''
        CREATE TABLE user_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          zodiac TEXT NOT NULL,
          birth_year INTEGER NOT NULL,
          has_enabled_notifications BOOLEAN DEFAULT TRUE,
          has_location_permission BOOLEAN DEFAULT FALSE,
          has_completed_onboarding BOOLEAN DEFAULT FALSE,
          has_accepted_terms BOOLEAN DEFAULT FALSE,
          has_accepted_privacy BOOLEAN DEFAULT FALSE,
          is_first_launch BOOLEAN DEFAULT TRUE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      _logger.info('數據庫表創建成功');
    } catch (e, stack) {
      _logger.error('創建數據庫表失敗', e, stack);
      rethrow;
    }
  }

  // 數據庫升級
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      _logger.info('數據庫升級: $oldVersion -> $newVersion');
      
      // 在這裡添加數據庫升級邏輯
      if (oldVersion < 2) {
        // 未來版本升級時添加相應的遷移邏輯
      }
    } catch (e, stack) {
      _logger.error('數據庫升級失敗', e, stack);
      rethrow;
    }
  }

  // 基本的 CRUD 操作方法

  // 插入數據
  Future<int> insert(String table, Map<String, dynamic> row) async {
    try {
      final db = await database;
      return await db.insert(table, row);
    } catch (e, stack) {
      _logger.error('插入數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 查詢數據
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e, stack) {
      _logger.error('查詢數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 更新數據
  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.update(
        table,
        row,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, stack) {
      _logger.error('更新數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 刪除數據
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, stack) {
      _logger.error('刪除數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 執行原始 SQL 查詢
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e, stack) {
      _logger.error('執行原始 SQL 查詢失敗', e, stack);
      rethrow;
    }
  }

  // 關閉數據庫連接
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _logger.info('數據庫連接已關閉');
      }
    } catch (e, stack) {
      _logger.error('關閉數據庫連接失敗', e, stack);
      rethrow;
    }
  }
} 