import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocoris/features/item/models/item.dart';

/// プロパティベーステスト用のヘルパー関数とデータジェネレーター
class PropertyTestHelpers {
  static final _faker = Faker();
  static final _random = Random();

  /// プロパティテストの設定
  static const int defaultIterations = 100;
  static const int maxIterations = 1000;

  /// プロパティテストを実行するヘルパー関数
  /// 
  /// [property]: テストするプロパティ関数
  /// [iterations]: 実行回数（デフォルト: 100回）
  /// [description]: テストの説明
  /// [tags]: テストタグ（Feature: nocoris-item-management, Property X: ...）
  static void runPropertyTest<T>({
    required String description,
    required bool Function(T) property,
    required T Function() generator,
    int iterations = defaultIterations,
    List<String>? tags,
  }) {
    test(
      description,
      () {
        for (int i = 0; i < iterations; i++) {
          final testData = generator();
          final result = property(testData);
          
          if (!result) {
            fail('Property failed on iteration ${i + 1} with data: $testData');
          }
        }
      },
      tags: tags,
    );
  }

  /// 複数の入力を持つプロパティテストを実行するヘルパー関数
  static void runPropertyTest2<T1, T2>({
    required String description,
    required bool Function(T1, T2) property,
    required T1 Function() generator1,
    required T2 Function() generator2,
    int iterations = defaultIterations,
    List<String>? tags,
  }) {
    test(
      description,
      () {
        for (int i = 0; i < iterations; i++) {
          final testData1 = generator1();
          final testData2 = generator2();
          final result = property(testData1, testData2);
          
          if (!result) {
            fail('Property failed on iteration ${i + 1} with data: ($testData1, $testData2)');
          }
        }
      },
      tags: tags,
    );
  }

  /// 3つの入力を持つプロパティテストを実行するヘルパー関数
  static void runPropertyTest3<T1, T2, T3>({
    required String description,
    required bool Function(T1, T2, T3) property,
    required T1 Function() generator1,
    required T2 Function() generator2,
    required T3 Function() generator3,
    int iterations = defaultIterations,
    List<String>? tags,
  }) {
    test(
      description,
      () {
        for (int i = 0; i < iterations; i++) {
          final testData1 = generator1();
          final testData2 = generator2();
          final testData3 = generator3();
          final result = property(testData1, testData2, testData3);
          
          if (!result) {
            fail('Property failed on iteration ${i + 1} with data: ($testData1, $testData2, $testData3)');
          }
        }
      },
      tags: tags,
    );
  }

  // ===== データジェネレーター =====

  /// 有効なアイテム名を生成する
  static String generateValidItemName() {
    final options = [
      _faker.food.dish(),
      _faker.lorem.word(),
      '${_faker.lorem.word()} ${_faker.lorem.word()}',
      _faker.person.firstName(),
      _faker.company.name(),
      _faker.animal.name(),
      '${_faker.lorem.word()} アイテム',
      'テスト${_faker.lorem.word()}',
    ];
    return options[_random.nextInt(options.length)];
  }

  /// 無効なアイテム名を生成する（空文字列、空白のみ）
  static String generateInvalidItemName() {
    final options = [
      '',           // 空文字列
      ' ',          // 空白1つ
      '  ',         // 空白2つ
      '\t',         // タブ
      '\n',         // 改行
      '   \t  ',    // 空白とタブの組み合わせ
    ];
    return options[_random.nextInt(options.length)];
  }

  /// 有効な数量を生成する（0以上の整数）
  static int generateValidCount() {
    return _random.nextInt(1000); // 0-999の範囲
  }

  /// 1以上の数量を生成する
  static int generatePositiveCount() {
    return _random.nextInt(999) + 1; // 1-999の範囲
  }

  /// 絵文字アイコンを生成する
  static String generateEmojiIcon() {
    final emojis = [
      '🐿️', '🥜', '🌰', '🍎', '🍊', '🍌', '🍇', '🍓', '🥕', '🥔',
      '🍞', '🥛', '🧀', '🥚', '🍖', '🐟', '🍚', '🍜', '☕', '🍵',
      '📱', '💻', '📚', '✏️', '🔑', '💡', '🔋', '📷', '🎧', '⌚',
      '👕', '👖', '👟', '🧦', '🎒', '👓', '🧴', '🧼', '🪥', '💊',
    ];
    return emojis[_random.nextInt(emojis.length)];
  }

