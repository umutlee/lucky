# 開發指南

## 環境設置

### 必要條件
- Flutter SDK (最新穩定版)
- Dart SDK (最新穩定版)
- Android Studio / VS Code
- Git
- SQLite

### 開發環境配置
1. 克隆項目
```bash
git clone https://github.com/your-org/all-lucky.git
cd all-lucky
```

2. 安裝依賴
```bash
flutter pub get
```

3. 運行代碼生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 開發規範

### 代碼風格
- 使用 `flutter_lints` 進行代碼規範檢查
- 遵循 Effective Dart 指南
- 使用中文註釋，清晰描述功能邏輯

### 文件結構
```
lib/
├── core/          # 核心功能
├── features/      # 功能模塊
└── shared/        # 共享組件
```

### 命名規範
- 文件名：小寫下劃線
- 類名：大駝峰命名
- 變量和方法：小駝峰命名
- 常量：大寫下劃線

## 開發流程

### 功能開發
1. 創建功能分支
```bash
git checkout -b feature/功能名稱
```

2. 實現功能
- 遵循 TDD 開發模式
- 編寫單元測試
- 實現功能代碼
- 進行代碼審查

3. 提交代碼
```bash
git add .
git commit -m "feat: 功能描述"
git push origin feature/功能名稱
```

### 測試規範
1. 單元測試
- 使用 `flutter_test` 包
- 測試覆蓋率要求 > 80%
- 測試命名規範：`test_功能名稱`

2. 集成測試
- 使用 `integration_test` 包
- 測試主要用戶流程
- 包含性能測試

## 發布流程

### 版本管理
- 遵循語義化版本
- 更新 CHANGELOG.md
- 標記版本號

### 打包發布
1. 更新版本號
```yaml
version: 1.0.0+1
```

2. 生成發布包
```bash
flutter build apk --release
flutter build ios --release
```

## 調試技巧

### 日誌記錄
```dart
import 'package:logger/logger.dart';

final logger = Logger();
logger.d('調試信息');
logger.i('信息');
logger.w('警告');
logger.e('錯誤');
```

### 性能優化
- 使用 Flutter DevTools
- 監控內存使用
- 檢查重建次數
- 優化圖片資源

## 常見問題

### 構建問題
1. 清理構建緩存
```bash
flutter clean
flutter pub get
```

2. 更新依賴
```bash
flutter pub upgrade
```

### 運行問題
1. 模擬器問題
```bash
flutter emulators
flutter emulators --launch <emulator_id>
```

2. 設備連接
```bash
flutter devices
flutter run -d <device_id>
```

## 更新記錄

### 2024-03-21
- 更新環境設置說明
- 完善開發流程文檔
- 添加調試技巧
- 補充常見問題解決方案 