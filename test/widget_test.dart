// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drop_counter/main.dart';

void main() {
  testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // 初期化のための待機（ItemService.create()の完了を待つ）
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // アプリタイトルが表示されていることを確認
    expect(find.text('CountDrop'), findsOneWidget);
    
    // アプリが正常に起動していることを確認
    // （ローディング中、空のメッセージ、またはFloatingActionButtonのいずれかが表示される）
    final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasEmptyMessage = find.text('アイテムがありません').evaluate().isNotEmpty;
    final hasFAB = find.byType(FloatingActionButton).evaluate().isNotEmpty;
    expect(hasLoading || hasEmptyMessage || hasFAB, isTrue);
  });
}
