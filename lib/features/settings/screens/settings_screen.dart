import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_identity_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../widgets/fortune_settings_section.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdentity = ref.watch(userIdentityProvider);
    final themeMode = ref.watch(themeModeProvider);
    final fortuneConfig = ref.watch(fortuneConfigProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('身份設置'),
            subtitle: Text(currentIdentity.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/identity'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('主題設置'),
            subtitle: Text(themeMode == ThemeMode.light ? '淺色主題' : '深色主題'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '運勢設置',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const FortuneSettingsSection(),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知設置'),
            subtitle: const Text('管理運勢提醒和其他通知'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // 其他設置選項將在後續添加
        ],
      ),
    );
  }
} 