import 'package:flutter_test/flutter_test.dart';
import 'package:nocoris/features/item/models/item.dart';
import '../helpers/property_test_framework.dart';
import '../helpers/property_test_helpers.dart';

/// データモデルのプロパティベーステスト
/// 
/// このファイルは設計書で定義された最初の4つの正確性プロパティを実装します：
/// - プロパティ 1: アイテム作成によるリスト拡張
/// - プロパティ 2: 無効入力の拒否
/// - プロパティ 3: アイコン設定の一貫性
/// - プロパティ 4: 数量設定の正確性
void main() {
  PropertyTestFramework.runAllProperties(() {
    PropertyTestFramework.runPropertyGroup('データモデル基本プロパティ', () {

      // プロパティ 1: アイテム作成によるリスト拡張
      // **検証対象: 要件 1.1**
      PropertyTestFramework.runProperty3<String, int, String?>(
        propertyNumber: 1,
        property: (name, count, icon) {
          try {
            // アイテムを作成
            final createdItem = Item.create(
              name: name,
              initialCount: count,
              icon: icon,
            );
            
            // アイテムをリストに追加
            final newItems = [createdItem];
            
            // プロパティ検証: リストの長さが1で、作成したアイテムが含まれる
            final lengthCorrect = newItems.length == 1;
            final itemInList = newItems.any((item) => item.id == createdItem.id);
            
            return lengthCorrect && itemInList;
          } catch (e) {
            // 有効な入力で例外が発生した場合はプロパティ違反
            return false;
          }
        },
        generator1: PropertyTestHelpers.generateValidItemName,
        generator2: PropertyTestHelpers.generateValidCount,
        generator3: PropertyTestHelpers.generateEmojiIcon,
      );

      // プロパティ 2: 無効入力の拒否
      // **検証対象: 要件 1.3, 4.4**
      PropertyTestFramework.runProperty<String>(
        propertyNumber: 2,
        property: (invalidName) {
          try {
            // 無効な名前でアイテム作成を試行
            Item.create(
              name: invalidName,
              initialCount: 0,
              icon: null,
            );
            
            // 例外が発生しなかった場合はプロパティ違反
            return false;
          } catch (e) {
            // ArgumentErrorが発生することを期待
            return e is ArgumentError;
          }
        },
        generator: PropertyTestHelpers.generateInvalidItemName,
      );

      // プロパティ 3: アイコン設定の一貫性
      // **検証対象: 要件 1.2, 8.2**
      PropertyTestFramework.runProperty2<String, String>(
        propertyNumber: 3,
        property: (name, icon) {
          try {
            // アイコン付きでアイテムを作成
            final item = Item.create(
              name: name,
              initialCount: 0,
              icon: icon,
            );
            
            // プロパティ検証: 設定したアイコンが正しく関連付けられている
            return item.icon == icon;
          } catch (e) {
            // 有効な入力で例外が発生した場合はプロパティ違反
            return false;
          }
        },
        generator1: PropertyTestHelpers.generateValidItemName,
        generator2: PropertyTestHelpers.generateEmojiIcon,
      );

      // プロパティ 4: 数量設定の正確性
      // **検証対象: 要件 1.4**
      PropertyTestFramework.runProperty2<String, int>(
        propertyNumber: 4,
        property: (name, count) {
          try {
            // 指定した数量でアイテムを作成
            final item = Item.create(
              name: name,
              initialCount: count,
              icon: null,
            );
            
            // プロパティ検証: 設定した数量が正しく設定されている
            return item.count == count;
          } catch (e) {
            // 有効な入力で例外が発生した場合はプロパティ違反
            return false;
          }
        },
        generator1: PropertyTestHelpers.generateValidItemName,
        generator2: PropertyTestHelpers.generateValidCount,
      );
    });

    PropertyTestFramework.runPropertyGroup('アイコン設定の詳細テスト', () {
      // プロパティ 3の拡張: nullアイコンの一貫性テスト
      PropertyTestFramework.runProperty<String>(
        propertyNumber: 3,
        property: (name) {
          try {
            // nullアイコンでアイテムを作成
            final item = Item.create(
              name: name,
              initialCount: 0,
              icon: null,
            );
            
            // プロパティ検証: nullアイコンが正しく設定されている
            return item.icon == null;
          } catch (e) {
            // 有効な入力で例外が発生した場合はプロパティ違反
            return false;
          }
        },
        generator: PropertyTestHelpers.generateValidItemName,
      );
    });

    PropertyTestFramework.runPropertyGroup('数量設定の境界値テスト', () {
      // プロパティ 4の拡張: 境界値（0）のテスト
      PropertyTestFramework.runProperty<String>(
        propertyNumber: 4,
        property: (name) {
          try {
            // 数量0でアイテムを作成
            final item = Item.create(
              name: name,
              initialCount: 0,
              icon: null,
            );
            
            // プロパティ検証: 数量0が正しく設定されている
            return item.count == 0;
          } catch (e) {
            // 有効な入力で例外が発生した場合はプロパティ違反
            return false;
          }
        },
        generator: PropertyTestHelpers.generateValidItemName,
      );

      // プロパティ 4の拡張: 大きな数量のテスト
      PropertyTestFramework.runProperty2<String, int>(
        propertyNumber: 4,
        property: (name, count) {
          try {
            // 大きな数量でアイテムを作成
            final item = Item.create(
              name: name,
              initialCount: count,
              icon: null,
            );
            
            // プロパティ検証: 大きな数量が正しく設定されている
            return item.count == count;
          } catch (e) {
            // 有効な入力で例外が発生した場合はプロパティ違反
            return false;
          }
        },
        generator1: PropertyTestHelpers.generateValidItemName,
        generator2: () => PropertyTestHelpers.generateValidCount() + 1000, // より大きな値
      );
    });

    PropertyTestFramework.runPropertyGroup('無効入力の詳細テスト', () {
      // プロパティ 2の拡張: 様々な無効入力パターンのテスト
      test('Property 2: 空文字列や空白文字のみの名前は拒否される', () {
        final whitespaceNames = ['',' ', '  ', '\t', '\n', '   \t  \n  '];
        
        for (final name in whitespaceNames) {
          expect(
            () => Item.create(name: name, initialCount: 0, icon: null),
            throwsA(isA<ArgumentError>()),
            reason: 'Whitespace-only name "$name" should be rejected',
          );
        }
      });
    });
  });
}
