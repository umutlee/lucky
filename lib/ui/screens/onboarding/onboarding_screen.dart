import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/ui/screens/onboarding/welcome_page.dart';
import 'package:all_lucky/ui/screens/onboarding/user_type_page.dart';
import 'package:all_lucky/ui/screens/onboarding/basic_info_page.dart';
import 'package:all_lucky/ui/screens/onboarding/preference_page.dart';
import 'package:all_lucky/core/utils/logger.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  int _currentPage = 0;
  bool _isLoading = false;
  final _logger = Logger('OnboardingScreen');

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(userProfileServiceProvider).init();
      _logger.info('用戶配置服務初始化成功');
    } catch (e) {
      _logger.error('用戶配置服務初始化失敗: $e');
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
    _animationController.dispose();
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
      
      // 更新進度動畫
      _progressAnimation = Tween<double>(
        begin: _currentPage * 0.25,
        end: (_currentPage + 1) * 0.25,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0);

      await _pageController.nextPage(
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
          behavior: SnackBarBehavior.floating,
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
      _logger.info('完成引導流程');
      
      if (mounted) {
        Navigator.of(context).pop(); // 關閉加載對話框
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _logger.error('保存用戶設置失敗: $e');
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
            // 進度指示器
            LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
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
                    TextButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentPage--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('上一步'),
                    )
                  else
                    const SizedBox(width: 100),
                  Row(
                    children: List.generate(4, (index) => 
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage 
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleNextPage,
                    icon: Icon(_currentPage == 3 ? Icons.check : Icons.arrow_forward),
                    label: Text(_currentPage == 3 ? '完成' : '下一步'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
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