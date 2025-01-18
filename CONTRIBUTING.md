# 貢獻指南

感謝您對諸事大吉專案的關注！我們歡迎任何形式的貢獻，包括但不限於：

- 提交 bug 報告
- 提出新功能建議
- 改進文檔
- 提交代碼

## 開發流程

1. Fork 專案到您的 GitHub 帳號
2. 克隆您的 Fork 到本地
   ```bash
   git clone https://github.com/YOUR_USERNAME/all-lucky.git
   ```
3. 創建新的功能分支
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. 進行開發並提交更改
   ```bash
   git add .
   git commit -m "feat: 添加新功能"
   ```
5. 推送到您的 Fork
   ```bash
   git push origin feature/your-feature-name
   ```
6. 創建 Pull Request

## 提交規範

### 分支命名

- 功能開發：`feature/feature-name`
- Bug 修復：`fix/bug-name`
- 文檔更新：`docs/update-name`
- 性能優化：`perf/optimization-name`

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 類型

- feat: 新功能
- fix: 修復問題
- docs: 文檔變更
- style: 代碼格式（不影響代碼運行的變動）
- refactor: 重構（既不是新增功能，也不是修改 bug 的代碼變動）
- perf: 性能優化
- test: 增加測試
- chore: 構建過程或輔助工具的變動

### Scope 範圍

- frontend: 前端相關
- backend: 後端相關
- api: API 相關
- docs: 文檔相關
- test: 測試相關
- deps: 依賴相關

### Subject 主題

- 使用中文
- 簡潔明了
- 結尾不加句號

## 代碼規範

### Flutter/Dart

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 規範
- 使用 `dart format` 格式化代碼
- 運行 `dart analyze` 進行靜態分析
- 確保所有測試通過

### Node.js/TypeScript

- 遵循 [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- 使用 ESLint 和 Prettier 格式化代碼
- 確保所有測試通過

## 測試要求

1. 單元測試
   - 新功能必須包含單元測試
   - 修復 bug 時需要添加相關測試用例
   - 測試覆蓋率不低於 80%

2. 集成測試
   - API 端點必須有集成測試
   - UI 組件需要有 widget 測試

## 文檔要求

1. 代碼註釋
   - 公共 API 必須有完整的文檔註釋
   - 複雜的業務邏輯需要添加註釋說明
   - 使用 /// 格式的文檔註釋

2. README 更新
   - 新功能需要在 README 中添加說明
   - API 變更需要更新 API 文檔
   - 配置變更需要更新安裝說明

## Review 流程

1. Pull Request 要求
   - 清晰的標題和描述
   - 相關的 issue 鏈接
   - 完整的測試覆蓋
   - 通過 CI 檢查

2. Code Review 標準
   - 代碼質量
   - 測試覆蓋
   - 文檔完整性
   - 性能影響

## 發布流程

1. 版本號規範
   - 遵循 [Semantic Versioning](https://semver.org/)
   - 主版本號：不兼容的 API 修改
   - 次版本號：向下兼容的功能性新增
   - 修訂號：向下兼容的問題修正

2. 更新日誌
   - 記錄所有變更
   - 按類型分類
   - 標註版本號和發布日期

## 其他注意事項

1. 安全性
   - 不要提交敏感信息
   - 使用環境變量存儲配置
   - 及時更新依賴版本

2. 性能
   - 注意代碼性能影響
   - 大文件需要優化
   - 考慮移動端限制

3. 兼容性
   - 確保跨平台兼容
   - 考慮不同設備適配
   - 注意 API 向下兼容

## 聯繫我們

如有任何問題，請通過以下方式聯繫：

- Issue: [GitHub Issues](https://github.com/your-username/all-lucky/issues)
- Email: your-email@example.com
- Discord: [加入我們的 Discord](https://discord.gg/your-invite-link) 