import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/utils/logger.dart';

class PreferencePage extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  const PreferencePage({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: formKey,
      child: const Center(
        child: Text('偏好設置頁面'),
      ),
    );
  }
} 