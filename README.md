# All Lucky - 現代化運勢指南

一款為年輕人打造的運勢諮詢應用，將傳統東方智慧以現代化方式呈現，幫助你在日常生活中做出更好的選擇。

## 主要特色

### 運勢計算核心 ✅
- 基礎運勢計算
- 生肖運勢計算
- 時間因素計算
- 運勢趨勢分析
- 運勢建議生成

### 資料管理系統 ✅
- API 資料獲取
- 本地緩存管理
- 資料預加載
- 錯誤處理機制

### 多語言支持 ✅
- 傳統文字風格
- 年輕人用語
- 場景化描述

### 每日運勢解讀 ⏳
- 黃曆日期查詢（現代化解讀）
- 今日宜忌指南（實用建議）
- 運勢提醒（工作、學習、愛情）
- 時間規劃建議

### 個人運勢分析 ⏳
- 生辰八字速查
- 流年運勢預測
- 星座運勢指南
- 生日密碼解析

### 生活指南 ⏳
- 考試選日助手
- 戀愛桃花指南
- 面試時機推薦
- 創業良機提示

### 互動功能 ⏳
- 運勢分享牆
- 好友互動系統
- 運勢打卡
- 心得交流

## 特色亮點

- 現代化解讀：用淺顯易懂的方式詮釋傳統文化
- 實用建議：針對學習、工作、感情等現代生活場景
- 精美介面：年輕化的設計風格
- 社交互動：分享、討論的社群功能
- 隱私保護：嚴格的用戶資料保護機制

## 開始使用

1. 下載安裝
- App Store：[開發中]
- Google Play：[開發中]

2. 快速上手
- 註冊登入
- 填寫基本資料（生日等）
- 獲取個人運勢報告
- 探索更多功能

## 技術特點

### 已完成 ✅
- Flutter 跨平台開發
- 智能緩存預取
- 運勢計算引擎
- 場景匹配系統
- 多語言風格支持
- 資料加密與同步
- 精確農曆計算（lunar）
- 完整節氣支持
- 八字五行分析

### 開發中 ⏳
- Material You 設計風格
- 離線運算支持
- 動態指南針效果
- 深色模式支持

## 專案結構

```
lib/
  ├── core/           # 核心功能
  │   ├── models/     # 資料模型
  │   ├── services/   # 核心服務
  │   │   ├── lunar_service.dart        # 農曆服務
  │   │   ├── astronomical_service.dart  # 天文服務
  │   │   ├── fortune_score_service.dart # 運勢評分
  │   │   └── calendar_service.dart      # 日曆服務
  │   └── utils/      # 工具類
  ├── features/       # 功能模組
  │   ├── daily/      # 每日運勢
  │   ├── personal/   # 個人分析
  │   └── scenes/     # 場景功能
  └── ui/            # 使用者介面
      ├── theme/      # 主題設計
      └── widgets/    # 共用元件
```

## 開發指南

### 環境配置
- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Android Studio / VS Code

### 開發流程
1. 克隆專案
```bash
git clone https://github.com/username/all-lucky.git
```

2. 安裝依賴
```bash
flutter pub get
```

3. 運行專案
```bash
dart run
```

## 文件

- [使用指南](docs/guides/README.md)
- [API 文檔](docs/api/README.md)
- [開發計劃](docs/mvp/README.md)
- [更新記錄](docs/PROGRESS.md)
- [儲存策略](docs/STORAGE_POLICY.md)

## 參與貢獻

歡迎提交 Issue 和 Pull Request，請參考 [貢獻指南](CONTRIBUTING.md)。

## 授權協議

本專案採用 MIT 授權 - 詳見 [LICENSE](LICENSE) 文件。 