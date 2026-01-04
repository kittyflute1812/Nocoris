import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/item.dart';
import '../../../core/services/storage_service.dart';

/// アイテムのビジネスロジックを管理するサービス
/// 
/// アイテムの作成、更新、削除、カウント操作を提供します。
/// ChangeNotifierを継承し、状態変更時にリスナーに通知します。
class ItemService extends ChangeNotifier {
  final Logger _logger = Logger();
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

  /// アイテムリストの不変コピーを取得
  List<Item> get items => List.unmodifiable(_items);

  /// IDでアイテムを検索
  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } on StateError {
      return null;
    }
  }

  /// 新しいアイテムを作成
  Future<Item> createItem(String name, int initialCount) async {
    final item = Item.create(name: name, initialCount: initialCount);
    _items.add(item);
    await _saveItems();
    notifyListeners();
    return item;
  }

  /// アイテムのカウントを更新
  Future<bool> updateItem(String id, int count) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return false;

    _items[index] = _items[index].setCount(count);
    await _saveItems();
    notifyListeners();
    return true;
  }

  /// アイテムを削除
  Future<bool> deleteItem(String id) async {
    final initialLength = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length != initialLength) {
      await _saveItems();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// アイテムのカウントを1減らす
  Future<bool> decrementItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return false;

    _items[index] = _items[index].decrement();
    await _saveItems();
    notifyListeners();
    return true;
  }

  /// アイテムのカウントを1増やす
  Future<bool> incrementItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return false;

    _items[index] = _items[index].increment();
    await _saveItems();
    notifyListeners();
    return true;
  }

  /// ストレージからアイテムを読み込み
  void _loadItems() {
    final itemsJson = _storage.loadItems();
    if (itemsJson != null) {
      _items = itemsJson
          .map((json) {
            try {
              return Item.fromJson(json);
            } catch (e) {
              _logger.e('Failed to load item: $e');
              return null;
            }
          })
          .whereType<Item>()
          .toList();
    }
  }

  /// アイテムをストレージに保存
  Future<void> _saveItems() async {
    final itemsJson = _items.map((item) => item.toJson()).toList();
    await _storage.saveItems(itemsJson);
  }
}
