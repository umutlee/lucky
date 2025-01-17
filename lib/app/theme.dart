import 'package:flutter/material.dart';

/// 應用主題配置
/// 提供淺色和深色主題，以及自定義的顏色和文字樣式
class AppTheme {
  AppTheme._();

  /// 主要品牌顏色
  static const Color primaryColor = Color(0xFFE64A19);
  
  /// 次要品牌顏色
  static const Color secondaryColor = Color(0xFF2196F3);
  
  /// 背景顏色（淺色主題）
  static const Color backgroundLight = Color(0xFFFAFAFA);
  
  /// 背景顏色（深色主題）
  static const Color backgroundDark = Color(0xFF121212);

  /// 文字顏色（淺色主題）
  static const Color textLight = Color(0xFF212121);
  
  /// 文字顏色（深色主題）
  static const Color textDark = Color(0xFFE0E0E0);

  /// 卡片顏色（淺色主題）
  static const Color cardLight = Colors.white;
  
  /// 卡片顏色（深色主題）
  static const Color cardDark = Color(0xFF1E1E1E);

  /// 淺色主題
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundLight,
      ),
      textTheme: _buildTextTheme(textLight),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// 深色主題
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundDark,
      ),
      textTheme: _buildTextTheme(textDark),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: textDark,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// 構建文字主題
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      // 大標題，用於頁面主標題
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      // 中標題，用於區塊標題
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      // 小標題，用於卡片標題
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      // 正文文字
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
      // 次要文字
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textColor.withOpacity(0.87),
      ),
      // 說明文字
      bodySmall: TextStyle(
        fontSize: 12,
        color: textColor.withOpacity(0.75),
      ),
    );
  }
} 