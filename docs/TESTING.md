# 測試文檔

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

## 性能測試指標

### 1. 啟動性能
- 冷啟動時間 < 2秒
- 熱啟動時間 < 1秒
- 首頁渲染時間 < 500ms

### 2. 內存使用
- 正常使用 < 100MB
- 後台運行 < 50MB
- 無內存泄漏

### 3. API 性能
- 請求響應時間 < 1秒
- 錯誤率 < 1%
- 並發處理能力 > 100 QPS

## 測試覆蓋率要求

### 代碼覆蓋率
- 模型類：> 90%
- 服務類：> 85%
- UI 組件：> 80%
- 工具類：> 95%

### 功能覆蓋率
- 核心功能：100%
- 業務邏輯：> 90%
- 異常處理：> 95%
- UI 交互：> 85%

## 更新記錄

### 2024-03-21
- 添加性能測試指標
- 完善 UI 測試用例
- 更新測試覆蓋率要求
- 補充異常處理測試 