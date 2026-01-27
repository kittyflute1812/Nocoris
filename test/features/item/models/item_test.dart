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

    test('Item.create()がアイコン付きで正しく動作すること', () {
      final item = Item.create(name: 'New Item', initialCount: 10, icon: '🐿️');

      expect(item.name, 'New Item');
      expect(item.count, 10);
      expect(item.icon, '🐿️');
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

    test('toJson()メソッドがアイコン付きで正しくJSONを生成すること', () {
      final itemWithIcon = testItem.copyWith(icon: '🐿️');
      final json = itemWithIcon.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Item');
      expect(json['count'], 5);
      expect(json['icon'], '🐿️');
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

    test('fromJson()メソッドがアイコン付きで正しくItemを生成すること', () {
      final json = {
        'id': '1',
        'name': 'Test Item',
        'count': 5,
        'icon': '🐿️',
        'createdAt': '2025-10-13T00:00:00.000',
        'updatedAt': '2025-10-13T00:00:00.000',
      };

      final item = Item.fromJson(json);

      expect(item.id, '1');
      expect(item.name, 'Test Item');
      expect(item.count, 5);
      expect(item.icon, '🐿️');
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

    test('copyWith()メソッドがアイコンを正しく更新すること', () {
      final newItem = testItem.copyWith(icon: '🐿️');

      expect(newItem.icon, '🐿️');
      expect(newItem.id, testItem.id);
      expect(newItem.name, testItem.name);
      expect(newItem.count, testItem.count);
      expect(newItem.createdAt, testItem.createdAt);
      // 元のアイテムは変更されない
      expect(testItem.icon, null);
    });

    test('copyWith()メソッドがアイコンを削除できること', () {
      // まずアイコン付きのアイテムを作成
      final itemWithIcon = testItem.copyWith(icon: '🐿️');
      expect(itemWithIcon.icon, '🐿️');

      // アイコンを削除（nullに設定）
      final itemWithoutIcon = itemWithIcon.copyWith(icon: null);
      expect(itemWithoutIcon.icon, null);
      expect(itemWithoutIcon.id, testItem.id);
      expect(itemWithoutIcon.name, testItem.name);
      expect(itemWithoutIcon.count, testItem.count);
    });

    test('copyWith()メソッドでアイコンパラメータを省略した場合、既存のアイコンを維持すること', () {
      // まずアイコン付きのアイテムを作成
      final itemWithIcon = testItem.copyWith(icon: '🐿️');
      expect(itemWithIcon.icon, '🐿️');

      // アイコンパラメータを省略してcopyWith
      final updatedItem = itemWithIcon.copyWith(count: 10);
      expect(updatedItem.icon, '🐿️'); // アイコンは維持される
      expect(updatedItem.count, 10);
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

    group('バリデーションテスト', () {
      test('Item.create()で空文字列の名前を拒否すること', () {
        expect(
          () => Item.create(name: '', initialCount: 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Item.create()で空白のみの名前を拒否すること', () {
        expect(
          () => Item.create(name: '   ', initialCount: 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Item.create()で負の数量を拒否すること', () {
        expect(
          () => Item.create(name: 'Test', initialCount: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('通常のコンストラクタで空文字列の名前を拒否すること', () {
        expect(
          () => Item(
            id: '1',
            name: '',
            count: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('copyWith()で無効な名前に変更しようとした場合に拒否すること', () {
        expect(
          () => testItem.copyWith(name: ''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('後方互換性テスト', () {
      test('fromJson()で空文字列の名前をサニタイズすること', () {
        final json = {
          'id': '1',
          'name': '',
          'count': 5,
          'createdAt': '2025-10-13T00:00:00.000',
          'updatedAt': '2025-10-13T00:00:00.000',
        };

        final item = Item.fromJson(json);

        expect(item.id, '1');
        expect(item.name, '無名のアイテム');
        expect(item.count, 5);
      });

      test('fromJson()で空白のみの名前をサニタイズすること', () {
        final json = {
          'id': '1',
          'name': '   ',
          'count': 5,
          'createdAt': '2025-10-13T00:00:00.000',
          'updatedAt': '2025-10-13T00:00:00.000',
        };

        final item = Item.fromJson(json);

        expect(item.id, '1');
        expect(item.name, '無名のアイテム');
        expect(item.count, 5);
      });

      test('fromJson()で長すぎる名前を切り詰めること', () {
        // AppConstants.maxNameLengthは100
        final longName = 'a' * 150; // 150文字の名前
        final json = {
          'id': '1',
          'name': longName,
          'count': 5,
          'createdAt': '2025-10-13T00:00:00.000',
          'updatedAt': '2025-10-13T00:00:00.000',
        };

        final item = Item.fromJson(json);

        expect(item.id, '1');
        expect(item.name.length, 100); // AppConstants.maxNameLength
        expect(item.name, startsWith('a'));
        expect(item.count, 5);
      });

      test('fromJson()で有効な名前はそのまま保持すること', () {
        final json = {
          'id': '1',
          'name': 'Valid Name',
          'count': 5,
          'createdAt': '2025-10-13T00:00:00.000',
          'updatedAt': '2025-10-13T00:00:00.000',
        };

        final item = Item.fromJson(json);

        expect(item.id, '1');
        expect(item.name, 'Valid Name');
        expect(item.count, 5);
      });

      test('サニタイズされたアイテムのcopyWith()で名前を変更しない場合は正常動作すること', () {
        final json = {
          'id': '1',
          'name': '',
          'count': 5,
          'createdAt': '2025-10-13T00:00:00.000',
          'updatedAt': '2025-10-13T00:00:00.000',
        };

        final sanitizedItem = Item.fromJson(json);
        expect(sanitizedItem.name, '無名のアイテム');

        // 名前を変更せずにcopyWith
        final updatedItem = sanitizedItem.copyWith(count: 10);
        expect(updatedItem.name, '無名のアイテム');
        expect(updatedItem.count, 10);
      });

      test('サニタイズされたアイテムのcopyWith()で有効な名前に変更できること', () {
        final json = {
          'id': '1',
          'name': '',
          'count': 5,
          'createdAt': '2025-10-13T00:00:00.000',
          'updatedAt': '2025-10-13T00:00:00.000',
        };

        final sanitizedItem = Item.fromJson(json);
        expect(sanitizedItem.name, '無名のアイテム');

        // 有効な名前に変更
        final updatedItem = sanitizedItem.copyWith(name: 'New Valid Name');
        expect(updatedItem.name, 'New Valid Name');
        expect(updatedItem.count, 5);
      });
    });
  });
}

