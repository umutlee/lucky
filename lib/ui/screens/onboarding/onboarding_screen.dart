import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/user_onboarding.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/ui/screens/onboarding/welcome_page.dart';
import 'package:all_lucky/ui/screens/onboarding/user_type_page.dart';
import 'package:all_lucky/ui/screens/onboarding/basic_info_page.dart';
import 'package:all_lucky/ui/screens/onboarding/preference_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<GlobalKey<State>> _pageKeys = List.generate(4, (_) => GlobalKey());
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomePage(key: _pageKeys[0]),
                  UserTypePage(key: _pageKeys[1]),
                  BasicInfoPage(key: _pageKeys[2]),
                  PreferencePage(key: _pageKeys[3]),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('上一步'),
            )
          else
            const SizedBox(width: 80),
          _buildPageIndicator(),
          TextButton(
            onPressed: () => _handleNextPage(),
            child: Text(_currentPage < 3 ? '下一步' : '完成'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  void _handleNextPage() {
    if (_currentPage < 3) {
      // 驗證當前頁面
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeOnboarding();
    }
  }

  bool _validateCurrentPage() {
    final currentPageWidget = _pageKeys[_currentPage].currentState;
    if (_currentPage == 2 && currentPageWidget is _BasicInfoPageState) {
      return currentPageWidget.validateAndSave();
    } else if (_currentPage == 3 && currentPageWidget is _PreferencePageState) {
      return currentPageWidget.savePreferences();
    }
    return true;
  }

  void _completeOnboarding() {
    if (_validateCurrentPage()) {
      // 完成引導流程
      ref.read(userProfileServiceProvider).completeOnboarding();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
} 