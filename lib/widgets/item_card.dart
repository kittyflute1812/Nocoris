import 'package:flutter/material.dart';
import '../models/item.dart';

/// アイテムの情報を表示し、基本的な操作を提供するカードウィジェット
///
/// 表示する情報:
/// - アイテム名
/// - 現在の残数
/// - 増減ボタン
/// - 編集・削除メニュー
///
/// アクセシビリティ:
/// - 増減ボタンには適切なセマンティックラベルが設定されています
/// - メニューボタンはスクリーンリーダーでアクセス可能です
class ItemCard extends StatelessWidget {
  /// カードの内部パディング
  static const double _padding = 16.0;
  
  /// 要素間のスペース
  static const double _spacing = 8.0;
  
  /// アイテムデータ
  final Item item;
  
  /// 減算ボタンが押された時のコールバック
  final VoidCallback onDecrement;
  
  /// 加算ボタンが押された時のコールバック
  final VoidCallback onIncrement;
  
  /// 編集ボタンが押された時のコールバック
  final VoidCallback onEdit;
  
  /// 削除ボタンが押された時のコールバック
  final VoidCallback onDelete;

  /// コンストラクタ
  ///
  /// [item]の[count]は0以上である必要があります
  ItemCard({
    super.key,
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
    required this.onDelete,
  }) : assert(item.count >= 0, 'Count must be non-negative');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: _padding,
        vertical: _spacing,
      ),
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: _spacing),
            _buildCounterSection(context),
          ],
        ),
      ),
    );
  }

  /// ヘッダー部分（アイテム名とメニュー）を構築
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
            semanticsLabel: 'アイテム名: ${item.name}',
          ),
        ),
        _buildMenuButton(),
      ],
    );
  }

  /// メニューボタンを構築
  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      tooltip: 'アイテムの操作メニュー',
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
          child: Text('編集'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('削除'),
        ),
      ],
    );
  }

  /// カウンター部分（残数と増減ボタン）を構築
  Widget _buildCounterSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '残数: ${item.count}',
          style: Theme.of(context).textTheme.titleMedium,
          semanticsLabel: '残数: ${item.count}個',
        ),
        _buildCounterButtons(),
      ],
    );
  }

  /// 増減ボタンを構築
  Widget _buildCounterButtons() {
    return Row(
      children: [
        Semantics(
          label: '残数を1つ減らす',
          button: true,
          enabled: item.count > 0,
          child: IconButton(
            icon: const Icon(Icons.remove),
            onPressed: item.count > 0 ? onDecrement : null,
            tooltip: '残数を1つ減らす',
          ),
        ),
        Semantics(
          label: '残数を1つ増やす',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
            tooltip: '残数を1つ増やす',
          ),
        ),
      ],
    );
  }
}
