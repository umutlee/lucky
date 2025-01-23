import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_identity.dart';
import '../../../core/providers/user_identity_provider.dart';
import '../../../core/theme/identity_theme.dart';
import '../../../core/router/router.dart';
import '../../../core/widgets/custom_button.dart';

/// 身份設置畫面
class IdentitySettingsScreen extends ConsumerWidget {
  /// 構造函數
  const IdentitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改身份'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '選擇你的身份',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: '學生',
                onPressed: () {
                  ref.read(routerProvider).go('/student');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '老師',
                onPressed: () {
                  ref.read(routerProvider).go('/teacher');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IdentitySelectionScreen extends ConsumerWidget {
  const IdentitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdentity = ref.watch(userIdentityProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇身份'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: UserIdentity.defaultIdentities.length,
        itemBuilder: (context, index) {
          final identity = UserIdentity.defaultIdentities[index];
          final isSelected = currentIdentity.type == identity.type;
          final identityTheme = IdentityTheme.getThemeForIdentity(identity.type);

          return _IdentityCard(
            identity: identity,
            isSelected: isSelected,
            theme: identityTheme,
            onTap: () {
              ref.read(userIdentityProvider.notifier).updateIdentity(identity);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final UserIdentity identity;
  final bool isSelected;
  final IdentityTheme theme;
  final VoidCallback onTap;

  const _IdentityCard({
    required this.identity,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: theme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  color: theme.primaryColor,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: identity.tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: theme.primaryColor,
        ),
      ),
    );
  }
} 