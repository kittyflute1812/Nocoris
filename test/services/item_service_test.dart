import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_counter/services/storage_service.dart';
import 'package:drop_counter/services/item_service.dart';

void main() {
  group('ItemService Tests', () {
    late ItemService itemService;
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      itemService = ItemService(storageService);
    });

    test('createItem()が正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      
      expect(item.name, 'Test Item');
      expect(item.count, 5);
      expect(itemService.items.length, 1);
      expect(itemService.items.first.id, item.id);
    });

    test('getItemById()が正しく動作すること', () async {
      final createdItem = await itemService.createItem('Test Item', 5);
      final foundItem = itemService.getItemById(createdItem.id);
      
      expect(foundItem, isNotNull);
      expect(foundItem!.name, 'Test Item');
      expect(foundItem.count, 5);
    });

    test('存在しないIDのgetItemById()がnullを返すこと', () {
      final item = itemService.getItemById('non_existent_id');
      expect(item, null);
    });

    test('updateItem()が正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final result = await itemService.updateItem(item.id, 10);
      
      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, 10);
    });

    test('存在しないIDのupdateItem()がfalseを返すこと', () async {
      final result = await itemService.updateItem('non_existent_id', 10);
      expect(result, false);
    });

    test('deleteItem()が正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final initialLength = itemService.items.length;
      
      final result = await itemService.deleteItem(item.id);
      
      expect(result, true);
      expect(itemService.items.length, initialLength - 1);
      expect(itemService.getItemById(item.id), null);
    });

    test('存在しないIDのdeleteItem()がfalseを返すこと', () async {
      final result = await itemService.deleteItem('non_existent_id');
      expect(result, false);
    });

    test('incrementItem()が正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final initialCount = item.count;
      
      final result = await itemService.incrementItem(item.id);
      
      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, initialCount + 1);
    });

    test('decrementItem()が正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final initialCount = item.count;
      
      final result = await itemService.decrementItem(item.id);
      
      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, initialCount - 1);
    });

    test('count=0の場合のdecrementItem()が値を変更しないこと', () async {
      final item = await itemService.createItem('Test Item', 0);
      
      final result = await itemService.decrementItem(item.id);
      
      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, 0);
    });
  });
}
