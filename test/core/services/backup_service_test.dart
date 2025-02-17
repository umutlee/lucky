// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:all_lucky/core/services/backup_service.dart';
import 'package:all_lucky/core/database/database_helper.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'backup_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path provider
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return './test/temp';
      }
      return null;
    },
  );

  group('備份服務測試', () {
    late BackupService backupService;
    late MockDatabaseHelper mockDatabaseHelper;
    late String testBackupPath;

    setUp(() async {
      mockDatabaseHelper = MockDatabaseHelper();
      backupService = BackupServiceImpl(mockDatabaseHelper);
      
      // 創建臨時測試目錄
      final testDir = Directory('./test/temp');
      if (!await testDir.exists()) {
        await testDir.create(recursive: true);
      }
      
      // 創建測試備份文件
      testBackupPath = '${testDir.path}/test_backup.db';
      final testFile = File(testBackupPath);
      if (!await testFile.exists()) {
        await testFile.create();
      }
    });

    tearDown(() async {
      // 清理測試目錄
      final testDir = Directory('./test/temp');
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    test('創建備份', () async {
      when(mockDatabaseHelper.database).thenReturn(sqlite3.openInMemory());

      final backupPath = await backupService.createBackup();
      
      expect(backupPath, isNotEmpty);
      verify(mockDatabaseHelper.database).called(1);
    });

    test('從備份恢復', () async {
      when(mockDatabaseHelper.database).thenReturn(sqlite3.openInMemory());

      final result = await backupService.restoreFromBackup(testBackupPath);
      
      expect(result, isTrue);
      verify(mockDatabaseHelper.database).called(1);
    });

    test('獲取備份列表', () async {
      final backupList = await backupService.getBackups();
      
      expect(backupList, isA<List<String>>());
    });

    test('刪除備份', () async {
      final result = await backupService.deleteBackup(testBackupPath);
      
      expect(result, isTrue);
    });

    test('自動備份 - 首次備份', () async {
      when(mockDatabaseHelper.database).thenReturn(sqlite3.openInMemory());
      when(mockDatabaseHelper.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['last_backup_time'],
      )).thenAnswer((_) async => []);
      when(mockDatabaseHelper.insert(
        'preferences',
        any,
        conflictResolution: 'REPLACE',
      )).thenAnswer((_) async => 1);

      final result = await backupService.autoBackup();
      
      expect(result, isTrue);
      verify(mockDatabaseHelper.database).called(1);
    });

    test('自動備份 - 最近已備份', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['last_backup_time'],
      )).thenAnswer((_) async => [{
        'value': DateTime.now().toIso8601String(),
      }]);

      final result = await backupService.autoBackup();
      
      expect(result, isTrue);
      verifyNever(mockDatabaseHelper.database);
    });
  });
} 