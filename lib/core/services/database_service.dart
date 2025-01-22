import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/logger.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

class DatabaseService {
  Database? _database;
  final _logger = Logger('DatabaseService');

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'all_lucky.db');
      
      _logger.info('初始化數據庫: $path');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          _logger.info('創建數據庫表');
          // 表的創建將由各個服務自己處理
        },
      );
    } catch (e, stackTrace) {
      _logger.error('初始化數據庫失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _logger.info('數據庫已關閉');
      }
    } catch (e, stackTrace) {
      _logger.error('關閉數據庫失敗', e, stackTrace);
      rethrow;
    }
  }
} 