# 諸事大吉 (All Lucky)

一款現代化的中國傳統黃曆應用，專注於為用戶提供準確的黃曆信息，並以簡潔直觀的方式呈現。

## 開發進度

### 已完成
- [x] 專案初始化
- [x] 基礎架構搭建
- [x] 路由系統配置
- [x] 主題系統配置
- [x] 錯誤處理機制
- [x] 開發環境配置
- [x] 數據模型設計（LunarDate、DailyFortune）
- [x] 工具類實現（DateConverter）
- [x] 服務層實現（LunarCalculator）
- [x] 數據倉庫層實現（AlmanacRepository、FortuneRepository）
- [x] 狀態管理層實現（Provider）
- [x] 首頁基礎 UI 組件（FortuneCard、LunarInfoCard）
- [x] 月曆視圖基礎組件（CalendarView、FortunePreview）

### 進行中
- [ ] API 整合
- [ ] 本地存儲實現
- [ ] 通知系統實現
- [ ] 設置頁面開發

### 待開發
- [ ] 主題切換功能
- [ ] 多語言支持
- [ ] 離線模式支持
- [ ] 小組件支持
- [ ] 分享功能
- [ ] 自定義提醒

## 功能特點

### MVP 版本
- 今日黃曆信息查看
- 月曆視圖
- 基礎查詢功能
- 個人設置

## 技術架構

### 前端框架
- Flutter 3.27.2
- Dart 3.6.1

### 主要依賴
- flutter_riverpod: ^2.4.9 - 狀態管理
- go_router: ^13.1.0 - 路由管理
- dio: ^5.4.0 - 網絡請求
- shared_preferences: ^2.2.2 - 本地設置存儲
- sqflite: ^2.3.0 - 本地數據庫
- path_provider: ^2.1.2 - 文件路徑管理
- intl: ^0.19.0 - 國際化支持

### 項目結構
```
lib/
├── main.dart                 # 應用入口
├── app/                      # 應用核心
│   ├── app.dart             # 應用配置
│   ├── router.dart          # 路由配置
│   └── theme.dart           # 主題配置
├── features/                 # 功能模組
│   ├── calendar/            # 日曆相關
│   ├── settings/            # 設置相關
│   └── fortune/             # 運勢相關
├── core/                    # 核心功能
│   ├── models/              # 數據模型
│   ├── services/            # 服務層
│   └── repositories/        # 數據倉庫
└── shared/                  # 共享組件
    ├── widgets/             # 共用組件
    └── utils/               # 工具函數
```

## 開發計劃

### 第一階段（MVP）- 4週
1. 週次一：基礎架構搭建 ✓
2. 週次二：今日視圖開發
3. 週次三：月曆視圖開發
4. 週次四：查詢功能與設置

### 數據來源
- 農曆計算：lunar-javascript
- 宜忌數據：中華萬年曆 API
- 運勢數據：開源星座 API

## 環境要求
- Flutter 3.27.2 或以上
- Dart 3.6.1 或以上
- iOS 12.0 或以上
- Android 5.0 (API 21) 或以上
- Java 17 (用於 Android 構建)

## 安裝說明
1. 克隆專案
```bash
git clone [repository-url]
```

2. 安裝依賴
```bash
flutter pub get
```

3. 運行應用
```bash
flutter run
```

## 開發環境設置
1. 安裝 Java 17
```bash
brew install openjdk@17
```

2. 配置 Java 環境
```bash
sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

3. 配置 Flutter 的 Java 路徑
```bash
flutter config --jdk-dir=/usr/local/opt/openjdk@17
```

## 貢獻指南
1. Fork 專案
2. 創建特性分支
3. 提交變更
4. 發起合併請求

## 授權協議
MIT License 