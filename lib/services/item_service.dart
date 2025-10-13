import 'package:logger/logger.dart';

import '../models/item.dart';
import 'storage_service.dart';

class ItemService {
  final _logger = Logger();
  final StorageService _storage;
  List<Item> _items = [];

  ItemService(this._storage) {
    _loadItems();
  }

  /// StorageServiceを初期化して新しいItemServiceを作成
  static Future<ItemService> create() async {
    final storage = await StorageService.create();
    return ItemService(storage);
  }

  List<Item> get items => List.unmodifiable(_items);

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } on StateError {
      return null;
    }
  }

  Future<Item> createItem(String name, int initialCount) async {
    final item = Item.create(name: name, initialCount: initialCount);
    _items.add(item);
    await _saveItems();
    return item;
  }

  Future<bool> updateItem(String id, int count) async {
    final item = getItemById(id);
    if (item == null) return false;

    item.setCount(count);
    await _saveItems();
    return true;
  }

  Future<bool> deleteItem(String id) async {
    final initialLength = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length != initialLength) {
      await _saveItems();
      return true;
    }
    return false;
  }

  Future<bool> decrementItem(String id) async {
    final item = getItemById(id);
    if (item == null) return false;

    item.decrement();
    await _saveItems();
    return true;
  }

  Future<bool> incrementItem(String id) async {
    final item = getItemById(id);
    if (item == null) return false;

    item.increment();
    await _saveItems();
    return true;
  }

  void _loadItems() {
    final itemsJson = _storage.loadItems();
    if (itemsJson != null) {
      _items = itemsJson.map((json) {
        try {
          return Item.fromJson(json);
        } catch (e) {
          _logger.e('Failed to load item: $e');
          return null;
        }
      }).whereType<Item>().toList();
    }
  }

  Future<void> _saveItems() async {
    final itemsJson = _items.map((item) => item.toJson()).toList();
    await _storage.saveItems(itemsJson);
  }
}
