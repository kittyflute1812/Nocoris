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
  static void runPropertyGroup(String description, void Function() testFunction) {
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
      debugPrint('Success rate: ${(_passedTests / _totalTests * 100).toStringAsFixed(1)}%');
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
  static void printPropertyStatistics(String propertyName, int iterations, int passed, int failed) {
    debugPrint('\n--- $propertyName Statistics ---');
    debugPrint('Iterations: $iterations');
    debugPrint('Passed: $passed');
    debugPrint('Failed: $failed');
    debugPrint('Success rate: ${(passed / iterations * 100).toStringAsFixed(1)}%');
    debugPrint('--------------------------------\n');
  }
}
