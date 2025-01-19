import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/user_onboarding.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/ui/screens/onboarding/welcome_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
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
                children: const [
                  WelcomePage(),
                  _UserTypePage(),
                  _BasicInfoPage(),
                  _PreferencePage(),
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
            onPressed: () {
              if (_currentPage < 3) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeOnboarding();
              }
            },
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

  void _completeOnboarding() {
    // TODO: 完成引導流程，保存用戶資料
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('歡迎使用諸事大吉'),
    );
  }
}

class _UserTypePage extends StatelessWidget {
  const _UserTypePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('選擇使用模式'),
    );
  }
}

class _BasicInfoPage extends StatelessWidget {
  const _BasicInfoPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('輸入基本資料'),
    );
  }
}

class _PreferencePage extends StatelessWidget {
  const _PreferencePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('設置偏好'),
    );
  }
} 