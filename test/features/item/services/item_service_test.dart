import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nocoris/core/services/storage_service.dart';
import 'package:nocoris/features/item/services/item_service.dart';

void main() {
  group('ItemService Tests', () {
    late ItemService itemService;
    late StorageService storageService;

    setUp(() async {
      // テストごとにSharedPreferencesをリセット
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      itemService = ItemService(storageService);
      // 既存のデータをクリア
      await Future.forEach(
        List.from(itemService.items),
        (item) => itemService.deleteItem(item.id),
      );
    });

    test('createItem()が正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5);

      expect(item.name, 'Test Item');
      expect(item.count, 5);
      expect(itemService.items.length, 1);
      expect(itemService.items.first.id, item.id);
    });

    test('createItem()がアイコン付きで正しく動作すること', () async {
      final item = await itemService.createItem('Test Item', 5, icon: '🐿️');

      expect(item.name, 'Test Item');
      expect(item.count, 5);
      expect(item.icon, '🐿️');
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
      // 名前を指定しない場合は既存の名前を維持
      expect(itemService.getItemById(item.id)!.name, 'Test Item');
    });

    test('updateItem()がアイコンを正しく更新すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final result = await itemService.updateItem(item.id, 10, icon: '🐿️');

      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, 10);
      expect(itemService.getItemById(item.id)!.icon, '🐿️');
      expect(itemService.getItemById(item.id)!.name, 'Test Item');
    });

    test('updateItem()が名前を正しく更新すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final result =
          await itemService.updateItem(item.id, 10, name: 'Updated Item');

      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, 10);
      expect(itemService.getItemById(item.id)!.name, 'Updated Item');
      expect(itemService.getItemById(item.id)!.icon, null);
    });

    test('updateItem()が名前とアイコンを同時に更新すること', () async {
      final item = await itemService.createItem('Test Item', 5, icon: '🎯');
      final result = await itemService.updateItem(item.id, 15,
          name: 'Updated Item', icon: '🐿️');

      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, 15);
      expect(itemService.getItemById(item.id)!.name, 'Updated Item');
      expect(itemService.getItemById(item.id)!.icon, '🐿️');
    });

    test('updateItem()で名前のみを更新すること（カウントとアイコンは維持）', () async {
      final item = await itemService.createItem('Test Item', 5, icon: '🎯');
      final originalCount = item.count;
      final originalIcon = item.icon;

      final result = await itemService.updateItem(item.id, originalCount,
          name: 'Updated Item');

      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, originalCount);
      expect(itemService.getItemById(item.id)!.name, 'Updated Item');
      expect(itemService.getItemById(item.id)!.icon, originalIcon);
    });

    test('updateItem()で名前を指定しない場合は既存の名前を維持すること', () async {
      final item = await itemService.createItem('Test Item', 5);
      final originalName = item.name;

      final result = await itemService.updateItem(item.id, 10);

      expect(result, true);
      expect(itemService.getItemById(item.id)!.count, 10);
      expect(itemService.getItemById(item.id)!.name, originalName);
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

    test('存在しないIDのincrementItem()がfalseを返すこと', () async {
      final result = await itemService.incrementItem('non_existent_id');
      expect(result, false);
    });

    test('存在しないIDのdecrementItem()がfalseを返すこと', () async {
      final result = await itemService.decrementItem('non_existent_id');
      expect(result, false);
    });

    group('名前編集のエッジケーステスト', () {
      test('空文字列の名前でアイテム作成が失敗すること', () async {
        // 空文字列での作成を試行
        expect(
          () => itemService.createItem('', 5),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('空白のみの名前でアイテム作成が失敗すること', () async {
        // 空白のみの文字列での作成を試行
        expect(
          () => itemService.createItem('   ', 5),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('最大長を超える名前でアイテム作成が失敗すること', () async {
        // 101文字の名前（maxNameLength = 100を超える）
        final longName = 'a' * 101;
        expect(
          () => itemService.createItem(longName, 5),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('最大長ちょうどの名前でアイテム作成が成功すること', () async {
        // 100文字の名前（maxNameLength = 100）
        final maxLengthName = 'a' * 100;
        final item = await itemService.createItem(maxLengthName, 5);

        expect(item.name, maxLengthName);
        expect(item.name.length, 100);
      });

      test('特殊文字を含む名前でアイテム作成が成功すること', () async {
        final specialName = '特殊文字!@#\$%^&*()_+-=[]{}|;:,.<>?';
        final item = await itemService.createItem(specialName, 5);

        expect(item.name, specialName);
      });

      test('絵文字を含む名前でアイテム作成が成功すること', () async {
        final emojiName = 'テスト🐿️🌰🍃アイテム';
        final item = await itemService.createItem(emojiName, 5);

        expect(item.name, emojiName);
      });

      test('Unicode文字を含む名前でアイテム作成が成功すること', () async {
        final unicodeName = 'Test中文العربية🌍';
        final item = await itemService.createItem(unicodeName, 5);

        expect(item.name, unicodeName);
      });

      test('空文字列での名前更新が失敗すること', () async {
        final item = await itemService.createItem('Original Name', 5);

        expect(
          () => itemService.updateItem(item.id, 5, name: ''),
          throwsA(isA<ArgumentError>()),
        );

        // 元の名前が保持されていることを確認
        expect(itemService.getItemById(item.id)!.name, 'Original Name');
      });

      test('空白のみでの名前更新が失敗すること', () async {
        final item = await itemService.createItem('Original Name', 5);

        expect(
          () => itemService.updateItem(item.id, 5, name: '   '),
          throwsA(isA<ArgumentError>()),
        );

        // 元の名前が保持されていることを確認
        expect(itemService.getItemById(item.id)!.name, 'Original Name');
      });

      test('最大長を超える名前での更新が失敗すること', () async {
        final item = await itemService.createItem('Original Name', 5);
        final longName = 'b' * 101;

        expect(
          () => itemService.updateItem(item.id, 5, name: longName),
          throwsA(isA<ArgumentError>()),
        );

        // 元の名前が保持されていることを確認
        expect(itemService.getItemById(item.id)!.name, 'Original Name');
      });

      test('最大長ちょうどの名前での更新が成功すること', () async {
        final item = await itemService.createItem('Original Name', 5);
        final maxLengthName = 'b' * 100;

        final result =
            await itemService.updateItem(item.id, 5, name: maxLengthName);

        expect(result, true);
        expect(itemService.getItemById(item.id)!.name, maxLengthName);
        expect(itemService.getItemById(item.id)!.name.length, 100);
      });

      test('前後の空白を含む名前が正しく処理されること', () async {
        final nameWithSpaces = '  Test Item  ';
        final item = await itemService.createItem(nameWithSpaces, 5);

        // 前後の空白は保持される（トリムしない）
        expect(item.name, nameWithSpaces);
      });

      test('改行文字を含む名前が正しく処理されること', () async {
        final nameWithNewlines = 'Test\nItem\nWith\nNewlines';
        final item = await itemService.createItem(nameWithNewlines, 5);

        expect(item.name, nameWithNewlines);
      });

      test('タブ文字を含む名前が正しく処理されること', () async {
        final nameWithTabs = 'Test\tItem\tWith\tTabs';
        final item = await itemService.createItem(nameWithTabs, 5);

        expect(item.name, nameWithTabs);
      });
    });
  });
}
