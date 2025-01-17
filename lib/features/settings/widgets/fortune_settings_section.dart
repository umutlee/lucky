import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../../../core/providers/study_fortune_provider.dart';
import '../../../core/providers/career_fortune_provider.dart';
import '../../../core/providers/love_fortune_provider.dart';

class FortuneSettingsSection extends ConsumerWidget {
  const FortuneSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(fortuneConfigProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFortuneTypeSetting(
          context,
          ref,
          title: '學業運勢',
          subtitle: '顯示學習效率、記憶力、考試運等指標',
          icon: Icons.school,
          isEnabled: config.isVisible('study'),
          onChanged: (value) => ref.read(fortuneConfigProvider.notifier)
              .toggleVisibility('study'),
          notificationProvider: studyFortuneNotificationProvider,
        ),
        const SizedBox(height: 16),
        _buildFortuneTypeSetting(
          context,
          ref,
          title: '事業運勢',
          subtitle: '顯示工作效率、人際關係、財運等指標',
          icon: Icons.work,
          isEnabled: config.isVisible('career'),
          onChanged: (value) => ref.read(fortuneConfigProvider.notifier)
              .toggleVisibility('career'),
          notificationProvider: careerFortuneNotificationProvider,
        ),
        const SizedBox(height: 16),
        _buildFortuneTypeSetting(
          context,
          ref,
          title: '愛情運勢',
          subtitle: '顯示桃花指數、告白時機、約會建議等指標',
          icon: Icons.favorite,
          isEnabled: config.isVisible('love'),
          onChanged: (value) => ref.read(fortuneConfigProvider.notifier)
              .toggleVisibility('love'),
          notificationProvider: loveFortuneNotificationProvider,
        ),
      ],
    );
  }

  Widget _buildFortuneTypeSetting(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isEnabled,
    required void Function(bool) onChanged,
    required StateNotifierProvider<NotificationNotifier, bool> notificationProvider,
  }) {
    final theme = Theme.of(context);
    final notificationEnabled = ref.watch(notificationProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onChanged,
                ),
              ],
            ),
            if (isEnabled) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '每日通知',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Switch(
                    value: notificationEnabled,
                    onChanged: (value) {
                      ref.read(notificationProvider.notifier).toggle();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 