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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(userProfileServiceProvider).init();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('初始化失敗', '請檢查您的網絡連接並重試。');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
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
    if (_currentPage == 0) return true;
    if (_currentPage == 1) return true;
    
    final formKey = _formKeys[_currentPage];
    final isValid = formKey.currentState?.validate() ?? false;
    
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請檢查並填寫所有必填項'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    return isValid;
  }

  Future<void> _completeOnboarding() async {
    _showLoadingDialog();
    try {
      final userProfileService = ref.read(userProfileServiceProvider);
      await userProfileService.completeOnboarding();
      
      if (mounted) {
        Navigator.of(context).pop(); // 關閉加載對話框
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 關閉加載對話框
        _showErrorDialog('保存失敗', '無法保存您的設置，請稍後重試。');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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