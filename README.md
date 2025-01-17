# All Lucky 運勢預測應用

一款基於多重因素分析的運勢預測應用，結合傳統黃曆、節氣、生肖、星座等元素，為用戶提供個性化的運勢分析。

## 功能特點

### 運勢預測
- 📅 支持日運、月運、年運預測
- 📚 學業運勢分析
- 💼 事業運勢評估
- 💕 愛情運勢預測
- 🎯 綜合運勢評分

### 黃曆查詢
- 🌙 農曆日期轉換
- 🌞 24節氣提示
- ⭐ 吉日查詢
- 📋 每日宜忌

### 個性化配置
- 👤 生肖、星座設置
- 🎨 主題切換
- 🌍 多語言支持
- 🔔 運勢提醒

## 技術架構

### 前端技術
- Flutter 框架
- Provider 狀態管理
- Material Design 3
- 本地存儲
- 多語言支持

### 後端技術
- Node.js + Express
- TypeScript
- Jest 測試框架
- API 密鑰認證
- 緩存管理

## 開發進度

### 已完成功能
- ✅ 核心服務開發
  - StorageService（緩存服務）
  - FortuneService（運勢服務）
  - AlmanacService（黃曆服務）
  - ConfigService（配置服務）
- ✅ 工具類開發
  - DateConverter（日期轉換）
  - FortuneCalculator（運勢計算）
- ✅ API 配置
  - API Key 生成
  - 環境變量配置
  - 安全性設置

### 進行中功能
- 🚧 後端 API 服務
- 🚧 緩存策略優化
- 🚧 錯誤處理完善

### 計劃中功能
- 📝 API 文檔完善
- 💾 數據庫集成
- 📊 性能監控
- 🎨 UI 優化

## 快速開始

### 環境要求
- Flutter 3.0+
- Node.js 18+
- TypeScript 5.0+

### 安裝步驟
1. 克隆項目
```bash
git clone https://github.com/yourusername/all-lucky.git
cd all-lucky
```

2. 安裝依賴
```bash
# 前端依賴
flutter pub get

# 後端依賴
cd server
npm install
```

3. 配置環境變量
```bash
cp .env.example .env
# 編輯 .env 文件，填入必要的配置信息
```

4. 運行應用
```bash
# 運行前端
flutter run

# 運行後端
npm run dev
```

## 開發指南

### 目錄結構
```
all-lucky/
├── lib/                # Flutter 前端代碼
│   ├── core/          # 核心功能
│   ├── features/      # 功能模塊
│   ├── shared/        # 共享組件
│   └── main.dart      # 入口文件
├── server/            # Node.js 後端代碼
│   ├── src/           # 源代碼
│   ├── tests/         # 測試文件
│   └── package.json   # 依賴配置
└── README.md          # 項目說明
```

### 開發規範
- 遵循 Flutter 官方代碼規範
- 使用 TypeScript 嚴格模式
- 保持良好的測試覆蓋率
- 及時更新文檔

## 測試

### 運行測試
```bash
# 前端測試
flutter test

# 後端測試
npm test
```

## 貢獻指南
1. Fork 項目
2. 創建特性分支
3. 提交更改
4. 推送到分支
5. 創建 Pull Request

## 版本歷史
- v0.1.0 - 初始版本
  - 基礎架構搭建
  - 核心服務實現
  - 工具類開發

## 授權協議
本項目採用 MIT 授權協議 - 查看 [LICENSE](LICENSE) 文件了解更多細節。 