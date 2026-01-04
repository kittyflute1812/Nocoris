import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocoris/features/item/screens/home_screen.dart';
import 'package:nocoris/features/item/providers/item_provider.dart';
import '../../../helpers/test_helpers.dart';

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
      final mockItemService = TestHelpers.createMockItemService(
        initialItems: testItems,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceInitProvider.overrideWith((ref) async => mockItemService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // 非同期初期化の完了を待つ
      await tester.pumpAndSettle();

      // アイテムが表示されていることを確認
      expect(find.text('テストアイテム1'), findsOneWidget);
      expect(find.text('テストアイテム2'), findsOneWidget);
      expect(find.text('残数: 5'), findsOneWidget);
      expect(find.text('残数: 10'), findsOneWidget);
    });

    testWidgets('アイテムが空の場合、メッセージが表示される', (tester) async {
      final mockItemService = TestHelpers.createMockItemService(
        initialItems: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceInitProvider.overrideWith((ref) async => mockItemService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // 非同期初期化の完了を待つ
      await tester.pumpAndSettle();

      // 空状態のメッセージが表示されていることを確認
      expect(find.text('アイテムがありません'), findsOneWidget);
      expect(find.text('アイテムを追加'), findsOneWidget);
    });

    testWidgets('アイテムを追加ボタンが正しく動作する', (tester) async {
      final mockItemService = TestHelpers.createMockItemService(
        initialItems: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceInitProvider.overrideWith((ref) async => mockItemService),
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // 非同期初期化の完了を待つ
      await tester.pumpAndSettle();

      // FloatingActionButtonが表示されていることを確認
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
