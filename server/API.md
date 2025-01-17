# All Lucky API 文檔

## API 概述

所有 API 端點都需要在請求頭中包含有效的 API 密鑰：
```
X-API-Key: {ENV}_{KEY}
```

## 運勢相關 API

### 獲取每日運勢
```http
GET /api/v1/fortune/daily/:date
```

#### 參數
- `date`: 日期（格式：YYYY-MM-DD）
- `zodiac`: 生肖（可選）
- `constellation`: 星座（可選）

#### 響應
```json
{
  "overall": 85,
  "study": 90,
  "career": 80,
  "love": 85
}
```

### 獲取學業運勢
```http
GET /api/v1/fortune/study/:date
```

#### 參數
- `date`: 日期（格式：YYYY-MM-DD）
- `zodiac`: 生肖（可選）
- `constellation`: 星座（可選）

#### 響應
```json
{
  "study": 90
}
```

### 獲取事業運勢
```http
GET /api/v1/fortune/career/:date
```

#### 參數
- `date`: 日期（格式：YYYY-MM-DD）
- `zodiac`: 生肖（可選）
- `constellation`: 星座（可選）

#### 響應
```json
{
  "career": 80
}
```

### 獲取愛情運勢
```http
GET /api/v1/fortune/love/:date
```

#### 參數
- `date`: 日期（格式：YYYY-MM-DD）
- `zodiac`: 生肖（可選）
- `constellation`: 星座（可選）

#### 響應
```json
{
  "love": 85
}
```

## 黃曆相關 API

### 獲取每日黃曆
```http
GET /api/v1/almanac/daily/:date
```

#### 參數
- `date`: 日期（格式：YYYY-MM-DD）

#### 響應
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

### 獲取月曆
```http
GET /api/v1/almanac/monthly/:year/:month
```

#### 參數
- `year`: 年份
- `month`: 月份

#### 響應
```json
{
  "dates": [
    {
      "date": "2024-01-01",
      "lunarDate": {
        "year": 2024,
        "month": 1,
        "day": 1,
        "isLeap": false
      },
      "solarTerm": null
    }
    // ...更多日期
  ]
}
```

### 獲取節氣信息
```http
GET /api/v1/almanac/solar-terms/:year
```

#### 參數
- `year`: 年份

#### 響應
```json
{
  "solarTerms": [
    {
      "name": "立春",
      "date": "2024-02-04"
    }
    // ...更多節氣
  ]
}
```

### 農曆日期轉換
```http
GET /api/v1/almanac/lunar-date/:date
```

#### 參數
- `date`: 日期（格式：YYYY-MM-DD）

#### 響應
```json
{
  "lunarDate": {
    "year": 2024,
    "month": 1,
    "day": 1,
    "isLeap": false
  }
}
```

## 錯誤處理

所有 API 在發生錯誤時會返回統一格式的錯誤響應：

```json
{
  "error": "錯誤類型",
  "message": "錯誤描述",
  "isOperational": true
}
```

### 常見錯誤碼
- 400: 請求參數錯誤
- 401: API 密鑰無效
- 404: 資源不存在
- 429: 請求過於頻繁
- 500: 服務器內部錯誤

## 緩存策略

- 運勢數據緩存時間: 12 小時
- 黃曆數據緩存時間: 7 天
- 節氣數據緩存時間: 30 天

## 使用限制

- 每個 API 密鑰每分鐘最多 60 次請求
- 每個 IP 每分鐘最多 30 次請求
- 單個請求響應大小限制: 1MB 