---
inclusion: always
---

# Flutter開発ガイドライン

このプロジェクトのFlutter開発における包括的なガイドラインとベストプラクティスです。

## 0. Dartコーディング規約（必須遵守事項）

### 0.1 厳格なコード品質基準

**🚨 重要**: 以下の規約は必須遵守事項です。違反するコードは受け入れられません。

#### 実装時の必須チェック項目
- [ ] `flutter analyze` で警告ゼロを確認
- [ ] `getDiagnostics` ツールで診断結果をチェック
- [ ] 全てのlintルールをクリア
- [ ] 型安全性を最優先
- [ ] パフォーマンスを考慮した実装

### 0.2 禁止事項と推奨事項

#### ❌ 禁止事項
```dart
// ❌ print()の使用禁止
print('Debug message');

// ❌ 型注釈なしの変数宣言
var items = <Item>[];

// ❌ 不要なnewキーワード
var item = new Item();

// ❌ 非constコンストラクタ（可能な場合）
child: Text('Hello')

// ❌ 未使用のimport
import 'package:flutter/material.dart'; // 使用されていない場合
```

#### ✅ 推奨事項
```dart
// ✅ loggerパッケージを使用
logger.d('Debug message');
logger.e('Error occurred', error);

// ✅ 適切な型注釈
final List<Item> items = <Item>[];

// ✅ newキーワード省略
final item = Item();

// ✅ constコンストラクタを積極使用
child: const Text('Hello')

// ✅ 必要なimportのみ
import 'package:flutter/material.dart';
```

### 0.3 ログ出力ルール

#### Logger使用方法
```dart
import 'package:logger/logger.dart';

final logger = Logger();

// デバッグ情報
logger.d('Debug message');

// 情報
logger.i('Information message');

// 警告
logger.w('Warning message');

// エラー
logger.e('Error occurred', error, stackTrace);
```

#### ログレベル設定
```dart
// 本番環境では適切なログレベルを設定
final logger = Logger(
  level: kDebugMode ? Level.debug : Level.warning,
);
```

### 0.4 型安全性とNull安全性

#### 必須ルール
```dart
// ✅ 戻り値の型を明示
Future<bool> updateItem(String id) async {
  // 実装
}

// ✅ null認識演算子を活用
final name = item?.name ?? 'Unknown';

// ✅ late使用時は初期化を保証
late final ItemService _itemService;

// ❌ null assertion(!)の乱用を避ける
// final name = item!.name; // 危険
```

### 0.5 パフォーマンス最適化

#### 必須実装パターン
```dart
// ✅ constコンストラクタの積極使用
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: const Text('Static text'), // const使用
    );
  }
}

// ✅ ListView.builderの使用
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)

// ✅ 適切なリソース管理
class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _controller.dispose(); // 必須
    super.dispose();
  }
}
```

### 0.6 実装品質チェックリスト

#### コード提出前の必須確認事項
1. **静的解析**: `flutter analyze` で警告ゼロ
2. **診断チェック**: `getDiagnostics` で問題なし
3. **フォーマット**: `dart format` でコード整形
4. **テスト**: 関連するテストが全て通過
5. **パフォーマンス**: 不要な再描画やメモリリークなし
6. **型安全性**: null安全性とtype safetyを確保
7. **リソース管理**: 適切なdisposeとクリーンアップ

#### 実装時の心構え
- **品質第一**: 動作するだけでなく、保守しやすいコードを書く
- **一貫性**: プロジェクト全体で統一されたスタイルを維持
- **可読性**: 他の開発者が理解しやすいコードを心がける
- **パフォーマンス**: ユーザー体験を最優先に考慮
- **安全性**: null安全性と型安全性を徹底

**これらの規約に従わないコードは、品質基準を満たさないため受け入れられません。**

## 1. コード構成と構造

### 1.1 ディレクトリ構造のベストプラクティス

**`lib/` (ソースコード):**
- 機能ベースの構造を使用し、関連するコンポーネントをモジュールにグループ化します。
- 例:
```
lib/
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── home/
│       ├── models/
│       ├── screens/
│       └── widgets/
├── common/
│   ├── models/
│   ├── widgets/
│   └── utils/
├── core/
│   ├── services/
│   ├── theme/
│   └── constants/
├── main.dart
└── app.dart
```

**`test/` (テスト):** テストの検出を容易にするため、`lib/` の構造をミラーリングします。

**`assets/` (アセット):** 画像、フォント、その他の静的リソースを保存します。タイプ別にサブフォルダを整理します（例: `images/`, `fonts/`, `data/`）。

### 1.2 ファイル命名規則

- ファイル名には `snake_case` を使用します（例: `user_profile_screen.dart`）
- ファイル内のクラスについて、ファイル名は通常、含まれるメインクラスを反映します
- 例: `user_profile_screen.dart` に `UserProfileScreen` を含む

### 1.3 モジュール構成

- モジュールは特定の機能または機能性をカプセル化します
- モジュールは明確に定義されたインターフェースを持ち、他のモジュールへの依存関係を最小限に抑える必要があります
- 各モジュール内でレイヤードアーキテクチャを実装します（例: UI、ビジネスロジック、データアクセス）

### 1.4 コンポーネントアーキテクチャ

