# Nocoris - システムアーキテクチャドキュメント

## 📐 アーキテクチャ概要

Nocorisは、クリーンアーキテクチャの原則に基づいた4層構造を採用しています。

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

---

## 🏗 レイヤー詳細

### 1. Presentation Layer（プレゼンテーション層）

ユーザーインターフェースとユーザーインタラクションを担当します。

```
lib/features/item/
├── screens/
│   ├── home_screen.dart          # メイン画面 (ConsumerStatefulWidget)
│   └── item_form_screen.dart     # アイテム作成/編集画面 (ConsumerStatefulWidget)
└── widgets/
    └── item_card.dart            # アイテム表示カード

lib/core/
├── theme/
│   └── app_theme.dart            # テーマ定義
└── widgets/                      # 共通ウィジェット
    ├── empty_state_view.dart
    ├── error_view.dart
    └── loading_view.dart
```

#### HomeScreen（メイン画面）

**責務**:
- アイテム一覧の表示
- アイテムの追加・編集・削除のトリガー
- カウント操作のUI提供
- エラー表示とユーザーフィードバック

**状態管理**:
- `ConsumerStatefulWidget` を使用（Riverpod）
- `ref.watch(itemServiceInitProvider)` でItemServiceを取得
- `ref.read(itemServiceProvider)` で操作を実行
- ItemServiceの `notifyListeners()` により自動的にUI更新

**データフロー**:
```
HomeScreen (ConsumerStatefulWidget)
    ↓ (初期化時)
ref.watch(itemServiceInitProvider)
    ↓
ItemService.create() (非同期初期化)
    ↓
AsyncValue<ItemService> (loading/data/error)
    ↓ (データ取得)
ItemService.items (ChangeNotifier)
    ↓ (表示)
ListView.builder → ItemCard
    ↓ (状態変更時)
notifyListeners() → 自動的にUI再描画
```

#### ItemFormScreen（作成/編集画面）

**責務**:
- アイテム名と初期値の入力フォーム
- バリデーション
- アイテムの作成または更新

**バリデーション**:
- アイテム名: 必須入力
- 数値: 必須入力、0以上の整数

**データフロー**:
```
ItemFormScreen (ConsumerStatefulWidget)
    ↓ (保存ボタン押下)
ref.read(itemServiceProvider).createItem() / updateItem()
    ↓
ItemService.notifyListeners()
    ↓ (成功時)
Navigator.pop(true)
    ↓
HomeScreen (自動的にUI更新、setStateは不要)
```

#### ItemCard（アイテムカード）

**責務**:
- アイテム情報の表示
- インクリメント/デクリメントボタン
- 編集・削除アクションのトリガー

**コールバック**:
- `onIncrement`: カウント増加
- `onDecrement`: カウント減少
- `onEdit`: 編集画面への遷移
- `onDelete`: 削除確認ダイアログ表示

---

### 2. State Management Layer（状態管理層）

Riverpodを使用した状態管理を担当します。

```
lib/features/item/providers/
└── item_provider.dart        # Providerの定義
```

#### Riverpod Providers

**itemServiceProvider（ChangeNotifierProvider）**

```dart
final itemServiceProvider = ChangeNotifierProvider<ItemService>((ref) {
  throw UnimplementedError('itemServiceProvider must be overridden');
});
```

**責務**:
- ItemServiceのインスタンスを提供
- ChangeNotifierとして状態変更を監視
- テスト時にモックサービスをオーバーライド可能

**itemServiceInitProvider（FutureProvider）**

```dart
final itemServiceInitProvider = FutureProvider<ItemService>((ref) async {
  return await ItemService.create();
});
```

**責務**:
- ItemServiceの非同期初期化を管理
- StorageServiceの初期化とデータ読み込みを実行
- AsyncValue（loading/data/error）で状態を提供

#### 状態管理パターン

**ChangeNotifier + Riverpod パターン**

```dart
// 1. Serviceが状態を保持し、変更時にnotifyListeners()を呼び出す
class ItemService extends ChangeNotifier {
  final List<Item> _items = [];
  
  Future<Item> createItem(String name, int count) async {
    final item = Item.create(name: name, initialCount: count);
    _items.add(item);
    await _saveItems();
    notifyListeners(); // ← UIに変更を通知
    return item;
  }
}

// 2. UIはref.watchで状態を監視し、変更時に自動再描画
class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final itemServiceAsync = ref.watch(itemServiceInitProvider);
    // itemServiceAsyncが変更されると自動的に再描画
    
    return itemServiceAsync.when(
      loading: () => LoadingView(),
      error: (err, stack) => ErrorView(message: err.toString()),
      data: (itemService) {
        final items = itemService.items;
        // itemService.notifyListeners()が呼ばれると自動的に再描画
        return ListView.builder(...);
      },
    );
  }
}
```

