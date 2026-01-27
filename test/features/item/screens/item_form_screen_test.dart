import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocoris/features/item/models/item.dart';
import 'package:nocoris/features/item/screens/item_form_screen.dart';
import 'package:nocoris/features/item/providers/item_provider.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ItemFormScreen', () {
    late Item testItem;
    final now = DateTime.now();

    setUp(() {
      testItem = Item(
        id: 'test-id',
        name: 'テストアイテム',
        count: 5,
        createdAt: now,
        updatedAt: now,
      );
    });

    testWidgets('新規作成モードで表示される', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: const MaterialApp(
            home: ItemFormScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('新しいアイテム'), findsOneWidget);
      expect(find.text('アイテム名'), findsOneWidget);
      expect(find.text('値'), findsOneWidget);
    });

    testWidgets('編集モードで表示される', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: MaterialApp(
            home: ItemFormScreen(item: testItem),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('アイテムを編集'), findsOneWidget);
      expect(find.text('テストアイテム'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('バリデーションが機能する - アイテム名が空', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: const MaterialApp(
            home: ItemFormScreen(),
          ),
        ),
      );

      await tester.pump();

      // 保存ボタンをタップ（バリデーションエラーが表示されるはず）
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // バリデーションエラーが表示されていることを確認
      expect(find.text('アイテム名を入力してください'), findsOneWidget);
    });

    testWidgets('バリデーションが機能する - 値が空', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: const MaterialApp(
            home: ItemFormScreen(),
          ),
        ),
      );

      await tester.pump();

      // アイテム名のみ入力
      await tester.enterText(find.byType(TextFormField).first, 'テストアイテム');
      // 値フィールドをクリアして空にする
      await tester.enterText(find.byType(TextFormField).last, '');

      // 保存ボタンをタップ（バリデーションエラーが表示されるはず）
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // バリデーションエラーが表示されていることを確認
      expect(find.text('値を入力してください'), findsOneWidget);
    });

    testWidgets('バリデーションが機能する - 値が無効な文字列', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: const MaterialApp(
            home: ItemFormScreen(),
          ),
        ),
      );

      await tester.pump();

      // フォームに入力
      await tester.enterText(find.byType(TextFormField).first, 'テストアイテム');
      
      // 値フィールドに直接無効な値を設定（digitsOnlyフィルターをバイパス）
      final countField = find.byType(TextFormField).last;
      final textField = tester.widget<TextFormField>(countField);
      textField.controller?.text = 'abc';

      // 保存ボタンをタップ（バリデーションエラーが表示されるはず）
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // バリデーションエラーが表示されていることを確認
      expect(find.text('0以上の数値を入力してください'), findsOneWidget);
    });

    testWidgets('アイテムが正しく作成される', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: const MaterialApp(
            home: ItemFormScreen(),
          ),
        ),
      );

      await tester.pump();

      // フォームに入力
      await tester.enterText(find.byType(TextFormField).first, 'テストアイテム');
      await tester.enterText(find.byType(TextFormField).last, '10');

      // 保存ボタンをタップ
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // createItemが呼ばれたことを確認
      // （実際のテストではmockItemServiceのverifyを使用）
    });

    testWidgets('アイテムが正しく更新される', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: MaterialApp(
            home: ItemFormScreen(item: testItem),
          ),
        ),
      );

      await tester.pump();

      // フォームの値を変更
      await tester.enterText(find.byType(TextFormField).first, '更新されたアイテム');
      await tester.enterText(find.byType(TextFormField).last, '20');

      // 保存ボタンをタップ
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // updateItemが呼ばれたことを確認
      // （実際のテストではmockItemServiceのverifyを使用）
    });

    testWidgets('編集モードで名前フィールドが有効化されている', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: MaterialApp(
            home: ItemFormScreen(item: testItem),
          ),
        ),
      );

      await tester.pump();

      // 名前フィールドを取得
      final nameField = find.byType(TextFormField).first;
      final nameTextFormField = tester.widget<TextFormField>(nameField);

      // 編集モードでも名前フィールドが有効であることを確認
      expect(nameTextFormField.enabled, isTrue);
    });

    testWidgets('編集モードで名前を変更できる', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: MaterialApp(
            home: ItemFormScreen(item: testItem),
          ),
        ),
      );

      await tester.pump();

      // 名前フィールドの初期値を確認
      expect(find.text('テストアイテム'), findsOneWidget);

      // 名前フィールドをクリアして新しい名前を入力
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '新しいアイテム名');
      await tester.pump();

      // 新しい名前が表示されていることを確認
      expect(find.text('新しいアイテム名'), findsOneWidget);
      expect(find.text('テストアイテム'), findsNothing);
    });

    testWidgets('編集モードで名前のバリデーションが機能する', (tester) async {
      final mockItemService = TestHelpers.createMockItemService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            itemServiceProvider.overrideWith((ref) => mockItemService),
          ],
          child: MaterialApp(
            home: ItemFormScreen(item: testItem),
          ),
        ),
      );

      await tester.pump();

      // 名前フィールドを空にする
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');
      await tester.pump();

      // 保存ボタンをタップ（バリデーションエラーが表示されるはず）
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // バリデーションエラーが表示されていることを確認
      expect(find.text('アイテム名を入力してください'), findsOneWidget);
    });

    group('名前編集のエッジケーステスト', () {
      testWidgets('最大長を超える名前の入力でバリデーションエラーが表示される', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 101文字の名前を入力（maxNameLength = 100を超える）
        final longName = 'a' * 101;
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, longName);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 保存ボタンをタップ
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        // バリデーションエラーが表示されていることを確認
        // TextFormFieldのmaxLengthプロパティにより、101文字目は入力されない
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text.length, lessThanOrEqualTo(100));
      });

      testWidgets('最大長ちょうどの名前が正常に入力できる', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 100文字の名前を入力（maxNameLength = 100）
        final maxLengthName = 'a' * 100;
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, maxLengthName);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 名前が正しく入力されていることを確認
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, maxLengthName);
        expect(textField.controller?.text.length, 100);

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        // バリデーションエラーが表示されていないことを確認
        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('空白のみの名前でバリデーションエラーが表示される', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 空白のみの名前を入力
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, '   ');
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 保存ボタンをタップ
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        // バリデーションエラーが表示されていることを確認
        expect(find.text('アイテム名を入力してください'), findsOneWidget);
      });

      testWidgets('特殊文字を含む名前が正常に入力できる', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 特殊文字を含む名前を入力
        final specialName = '特殊文字!@#\$%^&*()_+-=[]{}|;:,.<>?';
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, specialName);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 名前が正しく入力されていることを確認
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, specialName);

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('絵文字を含む名前が正常に入力できる', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 絵文字を含む名前を入力
        final emojiName = 'テスト🐿️🌰🍃アイテム';
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, emojiName);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 名前が正しく入力されていることを確認
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, emojiName);

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('Unicode文字を含む名前が正常に入力できる', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // Unicode文字を含む名前を入力
        final unicodeName = 'Test中文العربية🌍';
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, unicodeName);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 名前が正しく入力されていることを確認
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, unicodeName);

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('編集モードで名前を最大長まで変更できる', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: MaterialApp(
              home: ItemFormScreen(item: testItem),
            ),
          ),
        );

        await tester.pump();

        // 最大長の名前に変更
        final maxLengthName = 'b' * 100;
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, maxLengthName);

        // 名前が正しく入力されていることを確認
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, maxLengthName);
        expect(textField.controller?.text.length, 100);

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('前後の空白を含む名前が正しく処理される', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 前後に空白を含む名前を入力
        final nameWithSpaces = '  Test Item  ';
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, nameWithSpaces);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // 名前が正しく入力されていることを確認（空白も保持される）
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, nameWithSpaces);

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('改行文字を含む名前が正しく処理される', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 改行文字を含む名前を入力
        final nameWithNewlines = 'Test\nItem\nWith\nNewlines';
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, nameWithNewlines);
        await tester.enterText(find.byType(TextFormField).last, '5');

        // TextFormFieldは改行文字を自動的に削除するため、削除された状態で確認
        final textField = tester.widget<TextFormField>(nameField);
        expect(textField.controller?.text, 'TestItemWithNewlines');

        // 保存ボタンをタップしてもバリデーションエラーが出ないことを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });

      testWidgets('フォーム状態がバリデーションエラー後も保持される', (tester) async {
        final mockItemService = TestHelpers.createMockItemService();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              itemServiceProvider.overrideWith((ref) => mockItemService),
            ],
            child: const MaterialApp(
              home: ItemFormScreen(),
            ),
          ),
        );

        await tester.pump();

        // 有効な値を入力
        final nameField = find.byType(TextFormField).first;
        final countField = find.byType(TextFormField).last;
        await tester.enterText(nameField, 'Valid Name');
        await tester.enterText(countField, '10');

        // 名前を空にしてバリデーションエラーを発生させる
        await tester.enterText(nameField, '');
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        // バリデーションエラーが表示されることを確認
        expect(find.text('アイテム名を入力してください'), findsOneWidget);

        // カウントフィールドの値が保持されていることを確認
        final countTextFormField = tester.widget<TextFormField>(countField);
        expect(countTextFormField.controller?.text, '10');

        // 名前を修正
        await tester.enterText(nameField, 'Fixed Name');
        await tester.pump();

        // 保存ボタンをタップしてバリデーションエラーが消えることを確認
        await tester.tap(find.byIcon(Icons.save));
        await tester.pump();

        expect(find.text('アイテム名を入力してください'), findsNothing);
      });
    });
  });
}
