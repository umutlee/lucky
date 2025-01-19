import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/route_generator.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/ui/screens/onboarding/onboarding_screen.dart';
import 'package:all_lucky/ui/screens/home/home_screen.dart';
import 'package:all_lucky/ui/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileService = ref.watch(userProfileServiceProvider);
    final hasProfile = userProfileService.currentProfile != null;

    return MaterialApp(
      title: '運勢預測',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: RouteGenerator.generateRoute,
      home: hasProfile ? const HomeScreen() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 