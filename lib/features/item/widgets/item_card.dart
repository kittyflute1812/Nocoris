import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../models/item.dart';

/// アイテムの情報を表示し、基本的な操作を提供するカードウィジェット
///
/// 表示する情報:
/// - アイテム名
/// - 現在の残数
/// - 増減ボタン
/// - 編集・削除メニュー
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const ItemCard({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
    required this.onDelete,
    super.key,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    // インデックスに基づいてカードの背景色を変える
    final backgroundColor = AppColors.getCardBackground(index);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultSpacing,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppConstants.cardBorderRadius * 1.5,
        ),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemCardHeader(item: item, onEdit: onEdit, onDelete: onDelete),
            const SizedBox(height: AppConstants.defaultSpacing * 1.5),
            _ItemCardCounter(
              item: item,
              onDecrement: onDecrement,
              onIncrement: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

/// アイテムカードのヘッダー部分（アイテム名とメニュー）
class _ItemCardHeader extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCardHeader({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // アイコン表示
        if (item.icon != null) ...[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(item.icon!, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Text(
            item.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
            overflow: TextOverflow.ellipsis,
            semanticsLabel: AppStrings.itemNameSemantics(item.name),
          ),
        ),
        _ItemCardMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }
}

/// アイテムカードのメニューボタン
class _ItemCardMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCardMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: AppStrings.itemMenuTooltip,
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: AppColors.primary),
              SizedBox(width: 12),
              Text(AppStrings.edit),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: AppColors.error),
              SizedBox(width: 12),
              Text(AppStrings.delete),
            ],
          ),
        ),
      ],
    );
  }
}

/// アイテムカードのカウンター部分（残数と増減ボタン）
class _ItemCardCounter extends StatelessWidget {
  final Item item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ItemCardCounter({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 残数表示
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: Row(
            children: [
              Text(
                '${AppStrings.remainingCount}: ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${item.count}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                semanticsLabel: AppStrings.remainingCountSemantics(item.count),
              ),
            ],
          ),
        ),
        // 増減ボタン
        _CounterButtons(
          count: item.count,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
        ),
      ],
    );
  }
}

/// カウンターの増減ボタン
class _CounterButtons extends StatelessWidget {
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CounterButtons({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 減算ボタン
        Semantics(
          label: AppStrings.decrementTooltip,
          button: true,
          enabled: count > 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: count > 0 ? onDecrement : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: count > 0 ? AppColors.primary : AppColors.borderLight,
                  shape: BoxShape.circle,
                  boxShadow: count > 0
                      ? const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.remove,
                  color: count > 0 ? Colors.white : AppColors.textTertiary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 加算ボタン
        Semantics(
          label: AppStrings.incrementTooltip,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onIncrement,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
