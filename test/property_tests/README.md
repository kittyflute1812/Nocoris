# プロパティベーステスト

このディレクトリには、Nocorisアイテム管理機能の正確性プロパティを検証するプロパティベーステストが含まれています。

## 概要

プロパティベーステストは、システムの普遍的な特性（プロパティ）をランダムなデータで検証するテスト手法です。従来の単体テストが特定の例をテストするのに対し、プロパティベーステストは大量のランダムデータでシステムの動作を検証します。

## 設定

### 必要なパッケージ

- `faker: ^2.1.0` - ランダムデータ生成用
- `flutter_test` - Flutterテストフレームワーク
- `mocktail: ^1.0.3` - モック作成用

### テスト実行設定

- **最低反復回数**: 100回（`PropertyTestConfig.defaultIterations`）
- **最大反復回数**: 1000回（`PropertyTestConfig.maxIterations`）
- **タイムアウト**: 10分（プロパティテスト用）
- **並列実行**: 2（重い処理のため制限）

## 12の正確性プロパティ

設計書で定義された12の正確性プロパティを検証します：

### データモデルのプロパティ（1-4）
1. **アイテム作成によるリスト拡張** - 要件 1.1
2. **無効入力の拒否** - 要件 1.3, 4.4
3. **アイコン設定の一貫性** - 要件 1.2, 8.2
4. **数量設定の正確性** - 要件 1.4

### ビジネスロジックのプロパティ（5-7, 10）
5. **アイテム表示の完全性** - 要件 2.2
6. **インクリメント操作の正確性** - 要件 3.1
7. **デクリメント操作の正確性** - 要件 3.2
10. **アイテム削除の完全性** - 要件 5.2

### UI・統合のプロパティ（8-9）
8. **編集フォーム情報の一致** - 要件 4.1
9. **アイテム更新の反映** - 要件 4.2, 4.3

### データ永続化のプロパティ（11-12）
11. **データ永続化のラウンドトリップ** - 要件 1.6, 3.5, 4.5, 5.4, 6.1
12. **エラー処理の堅牢性** - 要件 6.3

## ファイル構成

```
test/property_tests/
├── README.md                           # このファイル
├── setup_verification_test.dart        # セットアップ検証テスト
└── [将来実装予定]
    ├── data_model_properties_test.dart     # プロパティ1-4
    ├── business_logic_properties_test.dart # プロパティ5-7, 10
    ├── ui_integration_properties_test.dart # プロパティ8-9
    └── data_persistence_properties_test.dart # プロパティ11-12

test/helpers/
├── property_test_helpers.dart          # データジェネレーターとヘルパー関数
├── property_test_config.dart           # プロパティテスト設定
├── property_test_framework.dart        # プロパティテスト実行フレームワーク
└── test_helpers.dart                   # 既存テストヘルパー（更新済み）
```

## 使用方法

### 基本的なプロパティテストの実行

```dart
import '../helpers/property_test_framework.dart';
import '../helpers/property_test_helpers.dart';

void main() {
  PropertyTestFramework.runAllProperties(() {
    
    // 単一入力のプロパティテスト
    PropertyTestFramework.runProperty<String>(
      propertyNumber: 1,
      property: (name) {
        // プロパティロジック
        return true; // または false
      },
      generator: PropertyTestHelpers.generateValidItemName,
    );

    // 複数入力のプロパティテスト
    PropertyTestFramework.runProperty2<String, int>(
      propertyNumber: 4,
      property: (name, count) {
        // プロパティロジック
        return true; // または false
      },
      generator1: PropertyTestHelpers.generateValidItemName,
      generator2: PropertyTestHelpers.generateValidCount,
    );

  });
}
```

### データジェネレーターの使用

```dart
// 有効なアイテム名を生成
final name = PropertyTestHelpers.generateValidItemName();

// 無効なアイテム名を生成
final invalidName = PropertyTestHelpers.generateInvalidItemName();

// ランダムなアイテムを生成
final item = PropertyTestHelpers.generateRandomItem();

// 特定の条件でアイテムを生成
final itemWithIcon = PropertyTestHelpers.generateItemWithIcon('🐿️');
```

## テスト実行コマンド

```bash
# すべてのプロパティテストを実行
flutter test test/property_tests/ --reporter=expanded

# 特定のプロパティテストを実行
flutter test test/property_tests/ --tags=property-1

# セットアップ検証テストのみ実行
flutter test test/property_tests/setup_verification_test.dart

# プロパティベーステストのみ実行
flutter test --tags=property-based-test

# 詳細な出力で実行
flutter test test/property_tests/ --reporter=expanded --verbose
```

## デバッグとトラブルシューティング

### プロパティテストが失敗した場合

1. **失敗したデータを確認**: テスト出力に失敗したデータが表示されます
2. **プロパティの前提条件を確認**: 入力データが期待される範囲内かチェック
3. **実装のロジックを見直し**: プロパティが正しく実装されているか確認
4. **デバッグ出力を使用**: `PropertyTestHelpers.debugPrintTestData()`を使用

### パフォーマンスの最適化

- 反復回数を調整: `iterations`パラメータで調整
- 並列実行の制御: `dart_test.yaml`で`concurrency`を調整
- タイムアウトの調整: 重いテストには長めのタイムアウトを設定

## ベストプラクティス

1. **プロパティの明確な定義**: 各プロパティが何を検証するかを明確にする
2. **適切なデータジェネレーター**: テスト対象に適したランダムデータを生成
3. **エッジケースの考慮**: 境界値や特殊なケースも含める
4. **実行時間の管理**: 適切な反復回数とタイムアウトを設定
5. **失敗時の分析**: 失敗したケースから学び、実装を改善

## 今後の実装予定

- [ ] データモデルのプロパティテスト（プロパティ1-4）
- [ ] ビジネスロジックのプロパティテスト（プロパティ5-7, 10）
- [ ] UI・統合のプロパティテスト（プロパティ8-9）
- [ ] データ永続化のプロパティテスト（プロパティ11-12）
- [ ] CI/CDパイプラインでの自動実行
- [ ] カバレッジレポートの生成
- [ ] パフォーマンス測定とベンチマーク
