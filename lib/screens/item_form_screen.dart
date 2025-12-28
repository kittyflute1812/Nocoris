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
    _itemService = widget.itemService ?? await ItemService.create();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate() && _itemService != null) {
      final name = _nameController.text;
      final count = int.parse(_countController.text);

      if (widget.item != null) {
        // 編集モード
        await _itemService!.updateItem(widget.item!.id, count);
      } else {
        // 作成モード
        await _itemService!.createItem(name, count);
      }

      if (mounted) {
        Navigator.of(context).pop();
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
