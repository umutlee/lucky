import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences.dart';
import '../providers/fortune_config_provider.dart';
import '../../features/onboarding/screens/identity_selection_screen.dart';
import '../../features/onboarding/screens/birth_info_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/identity_selection_screen.dart';

/// 路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  
  return GoRouter(
    initialLocation: _getInitialLocation(prefs),
    routes: [
      GoRoute(
        path: '/identity',
        builder: (context, state) => const IdentitySelectionScreen(),
      ),
      GoRoute(
        path: '/birth-info',
        builder: (context, state) {
          final identity = state.extra as UserIdentity;
          return BirthInfoScreen(selectedIdentity: identity);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings/identity',
        builder: (context, state) => const IdentitySelectionScreen(),
      ),
    ],
  );
});

/// 獲取初始路由
String _getInitialLocation(SharedPreferences prefs) {
  // 檢查是否首次打開應用
  final hasSelectedIdentity = prefs.containsKey('user_identity');
  final hasBirthInfo = prefs.containsKey('birth_info');
  
  if (!hasSelectedIdentity) {
    return '/identity';
  } else if (!hasBirthInfo) {
    return '/birth-info';
  } else {
    return '/home';
  }
}

/// 底部導航欄腳手架
class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;

  static const List<(String path, String label, IconData icon)> _tabs = [
    ('/home', '今日運勢', Icons.home),
    ('/calendar', '月曆', Icons.calendar_today),
    ('/settings', '設定', Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_tabs[index].$1);
        },
        destinations: _tabs
            .map((tab) => NavigationDestination(
                  icon: Icon(tab.$3),
                  label: tab.$2,
                ))
            .toList(),
      ),
    );
  }
} 