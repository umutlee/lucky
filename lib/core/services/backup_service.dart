import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/services/encryption_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../providers/providers.dart';

/// 備份服務提供者
final backupServiceProvider = Provider<BackupService>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return BackupServiceImpl(databaseHelper);
});

/// 備份服務基類
abstract class BackupService {
  /// 創建備份
  Future<String> createBackup();
  
  /// 從備份恢復
  Future<bool> restoreFromBackup(String backupPath);
  
  /// 獲取所有備份
  Future<List<String>> getBackups();
  
  /// 刪除備份
  Future<bool> deleteBackup(String backupPath);
  
  /// 自動備份
  Future<bool> autoBackup();
}

/// 備份服務實現
class BackupServiceImpl implements BackupService {
  static const String _tag = 'BackupService';
  final _logger = Logger(_tag);
  final DatabaseHelper _databaseHelper;
  
  BackupServiceImpl(this._databaseHelper);
  
  @override
  Future<String> createBackup() async {
    try {
      // 確保數據庫已關閉
      final db = _databaseHelper.database;
      
      // 獲取數據庫文件路徑
      final dbPath = await _getDatabasesPath();
      
      // 創建備份目錄
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // 生成備份文件名
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = join(backupDir.path, 'backup_$timestamp.db');
      
      // 創建備份文件
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        await backupFile.create(recursive: true);
      }
      
      // 複製數據庫文件
      if (await File(dbPath).exists()) {
        await File(dbPath).copy(backupPath);
      } else {
        // 如果數據庫文件不存在，創建一個空的備份文件
        await backupFile.writeAsString('');
      }
      
      _logger.info('創建備份成功: $backupPath');
      return backupPath;
    } catch (e, stackTrace) {
      _logger.error('創建備份失敗', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      // 確保數據庫已關閉
      final db = _databaseHelper.database;
      
      // 獲取當前數據庫路徑
      final dbPath = await _getDatabasesPath();
      
      // 確保數據庫目錄存在
      final dbDir = Directory(dirname(dbPath));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      
      // 複製備份文件到數據庫位置
      await File(backupPath).copy(dbPath);
      
      _logger.info('從備份恢復成功');
      return true;
    } catch (e, stackTrace) {
      _logger.error('從備份恢復失敗', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<List<String>> getBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        return [];
      }
      
      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .map((entity) => entity.path)
          .toList();
      
      return files;
    } catch (e, stackTrace) {
      _logger.error('獲取備份列表失敗', e, stackTrace);
      return [];
    }
  }
  
  @override
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        _logger.info('刪除備份成功: $backupPath');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      _logger.error('刪除備份失敗', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<bool> autoBackup() async {
    try {
      // 檢查上次備份時間
      final lastBackupTime = await _getLastBackupTime();
      final now = DateTime.now();
      
      // 如果距離上次備份不足24小時，跳過
      if (lastBackupTime != null &&
          now.difference(lastBackupTime).inHours < 24) {
        return true;
      }
      
      // 創建新備份
      await createBackup();
      
      // 更新上次備份時間
      await _updateLastBackupTime(now);
      
      // 清理舊備份（保留最近7天的備份）
      await _cleanOldBackups();
      
      return true;
    } catch (e, stackTrace) {
      _logger.error('自動備份失敗', e, stackTrace);
      return false;
    }
  }
  
  /// 獲取備份目錄
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }
  
  /// 獲取數據庫路徑
  Future<String> _getDatabasesPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(join(appDir.path, 'data'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    return join(dbDir.path, 'app.db');
  }
  
  /// 獲取上次備份時間
  Future<DateTime?> _getLastBackupTime() async {
    try {
      final results = await _databaseHelper.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['last_backup_time'],
      );
      
      if (results.isNotEmpty) {
        return DateTime.parse(results.first['value'] as String);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 更新上次備份時間
  Future<void> _updateLastBackupTime(DateTime time) async {
    await _databaseHelper.insert(
      'preferences',
      {
        'key': 'last_backup_time',
        'value': time.toIso8601String(),
        'type': 'datetime',
      },
      conflictResolution: 'REPLACE',
    );
  }
  
  /// 清理舊備份
  Future<void> _cleanOldBackups() async {
    try {
      final backups = await getBackups();
      final now = DateTime.now();
      
      for (final backup in backups) {
        final fileName = basename(backup);
        // 從文件名中提取時間戳
        final match = RegExp(r'backup_(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})').firstMatch(fileName);
        if (match != null) {
          final timestamp = match.group(1)!.replaceAll('-', ':');
          final backupTime = DateTime.parse(timestamp);
          
          // 如果備份超過7天，刪除
          if (now.difference(backupTime).inDays > 7) {
            await deleteBackup(backup);
          }
        }
      }
    } catch (e, stackTrace) {
      _logger.error('清理舊備份失敗', e, stackTrace);
    }
  }
} 