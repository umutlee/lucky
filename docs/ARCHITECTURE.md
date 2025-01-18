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

## 通知系統 (Notification System)

### MVP 版本功能
1. **本地通知實現**
   - 每日運勢提醒（固定文案）
   - 節氣變化提醒（基礎提示）
   - 吉日提醒（簡單提示）

2. **基礎配置管理**
   - 通知開關設置
   - 提醒時間設置
   - 提前提醒天數設置

3. **通知處理**
   - 基礎點擊響應
   - 簡單的錯誤處理
   - 本地存儲配置

### 後續迭代計劃

#### 第二階段：通知內容優化
1. **通知模板系統**
   - 設計模板數據結構
   - 實現模板引擎
   - 支持變量替換
   - 多語言支持

2. **個性化內容**
   - 根據用戶生辰八字定制
   - 結合星座運勢
   - 整合農曆節日
   - 特殊節日提醒

3. **智能推送策略**
   - 用戶活躍時間分析
   - 推送頻率優化
   - 重要性分級
   - 免打擾時段

#### 第三階段：後端集成
1. **通知管理後台**
   - 模板管理界面
   - 推送規則配置
   - 用戶分群管理
   - 效果數據分析

2. **數據分析系統**
   - 通知送達率統計
   - 點擊率追蹤
   - 用戶行為分析
   - A/B 測試支持

3. **高級功能**
   - 多設備同步
   - 跨平台推送
   - 緊急通知通道
   - 離線消息隊列

#### 第四階段：商業化功能
1. **會員特權**
   - 更多通知類型
   - 自定義通知模板
   - 優先推送級別
   - 高級分析報告

2. **廣告整合**
   - 推廣消息通道
   - 精準投放策略
   - 廣告效果追蹤
   - ROI 分析

3. **社交功能**
   - 分享通知內容
   - 群組通知
   - 互動反饋
   - 社交推薦

### 技術考量
1. **性能優化**
   - 本地緩存策略
   - 網絡請求優化
   - 電池使用優化
   - 存儲空間管理

2. **安全性**
   - 通知加密
   - 用戶授權管理
   - 敏感信息保護
   - 防濫用機制

3. **可擴展性**
   - 模塊化設計
   - 插件化架構
   - 服務解耦
   - 容錯機制

### 開發優先級
1. MVP 基礎功能（當前階段）
2. 通知內容優化
3. 後端服務集成
4. 商業化功能

### 注意事項
1. 確保通知不打擾用戶
2. 保護用戶隱私
3. 遵守平台規範
4. 優化用戶體驗
