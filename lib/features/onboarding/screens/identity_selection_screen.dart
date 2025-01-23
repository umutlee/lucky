import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/router.dart';
import '../../../core/widgets/custom_button.dart';

/// 身份選擇畫面
class IdentitySelectionScreen extends ConsumerWidget {
  /// 構造函數
  const IdentitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '選擇你的身份',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: '學生',
                onPressed: () {
                  ref.read(routerProvider).go('/student');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '老師',
                onPressed: () {
                  ref.read(routerProvider).go('/teacher');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 