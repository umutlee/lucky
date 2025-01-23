import 'package:flutter/material.dart';

/// 自定義按鈕組件
class CustomButton extends StatelessWidget {
  /// 按鈕文字
  final String text;

  /// 點擊回調
  final VoidCallback onPressed;

  /// 構造函數
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
} 