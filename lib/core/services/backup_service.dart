import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/utils/logger.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

class BackupService {
  static const String _tag = 'BackupService';
  final _logger = Logger(_tag);
  static const String _backupFileName = 'preferences_backup.json';
  
  Future<bool> createBackup() async {
    try {
      _logger.info('開始創建數據備份');
      
      // 獲取 SharedPreferences 實例
      final prefs = await SharedPreferences.getInstance();
      
      // 獲取所有數據
      final Map<String, dynamic> data = {};
      final keys = prefs.getKeys();
      for (final key in keys) {
        data[key] = prefs.get(key);
      }
      
      // 將數據轉換為 JSON
      final jsonData = jsonEncode(data);
      
      // 獲取備份文件路徑
      final backupFile = await _getBackupFile();
      
      // 寫入數據
      await backupFile.writeAsString(jsonData);
      
      _logger.info('數據備份創建成功');
      return true;
    } catch (e, stackTrace) {
      _logger.error('創建數據備份失敗', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> restoreFromBackup() async {
    try {
      _logger.info('開始從備份恢復數據');
      
      // 獲取備份文件
      final backupFile = await _getBackupFile();
      
      // 檢查備份文件是否存在
      if (!await backupFile.exists()) {
        _logger.error('備份文件不存在');
        return false;
      }
      
      // 讀取備份數據
      final jsonData = await backupFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonData);
      
      // 獲取 SharedPreferences 實例
      final prefs = await SharedPreferences.getInstance();
      
      // 清除當前數據
      await prefs.clear();
      
      // 恢復數據
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }
      
      _logger.info('數據恢復成功');
      return true;
    } catch (e, stackTrace) {
      _logger.error('恢復數據失敗', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> deleteBackup() async {
    try {
      _logger.info('開始刪除備份');
      
      final backupFile = await _getBackupFile();
      
      if (await backupFile.exists()) {
        await backupFile.delete();
        _logger.info('備份刪除成功');
        return true;
      } else {
        _logger.warning('備份文件不存在,無需刪除');
        return true;
      }
    } catch (e, stackTrace) {
      _logger.error('刪除備份失敗', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> hasBackup() async {
    try {
      final backupFile = await _getBackupFile();
      return await backupFile.exists();
    } catch (e, stackTrace) {
      _logger.error('檢查備份存在性失敗', e, stackTrace);
      return false;
    }
  }

  Future<File> _getBackupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_backupFileName');
  }
} 