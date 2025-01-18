# All Lucky API 文檔

## API 狀態總覽

### 運勢相關 API
| 端點 | 方法 | 說明 | 狀態 |
|------|------|------|------|
| `/api/v1/fortune/daily/:date` | GET | 獲取每日運勢 | ⏳ 整合中 |
| `/api/v1/fortune/study/:date` | GET | 獲取學業運勢 | ⏳ 整合中 |
| `/api/v1/fortune/career/:date` | GET | 獲取事業運勢 | ⏳ 整合中 |
| `/api/v1/fortune/love/:date` | GET | 獲取愛情運勢 | ⏳ 整合中 |

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
  "love": 85,
  "details": {
    "horoscope": {
      "description": "今日運勢描述",
      "mood": "excited",
      "color": "紅色",
      "lucky_time": "14:00-16:00"
    },
    "zodiac": {
      "fortune": {
        "overall": 80,
        "career": 85,
        "love": 75
      },
      "elements": {
        "lucky_directions": ["東", "南"],
        "lucky_numbers": ["3", "8"]
      }
    },
    "advice": [
      "今日幸運色：紅色",
      "幸運時段：14:00-16:00",
      "吉利方位：東、南",
      "幸運數字：3、8"
    ]
  }
}
```

## 實現狀態說明

### 已完成 ✅
- API 路由設置
- 參數驗證
- 錯誤處理
- 基本緩存機制
- 農曆轉換
- 節氣計算

### 進行中 ⏳
- 運勢計算邏輯整合
  - 星座運勢 API 整合
  - 生肖運勢 API 整合
  - 運勢數據合併與計算

### 待實現 ❌
- API 認證（已移除，改用外部 API 的認證機制）
- 請求限制（依賴外部 API 的限制）
- CORS 設置

## 外部 API 依賴

### 星座運勢
- API: Aztro API
- 端點: https://aztro.sameerkumar.website
- 狀態: ⏳ 整合中

### 生肖運勢
- API: Chinese Zodiac API
- 端點: https://chinese-zodiac.p.rapidapi.com
- 狀態: ⏳ 整合中

## 緩存策略

| 資源類型 | 緩存時間 | 實現狀態 |
|----------|----------|----------|
| 運勢數據 | 12 小時 | ✅ |
| 黃曆數據 | 7 天 | ⏳ |
| 節氣數據 | 30 天 | ⏳ |

## 環境變量

| 變量名 | 說明 | 預設值 | 狀態 |
|--------|------|--------|------|
| RAPIDAPI_KEY | RapidAPI 密鑰 | - | ⏳ |
| NODE_ENV | 執行環境 | development | ✅ |
| PORT | 服務埠號 | 3000 | ✅ |
| API_VERSION | API 版本 | v1 | ✅ |
| LOG_LEVEL | 日誌等級 | info | ✅ |
| CACHE_TTL | 緩存存活時間 | 12小時 | ✅ | 