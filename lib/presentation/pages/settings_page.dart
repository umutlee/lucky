import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStorageSection(context),
        ],
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('緩存管理'),
      subtitle: const Text('查看緩存統計和清理緩存'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/cache-stats'),
    );
  }
} 