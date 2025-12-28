import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop_counter/screens/home_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('HomeScreen', () {
    late List<Map<String, dynamic>> testItems;
    final now = DateTime.now();

    setUp(() {
      testItems = [
        {
          'id': 'test-id-1',
          'name': 'テストアイテム1',
          'count': 5,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'test-id-2',
          'name': 'テストアイテム2',
          'count': 10,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
    });

    testWidgets('アイテムが正しく表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            itemService: TestHelpers.createMockItemService(
              initialItems: testItems,
            ),
          ),
        ),
      );

      // 読み込みと描画の完了を待つ
      await tester.pumpAndSettle();

      // アイテムが表示されていることを確認
      expect(find.text('テストアイテム1'), findsOneWidget);
      expect(find.text('テストアイテム2'), findsOneWidget);
      expect(find.text('残数: 5'), findsOneWidget);
      expect(find.text('残数: 10'), findsOneWidget);
    });

    testWidgets('アイテムが空の場合、メッセージが表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            itemService: TestHelpers.createMockItemService(
              initialItems: [],
            ),
          ),
        ),
      );

      // 読み込みと描画の完了を待つ
      await tester.pumpAndSettle();

      // 空の状態のメッセージが表示されていることを確認
      expect(find.text('アイテムがありません'), findsOneWidget);
      expect(find.text('アイテムを追加'), findsOneWidget);
    });

    testWidgets('アイテムを追加ボタンが正しく動作する', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            itemService: TestHelpers.createMockItemService(
              initialItems: testItems,
            ),
          ),
        ),
      );

      // 読み込みと描画の完了を待つ
      await tester.pumpAndSettle();

      // FloatingActionButtonが表示されていることを確認
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // 追加ボタンをタップ
      await tester.tap(find.byType(FloatingActionButton));
      
      // 遷移アニメーションの完了を待つ
      await tester.pumpAndSettle();
    });

    testWidgets('外部から渡されたItemServiceを使用する場合、読み込み中の表示は表示されない', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            itemService: TestHelpers.createMockItemService(
              initialItems: testItems,
            ),
          ),
        ),
      );

      // 初期状態でローディングインジケータが表示されないことを確認
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // FloatingActionButtonが表示されていることを確認（読み込み完了の証）
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
