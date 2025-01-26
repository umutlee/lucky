# 專案文檔結構說明

## 文檔組織原則

1. **根目錄（/）**：放置專案整體相關文檔
   - `README.md`：專案總體說明、快速開始指南
   - `CONTRIBUTING.md`：貢獻指南
   - `CHANGELOG.md`：版本更新記錄
   - `LICENSE`：授權協議

2. **前端目錄（/lib）**：Flutter 相關文檔
   - `README.md`：前端架構說明、組件文檔
   - `CHANGELOG.md`：前端更新記錄

3. **後端目錄（/server）**：Node.js 相關文檔
   - `README.md`：後端架構說明、服務文檔
   - `API.md`：API 接口文檔
   - `CHANGELOG.md`：後端更新記錄

4. **文檔目錄（/docs）**：技術文檔和說明
   - `STRUCTURE.md`：本文檔（文檔結構說明）
   - `PROGRESS.md`：開發進度追蹤
   - `ARCHITECTURE.md`：系統架構設計
   - `DEPLOYMENT.md`：部署說明文檔

## 文檔更新規範

1. **版本控制**
   - 所有文檔變更都需要通過 git 提交
   - 提交信息格式：`docs: 更新XXX文檔`
   - 重大變更需要在 CHANGELOG.md 中記錄

2. **內容同步**
   - 功能變更時需要同步更新相關文檔
   - API 變更需要同步更新 API.md
   - 架構調整需要同步更新 ARCHITECTURE.md

3. **文檔審查**
   - 文檔變更需要經過 review
   - 確保文檔的準確性和完整性
   - 保持文檔格式的一致性

## 目錄結構

```
/
├── README.md           # 專案總體說明
├── CONTRIBUTING.md     # 貢獻指南
├── CHANGELOG.md        # 版本更新記錄
├── LICENSE            # 授權協議
│
├── lib/               # 前端代碼目錄
│   ├── README.md      # 前端說明文檔
│   └── CHANGELOG.md   # 前端更新記錄
│
├── server/            # 後端代碼目錄
│   ├── README.md      # 後端說明文檔
│   ├── API.md         # API 文檔
│   └── CHANGELOG.md   # 後端更新記錄
│
└── docs/              # 文檔目錄
    ├── STRUCTURE.md   # 文檔結構說明（本文檔）
    ├── PROGRESS.md    # 開發進度追蹤
    ├── ARCHITECTURE.md # 系統架構設計
    └── DEPLOYMENT.md  # 部署說明
```

## 注意事項

1. 避免在不同位置創建相同內容的文檔
2. 確保文檔之間的引用鏈接正確
3. 定期檢查和更新文檔內容
4. 保持文檔的簡潔性和可維護性 