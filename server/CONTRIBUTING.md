# 開發指南

## 開發環境設置

### 必要條件
- Node.js 18+
- TypeScript 5.0+
- VS Code（推薦）

### 推薦的 VS Code 插件
- ESLint
- Prettier
- TypeScript and JavaScript Language Features
- Jest Runner
- Git History
- GitLens

## 代碼規範

### TypeScript 規範
- 使用嚴格模式 (`strict: true`)
- 優先使用 `interface` 而不是 `type`
- 明確的函數返回類型
- 避免使用 `any`
- 使用可選鏈運算符 `?.` 和空值合併運算符 `??`

### 命名規範
- 文件名：使用 kebab-case（例如：`fortune-service.ts`）
- 類名：使用 PascalCase（例如：`FortuneService`）
- 函數和變量：使用 camelCase（例如：`calculateFortune`）
- 常量：使用 UPPER_SNAKE_CASE（例如：`MAX_CACHE_SIZE`）
- 接口名：使用 PascalCase，以 I 開頭（例如：`IFortuneService`）

### 文件結構
```
src/
├── controllers/     # 控制器層
├── services/       # 服務層
├── models/         # 數據模型
├── middleware/     # 中間件
├── utils/          # 工具類
└── types/          # 類型定義
```

### 代碼組織
- 每個文件只導出一個主要的類/函數
- 相關的功能放在同一個目錄下
- 使用 index.ts 文件導出模塊公共 API
- 保持文件大小合理（不超過 300 行）

## 開發流程

### 1. 分支管理
- `main`: 主分支，只接受合併請求
- `develop`: 開發分支，從這裡創建特性分支
- `feature/*`: 特性分支，用於開發新功能
- `bugfix/*`: 修復分支，用於修復 bug
- `release/*`: 發布分支，用於版本發布

### 2. 提交規範
提交信息格式：
```
<type>(<scope>): <subject>

<body>

<footer>
```

類型（type）：
- feat: 新功能
- fix: 修復 bug
- docs: 文檔更新
- style: 代碼格式（不影響代碼運行的變動）
- refactor: 重構
- test: 測試相關
- chore: 構建過程或輔助工具的變動

### 3. 測試規範
- 單元測試文件命名：`*.test.ts`
- 測試覆蓋率要求：
  - 語句覆蓋率 > 80%
  - 分支覆蓋率 > 70%
  - 函數覆蓋率 > 80%
- 使用 Jest 的 describe 和 it 組織測試用例
- 每個測試用例只測試一個功能點

### 4. 文檔規範
- 所有公共 API 都需要 JSDoc 註釋
- README.md 文件需要及時更新
- API 文檔需要與代碼同步更新
- 註釋使用繁體中文

### 5. 代碼審查
- 所有代碼必須經過審查才能合併
- 審查重點：
  - 代碼質量
  - 測試覆蓋
  - 文檔完整性
  - 性能考慮
  - 安全性考慮

## 發布流程

### 1. 版本號管理
使用語義化版本號：`major.minor.patch`
- major: 不兼容的 API 修改
- minor: 向下兼容的功能性新增
- patch: 向下兼容的問題修正

### 2. 發布步驟
1. 從 develop 分支創建 release 分支
2. 更新版本號
3. 運行完整測試套件
4. 生成更新日誌
5. 合併到 main 分支
6. 打標籤
7. 部署到生產環境

### 3. 發布檢查清單
- [ ] 所有測試通過
- [ ] 文檔已更新
- [ ] 版本號已更新
- [ ] 更新日誌已生成
- [ ] 代碼已審查
- [ ] 性能測試通過
- [ ] 安全掃描通過

## 問題反饋
- 使用 GitHub Issues 進行問題追蹤
- 提供問題復現步驟
- 附上相關的日誌和截圖
- 標註問題的優先級和類型

## 持續集成
- 提交時自動運行測試
- 自動檢查代碼風格
- 自動生成測試覆蓋率報告
- 自動部署到測試環境 