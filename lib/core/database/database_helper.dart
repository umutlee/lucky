import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

class DatabaseHelper {
  static const String _tag = 'DatabaseHelper';
  final _logger = Logger(_tag);
  static Database? _database;

  // 獲取數據庫實例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // 初始化數據庫
  Future<bool> init() async {
    try {
      await database;
      return true;
    } catch (e, stack) {
      _logger.error('數據庫初始化失敗', e, stack);
      return false;
    }
  }

  // 初始化數據庫
  Future<Database> _initDatabase() async {
    final path = await _getDatabasePath();
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<String> _getDatabasePath() async {
    return join(await getDatabasesPath(), 'all_lucky.db');
  }

  // 創建數據庫表
  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.info('創建數據庫表');
      
      // 創建偏好設置表
      await db.execute('''
        CREATE TABLE preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL UNIQUE,
          value TEXT,
          type TEXT
        )
      ''');

      // 創建用戶設置表
      await db.execute('''
        CREATE TABLE user_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          zodiac INTEGER,
          birth_year INTEGER,
          notifications_enabled INTEGER DEFAULT 0,
          location_permission_granted INTEGER DEFAULT 0,
          onboarding_completed INTEGER DEFAULT 0,
          terms_accepted INTEGER DEFAULT 0,
          privacy_accepted INTEGER DEFAULT 0
        )
      ''');

      _logger.info('數據庫表創建完成');
    } catch (e, stack) {
      _logger.error('創建數據庫表失敗', e, stack);
      rethrow;
    }
  }

  // 數據庫升級
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      _logger.info('升級數據庫從 v$oldVersion 到 v$newVersion');
      
      // 在這裡添加數據庫升級邏輯
      
      _logger.info('數據庫升級完成');
    } catch (e, stack) {
      _logger.error('升級數據庫失敗', e, stack);
      rethrow;
    }
  }

  // 基本的 CRUD 操作方法

  // 插入數據
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      _logger.error('插入數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 查詢數據
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct = false,
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
    } catch (e, stack) {
      _logger.error('查詢數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 更新數據
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      _logger.error('更新數據失敗: $table', e, stack);
      rethrow;
    }
  }

  // 刪除數據
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
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
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
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
      _logger.error('關閉數據庫失敗', e, stack);
      rethrow;
    }
  }
} 