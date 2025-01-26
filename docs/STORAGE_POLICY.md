# 儲存策略說明文件

## 儲存方案規範

### 強制規定
1. 本專案**僅允許使用 SQLite** 作為本地儲存方案
2. **嚴格禁止**使用以下儲存方式：
   - SharedPreferences
   - 本地文件儲存
   - 其他任何形式的鍵值對儲存

### 技術實現
- 所有本地儲存操作必須通過 `SQLitePreferencesService` 進行
- 資料庫操作統一由 `DatabaseHelper` 類處理
- 所有資料表結構變更必須通過資料庫遷移腳本進行

### 資料庫結構
#### preferences 表
- key: TEXT PRIMARY KEY
- value: TEXT
- type: TEXT
- updated_at: TEXT

### 注意事項
1. 不要在任何新功能中引入 SharedPreferences
2. 如需新增儲存功能，必須使用 SQLite
3. 定期檢查代碼，確保沒有誤用其他儲存方案

## 遷移歷史
- 2025-03-XX: 完全移除 SharedPreferences，統一使用 SQLite 