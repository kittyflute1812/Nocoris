import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/item_service.dart';

/// ItemServiceのProvider
/// 
/// アプリ全体でItemServiceのインスタンスを共有します。
final itemServiceProvider = ChangeNotifierProvider<ItemService>((ref) {
  throw UnimplementedError('itemServiceProvider must be overridden');
});

/// ItemServiceを初期化するFutureProvider
/// 
/// StorageServiceの初期化を含む非同期処理を実行します。
final itemServiceInitProvider = FutureProvider<ItemService>((ref) async {
  return await ItemService.create();
});

