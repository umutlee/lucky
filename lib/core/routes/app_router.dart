import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/scene/screens/scene_selection_screen.dart';
import '../../features/scene/screens/scene_details_screen.dart';
import '../../ui/screens/fortune/fortune_detail_screen.dart';
import '../models/scene.dart';
import '../models/fortune_type.dart';

class AppRouter {
  static const String home = '/';
  static const String sceneSelection = '/scene-selection';
  static const String sceneDetails = '/scene-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      
      case sceneSelection:
        return MaterialPageRoute(
          builder: (_) => const SceneSelectionScreen(),
        );
      
      case sceneDetails:
        final args = settings.arguments as Map<String, dynamic>;
        final sceneId = args['sceneId'] as String;
        return MaterialPageRoute(
          builder: (_) => SceneDetailsScreen(sceneId: sceneId),
        );
      
      case '/fortune/detail':
        final args = settings.arguments as ({
          FortuneType type,
          DateTime date,
          String? zodiac,
          String? targetZodiac,
        });
        return MaterialPageRoute(
          builder: (_) => FortuneDetailScreen(
            type: args.type,
            date: args.date,
            zodiac: args.zodiac,
            targetZodiac: args.targetZodiac,
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('找不到路由: ${settings.name}'),
            ),
          ),
        );
    }
  }
} 