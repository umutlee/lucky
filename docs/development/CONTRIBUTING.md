# 開發指南

## Git 工作流程

### 分支管理
- `main`: 主分支，只接受合併請求
- `develop`: 開發分支，所有功能分支都從這裡分出
- `feature/*`: 功能分支，例如 `feature/today-view`
- `bugfix/*`: 錯誤修復分支
- `release/*`: 發布分支

### 提交規範
提交信息格式：`<type>(<scope>): <subject>`

類型（type）：
- `feat`: 新功能
- `fix`: 錯誤修復
- `docs`: 文檔更新
- `style`: 代碼格式（不影響代碼運行的變動）
- `refactor`: 重構
- `test`: 測試相關
- `chore`: 構建過程或輔助工具的變動

範例：
```bash
feat(calendar): add lunar date display
fix(today): resolve date conversion issue
docs: update README with new features
```

### 開發流程
1. 從 `develop` 分支創建新的功能分支
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

2. 開發完成後，提交更改
```bash
git add .
git commit -m "feat(scope): your commit message"
git push origin feature/your-feature-name
```

3. 在 GitHub 上創建 Pull Request
4. 代碼審查通過後合併到 `develop` 分支

### 發布流程
1. 從 `develop` 分支創建發布分支
2. 測試和修復問題
3. 合併到 `main` 分支並打標籤
4. 合併回 `develop` 分支

## 開發環境設置
1. Flutter 3.27.2
2. Dart 3.6.1
3. VS Code 或 Android Studio
4. 必要的 Flutter 插件

## 代碼規範
- 使用 `flutter_lints` 規則
- 變數和函數使用駝峰命名法
- 類別使用大駝峰命名法
- 常量使用全大寫加下劃線
- 所有公開 API 都需要文檔註釋 