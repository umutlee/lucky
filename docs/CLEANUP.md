# 專案清理計劃

## 1. 存儲層清理（優先級最高）

### 移除服務
- [ ] lib/core/services/storage_service.dart
- [ ] lib/core/providers/storage_provider.dart

### 移除依賴
- [ ] shared_preferences
- [ ] hive
- [ ] hive_flutter

### 整合服務
- [ ] 將 CacheService 功能整合到 DatabaseService
- [ ] 更新所有使用 StorageService 的代碼
- [ ] 更新相關測試文件

## 2. 目錄結構精簡

### 移除目錄
- [ ] lib/features/calendar/
- [ ] lib/features/onboarding/

### 保留目錄
- lib/features/fortune/
- lib/features/settings/
- lib/features/home/

## 3. 功能精簡

### 通知系統
- [ ] 移除 lib/core/services/notification_service.dart 中的節氣提醒相關代碼
- [ ] 移除 lib/core/models/notification_settings.dart 中的節氣設置
- [ ] 簡化 lib/core/providers/notification_settings_provider.dart

### 方位指引
- [ ] 簡化 lib/core/services/compass_service.dart
- [ ] 移除 lib/core/services/fortune_direction_service.dart 中的運勢關聯邏輯
- [ ] 精簡 lib/ui/widgets/compass_widget.dart

### 運勢功能
- [ ] 移除社交分享相關代碼
- [ ] 移除會員系統相關代碼
- [ ] 簡化運勢計算邏輯

## 4. 代碼優化
- [ ] 移除未使用的依賴（特別是存儲相關）
- [ ] 清理未使用的資源文件
- [ ] 優化錯誤處理邏輯
- [ ] 簡化狀態管理
- [ ] 統一存儲層實現

## 5. 測試文件更新
- [ ] 更新測試用例以匹配簡化後的功能
- [ ] 移除不再需要的測試文件

## 6. 文檔更新
- [ ] 更新 README.md
- [ ] 更新 API 文檔
- [ ] 更新使用說明 