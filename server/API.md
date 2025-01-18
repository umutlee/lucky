# All Lucky API 文檔

## API 狀態總覽

### 運勢相關 API
| 端點 | 方法 | 說明 | 狀態 |
|------|------|------|------|
| `/api/v1/fortune/daily/:date` | GET | 獲取每日運勢 | ⏳ 基礎完成 |
| `/api/v1/fortune/study/:date` | GET | 獲取學業運勢 | ⏳ 基礎完成 |
| `/api/v1/fortune/career/:date` | GET | 獲取事業運勢 | ⏳ 基礎完成 |
| `/api/v1/fortune/love/:date` | GET | 獲取愛情運勢 | ⏳ 基礎完成 |

### 黃曆相關 API
| 端點 | 方法 | 說明 | 狀態 |
|------|------|------|------|
| `/api/v1/almanac/daily/:date` | GET | 獲取每日黃曆 | ⏳ 基礎完成 |
| `/api/v1/almanac/monthly/:year/:month` | GET | 獲取月曆 | ⏳ 基礎完成 |
| `/api/v1/almanac/solar-terms/:year` | GET | 獲取節氣信息 | ⏳ 基礎完成 |
| `/api/v1/almanac/lunar-date/:date` | GET | 農曆日期轉換 | ⏳ 基礎完成 |

## API 詳細說明

### 運勢相關 API

#### 獲取每日運勢
```http
GET /api/v1/fortune/daily/:date
```

**參數**
- `date`: 日期（格式：YYYY-MM-DD）✅
- `zodiac`: 生肖（可選）✅
- `constellation`: 星座（可選）✅

**響應** ⏳
```json
{
  "overall": 85,
  "study": 90,
  "career": 80,
  "love": 85
}
```

### 黃曆相關 API

#### 獲取每日黃曆
```http
GET /api/v1/almanac/daily/:date
```

**參數**
- `date`: 日期（格式：YYYY-MM-DD）✅

**響應** ⏳
```json
{
  "lunarDate": {
    "year": 2024,
    "month": 1,
    "day": 1,
    "isLeap": false
  },
  "solarTerm": "立春",
  "suitable": ["祈福", "開業", "入學"],
  "unsuitable": ["搬家", "動土"]
}
```

## 實現狀態說明

### 已完成 ✅
- API 路由設置
- 參數驗證
- 錯誤處理
- 基本緩存機制

### 進行中 ⏳
- 運勢計算邏輯
- 農曆轉換
- 節氣計算

### 待實現 ❌
- API 認證
- 請求限制
- CORS 設置

## 錯誤處理

所有 API 在發生錯誤時會返回統一格式的錯誤響應：

```json
{
  "error": "錯誤類型",
  "message": "錯誤描述",
  "isOperational": true
}
```

### 錯誤碼說明
| 狀態碼 | 說明 | 實現狀態 |
|--------|------|----------|
| 400 | 請求參數錯誤 | ✅ |
| 401 | API 密鑰無效 | ❌ |
| 404 | 資源不存在 | ✅ |
| 429 | 請求過於頻繁 | ❌ |
| 500 | 服務器內部錯誤 | ✅ |

## 緩存策略

| 資源類型 | 緩存時間 | 實現狀態 |
|----------|----------|----------|
| 運勢數據 | 12 小時 | ✅ |
| 黃曆數據 | 7 天 | ⏳ |
| 節氣數據 | 30 天 | ⏳ |

## 使用限制（待實現）

- 每個 API 密鑰每分鐘最多 60 次請求 ❌
- 每個 IP 每分鐘最多 30 次請求 ❌
- 單個請求響應大小限制: 1MB ❌ 