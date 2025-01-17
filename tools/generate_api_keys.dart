import 'dart:io';
import '../lib/core/utils/api_key_generator.dart';

void main() {
  const appId = 'com.alllucky.app';
  
  // 生成開發環境 API Key
  final devKey = ApiKeyGenerator.generateKey(
    environment: 'dev',
    appId: appId,
  );
  
  // 生成測試環境 API Key
  final testKey = ApiKeyGenerator.generateKey(
    environment: 'test',
    appId: appId,
  );
  
  // 生成生產環境 API Key
  final prodKey = ApiKeyGenerator.generateKey(
    environment: 'prod',
    appId: appId,
  );

  // 創建或更新 .env 文件
  final envFile = File('.env');
  final envContent = '''
# API Keys
DEV_API_KEY=$devKey
TEST_API_KEY=$testKey
PROD_API_KEY=$prodKey

# App Settings
APP_ID=$appId
VERSION=0.1.0
''';

  envFile.writeAsStringSync(envContent);
  
  print('API Keys 已生成並保存到 .env 文件：');
  print('開發環境：$devKey');
  print('測試環境：$testKey');
  print('生產環境：$prodKey');
} 