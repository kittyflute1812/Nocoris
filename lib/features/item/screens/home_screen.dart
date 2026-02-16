import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/item_service.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import '../screens/item_form_screen.dart';
import '../../../common/widgets/error_view.dart';
import '../../../common/widgets/loading_view.dart';
import '../../../common/widgets/empty_state_view.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

/// メイン画面
///
/// アイテム一覧の表示と、アイテムの追加・編集・削除機能を提供します。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// アイテム作成/編集画面を表示
  Future<void> _showItemFormDialog([String? itemId]) async {
    final itemServiceAsync = ref.read(itemServiceInitProvider);
    final itemService = itemServiceAsync.value;
    if (itemService == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => itemService),
          ],
          child: ItemFormScreen(
            item: itemId != null ? itemService.getItemById(itemId) : null,
          ),
        ),
      ),
    );

    // 結果は不要（Providerが自動的に更新を通知）
    if (result == true && mounted) {
      // 何もしない - Providerが自動的に更新
    }
  }

  /// アイテムの削除確認
  Future<void> _showDeleteConfirmation(String itemId) async {
    final itemServiceAsync = ref.read(itemServiceInitProvider);
    final itemService = itemServiceAsync.value;
    if (itemService == null) return;

    final item = itemService.getItemById(itemId);
    if (item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(itemName: item.name),
    );

    if (confirmed == true) {
      await _deleteItem(itemId);
    }
  }

  /// アイテムを削除
  Future<void> _deleteItem(String itemId) async {
    final itemServiceAsync = ref.read(itemServiceInitProvider);
    final itemService = itemServiceAsync.value;
    if (itemService == null) return;

    try {
      await itemService.deleteItem(itemId);
    } catch (e) {
      _showErrorSnackBar('${AppStrings.genericError}: ${e.toString()}');
    }
  }

  /// アイテムのカウントを変更
  Future<void> _handleCountChange(
    String itemId,
    Future<bool> Function() operation,
  ) async {
    if (!mounted) return;
    try {
      await operation();
    } catch (e) {
      _showErrorSnackBar('${AppStrings.genericError}: ${e.toString()}');
    }
  }

  /// エラーメッセージを表示
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemServiceAsync = ref.watch(itemServiceInitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: itemServiceAsync.when(
        data: (itemService) {
          // ItemServiceが初期化されたら、ProviderScopeにオーバーライドして提供
          return ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => itemService),
            ],
            child: _HomeScreenBody(
              onShowItemFormDialog: _showItemFormDialog,
              onShowDeleteConfirmation: _showDeleteConfirmation,
              onHandleCountChange: _handleCountChange,
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: '${AppStrings.initializationError}: ${error.toString()}',
          onRetry: () {
            ref.invalidate(itemServiceInitProvider);
          },
        ),
      ),
      floatingActionButton: itemServiceAsync.maybeWhen(
        data: (_) => FloatingActionButton(
          onPressed: () => _showItemFormDialog(),
          tooltip: AppStrings.addItem,
          child: const Icon(Icons.add),
        ),
        orElse: () => null,
      ),
    );
  }
}

/// ホーム画面のボディ部分
class _HomeScreenBody extends ConsumerStatefulWidget {
  final Future<void> Function([String?]) onShowItemFormDialog;
  final Future<void> Function(String) onShowDeleteConfirmation;
  final Future<void> Function(String, Future<bool> Function())
      onHandleCountChange;

  const _HomeScreenBody({
    required this.onShowItemFormDialog,
    required this.onShowDeleteConfirmation,
    required this.onHandleCountChange,
  });

  @override
  ConsumerState<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends ConsumerState<_HomeScreenBody> {
  ItemService? _itemService;

  @override
  void initState() {
    super.initState();
    // ItemServiceの変更を監視
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemService = ref.read(itemServiceProvider);
      _itemService!.addListener(_onItemServiceChanged);
    });
  }

  @override
  void dispose() {
    // リスナーを削除
    _itemService?.removeListener(_onItemServiceChanged);
    super.dispose();
  }

  void _onItemServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemService = ref.read(itemServiceProvider);

    if (itemService.items.isEmpty) {
      return EmptyStateView(
        message: AppStrings.noItems,
        actionLabel: AppStrings.addItem,
        onAction: () => widget.onShowItemFormDialog(),
        icon: Icons.inventory_2_outlined,
      );
    }

    return _ItemList(
      itemService: itemService,
      onDecrement: (itemId) => widget.onHandleCountChange(
        itemId,
        () => itemService.decrementItem(itemId),
      ),
      onIncrement: (itemId) => widget.onHandleCountChange(
        itemId,
        () => itemService.incrementItem(itemId),
      ),
      onEdit: widget.onShowItemFormDialog,
      onDelete: widget.onShowDeleteConfirmation,
    );
  }
}

/// アイテムリスト表示ウィジェット
class _ItemList extends StatelessWidget {
  final ItemService itemService;
  final void Function(String) onDecrement;
  final void Function(String) onIncrement;
  final void Function(String) onEdit;
  final void Function(String) onDelete;

  const _ItemList({
    required this.itemService,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemService.items.length,
      itemBuilder: (context, index) {
        final item = itemService.items[index];
        return ItemCard(
          key: ValueKey(item.id),
          item: item,
          index: index,
          onDecrement: () => onDecrement(item.id),
          onIncrement: () => onIncrement(item.id),
          onEdit: () => onEdit(item.id),
          onDelete: () => onDelete(item.id),
        );
      },
    );
  }
}

/// 削除確認ダイアログ
class _DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;

  const _DeleteConfirmationDialog({required this.itemName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 28,
          ),
          SizedBox(width: 12),
          Text(AppStrings.deleteItemTitle),
        ],
      ),
      content: Text(AppStrings.deleteItemMessage(itemName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}
