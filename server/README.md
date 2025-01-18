# All Lucky 後端服務

## 專案狀態

### 已完成功能 ✅
- 基礎架構搭建
  - Express 服務器設置
  - TypeScript 配置
  - 路由結構
  - 中間件設置
  - 日誌系統
- API 端點設置
  - 運勢預測路由 (/fortune/*)
  - 黃曆查詢路由 (/almanac/*)
- 資料驗證
  - 日期格式驗證
  - 生肖和星座驗證
- 緩存系統
  - 基本緩存機制
  - 緩存過期處理
- 核心功能
  - 農曆日期轉換
  - 節氣計算

### 進行中功能 ⏳
- 運勢計算邏輯整合
  - 星座運勢 API 整合
  - 生肖運勢 API 整合
  - 運勢數據合併與計算

### 待開發功能 ❌
- 基本單元測試
- API 端點測試
- CORS 設置

## 環境要求

- Node.js >= 20.18.1
- npm >= 10.8.2
- TypeScript >= 5.3.3

## 快速開始

1. **安裝 Node.js**
   ```bash
   # 使用 nvm 安裝指定版本
   nvm install
   nvm use
   ```

2. **安裝依賴**
   ```bash
   npm install
   ```

3. **環境設置**
   ```bash
   # 複製環境變量範例檔案
   cp .env.example .env
   # 編輯 .env 文件設置您的環境變量，特別是 RAPIDAPI_KEY
   ```

4. **開發模式**
   ```bash
   npm run dev
   ```

5. **生產環境建置**
   ```bash
   npm run build
   npm start
   ```

## 專案結構

```
server/
├── src/
│   ├── models/          - 資料模型定義
│   │   ├── almanac.ts   - 黃曆相關模型 ✅
│   │   └── fortune.ts   - 運勢相關模型 ✅
│   ├── services/        - 業務邏輯服務
│   │   ├── fortune-service.ts     - 運勢服務 ⏳
│   │   ├── almanac-service.ts     - 黃曆服務 ✅
│   │   ├── storage-service.ts     - 緩存服務 ✅
│   │   └── external/              - 外部 API 整合
│   │       ├── api-client.ts      - API 客戶端基礎類 ✅
│   │       ├── horoscope-api.ts   - 星座運勢 API ⏳
│   │       ├── chinese-zodiac-api.ts - 生肖運勢 API ⏳
│   │       └── fortune-integration.ts - 運勢整合服務 ⏳
│   ├── routes/          - API 路由
│   │   ├── fortune.ts   - 運勢路由 ⏳
│   │   └── almanac.ts   - 黃曆路由 ✅
│   ├── middleware/      - 中間件
│   │   ├── validators.ts - 驗證器 ✅
│   │   └── error-handler.ts - 錯誤處理 ✅
│   ├── utils/           - 工具函數
│   │   ├── logger.ts    - 日誌工具 ✅
│   │   └── date-utils.ts - 日期工具 ✅
│   └── types/          - 型別定義
│       └── lunar-calendar.d.ts - 農曆日期型別 ✅
├── tests/              - 測試文件 ❌
├── .env.example        - 環境變量範例 ✅
├── .nvmrc             - Node.js 版本設定 ✅
├── tsconfig.json      - TypeScript 配置 ✅
└── package.json       - 專案配置 ✅
```

## 環境變量說明

| 變量名 | 說明 | 預設值 | 必填 |
|--------|------|--------|------|
| NODE_ENV | 執行環境 | development | 否 |
| PORT | 服務埠號 | 3000 | 否 |
| API_VERSION | API 版本 | v1 | 否 |
| LOG_LEVEL | 日誌等級 | info | 否 |
| CACHE_TTL | 緩存存活時間 | 12小時 | 否 |
| RAPIDAPI_KEY | RapidAPI 密鑰 | - | 是 |

## 開發指南

### 程式碼風格
- 使用 ESLint 和 Prettier 進行程式碼格式化
- 遵循 TypeScript 嚴格模式
- 使用 async/await 處理非同步操作

### 提交規範
提交訊息格式：
```
<type>: <description>

[optional body]
[optional footer]
```

類型（type）：
- feat: 新功能
- fix: 錯誤修復
- docs: 文檔更新
- style: 程式碼格式（不影響代碼運行的變動）
- refactor: 重構（既不是新增功能，也不是修改錯誤的代碼變動）
- test: 新增測試
- chore: 建構過程或輔助工具的變動

### 測試（待實現）
```bash
# 運行所有測試
npm test

# 運行特定測試
npm test -- -t "test name"
```

## API 文檔

API 文檔請參考 [API.md](./API.md)

## 授權協議

本專案採用 ISC 授權協議 