#### 依存性注入

**本番環境**:
```dart
// main.dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**テスト環境**:
```dart
// テスト時にモックサービスを注入
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      itemServiceInitProvider.overrideWith((ref) async => mockItemService),
      itemServiceProvider.overrideWith((ref) => mockItemService),
    ],
    child: const MaterialApp(home: HomeScreen()),
  ),
);
```

**メリット**:
- テストが容易（モックの注入が簡単）
- 状態の一元管理
- 自動的なUI更新（setStateが不要）
- コンパイル時の型安全性
- グローバル状態の最小化

---

### 3. Business Logic Layer（ビジネスロジック層）

アプリケーションのコアロジックを担当します。

```
lib/features/item/services/
└── item_service.dart         # アイテム管理サービス

lib/core/services/
└── storage_service.dart      # ストレージ抽象化サービス
```

#### ItemService（アイテム管理サービス）

**責務**:
- アイテムのCRUD操作
- カウント操作（increment/decrement）
- データの整合性維持
- ストレージへの永続化
- **状態変更の通知（ChangeNotifier）**

**クラス定義**:
```dart
class ItemService extends ChangeNotifier {
  final StorageService _storageService;
  final List<Item> _items = [];
  
  // コンストラクタはプライベート
  ItemService._(this._storageService);
  
  // ファクトリメソッドで非同期初期化
  static Future<ItemService> create() async {
    final storageService = await StorageService.create();
    final service = ItemService._(storageService);
    await service._loadItems();
    return service;
  }
}
```

**主要メソッド**:

| メソッド | 説明 | 戻り値 | 通知 |
|---------|------|--------|------|
| `create()` | StorageServiceを初期化してItemServiceを作成 | `Future<ItemService>` | - |
| `items` | 全アイテムのリストを取得（読み取り専用） | `List<Item>` | - |
| `getItemById(id)` | IDでアイテムを検索 | `Item?` | - |
| `createItem(name, count)` | 新しいアイテムを作成 | `Future<Item>` | ✅ |
| `updateItem(id, count)` | アイテムのカウントを更新 | `Future<bool>` | ✅ |
| `deleteItem(id)` | アイテムを削除 | `Future<bool>` | ✅ |
| `incrementItem(id)` | カウントを1増やす | `Future<bool>` | ✅ |
| `decrementItem(id)` | カウントを1減らす | `Future<bool>` | ✅ |

**データフロー**:
```
ItemService (ChangeNotifier)
    ↓ (初期化時)
_loadItems() → StorageService.loadItems()
    ↓ (変更時)
_items.add(item) / _items.remove(item)
    ↓
_saveItems() → StorageService.saveItems()
    ↓
notifyListeners() ← UIに変更を通知
    ↓
shared_preferences (永続化)
    ↓
