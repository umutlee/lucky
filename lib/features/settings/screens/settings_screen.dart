import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_identity_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdentity = ref.watch(userIdentityProvider);
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
          // 其他設置選項將在後續添加
        ],
      ),
    );
  }
} 