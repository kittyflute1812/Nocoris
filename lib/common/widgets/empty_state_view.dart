import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 空状態表示用の共通ウィジェット
class EmptyStateView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyStateView({
    required this.message, super.key,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppConstants.errorIconSize,
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

