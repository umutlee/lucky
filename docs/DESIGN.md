# MVP 設計文檔

## 1. 架構概覽

### 1.1 技術棧
- 前端框架：Flutter 3.27.2
- 狀態管理：Riverpod
- 本地存儲：SQLite + SharedPreferences
- 網絡請求：Dio
- 國際化：intl

### 1.2 核心模組
```
lib/
├── app/                      # 應用核心
│   ├── app.dart             # 應用入口點
│   └── theme.dart           # 主題配置
├── features/                 # 功能模組
│   ├── calendar/            # 日曆相關
│   │   ├── models/         # 數據模型
│   │   ├── providers/      # 狀態管理
│   │   ├── repositories/   # 數據操作
│   │   ├── services/       # 業務邏輯
│   │   └── views/          # UI 組件
│   ├── settings/           # 設置相關
│   └── fortune/            # 運勢相關
└── shared/                  # 共享資源
    ├── widgets/            # 共用組件
    └── utils/              # 工具函數
```

## 2. 核心功能設計

### 2.1 今日視圖
- **數據模型**：
  ```dart
  class DailyInfo {
    final DateTime solarDate;    // 公曆日期
    final String lunarDate;      // 農曆日期
    final List<String> suitable; // 宜
    final List<String> avoid;    // 忌
    final String fortune;        // 運勢
  }
  ```

- **主要組件**：
  - 日期顯示卡片
  - 宜忌列表
  - 運勢概覽
  - 方位指示器

### 2.2 月曆視圖
- **數據模型**：
  ```dart
  class MonthView {
    final List<DailyInfo> days;
    final String monthLunar;
    final List<String> festivals;
  }
  ```

- **主要組件**：
  - 月曆網格
  - 日期詳情彈窗
  - 節日標記

### 2.3 設置功能
- 個人信息設置
- 推送通知設置
- 主題切換
- 字體大小調整

## 3. 數據流

### 3.1 本地數據
- 使用 SQLite 存儲黃曆基礎數據
- 使用 SharedPreferences 存儲用戶設置

### 3.2 網絡數據
- 中華萬年曆 API 獲取宜忌數據
- 星座 API 獲取運勢數據
- 實現數據緩存機制

## 4. UI/UX 設計原則

### 4.1 設計語言
- 遵循 Material Design 3
- 支持淺色/深色主題
- 適配不同屏幕尺寸

### 4.2 交互原則
- 重要信息優先展示
- 手勢操作順暢
- 提供清晰的視覺反饋

## 5. 測試策略

### 5.1 單元測試
- 數據轉換邏輯
- 日期計算功能
- 數據模型驗證

### 5.2 集成測試
- API 調用流程
- 數據持久化
- 狀態管理

## 6. 性能目標
- 應用啟動時間 < 2秒
- 頁面切換延遲 < 100ms
- 離線可用
- 數據緩存機制

## 7. 安全考慮
- 敏感數據本地加密
- API 調用限流
- 錯誤處理機制

## 8. 後續擴展計劃
- 社交分享功能
- 自定義主題
- 更多曆法支持
- 高級會員功能 