- Flutterウィジェットを使用したコンポーネントベースのアーキテクチャを優先します
- 複雑なUIをより小さな再利用可能なウィジェットに分解します
- プレゼンテーションロジックをビジネスロジックから分離します
- ウィジェットは入力データ（状態）の純粋関数である必要があります

## 2. 一般的なパターンとアンチパターン

### 2.1 Flutter固有のデザインパターン

- **Provider:** シンプルな依存性注入と状態管理ソリューション
- **Riverpod:** コンパイル時の安全性を備えたProviderの改良版
- **BLoC (Business Logic Component):** ビジネスロジックをUIから分離
- **MVVM (Model-View-ViewModel):** 関心の分離のためのパターン

### 2.2 一般的なタスクの推奨アプローチ

- **状態管理:** アプリの複雑さに適合する状態管理ソリューションを選択
- **ネットワーキング:** APIリクエストには `http` パッケージまたは `dio` を使用
- **非同期操作:** 非同期操作の処理には `async/await` を使用
- **データ永続化:** シンプルなデータストレージには `shared_preferences` を使用
- **ナビゲーション:** 型安全なナビゲーションには `go_router` を使用
- **フォーム処理:** バリデーター付きの `TextFormField` で `Form` ウィジェットを使用

### 2.3 避けるべきアンチパターン

- **巨大なウィジェット:** ロジックやUIコードが多すぎるウィジェット
- **ウィジェット内のロジック:** ウィジェット内にビジネスロジックを直接配置することを避ける
- **深くネストされたウィジェット:** パフォーマンスの問題や読みにくいコードにつながる
- **管理されていない状態:** リソースの破棄を忘れると、メモリリークにつながる
- **ハードコードされた値:** 色、サイズ、文字列などの値をハードコードすることを避ける
- **エラーの無視:** 例外を適切に処理しないと、予期しないクラッシュにつながる

## 3. パフォーマンスの考慮事項

### 3.1 最適化手法

- **不要なウィジェットの再構築を回避:** 不変ウィジェットには `const` コンストラクタを使用
- **`setState` 呼び出しを最小化:** 状態管理ソリューションを使用して状態更新を最適化
- **`ListView.builder` または `GridView.builder` を使用:** 大きなリストやグリッドでは、ウィジェットを遅延的に構築
- **`RepaintBoundary` を使用:** 頻繁に再描画する必要のないUI部分を分離

### 3.2 メモリ管理

- `dispose` メソッドで `StreamSubscription`、`AnimationController`、`TextEditingController` などのリソースを破棄
- 不要なオブジェクトの作成を避ける
- グローバル変数と静的フィールドの使用を最小限に抑える

## 4. セキュリティのベストプラクティス

### 4.1 一般的な脆弱性とその防止方法

- **データインジェクション:** ユーザー入力をサニタイズして、インジェクション攻撃を防ぐ
- **機密データの保存:** プレーンテキストで機密データを保存することを避ける
- **安全でないAPI通信:** すべてのAPI通信にHTTPSを使用
- **コード改ざん:** コードの難読化を使用して、リバースエンジニアリングを困難にする

### 4.2 入力検証

- クライアント側とサーバー側の両方でユーザー入力を検証
- 正規表現またはカスタム検証ロジックを使用してデータ制約を適用
- UIに表示する前にデータを適切にエンコード

## 5. テストアプローチ

### 5.1 単体テスト戦略

- 個々の関数、クラス、ウィジェットを分離してテスト
- モックオブジェクトを使用して、テスト対象のコードを依存関係から分離
- すべての重要なビジネスロジックに対してテストを記述

### 5.2 統合テスト

- アプリの異なる部分間の相互作用をテスト
- APIやデータベースなどの外部サービスとの統合をテスト

### 5.3 テストの構成

- `lib/` ディレクトリ構造をミラーリングする `test/` ディレクトリを作成
- 説明的なテスト名を使用
- テストを小さく焦点を絞ったものに保つ

## 6. よくある落とし穴と注意点

### 6.1 開発者がよく犯すミス

- リソースの破棄を忘れる
- エラーを無視する
- 値のハードコード
- `setState` の過度な使用
- 巨大なウィジェットの作成
- ユーザー入力の検証をしない

### 6.2 注意すべきエッジケース

- ネットワーク接続の問題
- デバイスの向きの変更
- バックグラウンドアプリの状態
- 低メモリ条件
- ローカライゼーションと国際化

### 6.3 デバッグ戦略

- デバッグとプロファイリングにFlutter DevToolsを使用
- ロギングを使用してエラーを追跡
- ブレークポイントを使用してコードをステップ実行
- Flutter Inspectorを使用してウィジェットツリーを検査

## 7. ツールと環境

### 7.1 推奨開発ツール

- Kiro IDE（推奨）
- Flutter DevTools
- Android EmulatorまたはiOS Simulator
- バージョン管理のためのGit

### 7.2 リンティングとフォーマット

- リンティングには `flutter_lints` パッケージを使用
- コードフォーマットには `dart format` を使用
- 保存時にコードを自動フォーマットするようにIDEを構成

### 7.3 デプロイのベストプラクティス

- 各プラットフォームのデプロイガイドラインに従う
- アプリの真正性を確保するためにコード署名を使用
- リリースを管理するためにバージョン管理を使用
- デプロイ後にアプリのクラッシュとエラーを監視

このガイドラインに従うことで、保守可能で高性能で安全なFlutterアプリを作成できます。
