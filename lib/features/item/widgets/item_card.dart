import 'package:flutter/material.dart';
import '../models/item.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

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

  const ItemCard({
    super.key,
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultSpacing,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemCardHeader(
              item: item,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
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
        Expanded(
          child: Text(
            item.name,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
            semanticsLabel: AppStrings.itemNameSemantics(item.name),
          ),
        ),
        _ItemCardMenu(
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

/// アイテムカードのメニューボタン
class _ItemCardMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCardMenu({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: AppStrings.itemMenuTooltip,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text(AppStrings.edit),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(AppStrings.delete),
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
        Text(
          '${AppStrings.remainingCount}: ${item.count}',
          style: Theme.of(context).textTheme.titleMedium,
          semanticsLabel: AppStrings.remainingCountSemantics(item.count),
        ),
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
        Semantics(
          label: AppStrings.decrementTooltip,
          button: true,
          enabled: count > 0,
          child: IconButton(
            icon: const Icon(Icons.remove),
            onPressed: count > 0 ? onDecrement : null,
            tooltip: AppStrings.decrementTooltip,
          ),
        ),
        Semantics(
          label: AppStrings.incrementTooltip,
          button: true,
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
            tooltip: AppStrings.incrementTooltip,
          ),
        ),
      ],
    );
  }
}

