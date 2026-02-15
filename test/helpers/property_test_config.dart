/// プロパティベーステストの設定とコンフィギュレーション
class PropertyTestConfig {
  /// デフォルトの反復回数（最低100回）
  static const int defaultIterations = 100;

  /// 最大反復回数
  static const int maxIterations = 1000;

  /// 短時間テスト用の反復回数
  static const int quickIterations = 50;

  /// 詳細テスト用の反復回数
  static const int thoroughIterations = 500;

  /// プロパティテストのタグ設定
  static const String featureTag = 'Feature: nocoris-item-management';
  static const String propertyTestTag = 'property-based-test';

  /// 各プロパティの定義
  static const Map<int, String> propertyDescriptions = {
    1: 'アイテム作成によるリスト拡張',
    2: '無効入力の拒否',
    3: 'アイコン設定の一貫性',
    4: '数量設定の正確性',
    5: 'アイテム表示の完全性',
    6: 'インクリメント操作の正確性',
    7: 'デクリメント操作の正確性',
    8: '編集フォーム情報の一致',
    9: 'アイテム更新の反映',
    10: 'アイテム削除の完全性',
    11: 'データ永続化のラウンドトリップ',
    12: 'エラー処理の堅牢性',
  };

  /// 各プロパティが検証する要件
  static const Map<int, List<String>> propertyRequirements = {
    1: ['要件 1.1'],
    2: ['要件 1.3', '要件 4.4'],
    3: ['要件 1.2', '要件 8.2'],
    4: ['要件 1.4'],
    5: ['要件 2.2'],
    6: ['要件 3.1'],
    7: ['要件 3.2'],
    8: ['要件 4.1'],
    9: ['要件 4.2', '要件 4.3'],
    10: ['要件 5.2'],
    11: ['要件 1.6', '要件 3.5', '要件 4.5', '要件 5.4', '要件 6.1'],
    12: ['要件 6.3'],
  };

  /// プロパティテストのタグを生成する
  static List<String> generateTags(int propertyNumber) {
    final description = propertyDescriptions[propertyNumber];
    if (description == null) {
      throw ArgumentError('Invalid property number: $propertyNumber');
    }

    return [
      'nocoris-item-management',
      'property-$propertyNumber',
      'property-based-test',
    ];
  }

  /// プロパティの説明を取得する
  static String getPropertyDescription(int propertyNumber) {
    final description = propertyDescriptions[propertyNumber];
    if (description == null) {
      throw ArgumentError('Invalid property number: $propertyNumber');
    }
    return description;
  }

  /// プロパティが検証する要件を取得する
  static List<String> getPropertyRequirements(int propertyNumber) {
    final requirements = propertyRequirements[propertyNumber];
    if (requirements == null) {
      throw ArgumentError('Invalid property number: $propertyNumber');
    }
    return requirements;
  }

  /// すべてのプロパティ番号を取得する
  static List<int> getAllPropertyNumbers() {
    return propertyDescriptions.keys.toList()..sort();
  }

  /// プロパティテストのデフォルトタイムアウト
  static const Duration defaultTestTimeout = Duration(minutes: 10);
}