  /// ランダムなアイテムを生成する
  static Item generateRandomItem() {
    return Item.create(
      name: generateValidItemName(),
      initialCount: generateValidCount(),
      icon: _random.nextBool() ? generateEmojiIcon() : null,
    );
  }

  /// 指定された名前でアイテムを生成する
  static Item generateItemWithName(String name) {
    return Item.create(
      name: name,
      initialCount: generateValidCount(),
      icon: _random.nextBool() ? generateEmojiIcon() : null,
    );
  }

  /// 指定された数量でアイテムを生成する
  static Item generateItemWithCount(int count) {
    return Item.create(
      name: generateValidItemName(),
      initialCount: count,
      icon: _random.nextBool() ? generateEmojiIcon() : null,
    );
  }

  /// 指定されたアイコンでアイテムを生成する
  static Item generateItemWithIcon(String? icon) {
    return Item.create(
      name: generateValidItemName(),
      initialCount: generateValidCount(),
      icon: icon,
    );
  }

  /// アイテムのリストを生成する
  static List<Item> generateItemList({int? length}) {
    final listLength = length ?? _random.nextInt(20) + 1; // 1-20個
    return List.generate(listLength, (_) => generateRandomItem());
  }

  /// 空のアイテムリストを生成する
  static List<Item> generateEmptyItemList() {
    return <Item>[];
  }

  /// アイテムの更新データを生成する
  static Map<String, dynamic> generateItemUpdateData() {
    final updates = <String, dynamic>{};
    
    // ランダムに更新するフィールドを選択
    if (_random.nextBool()) {
      updates['name'] = generateValidItemName();
    }
    if (_random.nextBool()) {
      updates['count'] = generateValidCount();
    }
    if (_random.nextBool()) {
      updates['icon'] = _random.nextBool() ? generateEmojiIcon() : null;
    }
    
    return updates;
  }

  /// ストレージエラーをシミュレートするかどうかを決定する
  static bool shouldSimulateStorageError() {
    return _random.nextDouble() < 0.1; // 10%の確率でエラー
  }

  /// テストタグを生成する
  static List<String> generatePropertyTestTags(int propertyNumber, String propertyDescription) {
    return [
      'Feature: nocoris-item-management',
      'Property $propertyNumber: $propertyDescription',
      'property-based-test',
    ];
  }

  // ===== バリデーション用ヘルパー =====

  /// アイテム名が有効かどうかを判定する
  static bool isValidItemName(String name) {
    return name.trim().isNotEmpty;
  }

  /// 数量が有効かどうかを判定する
  static bool isValidCount(int count) {
    return count >= 0;
  }

  /// アイテムが等しいかどうかを判定する（IDを除く）
  static bool areItemsEqualExceptId(Item item1, Item item2) {
    return item1.name == item2.name &&
           item1.count == item2.count &&
           item1.icon == item2.icon;
  }

  /// アイテムリストに指定されたアイテムが含まれているかを判定する
  static bool listContainsItem(List<Item> list, Item item) {
    return list.any((listItem) => listItem.id == item.id);
  }

  /// アイテムリストから指定されたIDのアイテムを削除したリストを返す
  static List<Item> removeItemFromList(List<Item> list, String itemId) {
    return list.where((item) => item.id != itemId).toList();
  }

  /// 2つのアイテムリストが同じ内容かどうかを判定する（順序は無視）
  static bool areItemListsEqual(List<Item> list1, List<Item> list2) {
    if (list1.length != list2.length) return false;
    
    for (final item1 in list1) {
      if (!list2.any((item2) => item1.id == item2.id)) {
        return false;
      }
    }
    return true;
  }

  // ===== デバッグ用ヘルパー =====

  /// テストデータの詳細情報を出力する
  static void debugPrintTestData(dynamic data) {
    print('Test data: $data');
    if (data is Item) {
      print('  ID: ${data.id}');
      print('  Name: "${data.name}"');
      print('  Count: ${data.count}');
      print('  Icon: ${data.icon}');
      print('  Created: ${data.createdAt}');
      print('  Updated: ${data.updatedAt}');
    }
  }

  /// プロパティテストの実行統計を出力する
  static void printTestStatistics(int iterations, int passed, int failed) {
    print('Property Test Statistics:');
    print('  Total iterations: $iterations');
    print('  Passed: $passed');
    print('  Failed: $failed');
    print('  Success rate: ${(passed / iterations * 100).toStringAsFixed(2)}%');
  }
}
