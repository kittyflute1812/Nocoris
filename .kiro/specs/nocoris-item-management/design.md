# 設計書

## 概要

Nocoris（ノコリス）は、日用品やアイテムの残数を直感的に管理するFlutterアプリケーションです。本設計書では、承認された要件定義書に基づき、現在実装されているクリーンアーキテクチャとRiverpod状態管理を活用したシステム設計について説明します。

## アーキテクチャ

### 全体アーキテクチャ

Nocorisは4層のクリーンアーキテクチャを採用しています：

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│                  (UI & User Interaction)                    │
│              ConsumerWidget / ConsumerStatefulWidget        │
├─────────────────────────────────────────────────────────────┤
│                  State Management Layer                     │
│                    (Riverpod Providers)                     │
│           ChangeNotifierProvider / FutureProvider           │
├─────────────────────────────────────────────────────────────┤
│                  Business Logic Layer                       │
│              (Services & Domain Logic)                      │
│                  ChangeNotifier Services                    │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                             │
│              (Models & Data Persistence)                    │
│                  Immutable Data Models                      │
└─────────────────────────────────────────────────────────────┘
```

### 技術スタック

- **フレームワーク**: Flutter 3.7.2+
- **状態管理**: Riverpod 2.6.1
- **データ永続化**: shared_preferences 2.5.3
- **ユニークID生成**: uuid 4.3.3
- **ロギング**: logger 2.3.0
- **絵文字選択**: emoji_picker_flutter 3.1.0
- **テスト**: mocktail 1.0.3

## コンポーネントとインターフェース

### Presentation Layer（プレゼンテーション層）

#### HomeScreen
- **責務**: アイテム一覧表示、CRUD操作のトリガー、エラーハンドリング
- **状態管理**: ConsumerStatefulWidget + Riverpod
- **プラットフォーム対応**: iOS/macOSではCupertinoウィジェットを適切に使用
- **主要機能**:
  - アイテム一覧の表示（ListView.builder）
  - アイテム作成・編集・削除のナビゲーション
  - カウント操作（増減）のハンドリング
  - エラー表示とユーザーフィードバック
  - プラットフォーム固有のUI/UXガイドライン準拠

#### ItemFormScreen
- **責務**: アイテムの作成・編集フォーム
- **バリデーション**: アイテム名必須、数量0以上
- **主要機能**:
  - アイテム名・初期数量の入力
  - 絵文字アイコンの選択
  - フォームバリデーション
  - 作成・更新処理

#### ItemCard
- **責務**: 個別アイテムの表示と操作
- **主要機能**:
  - アイテム情報表示（名前、数量、アイコン）
  - インクリメント・デクリメントボタン
  - 編集・削除メニュー
  - アクセシビリティ対応

### State Management Layer（状態管理層）

#### Riverpod Providers

**itemServiceInitProvider (FutureProvider)**
```dart
final itemServiceInitProvider = FutureProvider<ItemService>((ref) async {
  return await ItemService.create();
});
```
- **責務**: ItemServiceの非同期初期化
- **戻り値**: AsyncValue<ItemService>（loading/data/error）

**itemServiceProvider (Provider)**
```dart
final itemServiceProvider = Provider<ItemService>((ref) {
  throw UnimplementedError('itemServiceProvider must be overridden');
});
```
- **責務**: 初期化済みItemServiceの提供
- **特徴**: テスト時にオーバーライド可能

#### 状態管理パターン

**ChangeNotifier + Riverpod パターン**:
1. ItemServiceがChangeNotifierを継承
2. 状態変更時にnotifyListeners()を呼び出し
3. UIはref.watch()で状態を監視
4. 自動的なUI再描画（setState不要）

### Business Logic Layer（ビジネスロジック層）

#### ItemService
- **責務**: アイテムのCRUD操作、カウント管理、データ永続化
- **継承**: ChangeNotifier（状態変更通知）
- **初期化**: ファクトリメソッドによる非同期初期化

**主要メソッド**:
- `create()`: StorageService初期化とItemService作成
- `createItem(name, count, icon)`: 新規アイテム作成
- `updateItem(id, count, icon)`: アイテム更新
- `deleteItem(id)`: アイテム削除
- `incrementItem(id)`: カウント+1
- `decrementItem(id)`: カウント-1

#### StorageService
- **責務**: shared_preferencesの抽象化、JSONシリアライゼーション
- **主要メソッド**:
  - `saveItems(items)`: アイテムリストの保存
  - `loadItems()`: アイテムリストの読み込み
  - `saveJson(key, json)`: 汎用JSON保存
  - `loadJson(key)`: 汎用JSON読み込み

### Data Layer（データ層）

#### Item Model
**設計原則**: 不変データモデル（Immutable）

```dart
class Item {
  final String id;           // UUID v4
  final String name;         // アイテム名
  final int count;           // 現在の数量
  final String? icon;        // 絵文字アイコン（オプション）
  final DateTime createdAt;  // 作成日時
  final DateTime updatedAt;  // 更新日時
}
```

**主要メソッド**:
- `copyWith({...})`: 指定フィールドを変更した新インスタンス
- `increment()`: カウント+1の新インスタンス
- `decrement()`: カウント-1の新インスタンス（0未満にならない）
- `fromJson(json)`: JSON → Item変換
- `toJson()`: Item → JSON変換
- `create(name, count, icon)`: 新規Item作成

#### copyWithメソッドの設計詳細

**センチネル値パターンの実装**:
オプショナルなフィールド（特に`icon`）において、「値が提供されなかった場合」と「nullに設定する場合」を区別するため、センチネル値パターンを採用しています。

```dart
class Item {
  // センチネル値の定義
  static const Object _sentinel = Object();
  
