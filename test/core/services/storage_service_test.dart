import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nocoris/core/services/storage_service.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
    });

    test('saveJson()とloadJson()が正しく動作すること', () async {
      const testKey = 'test_key';
      final testData = {'name': 'Test', 'value': 42};

      await storageService.saveJson(testKey, testData);
      final loadedData = storageService.loadJson(testKey);

      expect(loadedData, testData);
    });

    test('存在しないキーのloadJson()がnullを返すこと', () {
      final loadedData = storageService.loadJson('non_existent_key');
      expect(loadedData, null);
    });

    test('saveJsonList()とloadJsonList()が正しく動作すること', () async {
      const testKey = 'test_list';
      final testList = [
        {'id': '1', 'name': 'Item 1'},
        {'id': '2', 'name': 'Item 2'},
      ];

      await storageService.saveJsonList(testKey, testList);
      final loadedList = storageService.loadJsonList(testKey);

      expect(loadedList, testList);
    });

    test('存在しないキーのloadJsonList()がnullを返すこと', () {
      final loadedList = storageService.loadJsonList('non_existent_list');
      expect(loadedList, null);
    });

    test('saveItems()とloadItems()が正しく動作すること', () async {
      final testItems = [
        {'id': '1', 'name': 'Item 1', 'count': 1},
        {'id': '2', 'name': 'Item 2', 'count': 2},
      ];

      await storageService.saveItems(testItems);
      final loadedItems = storageService.loadItems();

      expect(loadedItems, testItems);
    });

    test('アイテムが保存されていない場合のloadItems()がnullを返すこと', () {
      final loadedItems = storageService.loadItems();
      expect(loadedItems, null);
    });
  });
}
