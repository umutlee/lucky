# 存儲層設計

## 緩存策略

### 多級緩存
- 內存緩存: 最快的訪問速度,但容量有限
- SQLite緩存: 持久化存儲,支持複雜查詢
- API緩存: 通過攔截器實現網絡請求緩存

### 緩存清理
- 定期清理過期數據
- LRU算法管理內存緩存
- 支持手動清理

## 數據表設計

### cache_records 表
- key: 緩存鍵(TEXT PRIMARY KEY)
- value: 緩存值(TEXT)
- created_at: 創建時間(TEXT)
- expires_at: 過期時間(TEXT)
- type: 緩存類型(TEXT)
- metadata: 元數據(TEXT) 