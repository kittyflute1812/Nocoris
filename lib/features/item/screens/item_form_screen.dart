import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../../../common/widgets/error_view.dart';
import '../../../common/widgets/loading_view.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

/// アイテムの作成・編集フォーム画面
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
    _initializeFormFields();
  }

  /// ItemServiceの初期化
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
          _errorMessage = '${AppStrings.initializationError}: ${e.toString()}';
        });
      }
    }
  }

  /// フォームフィールドの初期化
  void _initializeFormFields() {
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _countController.text = widget.item!.count.toString();
    } else {
      _countController.text = AppConstants.minCount.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }

  /// アイテムを保存
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate() || _itemService == null) {
      return;
    }

    try {
      final name = _nameController.text;
      final count = int.parse(_countController.text);

      final success = widget.item != null
          ? await _updateItem(count)
          : await _createItem(name, count);

      if (mounted && success) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar('${AppStrings.genericError}: ${e.toString()}');
    }
  }

  /// 既存アイテムを更新
  Future<bool> _updateItem(int count) async {
    final success = await _itemService!.updateItem(widget.item!.id, count);
    if (!success && mounted) {
      _showErrorSnackBar(AppStrings.updateError);
    }
    return success;
  }

  /// 新しいアイテムを作成
  Future<bool> _createItem(String name, int count) async {
    await _itemService!.createItem(name, count);
    return true;
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
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveItem,
            tooltip: AppStrings.saveItemTooltip,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// タイトルを取得
  String _getTitle() {
    return widget.item != null ? AppStrings.editItem : AppStrings.newItem;
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

    return _ItemForm(
      formKey: _formKey,
      nameController: _nameController,
      countController: _countController,
      isEditMode: widget.item != null,
    );
  }
}

/// アイテムフォームウィジェット
class _ItemForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController countController;
  final bool isEditMode;

  const _ItemForm({
    required this.formKey,
    required this.nameController,
    required this.countController,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _ItemNameField(
            controller: nameController,
            enabled: !isEditMode,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _ItemCountField(
            controller: countController,
          ),
        ],
      ),
    );
  }
}

/// アイテム名入力フィールド
class _ItemNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _ItemNameField({
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: AppStrings.itemNameLabel,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.itemNameRequired;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      autofocus: true,
      enabled: enabled,
      maxLength: AppConstants.maxNameLength,
    );
  }
}

/// アイテムカウント入力フィールド
class _ItemCountField extends StatelessWidget {
  final TextEditingController controller;

  const _ItemCountField({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: AppStrings.countLabel,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.countRequired;
        }
        final number = int.tryParse(value);
        if (number == null || number < AppConstants.minCount) {
          return AppStrings.countValidation;
        }
        return null;
      },
    );
  }
}

