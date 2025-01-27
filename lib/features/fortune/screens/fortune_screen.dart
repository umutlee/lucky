import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/fortune_filter.dart';
import '../widgets/fortune_list.dart';

class FortuneScreen extends ConsumerStatefulWidget {
  const FortuneScreen({super.key});

  @override
  ConsumerState<FortuneScreen> createState() => _FortuneScreenState();
}

class _FortuneScreenState extends ConsumerState<FortuneScreen> with SingleTickerProviderStateMixin {
  late AnimationController _filterController;
  late Animation<double> _filterAnimation;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _filterAnimation = CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
      if (_isFilterVisible) {
        _filterController.forward();
      } else {
        _filterController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          '運勢預測',
          style: AppTextStyles.titleLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _filterAnimation,
              color: theme.colorScheme.primary,
            ),
            onPressed: _toggleFilter,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: theme.colorScheme.primary,
            onPressed: () {
              // 重新載入運勢列表
              ref.invalidate(fortuneListProvider);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
          ),
          
          // 主要內容
          Column(
            children: [
              // 篩選器動畫
              SizeTransition(
                sizeFactor: _filterAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const FortuneFilter(),
                ),
              ),
              
              // 運勢列表
              const Expanded(
                child: FortuneList(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/fortune-prediction');
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
} 