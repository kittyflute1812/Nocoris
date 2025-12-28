import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drop_counter/services/item_service.dart';
import 'package:drop_counter/services/storage_service.dart';

/// テストヘルパー関数をまとめたクラス
class TestHelpers {
  /// テスト用にウィジェットをラップする
  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }

  /// ItemServiceのモックを作成する
  static ItemService createMockItemService({
    List<Map<String, dynamic>>? initialItems,
  }) {
    final mockStorage = MockStorageService();
    
    // StorageService.loadItemsのモック
    when(() => mockStorage.loadItems())
        .thenReturn(initialItems ?? []);
    
    // StorageService.saveItemsのモック
    when(() => mockStorage.saveItems(any()))
        .thenAnswer((_) async => true);
    
    // StorageService.loadJsonListのモック（他のテストで使用される可能性があるため）
    when(() => mockStorage.loadJsonList(any()))
        .thenReturn(initialItems ?? []);
    
    // StorageService.saveJsonListのモック（他のテストで使用される可能性があるため）
    when(() => mockStorage.saveJsonList(any(), any()))
        .thenAnswer((_) async => true);

    // ItemServiceの作成（コンストラクタで_loadItems()が呼ばれる）
    return ItemService(mockStorage);
  }
}

class MockStorageService extends Mock implements StorageService {}
