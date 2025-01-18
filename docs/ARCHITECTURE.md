# 系統架構設計

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

enum SortField {
  date,
  score,
  compatibility
}
```

#### 1.2 功能模塊
- 條件組合器：組合多個篩選條件
- 智能排序：根據用戶偏好排序結果
- 推薦引擎：基於用戶歷史數據推薦

### 2. 推送通知系統

#### 2.1 通知類型
```dart
enum NotificationType {
  dailyFortune,    // 每日運勢
  solarTerm,       // 節氣提醒
  luckyDay,        // 吉日提醒
  customEvent      // 自定義事件
}

class NotificationConfig {
  final NotificationType type;
  final TimeOfDay notifyTime;    // 提醒時間
  final bool isEnabled;          // 是否啟用
  final Map<String, dynamic> customData; // 自定義數據
}
```

#### 2.2 功能模塊
- 通知管理器：管理不同類型的通知
- 定時任務：處理定時通知
- 本地通知：處理本地推送
- 遠程通知：處理服務器推送

### 3. 指南針系統（基礎架構）

#### 3.1 數據結構
```dart
class DirectionInfo {
  final double bearing;          // 方位角度
  final String direction;        // 方位名稱
  final bool isLucky;           // 是否為吉方
  final String description;      // 方位說明
  final List<String> suitable;   // 適合事項
  final List<String> avoid;      // 避免事項
}

class CompassData {
  final DirectionInfo currentDirection;
  final List<DirectionInfo> luckyDirections;
  final List<DirectionInfo> unluckyDirections;
  final String advice;          // 趨吉避凶建議
}
```

#### 3.2 功能模塊
- 方位檢測：獲取當前方位
- 吉凶判斷：根據黃曆判斷方位吉凶
- 建議生成：生成趨吉避凶建議

## 用戶界面設計

### 1. 智能篩選界面
- 多條件選擇器
- 結果列表視圖
- 排序控制器
- 推薦卡片

### 2. 通知設置界面
- 通知類型開關
- 時間選擇器
- 自定義設置

### 3. 方位指示卡片（首頁）
- 當前方位指示
- 吉方/凶方提示
- 簡短建議

## 數據流設計

### 1. 智能篩選
```
用戶輸入 -> 條件組合器 -> 數據過濾 -> 智能排序 -> 結果展示
                      -> 用戶偏好存儲 -> 推薦引擎
```

### 2. 推送通知
```
配置設置 -> 通知管理器 -> 定時任務 -> 本地/遠程通知 -> 用戶設備
服務器事件 -> 遠程通知 -> 通知管理器 -> 本地通知 -> 用戶設備
```

### 3. 方位指示
```
傳感器數據 -> 方位檢測 -> 吉凶判斷 -> 建議生成 -> 界面更新
```

## 技術實現要點

### 1. 智能篩選
- 使用 Provider 管理篩選狀態
- 實現高效的數據過濾算法
- 本地存儲用戶偏好

### 2. 推送通知
- 使用 flutter_local_notifications
- 實現後台任務處理
- 處理各平台特定的通知權限

### 3. 方位指示
- 使用設備傳感器 API
- 實現方位計算邏輯
- 優化性能和電池消耗
