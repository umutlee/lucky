import 'package:flutter/material.dart';
import 'package:all_lucky/core/utils/page_transitions.dart';
import 'package:all_lucky/ui/screens/home/home_screen.dart';
import 'package:all_lucky/ui/screens/onboarding/onboarding_screen.dart';
import 'package:all_lucky/ui/screens/settings/settings_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return PageTransitions.fadeTransition(
          page: const HomeScreen(),
        );
        
      case '/onboarding':
        return PageTransitions.slideTransition(
          page: const OnboardingScreen(),
          direction: SlideDirection.right,
        );
        
      case '/settings':
        return PageTransitions.slideTransition(
          page: const SettingsScreen(),
          direction: SlideDirection.left,
        );
        
      case '/fortune-detail':
        if (args is Map<String, dynamic>) {
          return PageTransitions.scaleTransition(
            page: FortuneDetailScreen(fortune: args),
          );
        }
        return _errorRoute();
        
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('錯誤'),
        ),
        body: const Center(
          child: Text('頁面不存在'),
        ),
      ),
    );
  }
} 