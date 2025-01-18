# API 文檔

## API 狀態總覽

### 運勢相關 API

| 端點 | 方法 | 狀態 | 說明 |
|------|------|------|------|
| `/fortune/daily/:date` | GET | ✅ 已完成 | 每日運勢查詢 |
| `/fortune/study/:date` | GET | ✅ 已完成 | 學業運勢查詢 |
| `/fortune/career/:date` | GET | ✅ 已完成 | 事業運勢查詢 |
| `/fortune/love/:date` | GET | ✅ 已完成 | 愛情運勢查詢 |

### 黃曆相關 API

| 端點 | 方法 | 狀態 | 說明 |
|------|------|------|------|
| `/almanac/daily/:date` | GET | ✅ 已完成 | 每日黃曆查詢 |
| `/almanac/monthly/:year/:month` | GET | ✅ 已完成 | 月度黃曆查詢 |
| `/almanac/solar-terms/:year` | GET | ✅ 已完成 | 節氣查詢 |
| `/almanac/lunar-date/:date` | GET | ✅ 已完成 | 農曆轉換 |

## API 詳細說明

### 1. 運勢查詢 API

#### 1.1 每日運勢查詢

```http
GET /fortune/daily/:date
```

**參數說明：**
- `date`: 日期，格式為 YYYY-MM-DD

**響應示例：**
```json
{
  "code": 0,
  "data": {
    "date": "2024-03-15",
    "overall": {
      "score": 85,
      "level": "大吉",
      "description": "今日運勢不錯，適合...",
      "advice": "建議早起，注意..."
    },
    "details": {
      "lucky_direction": "東南",
      "lucky_color": "藍色",
      "lucky_number": 6,
      "avoid": ["遠行", "簽約"],
      "suitable": ["會友", "運動"]
    }
  }
}
```

#### 1.2 學業運勢查詢

```http
GET /fortune/study/:date
```

**參數說明：**
- `date`: 日期，格式為 YYYY-MM-DD

**響應示例：**
```json
{
  "code": 0,
  "data": {
    "date": "2024-03-15",
    "study": {
      "score": 90,
      "level": "特吉",
      "description": "學習效率極佳，適合...",
      "advice": "建議多花時間在...",
      "subjects": {
        "math": 85,
        "literature": 95,
        "science": 88
      }
    }
  }
}
```

### 2. 黃曆查詢 API

#### 2.1 每日黃曆查詢

```http
GET /almanac/daily/:date
```

**參數說明：**
- `date`: 日期，格式為 YYYY-MM-DD

**響應示例：**
```json
{
  "code": 0,
  "data": {
    "date": "2024-03-15",
    "lunar": {
      "year": 2024,
      "month": 2,
      "day": 5,
      "isLeap": false
    },
    "solarTerm": "驚蟄",
    "zodiac": "龍",
    "suitable": ["祭祀", "出行", "開業"],
    "avoid": ["動土", "安葬"]
  }
}
```

## 錯誤碼說明

| 錯誤碼 | 說明 |
|--------|------|
| 0 | 成功 |
| 1001 | 參數錯誤 |
| 1002 | 日期格式錯誤 |
| 2001 | 服務器內部錯誤 |
| 2002 | 數據庫錯誤 |
| 3001 | 緩存錯誤 |
| 4001 | 請求過於頻繁 |

## 注意事項

1. 所有請求需要在 header 中攜帶 `Content-Type: application/json`
2. 日期格式統一使用 `YYYY-MM-DD`
3. 時間相關的返回值均為 UTC 時間
4. 請求頻率限制為每分鐘 60 次
5. 緩存時間為 5 分鐘

## 更新日誌

### v1.0.0 (2024-03-15)
- 完成基礎 API 開發
- 實現運勢和黃曆查詢功能
- 添加緩存機制
- 完善錯誤處理

### v0.9.0 (2024-03-01)
- API 架構設計
- 基礎功能實現
- 測試環境搭建 