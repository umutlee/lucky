# All Lucky 運勢應用

一個基於 Flutter 和 Node.js 的運勢預測應用。

## 項目結構

```
.
├── lib/                # Flutter 前端代碼
└── server/            # Node.js 後端服務
    ├── src/
    │   ├── models/    # 數據模型
    │   ├── routes/    # API 路由
    │   ├── services/  # 業務邏輯
    │   ├── middleware/# 中間件
    │   └── utils/     # 工具類
    └── tests/         # 測試文件
```

## 後端 API 服務

### 已完成功能

1. **基礎架構**
   - Express.js 服務器設置
   - TypeScript 配置
   - 環境變量管理
   - API 密鑰驗證
   - 錯誤處理中間件
   - 日誌系統

2. **API 端點**
   - 運勢相關
     - 每日運勢 `/api/v1/fortune/daily/:date`
     - 學業運勢 `/api/v1/fortune/study/:date`
     - 事業運勢 `/api/v1/fortune/career/:date`
     - 愛情運勢 `/api/v1/fortune/love/:date`
   - 黃曆相關
     - 每日黃曆 `/api/v1/almanac/daily/:date`
     - 月曆查詢 `/api/v1/almanac/monthly/:year/:month`
     - 節氣信息 `/api/v1/almanac/solar-terms/:year`
     - 農曆轉換 `/api/v1/almanac/lunar-date/:date`

3. **開發工具配置**
   - ESLint
   - Prettier
   - Jest
   - TypeScript
   - 熱重載

### 待開發功能

1. **運勢計算邏輯**
   - 實現具體的運勢計算算法
   - 添加更多運勢影響因素
   - 優化預測準確度

2. **數據存儲**
   - 添加數據庫連接
   - 實現數據緩存機制
   - 優化查詢性能

3. **測試覆蓋**
   - 單元測試
   - 集成測試
   - 性能測試

4. **API 文檔**
   - Swagger/OpenAPI 文檔
   - 使用示例
   - 錯誤碼說明

## 開發環境設置

1. 安裝依賴：
```bash
cd server
npm install
```

2. 設置環境變量：
```bash
cp .env.example .env
# 編輯 .env 文件設置必要的環境變量
```

3. 啟動開發服務器：
```bash
npm run dev
```

## API 密鑰

API 密鑰格式：`{ENV}_{KEY}`
- ENV: 環境標識符（DEV/TEST/PROD）
- KEY: 32位隨機字符串

示例：`DEV_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`

## 錯誤處理

所有 API 響應遵循統一的錯誤處理格式：

```json
{
  "error": "錯誤類型",
  "message": "錯誤描述",
  "isOperational": true/false
}
```

## 貢獻指南

1. Fork 本項目
2. 創建特性分支
3. 提交更改
4. 發起 Pull Request

## 許可證

MIT 