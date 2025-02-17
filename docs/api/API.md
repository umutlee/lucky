# API 文檔

## 概述
本文檔詳細說明了諸事大吉應用的 API 設計和使用方法。所有 API 都遵循 RESTful 設計原則，使用 HTTPS 進行安全傳輸。

## API 版本
當前版本：v1
基礎路徑：`https://api.alllucky.com/v1`

## 通用規範

### 請求格式
- Content-Type: application/json
- Accept: application/json
- 字符編碼：UTF-8

### 響應格式
```json
{
  "code": 200,          // 狀態碼
  "data": {},           // 響應數據
  "message": "success"  // 狀態信息
}
```

### 錯誤處理
```json
{
  "code": 400,                // 錯誤碼
  "error": "INVALID_PARAMS",  // 錯誤類型
  "message": "無效的參數"      // 錯誤信息
}
```

## 運勢相關 API

### 獲取每日運勢
GET /fortune/daily

請求參數：
```json
{
  "date": "2024-03-21",    // 日期，格式：YYYY-MM-DD
  "type": "general",       // 運勢類型：general, study, work, etc.
  "userId": "user123"      // 用戶ID（可選）
}
```

響應示例：
```json
{
  "code": 200,
  "data": {
    "date": "2024-03-21",
    "solarDate": "2024年3月21日",
    "lunarDate": {
      "year": 2024,
      "month": 2,
      "day": 12,
      "isLeap": false,
      "yearGanZhi": "甲辰",
      "monthGanZhi": "丙寅",
      "dayGanZhi": "壬午",
      "zodiac": "龍",
      "solarTerm": "春分",
      "festivals": ["春分節"]
    },
    "fortune": {
      "score": 85,
      "level": "極好",
      "description": "今日整體運勢不錯，適合...",
      "suggestions": [
        "建議早起進行重要工作",
        "適合戶外活動"
      ]
    },
    "dayLuck": {
      "yi": ["祭祀", "出行", "修造"],
      "ji": ["動土", "安葬"],
      "positions": ["東北", "西南"]
    },
    "timeZhi": "午時",
    "wuXing": "火",
    "luckyColors": ["紅", "黃"],
    "luckyNumbers": [3, 8]
  },
  "message": "success"
}
```

### 獲取月度運勢
GET /fortune/monthly

請求參數：
```json
{
  "year": 2024,           // 年份
  "month": 3,             // 月份
  "type": "general",      // 運勢類型
  "userId": "user123"     // 用戶ID（可選）
}
```

響應示例：
```json
{
  "code": 200,
  "data": {
    "year": 2024,
    "month": 3,
    "lunarMonth": {
      "month": 2,
      "isLeap": false,
      "monthGanZhi": "丙寅",
      "solarTerms": [
        {
          "name": "驚蟄",
          "date": "2024-03-05"
        },
        {
          "name": "春分",
          "date": "2024-03-20"
        }
      ]
    },
    "overview": "本月整體運勢平穩...",
    "details": {
      "study": 80,
      "work": 85,
      "health": 90
    },
    "highlights": [
      "3月15日：適合重要決策",
      "3月21日：貴人運旺"
    ],
    "monthFortune": {
      "score": 82,
      "description": "本月運勢穩定上升...",
      "luckyDays": [5, 15, 21],
      "cautionDays": [8, 18]
    }
  },
  "message": "success"
}
```

## 用戶相關 API

### 更新用戶設置
POST /user/settings

請求參數：
```json
{
  "userId": "user123",
  "settings": {
    "theme": "dark",
    "notification": true,
    "language": "zh-TW"
  }
}
```

響應示例：
```json
{
  "code": 200,
  "data": {
    "updated": true,
    "timestamp": "2024-03-21T10:30:00Z"
  },
  "message": "設置更新成功"
}
```

### 獲取系統配置
GET /system/config

響應示例：
```json
{
  "code": 200,
  "data": {
    "version": "1.1.4",
    "apiVersion": "v1",
    "features": {
      "notification": true,
      "backup": true
    },
    "maintenance": {
      "scheduled": false,
      "message": null
    }
  },
  "message": "success"
}
```

## 錯誤碼說明

| 錯誤碼 | 說明 | 處理建議 |
|--------|------|----------|
| 400 | 請求參數錯誤 | 檢查參數格式和必填項 |
| 401 | 未授權訪問 | 檢查認證信息 |
| 403 | 禁止訪問 | 檢查權限設置 |
| 404 | 資源不存在 | 檢查請求路徑 |
| 429 | 請求過於頻繁 | 降低請求頻率 |
| 500 | 服務器錯誤 | 聯繫技術支持 |

## 更新記錄

### 2024-03-21
- 優化錯誤處理機制
- 添加月度運勢 API
- 完善響應格式
- 更新錯誤碼說明 