import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocoris/features/item/models/item.dart';
import 'package:nocoris/features/item/widgets/item_card.dart';
import '../helpers/property_test_framework.dart';
import '../helpers/property_test_helpers.dart';

void main() {
  PropertyTestFramework.runAllProperties(() {
    PropertyTestFramework.runPropertyGroup('Property 5: アイテム表示の完全性', () {
      // プロパティ 5: アイテム表示の完全性
      // 任意のアイテムに対して、表示機能を実行すると、アイテム名、現在の数量、設定されたアイコンのすべてが含まれる
      testWidgets('Property 5: アイテム表示の完全性', (tester) async {
        const iterations = 100;
        int passedCount = 0;
        int failedCount = 0;

        debugPrint('実行中: Property 5 - アイテム表示の完全性');
        debugPrint('検証対象: 要件 2.2');
        debugPrint('反復回数: $iterations');

        for (int i = 0; i < iterations; i++) {
          try {
            final item = PropertyTestHelpers.generateRandomItem();
            final result = await _testItemDisplayCompleteness(tester, item);

            if (result) {
              passedCount++;
            } else {
              failedCount++;
              PropertyTestHelpers.debugPrintTestData(item);
              debugPrint(
                  'Property 5 failed on iteration ${i + 1} with item: $item');
            }
          } catch (e, stackTrace) {
            failedCount++;
            debugPrint('Exception on iteration ${i + 1}: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        }

        PropertyTestHelpers.printTestStatistics(
            iterations, passedCount, failedCount);
        if (failedCount > 0) {
          fail('$failedCount/$iterations iterations failed');
        } else {
          debugPrint('Property 5: すべてのテストが成功しました');
        }
      }, tags: [
        'nocoris-item-management',
        'property-5',
        'property-based-test'
      ]);
    });
  });
}

/// プロパティ 5: アイテム表示の完全性をテストする
///
/// アイテムカードが表示されたとき、アイテム名、現在の数量、設定されたアイコンのすべてが含まれることを検証する
Future<bool> _testItemDisplayCompleteness(
    WidgetTester tester, Item item) async {
  // ItemCardウィジェットを作成してテスト
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ItemCard(
          item: item,
          onDecrement: () {},
          onIncrement: () {},
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    ),
  );

  await tester.pump();

  // アイテム名が表示されていることを確認（semanticsLabelを使用してより正確に特定）
  final nameDisplayed =
      tester.any(find.bySemanticsLabel('アイテム名: ${item.name}'));
  if (!nameDisplayed) {
    PropertyTestHelpers.debugPrintTestData(
        'Item name not displayed: ${item.name}');
    return false;
  }

  // 現在の数量が表示されていることを確認（semanticsLabelを使用してより正確に特定）
  final countDisplayed =
      tester.any(find.bySemanticsLabel('のこり: ${item.count}個'));
  if (!countDisplayed) {
    PropertyTestHelpers.debugPrintTestData(
        'Item count not displayed: ${item.count}');
    return false;
  }

  // アイコンが設定されている場合、アイコンが表示されていることを確認
  if (item.icon != null) {
    final iconDisplayed = tester.any(find.text(item.icon!));
    if (!iconDisplayed) {
      PropertyTestHelpers.debugPrintTestData(
          'Item icon not displayed: ${item.icon}');
      return false;
    }
  }

  return true;
}
