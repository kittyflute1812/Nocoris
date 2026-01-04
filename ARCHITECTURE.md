# CountDrop - システムアーキテクチャドキュメント

## 📐 アーキテクチャ概要

CountDropは、クリーンアーキテクチャの原則に基づいた3層構造を採用しています。

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│                  (UI & User Interaction)                    │
├─────────────────────────────────────────────────────────────┤
│                  Business Logic Layer                       │
│              (Services & Domain Logic)                      │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                             │
│              (Models & Data Persistence)                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏗 レイヤー詳細

### 1. Presentation Layer（プレゼンテーション層）

ユーザーインターフェースとユーザーインタラクションを担当します。

```
lib/screens/
├── home_screen.dart          # メイン画面
└── item_form_screen.dart     # アイテム作成/編集画面

lib/widgets/
└── item_card.dart            # アイテム表示カード

lib/theme/
└── app_theme.dart            # テーマ定義
```

#### HomeScreen（メイン画面）

**責務**:
- アイテム一覧の表示
- アイテムの追加・編集・削除のトリガー
- カウント操作のUI提供
- エラー表示とユーザーフィードバック

**状態管理**:
- `StatefulWidget` を使用
- `ItemService` からアイテムリストを取得
- `setState()` でUI更新

**データフロー**:
```
HomeScreen
    ↓ (初期化時)
ItemService.create()
    ↓ (アイテム取得)
ItemService.items
    ↓ (表示)
ListView.builder → ItemCard
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
ItemFormScreen
    ↓ (保存ボタン押下)
ItemService.createItem() / updateItem()
    ↓ (成功時)
Navigator.pop(true)
    ↓
HomeScreen.setState() (リスト更新)
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

### 2. Business Logic Layer（ビジネスロジック層）

アプリケーションのコアロジックを担当します。

```
lib/services/
├── item_service.dart         # アイテム管理サービス
└── storage_service.dart      # ストレージ抽象化サービス
```

#### ItemService（アイテム管理サービス）

**責務**:
- アイテムのCRUD操作
- カウント操作（increment/decrement）
- データの整合性維持
- ストレージへの永続化

**主要メソッド**:

| メソッド | 説明 | 戻り値 |
|---------|------|--------|
| `create()` | StorageServiceを初期化してItemServiceを作成 | `Future<ItemService>` |
| `items` | 全アイテムのリストを取得（読み取り専用） | `List<Item>` |
| `getItemById(id)` | IDでアイテムを検索 | `Item?` |
| `createItem(name, count)` | 新しいアイテムを作成 | `Future<Item>` |
| `updateItem(id, count)` | アイテムのカウントを更新 | `Future<bool>` |
| `deleteItem(id)` | アイテムを削除 | `Future<bool>` |
| `incrementItem(id)` | カウントを1増やす | `Future<bool>` |
| `decrementItem(id)` | カウントを1減らす | `Future<bool>` |

**データフロー**:
```
ItemService
    ↓ (初期化時)
_loadItems() → StorageService.loadItems()
    ↓ (変更時)
_saveItems() → StorageService.saveItems()
    ↓
shared_preferences (永続化)
```

**エラーハンドリング**:
- すべての非同期操作で例外をキャッチ
- ログ出力（Logger使用）
- 操作の成功/失敗を `bool` で返却

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

### 3. Data Layer（データ層）

データモデルとデータ構造を定義します。

```
lib/models/
└── item.dart                 # アイテムデータモデル
```

#### Item（アイテムモデル）

**プロパティ**:

| プロパティ | 型 | 説明 |
|-----------|-----|------|
| `id` | `String` | ユニークID（UUID v4） |
| `name` | `String` | アイテム名 |
| `count` | `int` | 現在のカウント数 |
| `createdAt` | `DateTime` | 作成日時 |
| `updatedAt` | `DateTime` | 最終更新日時 |

**メソッド**:

| メソッド | 説明 |
|---------|------|
| `decrement()` | カウントを1減らす（0未満にはならない） |
| `increment()` | カウントを1増やす |
| `setCount(newCount)` | カウントを直接設定（0以上） |
| `fromJson(json)` | JSONからItemオブジェクトを生成 |
| `toJson()` | ItemオブジェクトをJSONに変換 |
| `create(name, count)` | 新しいItemを作成（ファクトリメソッド） |

**ビジネスルール**:
- カウントは常に0以上
- 更新時に `updatedAt` を自動更新
- IDはUUID v4で自動生成

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

**例**: `home_screen_test.dart`
```dart
testWidgets('アイテムが正しく表示される', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: HomeScreen(itemService: mockItemService),
  ));
  await tester.pumpAndSettle();
  
  expect(find.text('テストアイテム1'), findsOneWidget);
});
```

#### モックの使用

**ツール**: `mocktail`

**モック対象**:
- `StorageService`: データ永続化層のモック
- `ItemService`: ビジネスロジック層のモック

**例**: `test_helpers.dart`
```dart
class MockStorageService extends Mock implements StorageService {}

ItemService createMockItemService({List<Map<String, dynamic>>? initialItems}) {
  final mockStorage = MockStorageService();
  when(() => mockStorage.loadItems()).thenReturn(initialItems ?? []);
  return ItemService(mockStorage);
}
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
MyApp
  ↓
HomeScreen
  ├→ ItemService
  │   ├→ StorageService
  │   │   └→ shared_preferences
  │   └→ Item (Model)
  │       └→ uuid
  └→ ItemFormScreen
      └→ ItemService (同上)

ItemCard (Widget)
  ← HomeScreen から使用
```

### 外部パッケージ依存

| パッケージ | バージョン | 用途 |
|-----------|-----------|------|
| `shared_preferences` | 2.5.3 | ローカルストレージ |
| `uuid` | 4.3.3 | ユニークID生成 |
| `logger` | 2.3.0 | ロギング |
| `mocktail` | 1.0.3 | テスト用モック |

---

## 🔄 今後の拡張性

### iOSホーム画面ウィジェット機能の追加

iOSのホーム画面やロック画面に配置できるネイティブウィジェットを実装します。

```
現在のアーキテクチャ:
drop_counter/
├── lib/                         # Flutter アプリ
│   ├── models/
│   ├── services/
│   ├── screens/
│   └── widgets/
└── ios/
    └── Runner/

ウィジェット追加後:
drop_counter/
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
│    (group.com.example.drop_counter)         │
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
- 例: `group.com.example.drop_counter`

**2. データ共有の実装**
```dart
// Flutter側（app_group_storage_service.dart）
class AppGroupStorageService {
  static const String appGroupId = 'group.com.example.drop_counter';
  
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
        let userDefaults = UserDefaults(suiteName: "group.com.example.drop_counter")
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

**最終更新**: 2025-01-04

