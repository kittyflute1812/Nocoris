---
inclusion: fileMatch
fileMatchPattern: "**/*.dart"
---

# よくあるエラーと解決策

このドキュメントは、Nocorisプロジェクトでよく遭遇するエラーとその解決策をまとめたものです。

## コンパイルエラー

### ❌ Invalid constant value

**エラーメッセージ:**
```
Error: Invalid constant value.
```

**原因:**
- 実行時定数（`AppConstants`など）をconst contextで使用
- 非const値（変数、関数呼び出しなど）をconst contextで参照

**解決策:**
```dart
// ❌ 実行時定数をconst contextで使用
const Padding(
  padding: EdgeInsets.all(AppConstants.defaultPadding),
  child: Text('Hello'),
)

// ✅ 解決策1: constを削除
Padding(
  padding: const EdgeInsets.all(AppConstants.defaultPadding),
  child: const Text('Hello'),
)

// ✅ 解決策2: 固定値を使用
const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
)
```

### ❌ BoxShadow const エラー

**エラーメッセージ:**
```
Error: Cannot use 'const' on 'BoxShadow' because it doesn't have a const constructor.
```

**原因:**
`BoxShadow` クラスにはconstコンストラクタが定義されていない

**解決策:**
```dart
// ❌ BoxShadowのリストにconstを使用
boxShadow: const [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
]

// ✅ リストからconstを削除（Offsetはconstのまま）
boxShadow: const [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
]
```

### ❌ The argument type 'X' can't be assigned to the parameter type 'Y'

**原因:**
型の不一致

**解決策:**
```dart
// ❌ 型が一致しない
final String count = item.count; // countはint型

// ✅ 正しい型を使用
final int count = item.count;

// ✅ 型変換が必要な場合
final String countText = item.count.toString();
```

## Lint警告

### ⚠️ Unnecessary 'const' keyword

**警告メッセージ:**
```
Info: Unnecessary 'const' keyword.
```

**原因:**
既にconst contextにあるのに、さらにconstを指定している

**解決策:**
```dart
// ❌ 重複したconst
const Padding(
  padding: EdgeInsets.all(16.0),
  child: const Text('Hello'), // 不要なconst
)

// ✅ 子要素のconstを削除
const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
)
```

### ⚠️ Unused import

**警告メッセージ:**
```
Info: Unused import: 'package:xxx/xxx.dart'.
```

**原因:**
使用していないimportが残っている

**解決策:**
```dart
// ❌ 未使用のimport
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // 使用していない

// ✅ 未使用のimportを削除
import 'package:flutter/material.dart';
```

### ⚠️ The method 'print' shouldn't be used

**警告メッセージ:**
```
Info: Don't invoke 'print' in production code.
```

**原因:**
`print()` を使用している（Nocorisプロジェクトでは禁止）

**解決策:**
```dart
// ❌ print()の使用
print('Debug message');
print('Error: $error');

// ✅ loggerパッケージを使用
import 'package:logger/logger.dart';

final logger = Logger();
logger.d('Debug message');
logger.e('Error occurred', error: error);
```

### ⚠️ Prefer const with constant constructors

**警告メッセージ:**
```
Info: Prefer const with constant constructors.
```

**原因:**
constコンストラクタを使用できるのに使用していない

**解決策:**
```dart
// ❌ constを使用していない
Widget build(BuildContext context) {
  return Text('Hello');
}

// ✅ constを追加
Widget build(BuildContext context) {
  return const Text('Hello');
}
```

## 実行時エラー

### 💥 Null check operator used on a null value

**エラーメッセージ:**
```
Null check operator used on a null value
```

**原因:**
null assertion operator (`!`) を使用したが、値がnullだった

**解決策:**
```dart
// ❌ null assertionの乱用
final name = item!.name;

// ✅ null認識演算子を使用
final name = item?.name ?? 'Unknown';

// ✅ null チェック
if (item != null) {
  final name = item.name;
}
```

### 💥 setState() called after dispose()

**エラーメッセージ:**
```
setState() called after dispose()
```

**原因:**
ウィジェットが破棄された後にsetStateを呼び出している

**解決策:**
```dart
// ✅ mountedチェックを追加
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
}
```

### 💥 A TextEditingController was used after being disposed

**エラーメッセージ:**
```
A TextEditingController was used after being disposed.
```

**原因:**
disposeしたコントローラーを使用している

**解決策:**
```dart
// ✅ 適切なライフサイクル管理
class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## テストエラー

### ❌ Test failed: Expected X but got Y

**原因:**
期待値と実際の値が一致しない

**解決策:**
```dart
// テストの期待値を確認
expect(result, expectedValue);

// デバッグ出力で実際の値を確認
logger.d('Actual value: $result');
logger.d('Expected value: $expectedValue');
```

### ❌ MissingStubError

**原因:**
モックオブジェクトのメソッドがスタブされていない

**解決策:**
```dart
// ✅ whenメソッドでスタブを設定
when(() => mockService.getItems())
    .thenAnswer((_) async => <Item>[]);
```

## パフォーマンス問題

### 🐌 画面の再描画が多すぎる

**原因:**
不要なsetStateやウィジェットの再構築

**解決策:**
```dart
// ✅ constコンストラクタを使用
const Text('Static text')

// ✅ 状態管理を適切に使用（Riverpod）
final itemsProvider = StateNotifierProvider<ItemNotifier, List<Item>>(...);

// ✅ RepaintBoundaryで再描画を分離
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

### 🐌 リストのスクロールが重い

**原因:**
ListView.builderを使用していない

**解決策:**
```dart
// ❌ 全てのアイテムを一度に構築
ListView(
  children: items.map((item) => ItemCard(item: item)).toList(),
)

// ✅ ListView.builderを使用
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

## デバッグ方法

### 診断ツールの使用順序

1. **getDiagnostics**: コンパイルエラーと警告をチェック
2. **flutter analyze**: 静的解析でlint警告をチェック
3. **dart format**: コードフォーマットを整形
4. **flutter test**: テストを実行
5. **flutter run**: 実際の動作を確認

### ログ出力でデバッグ

```dart
import 'package:logger/logger.dart';

final logger = Logger();

// 変数の値を確認
logger.d('Item: $item');
logger.d('Count: ${item.count}');

// エラー情報を出力
try {
  // 処理
} catch (e, stackTrace) {
  logger.e('Error occurred', error: e, stackTrace: stackTrace);
}
```

### Flutter DevToolsの活用

```bash
# DevToolsを起動
flutter run
# ブラウザでDevToolsを開く
# - Widget Inspector: ウィジェットツリーを確認
# - Performance: パフォーマンスを分析
# - Memory: メモリ使用量を確認
# - Network: ネットワークリクエストを監視
```

このガイドを参考に、効率的にエラーを解決しましょう！
