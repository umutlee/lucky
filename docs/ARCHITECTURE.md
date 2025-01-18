# 系統架構設計

## MVP 階段範圍

### 1. 核心功能
- 運勢預測計算
- 黃曆查詢服務
- 智能篩選系統
- 本地推送通知

### 2. 基礎架構
- Flutter 框架
- Node.js 後端
- 狀態管理 (Riverpod)
- 本地存儲
- 錯誤處理
- 日誌系統

### 3. MVP 通知系統設計

#### 3.1 功能範圍
```dart
class NotificationFeatures {
  static const core = {
    'dailyFortune': true,    // 每日運勢
    'solarTerm': true,       // 節氣提醒
    'luckyDay': true,        // 吉日提醒
    'widget': false,         // Widget功能（延後）
    'remoteSync': false,     // 遠程同步（延後）
    'interaction': false,    // 互動功能（延後）
  };
}
```

#### 3.2 通知流程
```
用戶設置 -> 本地調度 -> 內容生成 -> 通知觸發 -> 點擊處理
```

#### 3.3 錯誤處理
```dart
class NotificationError {
  final String code;
  final String message;
  final ErrorLevel level;
  
  // MVP階段主要處理：
  // - 權限錯誤
  // - 調度失敗
  // - 觸發失敗
}
```

## 整體架構

### 前端架構 (Flutter)
```
lib/
├── core/                 # 核心功能
│   ├── models/          # 數據模型
│   ├── services/        # 業務服務
│   ├── providers/       # 狀態管理
│   ├── utils/           # 工具類
│   └── routes/          # 路由管理
├── features/            # 功能模塊
│   ├── fortune/         # 運勢相關
│   ├── calendar/        # 日曆相關
│   └── settings/        # 設置相關
└── widgets/             # 共用組件
```

### 後端架構 (Node.js)
```
server/
├── src/
│   ├── models/          # 數據模型
│   ├── services/        # 業務服務
│   ├── routes/          # API路由
│   ├── middleware/      # 中間件
│   └── utils/          # 工具類
└── tests/              # 測試文件
```

## 功能模塊設計

### 1. 智能篩選系統

#### 1.1 數據結構
```dart
class FilterCriteria {
  final FortuneType? fortuneType;    // 運勢類型（總運/學業/事業/愛情）
  final List<String>? luckyDirections; // 吉方位
  final int? minScore;               // 最低分數
  final int? maxScore;               // 最高分數
  final List<String>? activities;    // 適合活動
  final bool? isLuckyDay;           // 是否為吉日
  final DateTime? startDate;         // 起始日期
  final DateTime? endDate;           // 結束日期
}

class SortOption {
  final SortField field;            // 排序欄位
  final SortOrder order;            // 排序方式
}
```

#### 1.2 核心服務
- FilterService: 實現篩選邏輯
- RecommendationService: 實現推薦算法
- CacheService: 實現結果緩存

### 2. 通知系統

#### 2.1 數據結構
```dart
class NotificationSettings {
  final bool enableDailyFortune;    // 每日運勢通知
  final bool enableSolarTerm;       // 節氣提醒
  final bool enableLuckyDay;        // 吉日提醒
  final TimeOfDay notificationTime; // 通知時間
}
```

#### 2.2 核心服務
- NotificationService: 通知管理
- SchedulerService: 定時任務
- ContentGenerator: 通知內容生成

### 3. 運勢預測系統

#### 3.1 數據結構
```dart
class Fortune {
  final FortuneType type;
  final int score;
  final DateTime date;
  final bool isLuckyDay;
  final List<String> luckyDirections;
  final List<String> suitableActivities;
}
```

#### 3.2 核心服務
- FortuneService: 運勢計算
- AlmanacService: 黃曆查詢
- IntegrationService: 數據整合

## 技術實現

### 1. 狀態管理
使用 Riverpod 進行狀態管理，主要包括：
- 全局狀態：主題、用戶設置等
- 業務狀態：運勢數據、篩選條件等
- UI狀態：加載狀態、錯誤提示等

### 2. 數據持久化
- SharedPreferences: 用戶設置
- SQLite: 本地數據緩存
- Hive: 高性能數據存儲

### 3. 網絡請求
- Dio: HTTP客戶端
- Retrofit: API接口生成
- JsonSerializable: JSON序列化

### 4. 錯誤處理
```dart
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});
}
```

### 5. 日誌系統
```dart
class Logger {
  final String tag;
  
  void info(String message);
  void warning(String message);
  void error(String message, {dynamic error});
}
```

## 性能優化

### 1. 緩存策略
- 內存緩存：運勢數據、篩選結果
- 本地緩存：用戶設置、歷史記錄
- API緩存：網絡請求結果

### 2. 懶加載
- 圖片懶加載
- 列表分頁加載
- 模塊按需加載

### 3. 並發處理
- 異步操作優化
- 並發請求控制
- 後台任務管理

## 安全性設計

### 1. 數據安全
- 敏感數據加密
- 安全存儲機制
- 數據備份恢復

### 2. 網絡安全
- HTTPS加密
- 請求簽名驗證
- 防重放攻擊

### 3. 應用安全
- 代碼混淆
- 應用加固
- 越獄檢測
