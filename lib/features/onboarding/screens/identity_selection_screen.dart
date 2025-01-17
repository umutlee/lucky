import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_identity.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../../../core/theme/identity_theme.dart';
import 'birth_info_screen.dart';

/// 身份選擇頁面
class IdentitySelectionScreen extends ConsumerWidget {
  const IdentitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdentity = ref.watch(userIdentityProvider);
    final identities = UserIdentity.defaultIdentities;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('選擇你的身份'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final identity = identities[index];
                    final theme = IdentityTheme.getThemeForIdentity(identity.type);
                    final isSelected = currentIdentity.type == identity.type;

                    return _IdentityCard(
                      identity: identity,
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () => _selectIdentity(context, ref, identity),
                    );
                  },
                  childCount: identities.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.public),
                      label: const Text('訪客模式'),
                      onPressed: () => _enterGuestMode(context, ref),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '以訪客身份使用基本功能',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectIdentity(BuildContext context, WidgetRef ref, UserIdentity identity) async {
    final notifier = ref.read(userIdentityProvider.notifier);
    await notifier.updateIdentity(identity);
    
    if (context.mounted) {
      // 如果是從設置頁面進入，返回上一頁
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // 如果是首次選擇，導航到生辰八字輸入頁面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BirthInfoScreen(selectedIdentity: identity),
          ),
        );
      }
    }
  }

  void _enterGuestMode(BuildContext context, WidgetRef ref) async {
    // 設置訪客身份
    final notifier = ref.read(userIdentityProvider.notifier);
    await notifier.updateIdentity(UserIdentity(
      type: UserIdentityType.guest,
      name: '訪客',
      description: '體驗基本功能',
      icon: Icons.person_outline,
      tags: ['基本', '黃曆', '節氣'],
      languageStyle: LanguageStyle.modern,
    ));
    
    if (context.mounted) {
      context.go('/home');
    }
  }
}

/// 身份卡片
class _IdentityCard extends StatelessWidget {
  final UserIdentity identity;
  final IdentityTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _IdentityCard({
    required this.identity,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: theme.accentColor,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                identity.icon,
                size: 48,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                identity.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                identity.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: identity.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.backgroundColor,
                      ),
                    ),
                    backgroundColor: theme.accentColor,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 