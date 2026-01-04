import 'package:flutter_test/flutter_test.dart';
import 'package:nocoris/features/item/models/item.dart';

void main() {
  group('Item Model Tests', () {
    late Item testItem;

    setUp(() {
      testItem = Item(
        id: '1',
        name: 'Test Item',
        count: 5,
        createdAt: DateTime(2025, 10, 13),
        updatedAt: DateTime(2025, 10, 13),
      );
    });

    test('初期化が正しく行われること', () {
      expect(testItem.id, '1');
      expect(testItem.name, 'Test Item');
      expect(testItem.count, 5);
      expect(testItem.createdAt, DateTime(2025, 10, 13));
      expect(testItem.updatedAt, DateTime(2025, 10, 13));
    });

    test('Item.create()が正しく動作すること', () {
      final item = Item.create(name: 'New Item', initialCount: 10);

      expect(item.name, 'New Item');
      expect(item.count, 10);
      expect(item.id, isNotEmpty);
      expect(item.createdAt.day, DateTime.now().day);
      expect(item.updatedAt.day, DateTime.now().day);
    });

    test('increment()メソッドが新しいインスタンスを返すこと', () {
      final newItem = testItem.increment();

      expect(newItem.count, testItem.count + 1);
      expect(newItem.updatedAt.isAfter(testItem.updatedAt), true);
      expect(newItem.id, testItem.id);
      expect(newItem.name, testItem.name);
      // 元のアイテムは変更されない
      expect(testItem.count, 5);
    });

    test('decrement()メソッドが新しいインスタンスを返すこと', () {
      final newItem = testItem.decrement();

      expect(newItem.count, testItem.count - 1);
      expect(newItem.updatedAt.isAfter(testItem.updatedAt), true);
      expect(newItem.id, testItem.id);
      expect(newItem.name, testItem.name);
      // 元のアイテムは変更されない
      expect(testItem.count, 5);
    });

    test('decrement()メソッドが0未満にならないこと', () {
      final zeroItem = testItem.setCount(0);
      final newItem = zeroItem.decrement();

      expect(newItem.count, 0);
      expect(newItem.id, zeroItem.id);
    });

    test('setCount()メソッドが新しいインスタンスを返すこと', () {
      final newItem = testItem.setCount(10);

      expect(newItem.count, 10);
      expect(newItem.updatedAt.isAfter(testItem.updatedAt), true);
      expect(newItem.id, testItem.id);
      expect(newItem.name, testItem.name);
      // 元のアイテムは変更されない
      expect(testItem.count, 5);
    });

    test('setCount()メソッドが負の値を設定しないこと', () {
      final newItem = testItem.setCount(-1);

      expect(newItem.count, testItem.count);
      expect(newItem.id, testItem.id);
    });

    test('toJson()メソッドが正しくJSONを生成すること', () {
      final json = testItem.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Item');
      expect(json['count'], 5);
      expect(json['createdAt'], testItem.createdAt.toIso8601String());
      expect(json['updatedAt'], testItem.updatedAt.toIso8601String());
    });

    test('fromJson()メソッドが正しくItemを生成すること', () {
      final json = {
        'id': '1',
        'name': 'Test Item',
        'count': 5,
        'createdAt': '2025-10-13T00:00:00.000',
        'updatedAt': '2025-10-13T00:00:00.000',
      };

      final item = Item.fromJson(json);

      expect(item.id, '1');
      expect(item.name, 'Test Item');
      expect(item.count, 5);
      expect(item.createdAt, DateTime(2025, 10, 13));
      expect(item.updatedAt, DateTime(2025, 10, 13));
    });

    test('copyWith()メソッドが正しく動作すること', () {
      final newItem = testItem.copyWith(count: 10);

      expect(newItem.count, 10);
      expect(newItem.id, testItem.id);
      expect(newItem.name, testItem.name);
      expect(newItem.createdAt, testItem.createdAt);
      // 元のアイテムは変更されない
      expect(testItem.count, 5);
    });

    test('等価演算子が正しく動作すること', () {
      final item1 = Item(
        id: '1',
        name: 'Test',
        count: 5,
        createdAt: DateTime(2025, 10, 13),
        updatedAt: DateTime(2025, 10, 13),
      );
      final item2 = Item(
        id: '1',
        name: 'Test',
        count: 5,
        createdAt: DateTime(2025, 10, 13),
        updatedAt: DateTime(2025, 10, 13),
      );
      final item3 = Item(
        id: '2',
        name: 'Test',
        count: 5,
        createdAt: DateTime(2025, 10, 13),
        updatedAt: DateTime(2025, 10, 13),
      );

      expect(item1 == item2, true);
      expect(item1 == item3, false);
    });
  });
}

