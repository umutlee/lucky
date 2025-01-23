import 'package:flutter/material.dart';
import '../models/user_identity.dart';

/// 身份主題配色
class IdentityTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color accentColor;

  const IdentityTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.accentColor,
  });

  /// 獲取默認主題配色
  static IdentityTheme defaultTheme() {
    return const IdentityTheme(
      primaryColor: Color(0xFF1976D2),    // 專業藍
      secondaryColor: Color(0xFF64B5F6),  // 淺藍
      backgroundColor: Color(0xFFFAFAFA), // 淺灰白
      cardColor: Color(0xFFFFFFFF),       // 白色
      textColor: Color(0xFF0D47A1),       // 深藍
      accentColor: Color(0xFFFF4081),     // 活力粉
    );
  }

  /// 獲取身份對應的主題配色
  static IdentityTheme getThemeForIdentity(UserIdentityType type) {
    switch (type) {
      case UserIdentityType.student:
        return const IdentityTheme(
          primaryColor: Color(0xFF4CAF50),    // 清新綠
          secondaryColor: Color(0xFF81C784),  // 淺綠
          backgroundColor: Color(0xFFF5F5F5), // 純淨白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF2E7D32),       // 深綠
          accentColor: Color(0xFFFFC107),     // 活力黃
        );
      
      case UserIdentityType.programmer:
        return const IdentityTheme(
          primaryColor: Color(0xFF212121),    // 深灰
          secondaryColor: Color(0xFF424242),  // 中灰
          backgroundColor: Color(0xFF121212), // 近黑
          cardColor: Color(0xFF1E1E1E),      // VSCode 背景色
          textColor: Color(0xFF66BB6A),      // Matrix 綠
          accentColor: Color(0xFF64B5F6),    // 科技藍
        );
      
      case UserIdentityType.worker:
        return const IdentityTheme(
          primaryColor: Color(0xFF1976D2),    // 專業藍
          secondaryColor: Color(0xFF64B5F6),  // 淺藍
          backgroundColor: Color(0xFFFAFAFA), // 淺灰白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF0D47A1),       // 深藍
          accentColor: Color(0xFFFF4081),     // 活力粉
        );

      case UserIdentityType.officeWorker:
        return const IdentityTheme(
          primaryColor: Color(0xFF546E7A),    // 沉穩灰藍
          secondaryColor: Color(0xFF78909C),  // 淺灰藍
          backgroundColor: Color(0xFFECEFF1), // 辦公室白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF263238),       // 深灰藍
          accentColor: Color(0xFF00BCD4),     // 清新藍
        );

      case UserIdentityType.engineer:
        return const IdentityTheme(
          primaryColor: Color(0xFF455A64),    // 工業灰
          secondaryColor: Color(0xFF607D8B),  // 淺工業灰
          backgroundColor: Color(0xFFEEEEEE), // 淺灰
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF263238),       // 深灰
          accentColor: Color(0xFFFF5722),     // 工程橙
        );

      case UserIdentityType.otaku:
        return const IdentityTheme(
          primaryColor: Color(0xFFE91E63),    // 動漫粉
          secondaryColor: Color(0xFFF48FB1),  // 淺粉
          backgroundColor: Color(0xFFFCE4EC), // 粉白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFFC2185B),       // 深粉
          accentColor: Color(0xFF9C27B0),     // 紫色
        );

      case UserIdentityType.fujoshi:
        return const IdentityTheme(
          primaryColor: Color(0xFF9C27B0),    // 腐紫
          secondaryColor: Color(0xFFBA68C8),  // 淺紫
          backgroundColor: Color(0xFFF3E5F5), // 紫白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF6A1B9A),       // 深紫
          accentColor: Color(0xFFE91E63),     // 粉紅
        );

      case UserIdentityType.traditional:
        return const IdentityTheme(
          primaryColor: Color(0xFF795548),    // 古典棕
          secondaryColor: Color(0xFFA1887F),  // 淺棕
          backgroundColor: Color(0xFFEFEBE9), // 米白
          cardColor: Color(0xFFFAF3E0),       // 宣紙色
          textColor: Color(0xFF3E2723),       // 深棕
          accentColor: Color(0xFFBF360C),     // 朱紅
        );

      case UserIdentityType.both:
        return const IdentityTheme(
          primaryColor: Color(0xFF673AB7),    // 知性紫
          secondaryColor: Color(0xFF9575CD),  // 淺紫
          backgroundColor: Color(0xFFEDE7F6), // 紫白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF4527A0),       // 深紫
          accentColor: Color(0xFF00BCD4),     // 科技藍
        );

      case UserIdentityType.elder:
        return const IdentityTheme(
          primaryColor: Color(0xFF607D8B),    // 沉穩灰
          secondaryColor: Color(0xFF90A4AE),  // 淺灰
          backgroundColor: Color(0xFFECEFF1), // 柔和白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF455A64),       // 深灰
          accentColor: Color(0xFF8D6E63),     // 溫暖棕
        );

      case UserIdentityType.fortune:
        return const IdentityTheme(
          primaryColor: Color(0xFF9C27B0),    // 神秘紫
          secondaryColor: Color(0xFFBA68C8),  // 淺紫
          backgroundColor: Color(0xFFF3E5F5), // 紫白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF6A1B9A),       // 深紫
          accentColor: Color(0xFFFFD700),     // 金色
        );

      case UserIdentityType.spiritual:
        return const IdentityTheme(
          primaryColor: Color(0xFF00BCD4),    // 靈性藍
          secondaryColor: Color(0xFF4DD0E1),  // 淺藍
          backgroundColor: Color(0xFFE0F7FA), // 天空白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF006064),       // 深藍
          accentColor: Color(0xFFFFEB3B),     // 光明黃
        );

      case UserIdentityType.teacher:
        return const IdentityTheme(
          primaryColor: Color(0xFF3F51B5),    // 知識藍
          secondaryColor: Color(0xFF7986CB),  // 淺藍
          backgroundColor: Color(0xFFE8EAF6), // 書頁白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF1A237E),       // 深藍
          accentColor: Color(0xFF4CAF50),     // 希望綠
        );

      case UserIdentityType.artist:
        return const IdentityTheme(
          primaryColor: Color(0xFF9C27B0),    // 藝術紫
          secondaryColor: Color(0xFFBA68C8),  // 淺紫
          backgroundColor: Color(0xFFF3E5F5), // 創意白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF6A1B9A),       // 深紫
          accentColor: Color(0xFFFF4081),     // 靈感粉
        );

      case UserIdentityType.guest:
        return const IdentityTheme(
          primaryColor: Color(0xFF9E9E9E),    // 中性灰
          secondaryColor: Color(0xFFBDBDBD),  // 淺灰
          backgroundColor: Color(0xFFFAFAFA), // 純白
          cardColor: Color(0xFFFFFFFF),       // 白色
          textColor: Color(0xFF616161),       // 深灰
          accentColor: Color(0xFF2196F3),     // 基礎藍
        );
    }
  }

  /// 創建 Material 主題
  ThemeData createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? Colors.white : Colors.black,
        secondary: secondaryColor,
        onSecondary: isDark ? Colors.white : Colors.black,
        background: backgroundColor,
        onBackground: textColor,
        surface: cardColor,
        onSurface: textColor,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: textColor),
        headlineMedium: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
      ),
    );
  }
} 