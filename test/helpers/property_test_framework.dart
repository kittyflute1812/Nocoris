import 'package:flutter_test/flutter_test.dart';
import 'property_test_config.dart';
import 'property_test_helpers.dart';

/// プロパティベーステストを実行するためのフレームワーク
class PropertyTestFramework {
  /// プロパティテストを実行する
  /// 
  /// [propertyNumber]: プロパティ番号（1-12）
  /// [property]: テストするプロパティ関数
  /// [generator]: テストデータを生成する関数
  /// [iterations]: 実行回数（省略時はデフォルト値）
  /// [timeout]: テストのタイムアウト（省略時はデフォルト値）
  static void runProperty<T>({
    required int propertyNumber,
    required bool Function(T) property,
    required T Function() generator,
    int? iterations,
    Duration? timeout,
  }) {
    final description = PropertyTestConfig.getPropertyDescription(propertyNumber);
    final requirements = PropertyTestConfig.getPropertyRequirements(propertyNumber);
    final tags = PropertyTestConfig.generateTags(propertyNumber);
    final testIterations = iterations ?? PropertyTestConfig.defaultIterations;
    final testTimeout = timeout ?? PropertyTestConfig.getTestTimeout();

    test(
      'Property $propertyNumber: $description',
      () {
        print('実行中: Property $propertyNumber - $description');
        print('検証対象: ${requirements.join(', ')}');
        print('反復回数: $testIterations');
        
        int passedCount = 0;
        int failedCount = 0;
        
        for (int i = 0; i < testIterations; i++) {
          try {
            final testData = generator();
            final result = property(testData);
            
            if (result) {
              passedCount++;
            } else {
              failedCount++;
              PropertyTestHelpers.debugPrintTestData(testData);
              fail('Property $propertyNumber failed on iteration ${i + 1} with data: $testData');
            }
          } catch (e, stackTrace) {
            failedCount++;
            print('Exception on iteration ${i + 1}: $e');
            print('Stack trace: $stackTrace');
            rethrow;
          }
        }
        
        PropertyTestHelpers.printTestStatistics(testIterations, passedCount, failedCount);
        print('Property $propertyNumber: すべてのテストが成功しました');
      },
      tags: tags,
      timeout: Timeout(testTimeout),
    );
  }

  /// 2つの入力を持つプロパティテストを実行する
  static void runProperty2<T1, T2>({
    required int propertyNumber,
    required bool Function(T1, T2) property,
    required T1 Function() generator1,
    required T2 Function() generator2,
    int? iterations,
    Duration? timeout,
  }) {
    final description = PropertyTestConfig.getPropertyDescription(propertyNumber);
    final requirements = PropertyTestConfig.getPropertyRequirements(propertyNumber);
    final tags = PropertyTestConfig.generateTags(propertyNumber);
    final testIterations = iterations ?? PropertyTestConfig.defaultIterations;
    final testTimeout = timeout ?? PropertyTestConfig.getTestTimeout();

    test(
      'Property $propertyNumber: $description',
      () {
        print('実行中: Property $propertyNumber - $description');
        print('検証対象: ${requirements.join(', ')}');
        print('反復回数: $testIterations');
        
        int passedCount = 0;
        int failedCount = 0;
        
        for (int i = 0; i < testIterations; i++) {
          try {
            final testData1 = generator1();
            final testData2 = generator2();
            final result = property(testData1, testData2);
            
            if (result) {
              passedCount++;
            } else {
              failedCount++;
              print('Test data 1: $testData1');
              print('Test data 2: $testData2');
              fail('Property $propertyNumber failed on iteration ${i + 1} with data: ($testData1, $testData2)');
            }
          } catch (e, stackTrace) {
            failedCount++;
            print('Exception on iteration ${i + 1}: $e');
            print('Stack trace: $stackTrace');
            rethrow;
          }
        }
        
        PropertyTestHelpers.printTestStatistics(testIterations, passedCount, failedCount);
        print('Property $propertyNumber: すべてのテストが成功しました');
      },
      tags: tags,
      timeout: Timeout(testTimeout),
    );
  }

