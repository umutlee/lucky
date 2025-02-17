import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/backup_service.dart';
import 'package:all_lucky/core/services/storage_service.dart';
import 'package:all_lucky/core/utils/logger.dart';

@GenerateMocks([StorageService, Logger])
void main() {
  group('備份服務測試', () {
    late BackupService backupService;
    late MockStorageService mockStorageService;
    late MockLogger mockLogger;

    setUp(() {
      mockStorageService = MockStorageService();
      mockLogger = MockLogger();
      backupService = BackupService(mockStorageService, mockLogger);
    });

    test('創建備份', () async {
      when(mockStorageService.getAllKeys())
          .thenAnswer((_) async => ['key1', 'key2']);
      
      when(mockStorageService.getString(any))
          .thenAnswer((_) async => 'value');

      final success = await backupService.createBackup();
      expect(success, isTrue);
      
      verify(mockLogger.info('開始創建備份')).called(1);
      verify(mockStorageService.getAllKeys()).called(1);
      verify(mockStorageService.getString(any)).called(2);
    });

    test('從備份恢復', () async {
      final backupData = {
        'key1': 'value1',
        'key2': 'value2',
      };

      when(mockStorageService.setString(any, any))
          .thenAnswer((_) async => true);

      final success = await backupService.restoreFromBackup(backupData);
      expect(success, isTrue);
      
      verify(mockLogger.info('開始從備份恢復')).called(1);
      verify(mockStorageService.setString(any, any)).called(2);
    });

    test('刪除備份', () async {
      when(mockStorageService.remove(any))
          .thenAnswer((_) async => true);

      final success = await backupService.deleteBackup('backup_20240215');
      expect(success, isTrue);
      
      verify(mockLogger.info('刪除備份: backup_20240215')).called(1);
      verify(mockStorageService.remove(any)).called(1);
    });

    test('檢查備份是否存在', () async {
      when(mockStorageService.containsKey(any))
          .thenAnswer((_) async => true);

      final exists = await backupService.checkBackupExists('backup_20240215');
      expect(exists, isTrue);
      
      verify(mockStorageService.containsKey(any)).called(1);
    });

    test('獲取所有備份', () async {
      when(mockStorageService.getAllKeys())
          .thenAnswer((_) async => [
            'backup_20240215',
            'backup_20240214',
            'other_key',
          ]);

      final backups = await backupService.getAllBackups();
      expect(backups, hasLength(2));
      expect(backups, contains('backup_20240215'));
      expect(backups, contains('backup_20240214'));
      expect(backups, isNot(contains('other_key')));
    });

    test('處理備份錯誤', () async {
      when(mockStorageService.getAllKeys())
          .thenThrow(Exception('測試錯誤'));

      final success = await backupService.createBackup();
      expect(success, isFalse);
      
      verify(mockLogger.error(any, any)).called(1);
    });
  });
} 