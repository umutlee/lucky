import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/ui/screens/onboarding/welcome_page.dart';
import 'package:all_lucky/ui/screens/onboarding/user_type_page.dart';
import 'package:all_lucky/ui/screens/onboarding/basic_info_page.dart';
import 'package:all_lucky/ui/screens/onboarding/preference_page.dart';
import 'package:all_lucky/core/utils/logger.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歡迎'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('開始使用運勢預測'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: 實現用戶資料保存
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('開始使用'),
            ),
          ],
        ),
      ),
    );
  }
} 