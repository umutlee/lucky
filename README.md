# 運勢預測應用

一款基於 Flutter 開發的運勢預測應用，提供每日運勢、節氣提醒和吉日查詢等功能。

## 功能特點

### 核心功能
- 🎯 每日運勢預測
- 📅 黃曆查詢（節氣、吉日）
- 🔍 智能篩選系統
- 📱 本地通知提醒

### 技術特點
- ⚡ 高性能：優化的啟動時間和內存使用
- 💾 智能緩存：LRU + 弱引用的多級緩存
- 🎨 現代化 UI：Material Design 3
- 📊 完整測試：單元測試 + 集成測試

## 開發進度

### 已完成功能 (✅)
- 基礎架構搭建
- 運勢計算系統
- 智能篩選系統
- 本地通知系統
- 性能優化
  - 啟動時間優化 (90%)
  - 內存使用優化 (70%)
  - 列表滾動優化 (100%)

### 進行中功能 (⏳)
- 代碼分割和延遲加載
- 內存泄漏檢測
- 大對象回收優化
- 代碼重構

## 技術棧

### 前端
- Flutter 3.x
- Riverpod（狀態管理）
- SQLite（本地存儲）
- flutter_local_notifications（本地通知）

### 後端
- Node.js
- Express
- MongoDB

## 開發環境設置

1. 安裝依賴：
```bash
flutter pub get
```

2. 運行應用：
```bash
flutter run
```

3. 運行測試：
```bash
flutter test
```

## 項目結構

```
lib/
├── core/           # 核心功能
│   ├── models/     # 數據模型
│   ├── services/   # 業務服務
│   ├── providers/  # 狀態管理
│   └── utils/      # 工具類
├── features/       # 功能模塊
│   ├── fortune/    # 運勢相關
│   ├── settings/   # 設置相關
│   └── common/     # 公共組件
└── main.dart       # 入口文件
```

## 性能優化

### 啟動優化
- 並行資源加載
- 後台線程預加載
- 路由優化
- 圖片緩存優化

### 內存優化
- 圖片緩存限制
- 路由緩存管理
- 資源釋放機制

### 列表優化
- 項目緩存
- 固定高度
- 懶加載實現

## 待優化項目

1. 代碼分割和延遲加載
2. 內存泄漏檢測
3. 大對象回收優化
4. 代碼重構

## 貢獻指南

1. Fork 本項目
2. 創建新分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add some feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 提交 Pull Request

## 許可證

MIT License 