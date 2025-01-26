# 開發指南

## 運勢類型系統

### FortuneType 枚舉
運勢類型系統使用 `FortuneType` 枚舉來管理所有可能的運勢類型。主要分為四大類：

1. 日常決策
   - daily: 今日運勢
   - timing: 時機運勢
   - activity: 活動運勢
   - direction: 方位運勢

2. 學習職業
   - study: 學習運勢
   - work: 工作運勢
   - programming: 編程運勢
   - creative: 創作運勢

3. 人際互動
   - social: 人際運勢
   - relationship: 緣分運勢
   - cooperation: 合作運勢

4. 生活休閒
   - health: 健康運勢
   - entertainment: 娛樂運勢
   - shopping: 消費運勢
   - travel: 旅行運勢

### 使用方式
```dart
// 檢查運勢類型
final isDaily = fortuneType.isDaily;
final isCareer = fortuneType.isCareer;
final isSocial = fortuneType.isSocial;
final isLifestyle = fortuneType.isLifestyle;

// 獲取圖標
final iconPath = fortuneType.iconName;

// 獲取分類名稱
final category = fortuneType.categoryName;

// 從字符串創建
final type = FortuneType.fromString('daily');
```

### MVP 版本開發重點
目前 MVP 版本優先實現以下運勢類型：
1. ✅ daily（今日運勢）- 基礎運勢預測
2. ⏳ study（學習運勢）- 學業發展指引
3. ⏳ work（工作運勢）- 職場發展建議
4. ⏳ relationship（緣分運勢）- 感情發展預測

其他運勢類型將在後續版本中逐步添加。

## MVP 版本開發重點

### 當前階段（測試與優化）
1. 完成核心功能測試
   - 運行所有單元測試
   - 執行集成測試
   - 驗證性能指標

2. 優化用戶體驗
   - 確保頁面切換流暢
   - 優化載入提示
   - 完善錯誤提示

3. 確保數據安全
   - 驗證加密功能
   - 測試數據備份
   - 檢查權限管理

### 發布準備
1. 文檔完善
   - 更新使用說明
   - 補充 API 文檔
   - 完善開發指南

2. 打包準備
   - 更新版本號
   - 準備發布說明
   - 檢查應用配置

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

### 測試環境配置
1. 安裝測試工具
```bash
flutter pub global activate coverage
flutter pub global activate test_coverage
```

2. 設置環境變量
```bash
export VM_SERVICE_URL="http://127.0.0.1:8181/"
```

3. 安裝測試依賴
```bash
flutter pub add --dev mockito
flutter pub add --dev build_runner
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

test/
├── unit/          # 單元測試
├── integration/   # 集成測試
└── performance/   # 性能測試
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

### MVP 版本測試重點
1. 核心功能測試
   - 運勢計算準確性
   - 數據存儲可靠性
   - 推送通知可用性

2. 性能測試
   - 啟動時間 < 2秒
   - 頁面切換 < 500ms
   - 內存使用 < 100MB

3. 穩定性測試
   - 長時間運行
   - 異常恢復
   - 弱網絡環境

## 發布流程

### 版本管理
- 遵循語義化版本
- 更新 CHANGELOG.md
- 標記版本號

### MVP 版本發布檢查清單
1. 功能完整性
   - [ ] 所有核心功能可用
   - [ ] 無嚴重錯誤
   - [ ] 基本功能穩定

2. 性能指標
   - [ ] 啟動時間達標
   - [ ] 內存使用合理
   - [ ] 操作流暢度達標

3. 安全性
   - [ ] 數據加密正常
   - [ ] 權限管理完善
   - [ ] 敏感信息保護

4. 文檔完整
   - [ ] 使用說明完整
   - [ ] API 文檔更新
   - [ ] 開發指南完善

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
- 添加 MVP 版本開發重點
- 更新測試環境配置
- 添加發布檢查清單
- 完善測試規範說明 