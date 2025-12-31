import 'package:flutter/material.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import '../screens/item_form_screen.dart';

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
    _itemService = await ItemService.create();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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

    if (result == true) {
      setState(() {});
    }
  }

  /// アイテムの削除確認
  Future<void> _showDeleteConfirmation(String itemId) async {
    final item = _itemService.getItemById(itemId);
    if (item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アイテムの削除'),
        content: Text('${item.name}を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _itemService.deleteItem(itemId);
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CountDrop'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _itemService.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'アイテムがありません',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showItemFormDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('アイテムを追加'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _itemService.items.length,
                  itemBuilder: (context, index) {
                    final item = _itemService.items[index];
                    return ItemCard(
                      key: ValueKey(item.id),
                      item: item,
                      onDecrement: () async {
                        if (!mounted) return;
                        try {
                          await _itemService.decrementItem(item.id);
                          if (mounted) {
                            setState(() {});
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('エラーが発生しました: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      onIncrement: () async {
                        if (!mounted) return;
                        try {
                          await _itemService.incrementItem(item.id);
                          if (mounted) {
                            setState(() {});
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('エラーが発生しました: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      onEdit: () => _showItemFormDialog(item.id),
                      onDelete: () => _showDeleteConfirmation(item.id),
                    );
                  },
                ),
      floatingActionButton: !_isLoading
          ? FloatingActionButton(
              onPressed: () => _showItemFormDialog(),
              tooltip: 'アイテムを追加',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
