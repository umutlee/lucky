import 'package:flutter/material.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/scene/scene_selection_screen.dart';
import '../../ui/screens/scene/scene_detail_screen.dart';
import '../models/scene.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case '/scene':
        return MaterialPageRoute(builder: (_) => const SceneSelectionScreen());
      
      case '/scene/detail':
        final scene = settings.arguments as Scene;
        return MaterialPageRoute(
          builder: (_) => SceneDetailScreen(scene: scene),
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