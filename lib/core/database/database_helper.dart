import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/key_management_service.dart';
import '../utils/logger.dart';

/// 數據庫幫助類提供者
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  final keyManagementService = ref.watch(keyManagementServiceProvider);
  return DatabaseHelperImpl(keyManagementService);
});

/// 數據庫幫助類基類
abstract class DatabaseHelper {
  /// 獲取數據庫實例
  Future<Database> get database;

  /// 初始化數據庫
  Future<bool> init();

  /// 重新加密數據庫
  Future<bool> reencrypt();

  /// 插入數據
  Future<int> insert(String table, Map<String, dynamic> values, {ConflictAlgorithm? conflictAlgorithm});

  /// 更新數據
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs});

  /// 刪除數據
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  /// 查詢數據
  Future<List<Map<String, dynamic>>> query(String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// 執行 SQL 語句
  Future<void> execute(String sql, [List<Object?>? arguments]);
}

/// 數據庫幫助類實現
class DatabaseHelperImpl implements DatabaseHelper {
  static const String _tag = 'DatabaseHelper';
  final _logger = Logger(_tag);
  final KeyManagementService _keyManagementService;
  Database? _database;

  DatabaseHelperImpl(this._keyManagementService);

  @override
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  @override
  Future<bool> init() async {
    try {
      await database;
      return true;
    } catch (e, stackTrace) {
      _logger.error('初始化數據庫失敗', e, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> reencrypt() async {
    try {
      // 關閉現有數據庫連接
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // 生成新密鑰
      final newKey = await _keyManagementService.generateNewKey();
      
      // 重新打開數據庫
      _database = await _initDatabase();
      
      return true;
    } catch (e, stackTrace) {
      _logger.error('重新加密數據庫失敗', e, stackTrace);
      return false;
    }
  }

  /// 初始化數據庫
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'all_lucky.db');
      
      _logger.info('初始化數據庫: $path');
      
      // 獲取加密密鑰
      final key = await _keyManagementService.getDatabaseKey();
      
      return await openDatabase(
        path,
        version: 1,
        password: key, // 使用加密密鑰
        onCreate: (db, version) async {
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
        },
      );
    } catch (e, stackTrace) {
      _logger.error('初始化數據庫失敗', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {ConflictAlgorithm? conflictAlgorithm}) async {
    try {
      final db = await database;
      values['updated_at'] = DateTime.now().toIso8601String();
      return await db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
    } catch (e, stackTrace) {
      _logger.error('插入數據失敗', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) async {
    try {
      final db = await database;
      values['updated_at'] = DateTime.now().toIso8601String();
      return await db.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      _logger.error('更新數據失敗', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, stackTrace) {
      _logger.error('刪除數據失敗', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {
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
      _logger.error('查詢數據失敗', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    try {
      final db = await database;
      await db.execute(sql, arguments);
    } catch (e, stackTrace) {
      _logger.error('執行 SQL 失敗', e, stackTrace);
      rethrow;
    }
  }
} 