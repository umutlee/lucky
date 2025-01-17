# All Lucky

運勢與黃曆查詢應用

## 環境要求
- Flutter SDK: >=3.3.0 <4.0.0
- Dart SDK: >=3.3.0 <4.0.0

## 開發環境設置

### 1. 環境變量
```bash
# 開發環境（默認）
FLUTTER_ENV=dev
API_KEY=your_dev_key

# 測試環境
FLUTTER_ENV=test
API_KEY=your_test_key

# 生產環境
FLUTTER_ENV=prod
API_KEY=your_prod_key
```

### 2. 運行應用
```bash
# 開發環境
flutter run --dart-define=FLUTTER_ENV=dev --dart-define=API_KEY=your_dev_key

# 測試環境
flutter run --dart-define=FLUTTER_ENV=test --dart-define=API_KEY=your_test_key

# 生產環境
flutter run --dart-define=FLUTTER_ENV=prod --dart-define=API_KEY=your_prod_key
```

## 項目結構
```
lib/
  ├── core/                 # 核心功能
  │   ├── config/          # 配置文件
  │   ├── exceptions/      # 異常處理
  │   ├── interceptors/    # 攔截器
  │   ├── models/          # 數據模型
  │   ├── services/        # 服務層
  │   └── utils/           # 工具類
  ├── features/            # 功能模塊
  │   ├── home/           # 首頁
  │   ├── calendar/       # 日曆
  │   └── settings/       # 設置
  └── main.dart           # 入口文件
```

## API 配置
### 環境配置
- 開發環境：https://dev-api.alllucky.tw
- 測試環境：https://test-api.alllucky.tw
- 生產環境：https://api.alllucky.tw

### 端點配置
#### 運勢相關
- 每日運勢：/fortune/daily
- 學業運勢：/fortune/study
- 事業運勢：/fortune/career
- 愛情運勢：/fortune/love

#### 黃曆相關
- 每日黃曆：/almanac/daily
- 月度黃曆：/almanac/month
- 農曆日期：/almanac/lunar

### 版本控制
- API 版本：v1
- 版本號格式：X-API-Version
- 客戶端版本：X-Client-Version

### 請求頭配置
```json
{
  "Accept": "application/json",
  "Content-Type": "application/json",
  "X-API-Key": "your_api_key",
  "X-API-Version": "v1",
  "X-Platform": "mobile",
  "X-Client-Version": "0.1.0"
}
```

## 緩存策略
- 運勢數據：12 小時
- 黃曆數據：7 天
- 配置數據：永久存儲

## 貢獻指南
1. Fork 項目
2. 創建特性分支
3. 提交更改
4. 推送到分支
5. 創建 Pull Request 