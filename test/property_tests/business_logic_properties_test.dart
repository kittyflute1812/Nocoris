import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocoris/features/item/models/item.dart';
import 'package:nocoris/features/item/services/item_service.dart';
import 'package:nocoris/core/services/storage_service.dart';
import '../helpers/property_test_helpers.dart';

/// ビジネスロジックのプロパティベーステスト
/// 
/// このファイルは設計書で定義されたビジネスロジック関連の正確性プロパティを実装します：
/// - プロパティ 6: インクリメント操作の正確性
/// - プロパティ 7: デクリメント操作の正確性
/// - プロパティ 10: アイテム削除の完全性

/// StorageServiceのモック
class MockStorageService extends Mock implements StorageService {}

void main() {
  group('Property-Based Tests - ビジネスロジック', () {
    setUpAll(() {
      debugPrint('=== ビジネスロジックプロパティテスト開始 ===');
      debugPrint('Feature: nocoris-item-management');
      debugPrint('プロパティ 6, 7, 10 の検証');
    });

    tearDownAll(() {
      debugPrint('=== ビジネスロジックプロパティテスト完了 ===');
    });

    group('プロパティ 6: インクリメント操作の正確性', () {
      test('Property 6: インクリメント操作の正確性 - **検証対象: 要件 3.1**', () async {
        debugPrint('実行中: Property 6 - インクリメント操作の正確性');
        debugPrint('検証対象: 要件 3.1');
        debugPrint('反復回数: 100');
        
        for (int i = 0; i < 100; i++) {
          final mockStorage = MockStorageService();
          when(() => mockStorage.loadItems()).thenReturn([]);
          when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
          final itemService = ItemService(mockStorage);
          
          final testItem = PropertyTestHelpers.generateRandomItem();
          
          // テスト用のアイテムをサービスに追加
          await itemService.createItem(testItem.name, testItem.count, icon: testItem.icon);
          final createdItem = itemService.items.first;
          final initialCount = createdItem.count;
          
          // インクリメント操作を実行
          final success = await itemService.incrementItem(createdItem.id);
          expect(success, isTrue, reason: 'Increment operation should succeed on iteration ${i + 1}');
          
          // プロパティ検証: アイテムの数量が正確に1増加している
          final updatedItem = itemService.getItemById(createdItem.id);
          expect(updatedItem, isNotNull, reason: 'Item should exist after increment on iteration ${i + 1}');
          expect(updatedItem!.count, equals(initialCount + 1), 
                 reason: 'Count should increase by 1 on iteration ${i + 1}');
        }
        
        debugPrint('Property 6: すべてのテストが成功しました');
      }, tags: ['nocoris-item-management', 'property-6', 'property-based-test']);

      test('Property 6: 数量0からのインクリメント', () async {
        for (int i = 0; i < 50; i++) {
          final mockStorage = MockStorageService();
          when(() => mockStorage.loadItems()).thenReturn([]);
          when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
          final itemService = ItemService(mockStorage);
          
          final name = PropertyTestHelpers.generateValidItemName();
          
          // 数量0のアイテムを作成
          await itemService.createItem(name, 0);
          final createdItem = itemService.items.first;
          
          // インクリメント操作を実行
          final success = await itemService.incrementItem(createdItem.id);
          expect(success, isTrue);
          
          // プロパティ検証: 数量が0から1に増加している
          final updatedItem = itemService.getItemById(createdItem.id);
          expect(updatedItem, isNotNull);
          expect(updatedItem!.count, equals(1));
        }
      }, tags: ['nocoris-item-management', 'property-6', 'property-based-test']);

      test('Property 6: 存在しないアイテムのインクリメントは失敗する', () async {
        final mockStorage = MockStorageService();
        when(() => mockStorage.loadItems()).thenReturn([]);
        when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
        final itemService = ItemService(mockStorage);

        const nonExistentId = 'non-existent-id';
        final success = await itemService.incrementItem(nonExistentId);
        
        expect(success, isFalse, 
               reason: 'Incrementing non-existent item should return false');
      }, tags: ['nocoris-item-management', 'property-6', 'error-handling']);
    });

    group('プロパティ 7: デクリメント操作の正確性', () {
      test('Property 7: デクリメント操作の正確性 - **検証対象: 要件 3.2**', () async {
        debugPrint('実行中: Property 7 - デクリメント操作の正確性');
        debugPrint('検証対象: 要件 3.2');
        debugPrint('反復回数: 100');
        
        for (int i = 0; i < 100; i++) {
          final mockStorage = MockStorageService();
          when(() => mockStorage.loadItems()).thenReturn([]);
          when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
          final itemService = ItemService(mockStorage);
          
          // 数量が1以上のアイテムを生成
          final testItem = PropertyTestHelpers.generateItemWithCount(
            PropertyTestHelpers.generatePositiveCount()
          );
          
          // 前提条件チェック: 数量が1以上
          if (testItem.count < 1) {
            continue; // 前提条件を満たさない場合はスキップ
          }
          
          // テスト用のアイテムをサービスに追加
          await itemService.createItem(testItem.name, testItem.count, icon: testItem.icon);
          final createdItem = itemService.items.first;
          final initialCount = createdItem.count;
          
          // デクリメント操作を実行
          final success = await itemService.decrementItem(createdItem.id);
          expect(success, isTrue, reason: 'Decrement operation should succeed on iteration ${i + 1}');
          
          // プロパティ検証: アイテムの数量が正確に1減少している
          final updatedItem = itemService.getItemById(createdItem.id);
          expect(updatedItem, isNotNull, reason: 'Item should exist after decrement on iteration ${i + 1}');
          expect(updatedItem!.count, equals(initialCount - 1), 
                 reason: 'Count should decrease by 1 on iteration ${i + 1}');
        }
        
        debugPrint('Property 7: すべてのテストが成功しました');
      }, tags: ['nocoris-item-management', 'property-7', 'property-based-test']);

      test('Property 7: 数量0からのデクリメント（境界値テスト）', () async {
        final mockStorage = MockStorageService();
        when(() => mockStorage.loadItems()).thenReturn([]);
        when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
        final itemService = ItemService(mockStorage);

        // 数量0のアイテムを作成
        await itemService.createItem('テストアイテム', 0);
        final createdItem = itemService.items.first;
        
        // デクリメント操作を実行
        final success = await itemService.decrementItem(createdItem.id);
        
        expect(success, isTrue, reason: 'Decrement operation should succeed');
        
        // プロパティ検証: 数量が0のまま変わらない
        final updatedItem = itemService.getItemById(createdItem.id);
        expect(updatedItem, isNotNull);
        expect(updatedItem!.count, equals(0), 
               reason: 'Count should remain 0 when decrementing from 0');
      }, tags: ['nocoris-item-management', 'property-7', 'property-based-test']);

      test('Property 7: 存在しないアイテムのデクリメントは失敗する', () async {
        final mockStorage = MockStorageService();
        when(() => mockStorage.loadItems()).thenReturn([]);
        when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
        final itemService = ItemService(mockStorage);

        const nonExistentId = 'non-existent-id';
        final success = await itemService.decrementItem(nonExistentId);
        
        expect(success, isFalse, 
               reason: 'Decrementing non-existent item should return false');
      }, tags: ['nocoris-item-management', 'property-7', 'error-handling']);
    });

    group('プロパティ 10: アイテム削除の完全性', () {
      test('Property 10: アイテム削除の完全性 - **検証対象: 要件 5.2**', () async {
        debugPrint('実行中: Property 10 - アイテム削除の完全性');
        debugPrint('検証対象: 要件 5.2');
        debugPrint('反復回数: 100');
        
        for (int i = 0; i < 100; i++) {
          final mockStorage = MockStorageService();
          when(() => mockStorage.loadItems()).thenReturn([]);
          when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
          final itemService = ItemService(mockStorage);
          
          final testItem = PropertyTestHelpers.generateRandomItem();
          
          // テスト用のアイテムをサービスに追加
          await itemService.createItem(testItem.name, testItem.count, icon: testItem.icon);
          final createdItem = itemService.items.first;
          final initialLength = itemService.items.length;
          
          // 削除操作を実行
          final success = await itemService.deleteItem(createdItem.id);
          expect(success, isTrue, reason: 'Delete operation should succeed on iteration ${i + 1}');
          
          // プロパティ検証: アイテムがリストから完全に削除されている
          final itemExists = itemService.getItemById(createdItem.id) != null;
          final lengthDecreased = itemService.items.length == initialLength - 1;
          
          expect(itemExists, isFalse, reason: 'Item should be deleted on iteration ${i + 1}');
          expect(lengthDecreased, isTrue, reason: 'List length should decrease by 1 on iteration ${i + 1}');
        }
        
        debugPrint('Property 10: すべてのテストが成功しました');
      }, tags: ['nocoris-item-management', 'property-10', 'property-based-test']);

      test('Property 10: 複数アイテム中の特定アイテム削除', () async {
        for (int i = 0; i < 50; i++) {
          final mockStorage = MockStorageService();
          when(() => mockStorage.loadItems()).thenReturn([]);
          when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
          final itemService = ItemService(mockStorage);
          
          final items = PropertyTestHelpers.generateItemList(length: 3);
          if (items.isEmpty) continue;
          
          // 複数のアイテムを作成
          final createdItems = <Item>[];
          for (final item in items) {
            await itemService.createItem(item.name, item.count, icon: item.icon);
            createdItems.add(itemService.items.last);
          }
          
          final initialLength = itemService.items.length;
          final targetIndex = PropertyTestHelpers.generateValidCount() % createdItems.length;
          final targetItem = createdItems[targetIndex];
          
          // 特定のアイテムを削除
          final success = await itemService.deleteItem(targetItem.id);
          expect(success, isTrue);
          
          // プロパティ検証: 
          // 1. 対象アイテムが削除されている
          // 2. リストの長さが1減っている
          // 3. 他のアイテムは残っている
          final targetExists = itemService.getItemById(targetItem.id) != null;
          final lengthDecreased = itemService.items.length == initialLength - 1;
          
          expect(targetExists, isFalse, reason: 'Target item should be deleted');
          expect(lengthDecreased, isTrue, reason: 'List length should decrease by 1');
          
          // 他のアイテムが残っているかチェック
          for (final item in createdItems) {
            if (item.id != targetItem.id) {
              expect(itemService.getItemById(item.id), isNotNull, 
                     reason: 'Other items should remain');
            }
          }
        }
      }, tags: ['nocoris-item-management', 'property-10', 'property-based-test']);

      test('Property 10: 存在しないアイテムの削除は失敗する', () async {
        final mockStorage = MockStorageService();
        when(() => mockStorage.loadItems()).thenReturn([]);
        when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
        final itemService = ItemService(mockStorage);

        // 存在しないIDで削除を試行
        const nonExistentId = 'non-existent-id';
        final success = await itemService.deleteItem(nonExistentId);
        
        expect(success, isFalse, 
               reason: 'Deleting non-existent item should return false');
        expect(itemService.items.length, equals(0),
               reason: 'Item list should remain empty');
      }, tags: ['nocoris-item-management', 'property-10', 'error-handling']);
    });
  });
}
