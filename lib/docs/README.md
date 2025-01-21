# 專案技術文檔

## 存儲層優化計劃 (2024-01-19)

### 當前問題
1. 存儲服務存在重複實現:
   - `StorageService` (SharedPreferences)
   - `DatabaseService` (SQLite)
   - `CacheService` (內存緩存 + SQLite)

2. 依賴管理問題:
   - 引入了未使用的 Hive 依賴
   - SharedPreferences 和 SQLite 功能重疊

### 優化決策
1. 統一使用 SQLite 作為主要存儲方案:
   - 完整的 CRUD 操作支持
   - 事務處理能力
   - 結構化數據存儲
   - 完整的測試覆蓋

2. 代碼清理:
   - 移除 `StorageService` 類
   - 移除 SharedPreferences 相關代碼
   - 移除 Hive 相關依賴
   - 將 `CacheService` 功能整合到 `DatabaseService`

### 實施計劃
1. 第一階段: 存儲層重構
   - [ ] 將 `StorageService` 功能遷移到 `DatabaseService`
   - [ ] 在 `DatabaseService` 中實現緩存機制
   - [ ] 更新所有使用 `StorageService` 的代碼
   - [ ] 移除冗余的存儲相關代碼和依賴

2. 第二階段: 測試完善
   - [ ] 補充 Widget 測試
   - [ ] 添加整合測試
   - [ ] 提高測試覆蓋率
   - [ ] 確保所有存儲操作都有對應的測試用例

3. 第三階段: 性能優化
   - [ ] 實現數據庫查詢的緩存策略
   - [ ] 優化數據庫索引
   - [ ] 實現批量操作的優化
   - [ ] 性能測試和監控

### 預期效果
1. 代碼質量提升:
   - 減少代碼重複
   - 提高可維護性
   - 更清晰的架構

2. 性能改進:
   - 更高效的數據存取
   - 更好的內存使用
   - 更快的響應時間

3. 可靠性提升:
   - 完整的測試覆蓋
   - 統一的錯誤處理
   - 更好的數據一致性

### 注意事項
1. 遷移過程中確保數據不丟失
2. 保持向後兼容性
3. 確保所有更改都有對應的測試
4. 記錄所有重大更改