ref.watch(itemServiceInitProvider) が監視しているUIが自動再描画
```

**エラーハンドリング**:
- すべての非同期操作で例外をキャッチ
- ログ出力（Logger使用）
- 操作の成功/失敗を `bool` で返却
- エラー時も `notifyListeners()` を呼び出さない（状態の一貫性を保つ）

#### StorageService（ストレージサービス）

**責務**:
- `shared_preferences` の抽象化
- JSONシリアライゼーション/デシリアライゼーション
- データの読み書き

**主要メソッド**:

| メソッド | 説明 | 戻り値 |
|---------|------|--------|
| `create()` | SharedPreferencesインスタンスを初期化 | `Future<StorageService>` |
| `loadItems()` | アイテムリストを読み込み | `List<Map<String, dynamic>>` |
| `saveItems(items)` | アイテムリストを保存 | `Future<bool>` |

**ストレージキー**:
- `items`: アイテムリストのJSONデータ

---

### 4. Data Layer（データ層）

データモデルとデータ構造を定義します。

```
lib/features/item/models/
└── item.dart                 # アイテムデータモデル（不変）
```

#### Item（アイテムモデル）

**設計原則**: **不変データモデル（Immutable）**

```dart
class Item {
  final String id;
  final String name;
  final int count;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // すべてのフィールドがfinal
  const Item({
    required this.id,
    required this.name,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // 変更時は新しいインスタンスを返す
  Item copyWith({
    String? name,
    int? count,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      count: count ?? this.count,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
```

**プロパティ**:

| プロパティ | 型 | 説明 | 変更可能 |
|-----------|-----|------|---------|
| `id` | `String` | ユニークID（UUID v4） | ❌ |
| `name` | `String` | アイテム名 | ❌ |
| `count` | `int` | 現在のカウント数 | ❌ |
| `createdAt` | `DateTime` | 作成日時 | ❌ |
| `updatedAt` | `DateTime` | 最終更新日時 | ❌ |

**メソッド**:

| メソッド | 説明 | 戻り値 |
|---------|------|--------|
| `copyWith({...})` | 指定したフィールドを変更した新しいインスタンスを返す | `Item` |
| `decrement()` | カウントを1減らした新しいインスタンスを返す | `Item` |
| `increment()` | カウントを1増やした新しいインスタンスを返す | `Item` |
| `setCount(newCount)` | カウントを直接設定した新しいインスタンスを返す | `Item` |
| `fromJson(json)` | JSONからItemオブジェクトを生成 | `Item` |
| `toJson()` | ItemオブジェクトをJSONに変換 | `Map<String, dynamic>` |
| `create(name, count)` | 新しいItemを作成（ファクトリメソッド） | `Item` |

**ビジネスルール**:
- カウントは常に0以上
- 更新時に `updatedAt` を自動更新
- IDはUUID v4で自動生成
- **すべてのフィールドが不変（final）**
- **変更時は新しいインスタンスを生成（copyWith）**

**不変性のメリット**:
- 予期しない状態変更を防止
- テストが容易
- デバッグが簡単（状態の履歴を追跡可能）
- 並行処理での安全性
- Riverpodとの相性が良い

---

## 🔄 データフローの詳細

### アイテム作成フロー

```
1. ユーザー操作
   HomeScreen → FloatingActionButton タップ

2. 画面遷移
   Navigator.push → ItemFormScreen

3. フォーム入力
   ユーザーが名前と数値を入力

4. バリデーション
   ItemFormScreen._saveItem()
   ↓ (バリデーション成功)

5. アイテム作成
   ItemService.createItem(name, count)
   ↓
   Item.create(name, count)  // 新しいItemオブジェクト生成
   ↓
   _items.add(item)          // リストに追加
   ↓
   _saveItems()              // ストレージに保存

6. ストレージ保存
   StorageService.saveItems(_items)
   ↓
   items.map((item) => item.toJson())  // JSON変換
   ↓
   _prefs.setString('items', jsonEncode(itemsJson))

7. 画面更新
   Navigator.pop(true)       // 前の画面に戻る
   ↓
   HomeScreen.setState()     // UI更新
```

### カウント操作フロー

```
1. ユーザー操作
   ItemCard → インクリメントボタンタップ

2. コールバック実行
   onIncrement(item.id)
   ↓
   HomeScreen._handleIncrement(itemId)

3. サービス呼び出し
   ItemService.incrementItem(itemId)
   ↓
   item = getItemById(itemId)
   ↓
   item.increment()          // カウント+1、updatedAt更新
   ↓
   _saveItems()              // ストレージに保存

4. UI更新
   setState()                // HomeScreenを再描画
   ↓
   ItemCard が新しいカウント値で表示
```

### アプリ起動時のデータ読み込みフロー

```
1. アプリ起動
   main() → runApp(MyApp())

2. HomeScreen初期化
   HomeScreen.initState()
   ↓
   _initializeItemService()

3. サービス初期化
   ItemService.create()
   ↓
   StorageService.create()
   ↓
   SharedPreferences.getInstance()

4. データ読み込み
   ItemService._loadItems()
   ↓
   StorageService.loadItems()
   ↓
   _prefs.getString('items')
   ↓
   jsonDecode(itemsJson)
   ↓
   items.map((json) => Item.fromJson(json))

5. UI表示
   setState()
   ↓
   ListView.builder → ItemCard表示
```

---

## 🧪 テストアーキテクチャ

### テスト構造

```
test/
├── helpers/
│   └── test_helpers.dart         # モック作成ヘルパー
├── models/
│   └── item_test.dart            # Itemモデルのテスト
├── services/
│   ├── item_service_test.dart    # ItemServiceのテスト
│   └── storage_service_test.dart # StorageServiceのテスト
├── screens/
│   ├── home_screen_test.dart     # HomeScreenのテスト
│   └── item_form_screen_test.dart # ItemFormScreenのテスト
└── widgets/
    └── item_card_test.dart       # ItemCardのテスト
```

### テスト戦略

#### 単体テスト（Unit Tests）

**対象**: Models, Services

**アプローチ**:
- 各クラスのメソッドを個別にテスト
- 依存関係はモックで置き換え
- エッジケースを網羅

**例**: `item_test.dart`
```dart
test('increment() はカウントを1増やす', () {
  final item = Item.create(name: 'テスト', initialCount: 5);
  item.increment();
  expect(item.count, 6);
});
```

#### ウィジェットテスト（Widget Tests）

**対象**: Screens, Widgets

**アプローチ**:
- UI コンポーネントの描画を確認
- ユーザーインタラクションをシミュレート
- 状態変化を検証
- **Riverpodの依存性注入を活用**

**例**: `home_screen_test.dart`
```dart
testWidgets('アイテムが正しく表示される', (tester) async {
  final mockItemService = TestHelpers.createMockItemService(
    initialItems: [
      {'id': '1', 'name': 'テストアイテム1', 'count': 5, ...},
    ],
  );
  
  // ProviderScopeでラップし、モックサービスを注入
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemServiceInitProvider.overrideWith((ref) async => mockItemService),
        itemServiceProvider.overrideWith((ref) => mockItemService),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  
  await tester.pumpAndSettle();
  expect(find.text('テストアイテム1'), findsOneWidget);
});
```

**Riverpodテストのポイント**:
- `ProviderScope` でウィジェットをラップ
- `overrides` でモックサービスを注入
- 本番コードを変更せずにテスト可能
- 複数のProviderを同時にオーバーライド可能

#### モックの使用

**ツール**: `mocktail`

**モック対象**:
- `StorageService`: データ永続化層のモック
- `ItemService`: ビジネスロジック層のモック

**例**: `test_helpers.dart`
```dart
class MockStorageService extends Mock implements StorageService {}

class TestHelpers {
  static ItemService createMockItemService({
    List<Map<String, dynamic>>? initialItems,
  }) {
    final mockStorage = MockStorageService();
    
    // StorageServiceのモック動作を定義
    when(() => mockStorage.loadItems()).thenReturn(initialItems ?? []);
    when(() => mockStorage.saveItems(any())).thenAnswer((_) async => true);
    
    // ItemServiceを同期的に作成（テスト用）
    final service = ItemService._(mockStorage);
    
    // 初期データを読み込み
    if (initialItems != null && initialItems.isNotEmpty) {
      for (final json in initialItems) {
        service._items.add(Item.fromJson(json));
      }
    }
    
    return service;
  }
}
```

**Riverpod + Mocktailの組み合わせ**:
```dart
// 1. mocktailでモックサービスを作成
final mockItemService = TestHelpers.createMockItemService(
  initialItems: testItems,
);

// 2. Riverpodでモックを注入
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      itemServiceProvider.overrideWith((ref) => mockItemService),
    ],
    child: const MaterialApp(home: HomeScreen()),
  ),
);

// 3. モックの動作を検証
verify(() => mockItemService.incrementItem(any())).called(1);
```

---

## 🔐 エラーハンドリング戦略

### レイヤー別エラーハンドリング

#### Presentation Layer

**戦略**:
- ユーザーフレンドリーなエラーメッセージ
- `SnackBar` でフィードバック
- ローディング状態の管理

**実装例**:
```dart
try {
  await _itemService.createItem(name, count);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('アイテムを作成しました')),
    );
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('エラーが発生しました')),
    );
  }
}
```

#### Business Logic Layer

**戦略**:
- すべての非同期操作を `try-catch` でラップ
- ログ出力（`Logger` 使用）
- 操作の成功/失敗を返却

**実装例**:
```dart
Future<bool> incrementItem(String id) async {
  try {
    final item = getItemById(id);
    if (item == null) return false;
    
    item.increment();
    await _saveItems();
    return true;
  } catch (e) {
    _logger.e('Failed to increment item', error: e);
    return false;
  }
}
```

#### Data Layer

**戦略**:
- データの整合性を保証
- 不正な値を拒否
- 例外を上位レイヤーに伝播

**実装例**:
```dart
void setCount(int newCount) {
  if (newCount >= 0) {
    count = newCount;
    updatedAt = DateTime.now();
  }
  // 負の値は無視（エラーにしない）
}
```

---

## 🚀 パフォーマンス最適化

### 現在の最適化

1. **不変リストの使用**
   - `ItemService.items` は `List.unmodifiable()` で返却
   - 外部からの直接変更を防止

2. **効率的な状態管理**
   - 必要な時のみ `setState()` を呼び出し
   - 不要な再描画を回避

3. **非同期処理の適切な使用**
   - ストレージ操作は非同期
   - UI ブロックを防止

### 将来の最適化案

1. **大量アイテム対応**
   - 仮想スクロール（ListView.builder は既に使用）
   - ページネーション
   - 遅延読み込み

2. **キャッシュ戦略**
   - メモリキャッシュ
   - ストレージアクセスの削減

3. **状態管理の改善**
   - Provider/Riverpod の導入検討
   - より細かい粒度での状態管理

---

## 📦 依存関係グラフ

```
main.dart
  ↓
