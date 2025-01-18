# 諸事大吉

基於 Flutter 開發的運勢預測與黃曆查詢應用。

## 專案狀態

### 已完成功能 ✅

- 基礎架構
  - Flutter 框架配置
  - Node.js 後端服務
  - 狀態管理（Riverpod）
  - 路由管理
  - 本地存儲

- 核心服務
  - 運勢預測（基礎算法）
  - 黃曆查詢
  - 農曆轉換
  - 節氣計算
  - 緩存系統

### 進行中功能 ⚠️

- 智能篩選
  - 多條件組合
  - 結果排序
  - 智能推薦

- 方位指引
  - 指南針整合
  - 即時方位提示

### 待開發功能 ❌

- 推送通知
- 社交功能
- 進階功能（桌面小部件等）
- 商業化功能（會員系統、支付系統等）

## 技術架構

### 前端（Flutter）

- 框架：Flutter 3.x
- 狀態管理：Riverpod
- 路由：go_router
- 本地存儲：shared_preferences
- UI 框架：Material Design 3

### 後端（Node.js）

- 框架：Express
- 語言：TypeScript
- 緩存：Redis
- 日誌：Winston
- API 文檔：Swagger

## 快速開始

### 環境要求

- Flutter 3.x
- Node.js 20.x
- npm 10.x
- Redis

### 安裝步驟

1. 克隆專案
```bash
git clone https://github.com/your-username/all-lucky.git
cd all-lucky
```

2. 安裝依賴
```bash
# 前端
cd client
flutter pub get

# 後端
cd ../server
npm install
```

3. 運行開發環境
```bash
# 前端
flutter run

# 後端
npm run dev
```

## 開發指南

### 代碼風格

- 遵循 Flutter 官方代碼規範
- 使用 ESLint 和 Prettier 進行代碼格式化
- 提交前運行測試和 lint 檢查

### 提交規範

- feat: 新功能
- fix: 修復問題
- docs: 文檔變更
- style: 代碼格式
- refactor: 代碼重構
- test: 測試相關
- chore: 其他更改

### 測試指南

- 運行單元測試：`flutter test`
- 運行集成測試：`flutter drive`
- 檢查代碼覆蓋率：`flutter test --coverage`

## API 文檔

API 文檔請參考 [API.md](./API.md)

## 貢獻指南

請參考 [CONTRIBUTING.md](./CONTRIBUTING.md)

## 更新日誌

請參考 [CHANGELOG.md](./CHANGELOG.md)

## 開源協議

MIT License 