# 測試文檔

## MVP 版本測試重點

### 優先級 1：核心功能測試
1. **運勢計算功能**
   - 計算準確性
   - 數據一致性
   - 邊界條件處理

2. **數據存儲功能**
   - 本地存儲可靠性
   - 數據加密安全性
   - 備份恢復功能

3. **推送通知功能**
   - 通知觸發機制
   - 權限管理
   - 定時任務可靠性

### 優先級 2：性能測試
1. **啟動性能**
   - 冷啟動時間 < 2秒
   - 熱啟動時間 < 1秒
   - 首頁渲染時間 < 500ms

2. **運行性能**
   - 內存使用 < 100MB
   - CPU 使用率 < 30%
   - 電池消耗正常

3. **響應性能**
   - 頁面切換時間 < 300ms
   - 操作響應時間 < 100ms
   - 動畫流暢度 > 60fps

### 優先級 3：穩定性測試
1. **異常處理**
   - 網絡異常恢復
   - 數據異常處理
   - 權限變更處理

2. **長時間運行**
   - 24小時穩定性
   - 內存泄漏檢測
   - 性能衰減監控

## 測試策略

### 測試層級
1. **單元測試**
   - 模型類測試
   - 服務類測試
   - 工具類測試
   - Provider 測試

2. **集成測試**
   - API 整合測試
   - 數據庫操作測試
   - 狀態管理測試

3. **UI 測試**
   - 頁面渲染測試
   - 用戶交互測試
   - 主題切換測試

4. **性能測試**
   - 啟動時間測試
   - 內存使用測試
   - API 響應時間測試

## 測試用例

### 1. 運勢計算測試
```dart
void main() {
  group('運勢計算測試', () {
    test('基礎運勢計算', () {
      final calculator = FortuneCalculator();
      final result = calculator.calculate(
        date: DateTime.now(),
        type: FortuneType.daily,
      );
      
      expect(result.score, inRange(0, 100));
      expect(result.level, isNotNull);
      expect(result.description, isNotEmpty);
    });

    test('綜合運勢計算', () {
      final calculator = FortuneCalculator();
      final result = calculator.calculateOverall(
        date: DateTime.now(),
        userProfile: mockUserProfile,
      );
      
      expect(result.overall, inRange(0, 100));
      expect(result.details, hasLength(greaterThan(0)));
    });
  });
}
```

### 2. 數據存儲測試
```dart
void main() {
  group('SQLite 存儲測試', () {
    late SQLiteService sqliteService;
    
    setUp(() async {
      sqliteService = await SQLiteService.initialize();
    });
    
    test('保存設置', () async {
      final success = await sqliteService.saveSetting(
        key: 'theme_mode',
        value: 'dark',
      );
      expect(success, isTrue);
      
      final value = await sqliteService.getSetting('theme_mode');
      expect(value, equals('dark'));
    });
    
    test('批量操作', () async {
      final success = await sqliteService.batchSave([
        Setting('key1', 'value1'),
        Setting('key2', 'value2'),
      ]);
      expect(success, isTrue);
      
      final values = await sqliteService.getMultiple(['key1', 'key2']);
      expect(values, hasLength(2));
    });
  });
}
```

### 3. API 測試
```dart
void main() {
  group('API 客戶端測試', () {
    late ApiClient apiClient;
    
    setUp(() {
      apiClient = ApiClient(baseUrl: 'https://api.test.com');
    });
    
    test('獲取每日運勢', () async {
      final response = await apiClient.getDailyFortune(
        date: DateTime.now(),
        type: FortuneType.daily,
      );
      
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
    });
    
    test('錯誤處理', () async {
      expect(
        () => apiClient.getDailyFortune(date: null),
        throwsA(isA<InvalidParameterException>()),
      );
    });
  });
}
```

### 4. UI 測試
```dart
void main() {
  group('首頁測試', () {
    testWidgets('運勢卡片顯示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FortuneScreen(),
        ),
      );
      
      expect(find.byType(FortuneCard), findsOneWidget);
      expect(find.text('今日運勢'), findsOneWidget);
    });
    
    testWidgets('運勢詳情交互', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FortuneScreen(),
        ),
      );
      
      await tester.tap(find.byType(FortuneCard));
      await tester.pumpAndSettle();
      
      expect(find.byType(FortuneDetailScreen), findsOneWidget);
    });
  });
}
```

## 運勢類型測試

### FortuneType 枚舉測試
測試 `FortuneType` 枚舉的所有功能：

```dart
void main() {
  group('FortuneType Tests', () {
    test('基本類型檢查', () {
      expect(FortuneType.daily.isDaily, isTrue);
      expect(FortuneType.study.isDaily, isFalse);
    });

    test('職業類型檢查', () {
      expect(FortuneType.study.isCareer, isTrue);
      expect(FortuneType.work.isCareer, isTrue);
      expect(FortuneType.daily.isCareer, isFalse);
    });

    test('從字符串創建', () {
      expect(FortuneType.fromString('daily'), equals(FortuneType.daily));
      expect(FortuneType.fromString('invalid'), isNull);
    });

    test('圖標路徑檢查', () {
      expect(FortuneType.daily.iconName, equals('assets/icons/fortune_daily.png'));
    });
  });
}
```

### 測試覆蓋要求
- 枚舉值完整性測試
- 類型檢查方法測試
- 字符串轉換測試
- 圖標路徑驗證
- 分類名稱驗證

### MVP 版本測試重點
優先完成以下測試：
1. ✅ 基本運勢類型判斷
2. ✅ 特殊運勢類型判斷
3. ⏳ 運勢預測準確性驗證
4. ⏳ 用戶設置與運勢關聯測試

## MVP 版本性能指標

### 1. 啟動性能
- 冷啟動時間 < 2秒
- 熱啟動時間 < 1秒
- 首頁渲染時間 < 500ms

### 2. 運行性能
- 內存使用峰值 < 100MB
- 穩定運行內存 < 60MB
- CPU 使用率 < 30%
- 電池消耗 < 5%/小時

### 3. 操作響應
- 頁面切換 < 300ms
- 按鈕響應 < 100ms
- 列表滾動 > 60fps
- 動畫流暢度 > 60fps

### 4. 網絡性能
- API 響應 < 1秒
- 圖片載入 < 2秒
- 離線啟動 < 1秒
- 弱網絡適應性良好

## 測試覆蓋率要求

### MVP 版本覆蓋率
- 核心功能：100%
- 業務邏輯：> 90%
- UI 組件：> 80%
- 工具類：> 95%

### 測試優先級
1. 核心功能測試（必須）
   - 運勢計算邏輯
   - 數據存儲功能
   - 推送通知功能

2. 性能測試（必須）
   - 啟動性能
   - 運行性能
   - 操作響應

3. 穩定性測試（必須）
   - 異常處理
   - 長時間運行
   - 弱網絡環境

4. UI 測試（重要）
   - 頁面渲染
   - 用戶交互
   - 動畫效果

5. 安全性測試（重要）
   - 數據加密
   - 權限管理
   - 敏感信息

## 更新記錄

### 2024-03-21
- 添加 MVP 版本測試重點
- 更新性能指標要求
- 調整測試優先級
- 完善測試用例說明