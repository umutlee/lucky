import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 應用程序文字樣式主題
class AppTextStyles {
  // 標題樣式
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.onBackground,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.onBackground,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.onBackground,
  );

  // 標題樣式
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  static const titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  static const titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // 正文樣式
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: AppColors.onBackground,
    height: 1.4,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: AppColors.onBackground,
    height: 1.3,
  );

  // 標籤樣式
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onBackground,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onBackground,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onBackground,
  );

  // 運勢相關樣式
  static TextStyle fortuneScore(double score) {
    final color = score >= 0.8
        ? AppColors.fortuneExcellent
        : score >= 0.6
            ? AppColors.fortuneGood
            : score >= 0.4
                ? AppColors.fortuneNormal
                : AppColors.fortuneBad;

    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static const fortuneTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 0.15,
  );

  static const fortuneDescription = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.6,
    letterSpacing: 0.5,
  );

  static const fortuneDetail = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.4,
    letterSpacing: 0.25,
  );
} 