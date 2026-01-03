import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class ItemFormScreen extends StatefulWidget {
  final Item? item;
  final ItemService? itemService;

  const ItemFormScreen({
    super.key,
    this.item,
    this.itemService,
  });

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  ItemService? _itemService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeItemService();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _countController.text = widget.item!.count.toString();
    } else {
      _countController.text = '0';  // デフォルト値を設定
    }
  }

  Future<void> _initializeItemService() async {
    try {
      _itemService = widget.itemService ?? await ItemService.create();
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
          _errorMessage = '初期化に失敗しました: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate() || _itemService == null) {
      return;
    }

    try {
      final name = _nameController.text;
      final count = int.parse(_countController.text);

      bool success = false;
      if (widget.item != null) {
        // 編集モード
        success = await _itemService!.updateItem(widget.item!.id, count);
        if (!success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('アイテムの更新に失敗しました。アイテムが削除された可能性があります。'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      } else {
        // 作成モード
        await _itemService!.createItem(name, count);
        success = true;
      }

      if (mounted && success) {
        Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? 'アイテムを編集' : '新しいアイテム'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveItem,
            tooltip: 'アイテムを保存',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 18, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _initializeItemService();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('再試行'),
                      ),
                    ],
                  ),
                )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'アイテム名',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'アイテム名を入力してください';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    enabled: widget.item == null,  // 編集モードでは名前を変更不可
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _countController,
                    decoration: const InputDecoration(
                      labelText: '値',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '値を入力してください';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number < 0) {
                        return '0以上の数値を入力してください';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
