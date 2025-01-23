import 'package:flutter/material.dart';
import '../../fortune/pages/fortune_page.dart';
import '../../direction/pages/direction_page.dart';
import '../../history/pages/history_page.dart';
import '../../settings/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final _pages = const [
    FortunePage(),
    DirectionPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.stars),
            label: '運勢',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '方位',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '歷史',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
} 