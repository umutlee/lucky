# All Lucky - 運勢預測應用

一款基於 Flutter 開發的運勢預測應用，提供每日運勢查詢、方位指南和通知提醒功能。

## 當前版本狀態

- 版本：MVP 1.0.0（開發中）
- 進度：85%
- 預計發布：2024-04

### 完成功能
- ✅ 運勢查詢核心功能
- ✅ 用戶身份設置
- ✅ 基礎日曆功能
- ✅ 通知系統
- ✅ 錯誤處理機制
- ✅ 載入提示系統
- ✅ 頁面切換優化

### 進行中功能
- ⏳ 數據安全保障（待測試）
- ⏳ 推送通知功能（待測試）
- ⏳ 性能優化和測試

## 功能特點

### 1. 運勢預測
- 支持多種運勢類型（總體運勢、愛情運勢、事業運勢、財運）
- 提供每日運勢評分和詳細解讀
- 支持日期選擇和歷史記錄查詢

### 2. 方位指南
- 實時顯示當前方位
- 提供吉利方位提示
- 支持方位解讀和建議

### 3. 推送通知
- 支持每日運勢提醒
- 可自定義通知時間
- 支持即時通知和定時通知
- 提供通知管理功能

## 技術特點

- 使用 Flutter 3.x 最新版本開發
- 採用 Clean Architecture 架構
- 使用 Riverpod 進行狀態管理
- 實現響應式設計，支持多種設備尺寸
- 使用 SQLite 進行本地數據存儲
- 集成推送通知功能
- 實現完整的錯誤處理和日誌記錄

## 開發環境要求

### 必要條件
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- iOS 13.0+ / Android 5.0+
- Git
- SQLite

### 測試環境配置
1. 安裝必要工具
```bash
flutter pub global activate coverage
flutter pub global activate test_coverage
```

2. 配置環境變量
```bash
export VM_SERVICE_URL="http://127.0.0.1:8181/"
```

3. 安裝測試依賴
```bash
flutter pub add --dev mockito
flutter pub add --dev build_runner
```

## 安裝說明

1. 克隆項目
```bash
git clone https://github.com/umutlee/lucky.git
```

2. 安裝依賴
```bash
flutter pub get
```

3. 生成必要文件
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. 運行測試
```bash
flutter test
```

5. 運行應用
```bash
flutter run
```

## 項目結構

```
lib/
  ├── core/                 # 核心功能
  │   ├── services/        # 服務層
  │   ├── utils/           # 工具類
  │   └── widgets/         # 共用組件
  ├── features/            # 功能模塊
  │   ├── fortune/         # 運勢預測
  │   ├── compass/         # 方位指南
  │   └── notification/    # 推送通知
  └── main.dart            # 入口文件

test/
  ├── unit/               # 單元測試
  ├── integration/        # 集成測試
  └── performance/        # 性能測試
```

## 使用說明

### 運勢預測
1. 在首頁選擇想要查詢的運勢類型
2. 選擇日期（默認為當天）
3. 查看運勢評分和詳細解讀

### 方位指南
1. 進入方位指南頁面
2. 保持手機水平以獲取準確的方位數據
3. 查看當前方位和吉利方位提示

### 推送通知
1. 首次使用時會請求通知權限
2. 在設置中可以自定義通知時間
3. 可以開啟/關閉每日運勢提醒
4. 支持手動清除所有通知

## 開發指引

### 文檔閱讀順序
在開始任何開發工作前，請按照以下順序閱讀相關文檔：

1. **核心原則** (`/docs/CORE_PRINCIPLES.md`)
2. **架構文檔** (`/docs/ARCHITECTURE.md`)
3. **API 文檔** (`/docs/api/API.md`)
4. **開發指南** (`/docs/DEVELOPMENT_GUIDE.md`)
5. **測試文檔** (`/docs/TESTING.md`)
6. **進度記錄** (`/docs/PROGRESS.md`)

### MVP 版本發布檢查清單
- [ ] 完成所有核心功能測試
- [ ] 驗證性能指標達標
- [ ] 確認安全性要求
- [ ] 完成文檔更新
- [ ] 準備發布材料

## 注意事項

- 方位指南功能需要設備支持磁力計
- 推送通知需要系統授權
- 建議保持網絡連接以獲取最新數據

## 貢獻指南

歡迎提交 Issue 和 Pull Request 來改進項目。

## 許可證

本項目基於 MIT 許可證開源。

## 更新記錄

### 2024-03-21
- 更新 MVP 版本進度
- 添加測試環境配置說明
- 完善安裝步驟
- 添加發布檢查清單

## 技術架構

### 本地儲存
- 採用 SQLite 作為唯一的本地儲存方案
- 嚴格禁止使用其他儲存方式（如 SharedPreferences）
- 詳細規範請參考 `/docs/STORAGE_POLICY.md`

### 主要功能
// ... existing code ... 