ProviderScope (Riverpod)
  ↓
MyApp
  ↓
HomeScreen (ConsumerStatefulWidget)
  ├→ ref.watch(itemServiceInitProvider)
  │   ↓
  │   itemServiceInitProvider (FutureProvider)
  │   ↓
  │   ItemService.create()
  │   ├→ StorageService
  │   │   └→ shared_preferences
  │   └→ Item (Model)
  │       └→ uuid
  │
  ├→ ref.read(itemServiceProvider)
  │   ↓
  │   itemServiceProvider (ChangeNotifierProvider)
  │   ↓
  │   ItemService (ChangeNotifier)
  │   └→ notifyListeners() → UI自動更新
  │
  └→ ItemFormScreen (ConsumerStatefulWidget)
      └→ ref.read(itemServiceProvider) (同上)

ItemCard (Widget)
  ← HomeScreen から使用
  └→ コールバックでItemServiceのメソッドを呼び出し
```

### 状態の流れ

```
ユーザー操作
  ↓
UI (ConsumerWidget)
  ↓
ref.read(itemServiceProvider).incrementItem()
  ↓
ItemService (ChangeNotifier)
  ├→ _items.add/remove/update
  ├→ _saveItems() → StorageService
  └→ notifyListeners()
      ↓
Riverpod が検知
  ↓
