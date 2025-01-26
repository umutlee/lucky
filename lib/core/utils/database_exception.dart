/// 數據庫錯誤類型
class DatabaseException implements Exception {
  /// 錯誤類型
  final String type;

  /// 錯誤信息
  final String message;

  /// 原始錯誤
  final dynamic originalError;

  /// 堆棧跟蹤
  final StackTrace? stackTrace;

  /// 表名
  final String? table;

  /// 列名
  final String? column;

  DatabaseException(
    this.type,
    this.message, {
    this.originalError,
    this.stackTrace,
    this.table,
    this.column,
  });

  /// 創建唯一約束錯誤
  factory DatabaseException.unique(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    String? table,
    String? column,
  }) {
    return DatabaseException(
      'UNIQUE',
      message,
      originalError: originalError,
      stackTrace: stackTrace,
      table: table,
      column: column,
    );
  }

  /// 創建非空約束錯誤
  factory DatabaseException.notNull(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    String? table,
    String? column,
  }) {
    return DatabaseException(
      'NOT_NULL',
      message,
      originalError: originalError,
      stackTrace: stackTrace,
      table: table,
      column: column,
    );
  }

  /// 創建外鍵約束錯誤
  factory DatabaseException.foreignKey(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    String? table,
    String? column,
  }) {
    return DatabaseException(
      'FOREIGN_KEY',
      message,
      originalError: originalError,
      stackTrace: stackTrace,
      table: table,
      column: column,
    );
  }

  /// 創建表不存在錯誤
  factory DatabaseException.tableNotFound(
    String table, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DatabaseException(
      'TABLE_NOT_FOUND',
      '表 $table 不存在',
      originalError: originalError,
      stackTrace: stackTrace,
      table: table,
    );
  }

  /// 創建列不存在錯誤
  factory DatabaseException.columnNotFound(
    String column,
    String table, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return DatabaseException(
      'COLUMN_NOT_FOUND',
      '表 $table 中不存在列 $column',
      originalError: originalError,
      stackTrace: stackTrace,
      table: table,
      column: column,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (table != null) {
      buffer.write(' (表: $table');
      if (column != null) {
        buffer.write(', 列: $column');
      }
      buffer.write(')');
    }
    return buffer.toString();
  }
} 