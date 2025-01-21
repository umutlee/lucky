# 運勢預測應用

一款基於 Flutter 開發的運勢預測應用，為用戶提供每日運勢預測和方位指南功能。

## 功能特點

### 1. 運勢預測
- 每日運勢預測
- 運勢歷史記錄

### 2. 通知提醒
- 每日運勢推送
- 自定義通知設置

### 3. 方位指南
- 實時指南針顯示
- 方位說明

## 技術架構

### 前端（Flutter）
- Flutter SDK: 3.27.2
- 狀態管理：flutter_riverpod ^2.5.1
- 路由管理：go_router ^13.2.1
- 本地存儲：
  - shared_preferences ^2.2.2
  - hive ^2.2.3
  - sqflite ^2.3.2
- 通知系統：flutter_local_notifications ^16.3.2
- 方位服務：
  - flutter_compass ^0.8.0
  - geolocator ^11.0.0

## 安裝要求
- Flutter 3.27.2 或更高版本
- Dart 3.3.0 或更高版本
- Android SDK 21 或更高版本
- iOS 11.0 或更高版本

## 開始使用

1. 克隆項目
```bash
git clone https://github.com/yourusername/all-lucky.git
```

2. 安裝依賴
```bash
flutter pub get
```

3. 生成必要的代碼文件
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. 運行應用
```bash
flutter run
```

## 權限說明
- 通知權限：用於發送運勢提醒
- 位置權限：用於方位指南功能

## 開發進度
- [x] 運勢預測系統
- [x] 通知提醒系統
- [x] 方位指南系統
- [x] 路由系統優化
- [x] 代碼質量檢查工具

## 貢獻指南
歡迎提交 Issue 和 Pull Request 來幫助改進項目。

## 授權協議
本項目採用 MIT 授權協議。

# 存儲層優化更新說明

## 更新內容
1. 移除 SharedPreferences，統一使用 SQLite 作為本地存儲
2. 實現多級緩存策略（內存 + 數據庫）
3. 添加緩存監控和管理功能
4. 優化存儲層性能

## 主要改動
- 重構 Repository 類，統一使用 DatabaseService
- 實現 LRU 算法的內存緩存
- 添加緩存統計和監控界面
- 實現自動緩存清理機制
- 完善單元測試

## 使用說明
緩存管理功能可以在設置頁面中找到，提供以下功能：
- 查看緩存使用統計
- 清理過期緩存
- 清理所有緩存
- 實時監控緩存命中率（調試模式） 