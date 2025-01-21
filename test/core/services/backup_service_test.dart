import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/backup_service.dart';

@GenerateMocks([])
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;
  
  MockPathProviderPlatform(this.tempDir);
  
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir.path;
  }
}

void main() {
  late BackupService backupService;
  late Directory tempDir;
  late SharedPreferences prefs;

  setUp(() async {
    // 創建臨時目錄
    tempDir = await Directory.systemTemp.createTemp('backup_test_');
    
    // 設置 PathProvider mock
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);
    
    // 初始化 SharedPreferences mock
    SharedPreferences.setMockInitialValues({
      'test_key': 'test_value',
      'test_bool': true,
      'test_int': 42
    });
    prefs = await SharedPreferences.getInstance();
    
    // 初始化 BackupService
    backupService = BackupService();
  });

  tearDown(() async {
    // 清理臨時目錄
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('創建備份應該成功保存數據', () async {
    // 執行備份
    final success = await backupService.createBackup();
    expect(success, true);

    // 驗證備份文件存在
    final backupFile = File('${tempDir.path}/preferences_backup.json');
    expect(await backupFile.exists(), true);

    // 驗證備份內容
    final content = await backupFile.readAsString();
    final Map<String, dynamic> backupData = json.decode(content);
    expect(backupData['test_key'], 'test_value');
    expect(backupData['test_bool'], true);
    expect(backupData['test_int'], 42);
  });

  test('從備份恢復數據應該成功', () async {
    // 先創建備份
    await backupService.createBackup();

    // 清除 SharedPreferences
    await prefs.clear();

    // 從備份恢復
    final success = await backupService.restoreFromBackup();
    expect(success, true);

    // 驗證恢復的數據
    expect(prefs.getString('test_key'), 'test_value');
    expect(prefs.getBool('test_bool'), true);
    expect(prefs.getInt('test_int'), 42);
  });

  test('當備份文件不存在時恢復應該失敗', () async {
    final success = await backupService.restoreFromBackup();
    expect(success, false);
  });

  test('刪除備份應該成功', () async {
    // 先創建備份
    await backupService.createBackup();
    
    // 刪除備份
    final success = await backupService.deleteBackup();
    expect(success, true);
    
    // 驗證備份文件不存在
    final backupFile = File('${tempDir.path}/preferences_backup.json');
    expect(await backupFile.exists(), false);
  });

  test('檢查備份存在性應該正確', () async {
    // 初始狀態應該是不存在
    expect(await backupService.hasBackup(), false);
    
    // 創建備份後應該存在
    await backupService.createBackup();
    expect(await backupService.hasBackup(), true);
    
    // 刪除備份後應該不存在
    await backupService.deleteBackup();
    expect(await backupService.hasBackup(), false);
  });
} 