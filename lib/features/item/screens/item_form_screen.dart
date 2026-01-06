import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/emoji_picker_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

/// アイテムの作成・編集フォーム画面
class ItemFormScreen extends ConsumerStatefulWidget {
  final Item? item;

  const ItemFormScreen({
    super.key,
    this.item,
  });

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  /// フォームフィールドの初期化
  void _initializeFormFields() {
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _countController.text = widget.item!.count.toString();
      _selectedIcon = widget.item!.icon;
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

  /// アイコン選択ボトムシートを表示
  Future<void> _showIconPicker() async {
    final icon = await showEmojiPickerBottomSheet(
      context: context,
      currentEmoji: _selectedIcon,
    );
    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  /// アイテムを保存
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final name = _nameController.text;
      final count = int.parse(_countController.text);
      final itemService = ref.read(itemServiceProvider);

      final success = widget.item != null
          ? await _updateItem(itemService, count)
          : await _createItem(itemService, name, count);

      if (mounted && success) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar('${AppStrings.genericError}: ${e.toString()}');
    }
  }

  /// 既存アイテムを更新
  Future<bool> _updateItem(itemService, int count) async {
    final success = await itemService.updateItem(
      widget.item!.id,
      count,
      icon: _selectedIcon,
    );
    if (!success && mounted) {
      _showErrorSnackBar(AppStrings.updateError);
    }
    return success;
  }

  /// 新しいアイテムを作成
  Future<bool> _createItem(itemService, String name, int count) async {
    await itemService.createItem(name, count, icon: _selectedIcon);
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
            onPressed: _saveItem,
            tooltip: AppStrings.saveItemTooltip,
          ),
        ],
      ),
      body: _ItemForm(
        formKey: _formKey,
        nameController: _nameController,
        countController: _countController,
        selectedIcon: _selectedIcon,
        onIconTap: _showIconPicker,
        isEditMode: widget.item != null,
      ),
    );
  }

  /// タイトルを取得
  String _getTitle() {
    return widget.item != null ? AppStrings.editItem : AppStrings.newItem;
  }
}

/// アイテムフォームウィジェット
class _ItemForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController countController;
  final String? selectedIcon;
  final VoidCallback onIconTap;
  final bool isEditMode;

  const _ItemForm({
    required this.formKey,
    required this.nameController,
    required this.countController,
    required this.selectedIcon,
    required this.onIconTap,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _IconSelector(
            selectedIcon: selectedIcon,
            onTap: onIconTap,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
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

/// アイコン選択ウィジェット
class _IconSelector extends StatelessWidget {
  final String? selectedIcon;
  final VoidCallback onTap;

  const _IconSelector({
    required this.selectedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: selectedIcon != null
                    ? Text(
                        selectedIcon!,
                        style: const TextStyle(fontSize: 32),
                      )
                    : Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'アイコン',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedIcon != null ? 'タップして変更' : 'タップして選択',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
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
