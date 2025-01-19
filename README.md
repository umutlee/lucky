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
- 狀態管理：Riverpod
- 本地存儲：SharedPreferences
- 通知系統：flutter_local_notifications
- 方位服務：flutter_compass, geolocator

## 安裝要求
- Flutter 3.0.0 或更高版本
- Dart 3.0.0 或更高版本
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

3. 運行應用
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

## 貢獻指南
歡迎提交 Issue 和 Pull Request 來幫助改進項目。

## 授權協議
本項目採用 MIT 授權協議。 