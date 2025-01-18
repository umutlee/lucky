import 'package:get/get.dart';
import '../../features/fortune/screens/daily_fortune_screen.dart';
import '../../features/calendar/screens/solar_term_screen.dart';
import '../../features/calendar/screens/lucky_day_screen.dart';

class AppRoutes {
  static const String dailyFortune = '/fortune/daily';
  static const String solarTerm = '/calendar/solar-term';
  static const String luckyDay = '/calendar/lucky-day';

  static final List<GetPage> pages = [
    GetPage(
      name: dailyFortune,
      page: () => const DailyFortuneScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: solarTerm,
      page: () => const SolarTermScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: luckyDay,
      page: () => const LuckyDayScreen(),
      transition: Transition.rightToLeft,
    ),
  ];

  // 路由中間件
  static final RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

  // 路由攔截器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case dailyFortune:
        return GetPageRoute(
          settings: settings,
          page: () => DailyFortuneScreen(date: args as DateTime?),
        );
      case solarTerm:
        if (args is Map<String, dynamic>) {
          return GetPageRoute(
            settings: settings,
            page: () => SolarTermScreen(
              date: DateTime.parse(args['date']),
              termName: args['term_name'],
            ),
          );
        }
        return null;
      case luckyDay:
        if (args is Map<String, dynamic>) {
          return GetPageRoute(
            settings: settings,
            page: () => LuckyDayScreen(
              date: DateTime.parse(args['date']),
              description: args['description'],
            ),
          );
        }
        return null;
      default:
        return null;
    }
  }
} 