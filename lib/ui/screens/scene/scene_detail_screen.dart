import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scene.dart';
import '../../../core/providers/scene_provider.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';

class SceneDetailScreen extends ConsumerWidget {
  final Scene scene;

  const SceneDetailScreen({super.key, required this.scene});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ErrorBoundary(
        child: CustomScrollView(
          slivers: [
            // 頂部圖片和標題
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(scene.name),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      scene.imageAsset,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.colorScheme.surface.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 場景描述
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '場景描述',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scene.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    
                    // 運勢分析按鈕
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // TODO: 開始運勢分析
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('開始運勢分析'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 相關建議
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '相關建議',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildSuggestionList(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionList(ThemeData theme) {
    final suggestions = _getSuggestions();
    
    return Column(
      children: suggestions.map((suggestion) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              suggestion.icon,
              color: theme.colorScheme.primary,
            ),
            title: Text(suggestion.title),
            subtitle: Text(suggestion.description),
          ),
        );
      }).toList(),
    );
  }

  List<SceneSuggestion> _getSuggestions() {
    switch (scene.type) {
      case 'study':
        return [
          SceneSuggestion(
            icon: Icons.school,
            title: '選擇適當的學習時間',
            description: '根據你的運勢，建議在上午進行重要的學習任務',
          ),
          SceneSuggestion(
            icon: Icons.book,
            title: '複習重點科目',
            description: '今日特別適合複習數學和科學相關科目',
          ),
        ];
      case 'career':
        return [
          SceneSuggestion(
            icon: Icons.work,
            title: '把握商務機會',
            description: '今日適合進行重要的商務談判或提出新想法',
          ),
          SceneSuggestion(
            icon: Icons.trending_up,
            title: '職業發展機會',
            description: '可以考慮更新個人簡歷或參加專業培訓',
          ),
        ];
      default:
        return [
          SceneSuggestion(
            icon: Icons.tips_and_updates,
            title: '保持積極心態',
            description: '相信自己，保持樂觀正面的態度',
          ),
        ];
    }
  }
}

class SceneSuggestion {
  final IconData icon;
  final String title;
  final String description;

  SceneSuggestion({
    required this.icon,
    required this.title,
    required this.description,
  });
} 