  Item copyWith({
    String? name,
    int? count,
    Object? icon = _sentinel,  // センチネル値をデフォルトに使用
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      count: count ?? this.count,
      icon: identical(icon, _sentinel) ? this.icon : icon as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
```

**パターンの利点**:
- `copyWith(icon: null)`: アイコンを明示的にnullに設定（削除）
- `copyWith()`: アイコンフィールドは変更せず既存値を維持
- 型安全性を保ちながら、意図的なnull設定と未指定を区別

このパターンは、nocoris-project-guidelines.mdで言及されている通り、freezedパッケージの`Value.absent()`と同様の機能を、外部ライブラリなしで実現します。

## データモデル

### Item Entity

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | String | ✓ | ユニークID（UUID v4） |
| name | String | ✓ | アイテム名 |
| count | int | ✓ | 現在の数量（0以上） |
| icon | String? | - | 絵文字アイコン |
| createdAt | DateTime | ✓ | 作成日時 |
| updatedAt | DateTime | ✓ | 最終更新日時 |

### ビジネスルール

1. **カウント制約**: 常に0以上の値
2. **ID生成**: UUID v4による自動生成
3. **更新日時**: 変更時に自動更新
4. **不変性**: すべてのフィールドがfinal
5. **アイコン**: 絵文字文字列（オプション）

### データフロー

```
ユーザー操作
    ↓
UI (ConsumerWidget)
    ↓
ref.read(itemServiceProvider).method()
    ↓
ItemService (ChangeNotifier)
    ├→ Item操作（不変オブジェクト）
    ├→ StorageService.saveItems()
    └→ notifyListeners()
        ↓
Riverpod検知
    ↓
ref.watch()使用Widget
    ↓
自動UI再描画
```

## 正確性プロパティ

*プロパティとは、システムのすべての有効な実行において真であるべき特性や動作のことです。これらは人間が読める仕様と機械で検証可能な正確性保証の橋渡しとなる正式な記述です。*
### プロパティ反映

プロパティの冗長性を排除するため、以下の統合を行います：

**統合されるプロパティ**:
- アイテム作成時のデータ永続化（1.6）とデータ変更時の永続化（3.5, 4.5, 6.1）→ 包括的なデータ永続化プロパティに統合
- アイテム作成時のアイコン設定（1.2）と絵文字選択時のアイコン設定（8.2）→ アイコン設定プロパティに統合
- 編集時の名前変更（4.2）とアイコン変更（4.3）→ アイテム更新プロパティに統合

### 正確性プロパティ

以下のプロパティは、前作業分析に基づいて要件から導出されています：

**プロパティ 1: アイテム作成によるリスト拡張**
*任意の*有効なアイテム名と初期数量に対して、アイテム作成操作を実行すると、アイテムリストの長さが1増加し、作成されたアイテムがリストに含まれる
**検証対象: 要件 1.1**

**プロパティ 2: 無効入力の拒否**
*任意の*無効なアイテム名（空文字列、空白のみの文字列）に対して、アイテム作成または更新操作は拒否され、システム状態は変更されない
**検証対象: 要件 1.3, 4.4**

**プロパティ 3: アイコン設定の一貫性**
*任意の*絵文字アイコンに対して、アイテム作成時または更新時にアイコンを設定すると、そのアイコンがアイテムに正しく関連付けられる
**検証対象: 要件 1.2, 8.2**

**プロパティ 4: 数量設定の正確性**
*任意の*有効な数量（0以上の整数）に対して、アイテム作成時に数量を設定すると、作成されたアイテムにその数量が正しく設定される
**検証対象: 要件 1.4**

**プロパティ 5: アイテム表示の完全性**
*任意の*アイテムに対して、表示機能を実行すると、アイテム名、現在の数量、設定されたアイコンのすべてが含まれる
**検証対象: 要件 2.2**

**プロパティ 6: インクリメント操作の正確性**
*任意の*アイテムに対して、インクリメント操作を実行すると、そのアイテムの数量が正確に1増加する
**検証対象: 要件 3.1**

**プロパティ 7: デクリメント操作の正確性**
*任意の*数量が1以上のアイテムに対して、デクリメント操作を実行すると、そのアイテムの数量が正確に1減少する
**検証対象: 要件 3.2**

**プロパティ 8: 編集フォーム情報の一致**
*任意の*アイテムに対して、編集画面を開くと、現在のアイテム情報（名前、数量、アイコン）がすべて正しく表示される
**検証対象: 要件 4.1**

**プロパティ 9: アイテム更新の反映**
*任意の*アイテムと新しい値（名前、数量、アイコン）に対して、更新操作を実行すると、変更がアイテムに正しく反映される
**検証対象: 要件 4.2, 4.3**

**プロパティ 10: アイテム削除の完全性**
*任意の*アイテムに対して、削除操作を実行すると、そのアイテムがリストから完全に削除される
**検証対象: 要件 5.2**

**プロパティ 11: データ永続化のラウンドトリップ**
*任意の*アイテムデータ操作（作成、更新、削除）に対して、操作実行後にストレージから読み込んだデータは、操作結果と一致する
**検証対象: 要件 1.6, 3.5, 4.5, 5.4, 6.1**

**プロパティ 12: エラー処理の堅牢性**
*任意の*ストレージエラー状況に対して、システムは適切なエラーハンドリングを実行し、データの整合性を維持する
**検証対象: 要件 6.3**

## エラーハンドリング

### エラー処理戦略

#### Presentation Layer
- **ユーザーフレンドリーなメッセージ**: 技術的詳細を隠し、分かりやすい日本語メッセージを表示
- **SnackBar**: 一時的なフィードバック（成功・エラー通知）
- **ダイアログ**: 重要なエラーや確認が必要な操作
- **ローディング状態**: 非同期処理中の適切な表示

#### Business Logic Layer
- **例外キャッチ**: すべての非同期操作をtry-catchでラップ
- **ログ出力**: Loggerを使用した詳細なエラーログ
- **戻り値**: 操作の成功/失敗をboolで返却
- **状態保護**: エラー時は状態を変更せず、notifyListeners()を呼び出さない

#### Data Layer
- **データ整合性**: 不正な値（負の数量など）を自動的に修正または拒否
- **JSON変換エラー**: 破損したデータは無視し、有効なデータのみ読み込み
- **ストレージエラー**: SharedPreferencesの読み書きエラーを適切にハンドリング

### エラーカテゴリ

1. **バリデーションエラー**: 入力値の検証失敗
2. **ストレージエラー**: データ永続化の失敗
3. **ネットワークエラー**: 将来の機能拡張時
4. **システムエラー**: 予期しない例外

## テスト戦略

### デュアルテストアプローチ

**単体テスト**:
- 特定の例やエッジケース、エラー条件の検証
- 統合ポイント間のテスト
- モックを使用した依存関係の分離

**プロパティベーステスト**:
- 全入力に対する普遍的プロパティの検証
- ランダム化による包括的な入力カバレッジ
- 各プロパティテストは最低100回の反復実行

### プロパティベーステスト設定

**ライブラリ**: Dartの`test`パッケージと`faker`パッケージを使用
**設定**:
- 各プロパティテストは最低100回の反復
- テストタグ形式: **Feature: nocoris-item-management, Property {番号}: {プロパティテキスト}**
- 各正確性プロパティは単一のプロパティベーステストで実装

### テストカバレッジ

**単体テスト対象**:
- Item モデルのメソッド（copyWith, increment, decrement等）
- StorageService のJSON変換
- ItemService の個別メソッド
- エラーハンドリングのエッジケース

**プロパティテスト対象**:
- 設計書で定義された12の正確性プロパティ
- データの整合性とビジネスルール
- ラウンドトリップ特性（シリアライゼーション/デシリアライゼーション）

**ウィジェットテスト対象**:
- HomeScreen のアイテム表示
- ItemFormScreen のフォームバリデーション
- ItemCard のユーザーインタラクション
- Riverpod プロバイダーの状態管理

### モック戦略

**mocktail**を使用したモック作成:
- StorageService: データ永続化層のモック
- ItemService: ビジネスロジック層のモック（ウィジェットテスト用）

**Riverpod テスト**:
- ProviderScope でのオーバーライド
- 本番コードを変更せずにテスト可能
- 複数プロバイダーの同時オーバーライド対応
