import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/fortune/screens/daily_fortune_screen.dart';
import '../../features/calendar/screens/solar_term_screen.dart';
import '../../features/calendar/screens/lucky_day_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/widgets/error_screen.dart';
import '../../presentation/pages/cache_stats_page.dart';

class RouteParams {
  static Map<String, dynamic>? tryParseExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      return extra;
    }
    return null;
  }

  static DateTime? tryParseDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/fortune/daily',
      builder: (context, state) {
        final date = RouteParams.tryParseDate(state.extra);
        return DailyFortuneScreen(date: date);
      },
      pageBuilder: (context, state) {
        final date = RouteParams.tryParseDate(state.extra);
        return CustomTransitionPage(
          key: state.pageKey,
          child: DailyFortuneScreen(date: date),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/calendar/solar-term',
      builder: (context, state) {
        final params = RouteParams.tryParseExtra(state.extra);
        return SolarTermScreen(
          date: params?['date'] as DateTime? ?? DateTime.now(),
          termName: params?['term_name'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/calendar/lucky-day',
      builder: (context, state) {
        final params = RouteParams.tryParseExtra(state.extra);
        return LuckyDayScreen(
          date: params?['date'] as DateTime? ?? DateTime.now(),
          description: params?['description'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/cache-stats',
      builder: (context, state) => const CacheStatsPage(),
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(
    title: '找不到頁面',
    message: '無法找到路徑：${state.uri.path}',
    onRetry: () => context.go('/'),
  ),
); 