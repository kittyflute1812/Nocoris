import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:nocoris/features/item/models/item.dart';

/// プロパティベーステスト用のヘルパー関数
class PropertyTestHelpers {
  static final Random _random = Random();

  /// ランダムなアイテムを生成する
  static Item generateRandomItem() {
    final name = _generateRandomString(1, 50);
    final count = _random.nextInt(1000);
    final icon = _random.nextBool() ? _generateRandomEmoji() : null;
    final now = DateTime.now();

    return Item(
      id: _generateRandomId(),
      name: name,
      count: count,
      icon: icon,
      createdAt: now.subtract(Duration(days: _random.nextInt(365))),
      updatedAt: now,
    );
  }

  /// ランダムな文字列を生成する
  static String _generateRandomString(int minLength, int maxLength) {
    final length = minLength + _random.nextInt(maxLength - minLength + 1);
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん';
    
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(_random.nextInt(chars.length)))
    );
  }

  /// ランダムな絵文字を生成する
  static String _generateRandomEmoji() {
    final emojis = [
      '🍎', '🍌', '🍊', '🍇', '🍓', '🥝', '🍑', '🥭', '🍍', '🥥',
      '🍅', '🥑', '🍆', '🥒', '🥕', '🌽', '🥔', '🍠', '🥐', '🍞',
      '🧀', '🥚', '🍳', '🥓', '🥩', '🍗', '🍖', '🌭', '🍔', '🍟',
      '🍕', '🥪', '🌮', '🌯', '🥙', '🧆', '🥘', '🍝', '🍜', '🍲',
      '🍛', '🍣', '🍱', '🥟', '🦪', '🍤', '🍙', '🍚', '🍘', '🍥',
      '🥠', '🥮', '🍢', '🍡', '🍧', '🍨', '🍦', '🥧', '🧁', '🍰',
      '🎂', '🍮', '🍭', '🍬', '🍫', '🍿', '🍩', '🍪', '🌰', '🥜',
      '🍯', '🥛', '🍼', '☕', '🍵', '🧃', '🥤', '🧋', '🍶', '🍾',
      '🍷', '🍸', '🍹', '🍺', '🍻', '🥂', '🥃', '🥤', '🧊', '🥢',
      '🍽️', '🍴', '🥄', '🔪', '🏺'
    ];
    
    return emojis[_random.nextInt(emojis.length)];
  }

  /// ランダムなIDを生成する
  static String _generateRandomId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           _random.nextInt(10000).toString();
  }

  /// ランダムな正の整数を生成する
  static int generateRandomPositiveInt([int max = 1000]) {
    return _random.nextInt(max) + 1;
  }

  /// ランダムな非負の整数を生成する
  static int generateRandomNonNegativeInt([int max = 1000]) {
    return _random.nextInt(max + 1);
  }

  /// ランダムなブール値を生成する
  static bool generateRandomBool() {
    return _random.nextBool();
  }

  /// テストデータをデバッグ出力する
  static void debugPrintTestData(dynamic data) {
    debugPrint('Debug Test Data: $data');
  }

  /// テスト統計を出力する
  static void printTestStatistics(int total, int passed, int failed) {
    debugPrint('\n--- Test Statistics ---');
    debugPrint('Total iterations: $total');
    debugPrint('Passed: $passed');
    debugPrint('Failed: $failed');
    if (total > 0) {
      debugPrint('Success rate: ${(passed / total * 100).toStringAsFixed(1)}%');
    }
    debugPrint('----------------------\n');
  }

  /// 有効なアイテム名を生成する（空でない文字列）
  static String generateValidItemName() {
    final names = [
      'りんご', 'みかん', 'バナナ', 'ぶどう', 'いちご',
      'トマト', 'きゅうり', 'にんじん', 'じゃがいも', 'たまねぎ',
      'パン', 'お米', 'パスタ', 'うどん', 'そば',
      'コーヒー', 'お茶', 'ジュース', '水', 'ミルク',
      'ノート', 'ペン', '消しゴム', '定規', 'はさみ',
      'タオル', 'せっけん', 'シャンプー', '歯ブラシ', 'ティッシュ'
    ];
    
    return names[_random.nextInt(names.length)];
  }

  /// 無効なアイテム名を生成する（空文字列や空白のみ）
  static String generateInvalidItemName() {
    final invalidNames = ['', ' ', '  ', '\t', '\n', '   \t  \n  '];
    return invalidNames[_random.nextInt(invalidNames.length)];
  }

  /// 範囲内のランダムな整数を生成する
  static int generateRandomIntInRange(int min, int max) {
    if (min > max) {
      throw ArgumentError('min must be less than or equal to max');
    }
    return min + _random.nextInt(max - min + 1);
  }

  /// アイテムのリストを生成する
  static List<Item> generateRandomItemList([int? count]) {
    final listSize = count ?? _random.nextInt(20) + 1;
    return List.generate(listSize, (_) => generateRandomItem());
  }

  /// アイテム名が有効かどうかを判定する
  static bool isValidItemName(String name) {
    if (name.isEmpty) return false;
    if (name.trim().isEmpty) return false;
    if (name.length > 100) return false; // AppConstants.maxNameLength
    return true;
  }

  /// 数量が有効かどうかを判定する
  static bool isValidCount(int count) {
    return count >= 0; // AppConstants.minCount
  }

  /// 有効な数量を生成する
  static int generateValidCount() {
    return _random.nextInt(1000); // 0-999の範囲で有効な数量
  }

  /// 絵文字アイコンを生成する
  static String generateEmojiIcon() {
    return _generateRandomEmoji();
  }
}
