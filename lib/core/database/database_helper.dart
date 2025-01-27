import 'dart:io';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';
import '../services/key_management_service.dart';
import '../utils/logger.dart';

/// 數據庫幫助類工廠
class DatabaseHelperFactory {
  static DatabaseHelper create(KeyManagementService keyManagementService) {
    return DatabaseHelperImpl(keyManagementService);
  }
}

/// 數據庫幫助類基類
abstract class DatabaseHelper {
  /// 獲取數據庫實例
  Database get database;

  /// 初始化數據庫
  Future<bool> init();

  /// 重新加密數據庫
  Future<bool> reencrypt();

  /// 插入數據
  Future<int> insert(String table, Map<String, dynamic> values, {String? conflictResolution});

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
  final KeyManagementService _keyManagementService;
  final _logger = Logger();
  Database? _database;

  DatabaseHelperImpl(this._keyManagementService);

  @override
  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized');
    }
    return _database!;
  }

  @override
  Future<bool> init() async {
    try {
      final dbPath = await _getDatabasesPath();
      final key = await _keyManagementService.getDatabaseKey();
      
      _database = sqlite3.open(dbPath);
      
      // 設置加密密鑰
      await execute('PRAGMA key = ?', [key]);
      
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize database', e, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> reencrypt() async {
    try {
      final newKey = await _keyManagementService.generateDatabaseKey();
      await execute('PRAGMA rekey = ?', [newKey]);
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to reencrypt database', e, stackTrace);
      return false;
    }
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? conflictResolution}) async {
    try {
      final sql = _buildInsertStatement(table, values, conflictResolution);
      final stmt = database.prepare(sql);
      stmt.execute(values.values.toList());
      final id = database.lastInsertRowId;
      stmt.dispose();
      return id;
    } catch (e, stackTrace) {
      _logger.error('Failed to insert data', e, stackTrace);
      return -1;
    }
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) async {
    try {
      final sql = _buildUpdateStatement(table, values, where);
      final stmt = database.prepare(sql);
      final args = [...values.values, ...?whereArgs];
      stmt.execute(args);
      final count = database.lastInsertRowId;
      stmt.dispose();
      return count;
    } catch (e, stackTrace) {
      _logger.error('Failed to update data', e, stackTrace);
      return 0;
    }
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    try {
      final sql = _buildDeleteStatement(table, where);
      final stmt = database.prepare(sql);
      stmt.execute(whereArgs ?? []);
      final count = database.lastInsertRowId;
      stmt.dispose();
      return count;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete data', e, stackTrace);
      return 0;
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
      final sql = _buildQueryStatement(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      
      final stmt = database.prepare(sql);
      final results = stmt.select(whereArgs ?? []);
      final List<Map<String, dynamic>> items = [];
      
      // 先獲取列名
      final columnNames = _getTableColumns(table);
      
      for (final row in results) {
        final Map<String, dynamic> item = {};
        for (var i = 0; i < row.length; i++) {
          item[columnNames[i]] = row[i];
        }
        items.add(item);
      }
      
      stmt.dispose();
      return items;
    } catch (e, stackTrace) {
      _logger.error('Failed to query data', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    try {
      final stmt = database.prepare(sql);
      stmt.execute(arguments ?? []);
      stmt.dispose();
    } catch (e, stackTrace) {
      _logger.error('Failed to execute SQL', e, stackTrace);
      rethrow;
    }
  }

  Future<String> _getDatabasesPath() async {
    final dbDir = Directory(join(Directory.current.path, 'data'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    return join(dbDir.path, 'app.db');
  }

  String _buildInsertStatement(String table, Map<String, dynamic> values, String? conflictResolution) {
    final columns = values.keys.join(', ');
    final placeholders = List.filled(values.length, '?').join(', ');
    final conflict = conflictResolution != null ? ' OR $conflictResolution' : '';
    return 'INSERT$conflict INTO $table ($columns) VALUES ($placeholders)';
  }

  String _buildUpdateStatement(String table, Map<String, dynamic> values, String? where) {
    final set = values.keys.map((key) => '$key = ?').join(', ');
    final whereClause = where != null ? ' WHERE $where' : '';
    return 'UPDATE $table SET $set$whereClause';
  }

  String _buildDeleteStatement(String table, String? where) {
    final whereClause = where != null ? ' WHERE $where' : '';
    return 'DELETE FROM $table$whereClause';
  }

  String _buildQueryStatement(String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    final distinctClause = distinct == true ? 'DISTINCT ' : '';
    final columnsClause = columns?.join(', ') ?? '*';
    final whereClause = where != null ? ' WHERE $where' : '';
    final groupByClause = groupBy != null ? ' GROUP BY $groupBy' : '';
    final havingClause = having != null ? ' HAVING $having' : '';
    final orderByClause = orderBy != null ? ' ORDER BY $orderBy' : '';
    final limitClause = limit != null ? ' LIMIT $limit' : '';
    final offsetClause = offset != null ? ' OFFSET $offset' : '';
    
    return 'SELECT $distinctClause$columnsClause FROM $table$whereClause$groupByClause$havingClause$orderByClause$limitClause$offsetClause';
  }

  List<String> _getTableColumns(String table) {
    final stmt = database.prepare('PRAGMA table_info($table)');
    final results = stmt.select([]);
    final columnNames = results.map((row) => row[1] as String).toList();
    stmt.dispose();
    return columnNames;
  }
} 