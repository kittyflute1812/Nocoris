import 'package:flutter_test/flutter_test.dart';
import 'package:drop_counter/models/item.dart';

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

    test('increment()メソッドが正しく動作すること', () {
      final initialCount = testItem.count;
      final initialUpdatedAt = testItem.updatedAt;
      
      testItem.increment();
      
      expect(testItem.count, initialCount + 1);
      expect(testItem.updatedAt.isAfter(initialUpdatedAt), true);
    });

    test('decrement()メソッドが正しく動作すること', () {
      final initialCount = testItem.count;
      final initialUpdatedAt = testItem.updatedAt;
      
      testItem.decrement();
      
      expect(testItem.count, initialCount - 1);
      expect(testItem.updatedAt.isAfter(initialUpdatedAt), true);
    });

    test('decrement()メソッドが0未満にならないこと', () {
      testItem.setCount(0);
      final initialUpdatedAt = testItem.updatedAt;
      
      testItem.decrement();
      
      expect(testItem.count, 0);
      expect(testItem.updatedAt, initialUpdatedAt);
    });

    test('setCount()メソッドが正しく動作すること', () {
      final initialUpdatedAt = testItem.updatedAt;
      
      testItem.setCount(10);
      
      expect(testItem.count, 10);
      expect(testItem.updatedAt.isAfter(initialUpdatedAt), true);
    });

    test('setCount()メソッドが負の値を設定しないこと', () {
      final initialCount = testItem.count;
      final initialUpdatedAt = testItem.updatedAt;
      
      testItem.setCount(-1);
      
      expect(testItem.count, initialCount);
      expect(testItem.updatedAt, initialUpdatedAt);
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
  });
}