  /// 3つの入力を持つプロパティテストを実行する
  static void runProperty3<T1, T2, T3>({
    required int propertyNumber,
    required bool Function(T1, T2, T3) property,
    required T1 Function() generator1,
    required T2 Function() generator2,
    required T3 Function() generator3,
    int? iterations,
    Duration? timeout,
  }) {
    final description = PropertyTestConfig.getPropertyDescription(propertyNumber);
    final requirements = PropertyTestConfig.getPropertyRequirements(propertyNumber);
    final tags = PropertyTestConfig.generateTags(propertyNumber);
    final testIterations = iterations ?? PropertyTestConfig.defaultIterations;
    final testTimeout = timeout ?? PropertyTestConfig.getTestTimeout();

    test(
      'Property $propertyNumber: $description',
      () {
        print('実行中: Property $propertyNumber - $description');
        print('検証対象: ${requirements.join(', ')}');
        print('反復回数: $testIterations');
        
        int passedCount = 0;
        int failedCount = 0;
        
        for (int i = 0; i < testIterations; i++) {
          try {
            final testData1 = generator1();
            final testData2 = generator2();
            final testData3 = generator3();
            final result = property(testData1, testData2, testData3);
            
            if (result) {
              passedCount++;
            } else {
              failedCount++;
              print('Test data 1: $testData1');
              print('Test data 2: $testData2');
              print('Test data 3: $testData3');
              fail('Property $propertyNumber failed on iteration ${i + 1} with data: ($testData1, $testData2, $testData3)');
            }
          } catch (e, stackTrace) {
            failedCount++;
            print('Exception on iteration ${i + 1}: $e');
            print('Stack trace: $stackTrace');
            rethrow;
          }
        }
        
        PropertyTestHelpers.printTestStatistics(testIterations, passedCount, failedCount);
        print('Property $propertyNumber: すべてのテストが成功しました');
      },
      tags: tags,
      timeout: Timeout(testTimeout),
    );
  }

  /// すべてのプロパティテストを実行するためのグループを作成する
  static void runAllProperties(void Function() testDefinitions) {
    group('Property-Based Tests - 正確性プロパティ', () {
      setUpAll(() {
        print('=== プロパティベーステスト開始 ===');
        print('Feature: nocoris-item-management');
        print('総プロパティ数: ${PropertyTestConfig.getAllPropertyNumbers().length}');
        print('各プロパティの最低反復回数: ${PropertyTestConfig.defaultIterations}');
      });

      tearDownAll(() {
        print('=== プロパティベーステスト完了 ===');
      });

      testDefinitions();
    });
  }

  /// 特定のプロパティグループのテストを実行する
  static void runPropertyGroup(String groupName, void Function() testDefinitions) {
    group('Property Group: $groupName', () {
      setUpAll(() {
        print('=== プロパティグループ開始: $groupName ===');
      });

      tearDownAll(() {
        print('=== プロパティグループ完了: $groupName ===');
      });

      testDefinitions();
    });
  }

  /// プロパティテストの実行前チェック
  static void validatePropertyTest({
    required int propertyNumber,
    required Function property,
    required Function generator,
  }) {
    if (propertyNumber < 1 || propertyNumber > 12) {
      throw ArgumentError('Property number must be between 1 and 12, got: $propertyNumber');
    }

    if (!PropertyTestConfig.propertyDescriptions.containsKey(propertyNumber)) {
      throw ArgumentError('Unknown property number: $propertyNumber');
    }
  }

  /// テスト実行環境の情報を出力する
  static void printTestEnvironmentInfo() {
    print('=== テスト実行環境情報 ===');
    print('デフォルト反復回数: ${PropertyTestConfig.defaultIterations}');
    print('最大反復回数: ${PropertyTestConfig.maxIterations}');
    print('テストタイムアウト: ${PropertyTestConfig.getTestTimeout()}');
    print('リトライ回数: ${PropertyTestConfig.getRetryCount()}');
    print('並列実行: ${PropertyTestConfig.isParallelExecutionAllowed()}');
    print('========================');
  }
}