ref.watch(itemServiceInitProvider) を使用しているWidget
  ↓
自動的に再描画（setState不要）
```

### 外部パッケージ依存

| パッケージ | バージョン | 用途 | レイヤー |
|-----------|-----------|------|---------|
| `flutter_riverpod` | 2.6.1 | 状態管理 | State Management |
| `shared_preferences` | 2.5.3 | ローカルストレージ | Data |
| `uuid` | 4.3.3 | ユニークID生成 | Data |
| `logger` | 2.3.0 | ロギング | Business Logic |
| `mocktail` | 1.0.3 | テスト用モック | Test |

---

## 🎯 アーキテクチャの利点

### 1. テスト容易性

**Riverpodによる依存性注入**:
```dart
// テスト時にモックを簡単に注入
testWidgets('アイテムが正しく表示される', (tester) async {
  final mockItemService = TestHelpers.createMockItemService(
    initialItems: testItems,
  );
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemServiceProvider.overrideWith((ref) => mockItemService),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  
  expect(find.text('テストアイテム'), findsOneWidget);
});
```

### 2. 保守性

**機能ベースのディレクトリ構造**:
- 関連するコードが同じディレクトリにまとまっている
- 機能の追加・削除が容易
- コードの検索が簡単

**不変データモデル**:
- 予期しない状態変更を防止
- デバッグが容易
- 並行処理での安全性

### 3. スケーラビリティ

**状態管理の一元化**:
- 新しい機能を追加する際も同じパターンを適用
- Providerを追加するだけで新しい状態を管理可能

**レイヤー分離**:
- UIとビジネスロジックが分離されている
- データ層の変更がUIに影響しない
- ストレージの実装を簡単に変更可能

### 4. パフォーマンス

**効率的な状態更新**:
- `notifyListeners()` により必要な部分のみ再描画
- `ref.watch()` で細かい粒度での監視が可能
- 不要な `setState()` 呼び出しを削減

**非同期処理の最適化**:
- `FutureProvider` で非同期初期化を管理
- UI ブロックを防止
- ローディング状態の自動管理

---

## 🔄 今後の拡張性

### iOSホーム画面ウィジェット機能の追加

iOSのホーム画面やロック画面に配置できるネイティブウィジェットを実装します。

```
現在のアーキテクチャ:
Nocoris/
├── lib/                         # Flutter アプリ
│   ├── models/
│   ├── services/
│   ├── screens/
│   └── widgets/
└── ios/
    └── Runner/

