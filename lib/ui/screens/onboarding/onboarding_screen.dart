import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    ref.read(userProfileServiceProvider).init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleNextPage() async {
    if (_currentPage == 3) {
      if (_validateCurrentPage()) {
        await _completeOnboarding();
      }
      return;
    }

    if (_validateCurrentPage()) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    if (_currentPage == 0) return true; // Welcome page doesn't need validation
    if (_currentPage == 1) return true; // User type page doesn't need form validation
    
    final formKey = _formKeys[_currentPage];
    return formKey.currentState?.validate() ?? false;
  }

  Future<void> _completeOnboarding() async {
    final userProfileService = ref.read(userProfileServiceProvider);
    await userProfileService.completeOnboarding();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  WelcomePage(),
                  UserTypePage(formKey: _formKeys[1]),
                  BasicInfoPage(formKey: _formKeys[2]),
                  PreferencePage(formKey: _formKeys[3]),
                ],
              ),
            ),
            Padding(
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
                        setState(() {
                          _currentPage--;
                        });
                      },
                      child: const Text('上一步'),
                    )
                  else
                    const SizedBox(width: 80),
                  Text('${_currentPage + 1}/4'),
                  ElevatedButton(
                    onPressed: _handleNextPage,
                    child: Text(_currentPage == 3 ? '完成' : '下一步'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 