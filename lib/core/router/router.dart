import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/sqlite_preferences_service.dart';
import '../providers/fortune_config_provider.dart';
import '../utils/page_transition_manager.dart';
import '../../features/onboarding/screens/identity_selection_screen.dart';
import '../../features/onboarding/screens/birth_info_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/identity_settings_screen.dart';

/// 路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  
  return GoRouter(
    initialLocation: '/identity',
    routes: [
      GoRoute(
        path: '/identity',
        pageBuilder: (context, state) => PageTransitionManager.createRoute(
          page: const IdentitySelectionScreen(),
          type: PageTransitionType.fade,
        ),
      ),
      GoRoute(
        path: '/birth-info',
        pageBuilder: (context, state) => PageTransitionManager.createRoute(
          page: const BirthInfoScreen(),
          type: PageTransitionType.slideAndFade,
          direction: TransitionDirection.left,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => PageTransitionManager.createRoute(
              page: const HomeScreen(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => PageTransitionManager.createRoute(
              page: const CalendarScreen(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => PageTransitionManager.createRoute(
              page: const SettingsScreen(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 200),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings/identity',
        pageBuilder: (context, state) => PageTransitionManager.createRoute(
          page: const IdentitySettingsScreen(),
          type: PageTransitionType.slideAndFade,
          direction: TransitionDirection.right,
        ),
      ),
    ],
  );
});

/// 獲取初始路由
Future<String> _getInitialLocation(SQLitePreferencesService prefsService) async {
  // 檢查是否首次打開應用
  final hasIdentity = await prefsService.getValue<bool>('has_identity') ?? false;
  final hasBirthInfo = await prefsService.getValue<bool>('has_birth_info') ?? false;
  
  if (!hasIdentity) {
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

class _ScaffoldWithBottomNavBarState extends ConsumerState<ScaffoldWithBottomNavBar> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  static const List<(String path, String label, IconData icon)> _tabs = [
    ('/home', '今日運勢', Icons.home),
    ('/calendar', '月曆', Icons.calendar_today),
    ('/settings', '設定', Icons.settings),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageTransitionManager.createController(
      this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = PageTransitionManager.createAnimation(
      controller: _controller,
      begin: 0.0,
      end: 1.0,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _controller.reverse().then((_) {
            context.go(_tabs[index].$1);
            _controller.forward();
          });
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