# Nocoris - 残数管理アプリ 🐿️

## 📱 概要

iPhoneユーザー向けの残数管理アプリケーション「Nocoris（ノコリス）」。日用品やアイテムの数量を簡単に管理し、ウィジェットからも操作可能なカウンターアプリです。

かわいいリスのキャラクターと一緒に、残数管理を楽しく便利に！

## 🎯 主な機能

- ✅ **アイテム管理**: 名前と数量を持つアイテムの作成・編集・削除
- ✅ **カウント操作**: インクリメント（+）・デクリメント（-）による残数管理
- ✅ **データ永続化**: ローカルストレージによる自動保存
- ✅ **ダークモード対応**: システム設定に応じた自動切り替え
- 🚧 **iOSホーム画面ウィジェット**: ホーム画面・ロック画面からの直接操作（開発予定）

## 🛠 技術スタック

### フレームワーク・言語
- **Flutter**: v3.29.3
- **Dart**: v3.7.2

### 主要パッケージ
- `shared_preferences` (v2.5.3): ローカルデータ永続化
- `uuid` (v4.3.3): ユニークID生成
- `logger` (v2.3.0): ロギング
- `mocktail` (v1.0.3): テスト用モック（開発依存）

### 対象プラットフォーム
- iOS（iPhone）
- macOS（開発・テスト用）
- Android（将来的に対応予定）

## 📂 プロジェクト構成

```
Nocoris/
├── lib/
│   ├── main.dart                    # アプリケーションのエントリーポイント
│   ├── models/
│   │   └── item.dart                # アイテムデータモデル
│   ├── screens/
│   │   ├── home_screen.dart         # メイン画面（アイテム一覧）
│   │   └── item_form_screen.dart    # アイテム作成・編集画面
│   ├── services/
│   │   ├── item_service.dart        # アイテム管理ビジネスロジック
│   │   └── storage_service.dart     # ローカルストレージ抽象化層
│   ├── theme/
│   │   └── app_theme.dart           # アプリケーションテーマ定義
│   └── widgets/
│       └── item_card.dart           # アイテム表示カード
├── test/
│   ├── helpers/
│   │   └── test_helpers.dart        # テストユーティリティ
│   ├── models/
│   │   └── item_test.dart           # アイテムモデルのテスト
│   ├── screens/                     # 画面のウィジェットテスト
│   ├── services/                    # サービス層の単体テスト
│   └── widgets/                     # ウィジェットの単体テスト
├── ios/                             # iOSプラットフォーム固有ファイル
├── macos/                           # macOSプラットフォーム固有ファイル
├── android/                         # Androidプラットフォーム固有ファイル
└── pubspec.yaml                     # パッケージ依存関係定義
```

## 🏗 システムアーキテクチャ

### レイヤー構成

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens & Widgets)                    │
│  - HomeScreen                           │
│  - ItemFormScreen                       │
│  - ItemCard                             │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Business Logic Layer            │
│  (Services)                             │
│  - ItemService                          │
│    - CRUD操作                           │
│    - カウント操作                        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Layer                      │
│  (Models & Storage)                     │
│  - Item (データモデル)                   │
│  - StorageService                       │
│    (shared_preferences抽象化)           │
└─────────────────────────────────────────┘
```

### データフロー

1. **画面表示**: `HomeScreen` → `ItemService.items` → `ItemCard`
2. **アイテム作成**: `ItemFormScreen` → `ItemService.createItem()` → `StorageService.saveItems()`
3. **カウント操作**: `ItemCard` → `ItemService.incrementItem()/decrementItem()` → `StorageService.saveItems()`
4. **データ永続化**: すべての変更操作後に自動的に `shared_preferences` へ保存

## 🚀 セットアップ

### 必要条件

- Flutter SDK (v3.29.3以上)
- Dart SDK (v3.7.2以上)
- Xcode 15以上（iOS開発用）
- CocoaPods（iOS依存関係管理）

### インストール手順

1. **リポジトリのクローン**
```bash
git clone https://github.com/tomomi-hirano/Nocoris.git
cd Nocoris
```

2. **依存パッケージのインストール**
```bash
flutter pub get
```

3. **iOS依存関係のインストール**
```bash
cd ios
pod install
cd ..
```

## 🎮 実行方法

### iOSシミュレータで実行

```bash
# シミュレータを起動
open -a Simulator

# アプリを実行
flutter run
```

### 特定のデバイスで実行

```bash
# 利用可能なデバイスを確認
flutter devices

# デバイスを指定して実行
flutter run -d <device-id>
```

### リリースビルド

```bash
# iOSリリースビルド
flutter build ios --release

# IPAファイルの生成（App Store配布用）
flutter build ipa
```

## 🧪 テスト

### すべてのテストを実行

```bash
flutter test
```

### 特定のテストファイルを実行

```bash
flutter test test/models/item_test.dart
```

### カバレッジレポートの生成

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📊 実装状況

### ✅ 完了した機能

- **アイテム管理**: CRUD操作（作成・読取・更新・削除）
- **カウント機能**: インクリメント・デクリメント・直接設定
- **データ永続化**: `shared_preferences`によるローカル保存
- **UI実装**: メイン画面、アイテム作成/編集画面
- **テーマ**: ライト/ダークモード対応
- **テスト**: 単体テスト、ウィジェットテスト（39テスト、すべてパス）
- **エラーハンドリング**: 非同期処理のエラー処理、ユーザーフィードバック

### 🚧 開発中・予定の機能

- **iOSホーム画面ウィジェット**: WidgetKitを使用したホーム画面・ロック画面ウィジェット
  - アイテムの残数表示
  - ウィジェットから直接カウントダウン
  - 小・中・大サイズ対応
- **パフォーマンス最適化**: メモリ使用量の最適化
- **追加機能**:
  - アイテムのカテゴリ分け
  - データのバックアップ/リストア
  - アイテムごとの通知（残数が少なくなった時）
  - 履歴機能（カウント変更履歴）

## 🔧 開発ガイドライン

### コーディング規約

- Dart公式スタイルガイドに準拠
- 変数名・メソッド名は `camelCase`
- プライベートメンバーは `_` で始める
- 非同期処理には `async/await` を使用
- エラーハンドリングは `try-catch` で実装

### テスト戦略

- **単体テスト**: すべてのモデルとサービスをテスト
- **ウィジェットテスト**: UI コンポーネントの動作確認
- **モック**: `mocktail` を使用してサービスをモック化
- **カバレッジ目標**: 80%以上

### Git ワークフロー

- `main` ブランチ: 本番環境用の安定版
- `develop` ブランチ: 開発中の機能統合
- フィーチャーブランチ: `feature/機能名` で作成
- バグ修正: `fix/バグ名` で作成

## 📝 ライセンス

MIT License - Copyright (c) 2025 tomomi-hirano

## 👤 作者

tomomi-hirano

## 🔗 関連リンク

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Dart言語ツアー](https://dart.dev/guides/language/language-tour)
- [shared_preferences パッケージ](https://pub.dev/packages/shared_preferences)
