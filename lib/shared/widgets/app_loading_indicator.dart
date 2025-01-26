import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/loading_state_provider.dart';

class AppLoadingIndicator extends ConsumerWidget {
  final bool overlay;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? size;

  const AppLoadingIndicator({
    super.key,
    this.overlay = false,
    this.backgroundColor,
    this.progressColor,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loadingState = ref.watch(loadingStateProvider);

    if (!loadingState.isLoading) {
      return const SizedBox.shrink();
    }

    final indicator = _buildLoadingIndicator(
      context,
      loadingState,
      theme,
    );

    if (overlay) {
      return Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: backgroundColor ?? Colors.black54,
          ),
          Center(child: indicator),
        ],
      );
    }

    return indicator;
  }

  Widget _buildLoadingIndicator(
    BuildContext context,
    LoadingState state,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.progress != null) ...[
            SizedBox(
              width: size ?? 100,
              height: size ?? 100,
              child: CircularProgressIndicator(
                value: state.progress,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? theme.colorScheme.primary,
                ),
                strokeWidth: 4.0,
              ),
            ),
          ] else ...[
            SizedBox(
              width: size ?? 50,
              height: size ?? 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? theme.colorScheme.primary,
                ),
                strokeWidth: 4.0,
              ),
            ),
          ],
          if (state.message != null) ...[
            const SizedBox(height: 16.0),
            Text(
              state.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 