ウィジェット追加後:
Nocoris/
├── lib/                         # Flutter アプリ
│   ├── models/
│   ├── services/
│   │   └── app_group_storage_service.dart  # 新規: App Groups対応
│   ├── screens/
│   └── widgets/
└── ios/
    ├── Runner/
    └── CountDropWidget/         # 新規: Widget Extension
        ├── CountDropWidget.swift           # ウィジェット定義
        ├── CountDropWidgetBundle.swift     # ウィジェットバンドル
        ├── TimelineProvider.swift          # データ更新管理
        ├── WidgetView.swift                # SwiftUI ビュー
        ├── AppIntent.swift                 # ボタンアクション（iOS 16+）
        └── Info.plist

App Groups によるデータ共有:
┌─────────────────────────────────────────────┐
│ Flutter App (メインアプリ)                   │
│   ItemService → StorageService              │
│                      ↓                      │
│              shared_preferences             │
│                      ↓                      │
│         App Groups Container                │
│    (group.com.example.nocoris)              │
└─────────────────┬───────────────────────────┘
                  │ (共有データ)
┌─────────────────▼───────────────────────────┐
│ WidgetKit Extension (ウィジェット)           │
│   TimelineProvider → UserDefaults(suiteName)│
│                      ↓                      │
│              SwiftUI View                   │
│                      ↓                      │
│        ホーム画面/ロック画面に表示            │
└─────────────────────────────────────────────┘
```

#### 実装の技術詳細

**1. App Groups の設定**
- Xcode で App Groups Capability を有効化
- メインアプリとWidget Extensionで同じグループIDを使用
- 例: `group.com.example.nocoris`

**2. データ共有の実装**
```dart
// Flutter側（app_group_storage_service.dart）
class AppGroupStorageService {
  static const String appGroupId = 'group.com.example.nocoris';
  
  // App Groups対応のshared_preferencesを使用
  // または、MethodChannelでSwift側のUserDefaultsにアクセス
}
```

**3. WidgetKit の実装（Swift）**
```swift
// TimelineProvider.swift
struct Provider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // App Groupsからデータを読み込み
        let userDefaults = UserDefaults(suiteName: "group.com.example.nocoris")
        let itemsData = userDefaults?.data(forKey: "items")
        
        // タイムラインエントリを作成
        let entries = // ... データをパース
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// WidgetView.swift (SwiftUI)
struct CountDropWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text(entry.itemName)
            Text("\(entry.count)")
            // iOS 16+ ではボタンを配置可能
        }
    }
}
```

**4. インタラクティブウィジェット（iOS 16+）**
```swift
// AppIntent.swift
struct DecrementItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Decrement Item"
    
    @Parameter(title: "Item ID")
    var itemId: String
    
    func perform() async throws -> some IntentResult {
        // App Groupsのデータを更新
        // メインアプリに通知（オプション）
        return .result()
    }
}
```

#### ウィジェットのサイズ対応

- **Small（小）**: 1つのアイテムの名前とカウント表示
- **Medium（中）**: 2-3個のアイテムを横並びで表示
- **Large（大）**: 複数アイテムをリスト形式で表示
- **Lock Screen（ロック画面）**: コンパクトな表示（iOS 16+）

### カテゴリ機能の追加

```
新規モデル:
lib/models/
├── item.dart
└── category.dart                # 新規

新規サービス:
lib/services/
├── item_service.dart
└── category_service.dart        # 新規

データ構造の変更:
Item {
  ...
  categoryId: String?            # 新規フィールド
}
```

---

## 📚 参考資料

- [Flutter アーキテクチャガイド](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
- [クリーンアーキテクチャ](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter テストベストプラクティス](https://flutter.dev/docs/testing)

---

**最終更新**: 2026-01-04（Riverpod状態管理の追加）

