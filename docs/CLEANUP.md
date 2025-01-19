# 專案清理計劃

## 1. 目錄結構精簡

### 移除目錄
- [ ] lib/features/calendar/
- [ ] lib/features/onboarding/

### 保留目錄
- lib/features/fortune/
- lib/features/settings/
- lib/features/home/

## 2. 功能精簡

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

## 3. 代碼優化
- [ ] 移除未使用的依賴
- [ ] 清理未使用的資源文件
- [ ] 優化錯誤處理邏輯
- [ ] 簡化狀態管理

## 4. 測試文件更新
- [ ] 更新測試用例以匹配簡化後的功能
- [ ] 移除不再需要的測試文件

## 5. 文檔更新
- [ ] 更新 README.md
- [ ] 更新 API 文檔
- [ ] 更新使用說明 