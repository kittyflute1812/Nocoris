import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// プロパティベーステストのフレームワーク
///
/// プロパティベーステストの実行と管理を行うためのユーティリティクラス
class PropertyTestFramework {
  static int _totalTests = 0;
  static int _passedTests = 0;
  static int _failedTests = 0;

  /// すべてのプロパティテストを実行する
  static void runAllProperties(void Function() testFunction) {
    group('Property-Based Tests', () {
      setUp(() {
        _resetCounters();
      });

      testFunction();

      tearDown(() {
        _printFinalStatistics();
      });
    });
  }

  /// プロパティテストのグループを実行する
  static void runPropertyGroup(
      String description, void Function() testFunction) {
    group(description, () {
      testFunction();
    });
  }

  /// テストカウンターをリセット
  static void _resetCounters() {
    _totalTests = 0;
    _passedTests = 0;
    _failedTests = 0;
  }

  /// 最終統計を出力
  static void _printFinalStatistics() {
    if (_totalTests > 0) {
      debugPrint('\n=== Property Test Summary ===');
      debugPrint('Total tests: $_totalTests');
      debugPrint('Passed: $_passedTests');
      debugPrint('Failed: $_failedTests');
      debugPrint(
          'Success rate: ${(_passedTests / _totalTests * 100).toStringAsFixed(1)}%');
      debugPrint('=============================\n');
    }
  }

  /// テスト結果を記録
  static void recordTestResult(bool passed) {
    _totalTests++;
    if (passed) {
      _passedTests++;
    } else {
      _failedTests++;
    }
  }

  /// プロパティテストの実行統計を出力
  static void printPropertyStatistics(
      String propertyName, int iterations, int passed, int failed) {
    debugPrint('\n--- $propertyName Statistics ---');
    debugPrint('Iterations: $iterations');
    debugPrint('Passed: $passed');
    debugPrint('Failed: $failed');
    debugPrint(
        'Success rate: ${(passed / iterations * 100).toStringAsFixed(1)}%');
    debugPrint('--------------------------------\n');
  }

  /// 単一パラメータのプロパティテストを実行する
  static void runProperty<T>(
      {required int propertyNumber,
      required bool Function(T) property,
      required T Function() generator,
      int? iterations}) {
    validatePropertyTest(
      propertyNumber: propertyNumber,
      property: property,
      generator: generator,
    );

    final testIterations = iterations ?? 100;

    test('Property $propertyNumber test', () {
      int passed = 0;
      int failed = 0;

      for (int i = 0; i < testIterations; i++) {
        final input = generator();
        final result = property(input);

        if (result) {
          passed++;
        } else {
          failed++;
        }
      }

      printPropertyStatistics(
          'Property $propertyNumber', testIterations, passed, failed);

      if (failed > 0) {
        fail('Property $propertyNumber failed $failed/$testIterations times');
      }
    });
  }

  /// 2つのパラメータのプロパティテストを実行する
  static void runProperty2<T1, T2>(
      {required int propertyNumber,
      required bool Function(T1, T2) property,
      required T1 Function() generator1,
      required T2 Function() generator2,
      int? iterations}) {
    final testIterations = iterations ?? 100;

    test('Property $propertyNumber test (2 params)', () {
      int passed = 0;
      int failed = 0;

      for (int i = 0; i < testIterations; i++) {
        final input1 = generator1();
        final input2 = generator2();
        final result = property(input1, input2);

        if (result) {
          passed++;
        } else {
          failed++;
        }
      }

      printPropertyStatistics(
          'Property $propertyNumber', testIterations, passed, failed);

      if (failed > 0) {
        fail('Property $propertyNumber failed $failed/$testIterations times');
      }
    });
  }

  /// 3つのパラメータのプロパティテストを実行する
  static void runProperty3<T1, T2, T3>(
      {required int propertyNumber,
      required bool Function(T1, T2, T3) property,
      required T1 Function() generator1,
      required T2 Function() generator2,
      required T3 Function() generator3,
      int? iterations}) {
    final testIterations = iterations ?? 100;

    test('Property $propertyNumber test (3 params)', () {
      int passed = 0;
      int failed = 0;

      for (int i = 0; i < testIterations; i++) {
        final input1 = generator1();
        final input2 = generator2();
        final input3 = generator3();
        final result = property(input1, input2, input3);

        if (result) {
          passed++;
        } else {
          failed++;
        }
      }

      printPropertyStatistics(
          'Property $propertyNumber', testIterations, passed, failed);

      if (failed > 0) {
        fail('Property $propertyNumber failed $failed/$testIterations times');
      }
    });
  }

  /// プロパティテストのバリデーションを行う
  static void validatePropertyTest<T>({
    required int propertyNumber,
    required bool Function(T) property,
    required T Function() generator,
  }) {
    if (propertyNumber < 1 || propertyNumber > 12) {
      throw ArgumentError(
          'Property number must be between 1 and 12, got: $propertyNumber');
    }
  }
}
