---
inclusion: always
---

# Dartコーディング規約（厳格版）

このドキュメントは、Nocorisプロジェクトにおける厳格なDartコーディング規約を定義します。

## 🚨 必須遵守事項

### Logger使用ルール

**絶対禁止:**
```dart
// ❌ print()の使用は一切禁止
print('Debug message');
print('Error: $error');
```

**必須使用:**
```dart
// ✅ loggerパッケージを使用
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Information');
logger.w('Warning');
logger.e('Error occurred', error: error, stackTrace: stackTrace);
```

### Const使用ルール

**基本原則:**
- 可能な限り `const` コンストラクタを使用してパフォーマンスを最適化
- コンパイル時定数のみ `const` context で使用可能
- 実行時定数（`AppConstants` など）は `const` context で使用不可

**注意が必要なケース:**
```dart
// ❌ BoxShadowにはconstコンストラクタがない
boxShadow: const [
  BoxShadow(color: Colors.black, blurRadius: 4),
]

// ✅ constを削除
boxShadow: const [
  BoxShadow(color: Colors.black, blurRadius: 4),
]

// ❌ 実行時定数をconst contextで使用
const Padding(
  padding: EdgeInsets.all(AppConstants.defaultPadding),
  child: Text('Hello'),
)

// ✅ constを削除するか、固定値を使用
Padding(
  padding: const EdgeInsets.all(16.0),
  child: const Text('Hello'),
)
```

### 型安全性

**必須ルール:**
```dart
// ✅ 全ての変数に明示的な型注釈
final List<Item> items = <Item>[];
final String? name = item.name;
final int count = 0;

// ❌ 型注釈なし
var items = [];
var name = item.name;
```

**Null安全性:**
```dart
// ✅ null認識演算子を活用
final name = item?.name ?? 'Unknown';
final count = item?.count ?? 0;

// ❌ null assertion(!)の乱用
final name = item!.name; // 危険：itemがnullの場合クラッシュ
```

**戻り値の型を明示:**
```dart
// ✅ 戻り値の型を明示
Future<bool> updateItem(String id) async {
  // 実装
  return true;
}

// ❌ 型省略
updateItem(String id) async {
  return true;
}
```

### Import整理

**ルール:**
- 未使用のimportは削除
- Dart SDK → Flutter SDK → パッケージ → 相対パス の順序
- 各グループ間に空行

```dart
// ✅ 正しいimport順序
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';
import '../services/item_service.dart';
```

## 実装前チェックリスト

コードを提出する前に、以下を必ず確認してください：

- [ ] `getDiagnostics` でエラーゼロを確認
- [ ] `flutter analyze` で警告ゼロを確認
- [ ] `dart format` でコード整形済み
- [ ] 関連するテストが全て通過
- [ ] `print()` を使用していない（`logger` を使用）
- [ ] 適切な型注釈を付与
- [ ] `const` コンストラクタを可能な限り使用
- [ ] 未使用のimportを削除
- [ ] null安全性を考慮

## パフォーマンス最適化

### Constコンストラクタの積極使用

```dart
// ✅ constを使用して再構築を防ぐ
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Static text'),
        SizedBox(height: 16),
        Icon(Icons.star),
      ],
    );
  }
}
```

### ListView.builderの使用

```dart
// ✅ 大きなリストではbuilderを使用
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)

// ❌ 全てのアイテムを一度に構築
ListView(
  children: items.map((item) => ItemCard(item: item)).toList(),
)
```

### リソース管理

```dart
// ✅ 適切なdispose
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
  
  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

## コード品質チェックコマンド

### 診断実行
```bash
# Kiroのツールで診断
getDiagnostics(['path/to/file.dart'])

# Flutter analyze
flutter analyze

# Dart format
dart format .

# テスト実行
flutter test
```

### 自動修正
```bash
# import整理とフォーマット
dart fix --apply
dart format .
```

## よくあるエラーと解決策

### エラー: Invalid constant value
**原因:** 実行時定数をconst contextで使用
**解決:** constを削除するか、コンパイル時定数を使用

### 警告: Unnecessary 'const' keyword
**原因:** 既にconst contextにある
**解決:** 重複したconstを削除

### 警告: Unused import
**原因:** 使用していないimportが残っている
**解決:** importを削除

### エラー: The method 'print' shouldn't be used
**原因:** print()を使用している
**解決:** loggerパッケージを使用

このガイドラインに従うことで、高品質で保守しやすいコードを維持できます。
