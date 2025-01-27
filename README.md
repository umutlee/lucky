# All Lucky

一個基於 Dart 的高性能緩存和數據管理系統。

## 功能特點

### 數據庫管理
- SQLite 數據庫操作
- 數據庫加密
- 完整的 CRUD 操作
- 事務支持

### 緩存系統
- 內存緩存
- 持久化緩存
- 緩存過期機制
- 緩存統計

### 安全功能
- 數據庫加密
- 密鑰管理
- 安全審計

### 性能監控
- 操作計時
- 資源使用監控
- 性能報告

## 快速開始

### 安裝
```yaml
dependencies:
  sqlite3: ^2.0.0
  path: ^1.8.0
  logging: ^1.2.0
```

### 基本使用
```dart
// 初始化數據庫
final keyManagementService = KeyManagementServiceFactory.create();
final databaseHelper = DatabaseHelperFactory.create(keyManagementService);
await databaseHelper.init();

// 使用緩存服務
final cacheService = CacheServiceFactory.create(databaseHelper);

// 設置緩存
await cacheService.set('key', 'value');

// 獲取緩存
final value = await cacheService.get<String>('key', (json) => json as String);

// 清理緩存
await cacheService.clear();
```

## 項目結構

```
lib/
  ├── core/           # 核心功能
  │   ├── database/   # 數據庫相關
  │   ├── services/   # 服務實現
  │   └── utils/      # 工具類
  ├── features/       # 功能模塊
  └── shared/         # 共享組件

test/
  ├── core/           # 核心功能測試
  ├── features/       # 功能模塊測試
  └── integration/    # 集成測試
```

## 開發指南

### 環境要求
- Dart SDK: >=3.0.0 <4.0.0
- SQLite: ^3.0.0

### 開發設置
1. 克隆倉庫
```bash
git clone https://github.com/username/all-lucky.git
```

2. 安裝依賴
```bash
dart pub get
```

3. 運行測試
```bash
dart test
```

### 代碼風格
- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 使用 `dartfmt` 格式化代碼
- 添加適當的代碼註釋

## 測試

### 運行測試
```bash
# 運行所有測試
dart test

# 運行特定測試
dart test test/core/services/cache_service_test.dart
```

### 測試覆蓋率
```bash
dart test --coverage=coverage
dart pub global run coverage:format_coverage --packages=.packages --report-on=lib --lcov -o coverage/lcov.info -i coverage
```

## 文檔

- [API 文檔](docs/api/README.md)
- [開發指南](docs/guides/README.md)
- [MVP 計劃](docs/mvp/README.md)
- [進度記錄](docs/PROGRESS.md)

## 貢獻

請查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何貢獻代碼。

## 許可證

本項目採用 MIT 許可證 - 查看 [LICENSE](LICENSE) 文件了解詳情。 