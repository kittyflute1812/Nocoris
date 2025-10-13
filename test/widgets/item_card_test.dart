import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop_counter/widgets/item_card.dart';
import 'package:drop_counter/models/item.dart';

void main() {
  group('ItemCard Widget Tests', () {
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

    testWidgets('ItemCardが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onDecrement: () {},
              onIncrement: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('残数: 5'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('count=0の時にdecrementボタンが無効化されること', (WidgetTester tester) async {
      testItem = Item(
        id: '1',
        name: 'Test Item',
        count: 0,
        createdAt: DateTime(2025, 10, 13),
        updatedAt: DateTime(2025, 10, 13),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onDecrement: () {},
              onIncrement: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final decrementButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove),
      );
      expect(decrementButton.onPressed, null);
    });

    testWidgets('減算・加算ボタンのコールバックが正しく呼ばれること', (WidgetTester tester) async {
      bool decrementCalled = false;
      bool incrementCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onDecrement: () => decrementCalled = true,
              onIncrement: () => incrementCalled = true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Decrementボタンのタップ
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(decrementCalled, true);

      // Incrementボタンのタップ
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(incrementCalled, true);
    });

    testWidgets('メニューボタンのコールバックが正しく呼ばれること', (WidgetTester tester) async {
      bool editCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onDecrement: () {},
              onIncrement: () {},
              onEdit: () => editCalled = true,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // メニューボタンを開く
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // 編集メニューのタップ
      await tester.tap(find.text('編集').last);
      await tester.pumpAndSettle();
      expect(editCalled, true);

      // メニューを再度開く（古いメニューが閉じるのを待つ）
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // 削除メニューのタップ
      await tester.tap(find.text('削除').last);
      await tester.pumpAndSettle();
      expect(deleteCalled, true);
    });
  });
}
