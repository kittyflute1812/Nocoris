import 'package:flutter/material.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import '../screens/item_form_screen.dart';
import '../../../common/widgets/error_view.dart';
import '../../../common/widgets/loading_view.dart';
import '../../../common/widgets/empty_state_view.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

/// メイン画面
/// 
/// アイテム一覧の表示と、アイテムの追加・編集・削除機能を提供します。
class HomeScreen extends StatefulWidget {
  final ItemService? itemService;

  const HomeScreen({super.key, this.itemService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ItemService _itemService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.itemService != null) {
      _itemService = widget.itemService!;
      _isLoading = false;
    } else {
      _initializeItemService();
    }
  }

  /// ItemServiceの初期化
  Future<void> _initializeItemService() async {
    try {
      _itemService = await ItemService.create();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${AppStrings.initializationError}: ${e.toString()}';
        });
      }
    }
  }

  /// アイテム作成/編集画面を表示
  Future<void> _showItemFormDialog([String? itemId]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(
          item: itemId != null ? _itemService.getItemById(itemId) : null,
          itemService: _itemService,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  /// アイテムの削除確認
  Future<void> _showDeleteConfirmation(String itemId) async {
    final item = _itemService.getItemById(itemId);
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
    try {
      await _itemService.deleteItem(itemId);
      if (mounted) {
        setState(() {});
      }
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
      if (mounted) {
        setState(() {});
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// ボディ部分を構築
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          _initializeItemService();
        },
      );
    }

    if (_itemService.items.isEmpty) {
      return EmptyStateView(
        message: AppStrings.noItems,
        actionLabel: AppStrings.addItem,
        onAction: () => _showItemFormDialog(),
        icon: Icons.inventory_2_outlined,
      );
    }

    return _ItemList(
      itemService: _itemService,
      onDecrement: (itemId) => _handleCountChange(
        itemId,
        () => _itemService.decrementItem(itemId),
      ),
      onIncrement: (itemId) => _handleCountChange(
        itemId,
        () => _itemService.incrementItem(itemId),
      ),
      onEdit: _showItemFormDialog,
      onDelete: _showDeleteConfirmation,
    );
  }

  /// フローティングアクションボタンを構築
  Widget? _buildFloatingActionButton() {
    if (_isLoading) return null;

    return FloatingActionButton(
      onPressed: () => _showItemFormDialog(),
      tooltip: AppStrings.addItem,
      child: const Icon(Icons.add),
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
      title: const Text(AppStrings.deleteItemTitle),
      content: Text(AppStrings.deleteItemMessage(itemName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            AppStrings.delete,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

