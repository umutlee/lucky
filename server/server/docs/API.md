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

### 愛情運勢 API

#### 獲取愛情運勢
```http
GET /api/v1/fortune/love/:date
```

**參數**
- `date`: 日期（格式：YYYY-MM-DD）✅
- `zodiac`: 生肖（必填）✅
- `constellation`: 星座（必填）✅
- `partner_zodiac`: 對象生肖（可選）
- `partner_constellation`: 對象星座（可選）

**響應**
```json
{
  "love": {
    "score": 85,
    "horoscope": {
      "description": "今日愛情運勢描述",
      "compatibility": "處女座",
      "lucky_time": "19:00-21:00",
      "romance_aspects": ["月亮與金星相位有利桃花運"]
    },
    "chinese_astrology": {
      "red_romance_star": true,
      "peach_blossom": "旺",
      "compatible_zodiac": "兔",
      "elements": {
        "day_pillar": "甲子",
        "romance_star": ["紅鸞星", "天喜"]
      }
    },
    "compatibility": {
      "zodiac_match": 90,
      "constellation_match": 85,
      "overall_match": 87
    },
    "advice": [
      "今日桃花位在東南方",
      "適合穿粉色增進桃花運",
      "良緣貴人在傍晚出現",
      "建議多參加社交活動"
    ]
  }
}
```

**實現說明**
1. 星座運勢：整合 Aztro API 的愛情相關預測
2. 紫微斗數：計算紅鸞、天喜等桃花星動向
3. 生肖配對：根據生肖相配理論提供匹配建議
4. 綜合分析：結合多項指標給出整體評分和建議

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