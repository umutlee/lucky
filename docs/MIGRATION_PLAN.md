# SharedPreferences 到 SQLite 遷移計劃

## 當前使用 SharedPreferences 的服務
1. PreferencesService
   - 存儲內容: 通知設置
   - 主要字段:
     - daily_notification (bool)
     - notification_time (string)

2. UserSettingsService  
   - 存儲內容: 用戶設置
   - 主要字段:
     - user_settings (JSON string)
     - 包含: zodiac, birthYear, notifications, location permission 等

## SQLite 表結構設計

### preferences 表
```sql
CREATE TABLE preferences (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### user_settings 表
```sql
CREATE TABLE user_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    zodiac TEXT NOT NULL,
    birth_year INTEGER NOT NULL,
    has_enabled_notifications BOOLEAN DEFAULT TRUE,
    has_location_permission BOOLEAN DEFAULT FALSE,
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    has_accepted_terms BOOLEAN DEFAULT FALSE,
    has_accepted_privacy BOOLEAN DEFAULT FALSE,
    is_first_launch BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 遷移步驟

1. 數據庫準備 (預計時間: 2小時)
   - 創建 DatabaseHelper 類
   - 實現數據庫初始化和表創建
   - 添加基本的 CRUD 操作方法

2. 新服務實現 (預計時間: 4小時)
   - 創建 SQLitePreferencesService
   - 創建 SQLiteUserSettingsService
   - 實現所有必要的數據操作方法
   - 添加數據遷移邏輯

3. 數據遷移 (預計時間: 2小時)
   - 實現從 SharedPreferences 讀取數據
   - 將數據寫入 SQLite
   - 添加遷移成功標記

4. 服務替換 (預計時間: 2小時)
   - 更新 Provider 定義
   - 替換服務注入
   - 移除舊的 SharedPreferences 代碼

5. 測試 (預計時間: 4小時)
   - 單元測試
   - 集成測試
   - 遷移測試

## 風險評估

1. 數據丟失風險
   - 緩解措施: 在完全確認遷移成功前保留舊數據
   - 添加數據備份機制

2. 性能影響
   - 緩解措施: 使用批量操作
   - 添加緩存層

3. 兼容性問題
   - 緩解措施: 全面的測試覆蓋
   - 添加版本檢查機制

## 回滾計劃

1. 保留舊的 SharedPreferences 實現
2. 添加版本標記
3. 實現回滾機制

## 時間估計

總計預計需要 14 小時完成遷移工作:
- 準備工作: 2小時
- 實現: 4小時
- 遷移: 2小時
- 替換: 2小時
- 測試: 4小時

## 驗收標準

1. 所有數據正確遷移
2. 無數據丟失
3. 所有測試通過
4. 性能符合要求
5. 用戶無感知切換 