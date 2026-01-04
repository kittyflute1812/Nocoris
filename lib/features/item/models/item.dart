import 'package:uuid/uuid.dart';

/// アイテムのデータモデル
/// 
/// 不変性を保つため、状態変更は新しいインスタンスを返すメソッドで行います。
class Item {
  final String id;
  final String name;
  final int count;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(count >= 0, 'Count must be non-negative');

  /// カウントを1減らした新しいインスタンスを返す
  Item decrement() {
    if (count <= 0) return this;
    return copyWith(
      count: count - 1,
      updatedAt: DateTime.now(),
    );
  }

  /// カウントを1増やした新しいインスタンスを返す
  Item increment() {
    return copyWith(
      count: count + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// カウントを設定した新しいインスタンスを返す
  Item setCount(int newCount) {
    if (newCount < 0) return this;
    return copyWith(
      count: newCount,
      updatedAt: DateTime.now(),
    );
  }

  /// プロパティをコピーして新しいインスタンスを作成
  Item copyWith({
    String? id,
    String? name,
    int? count,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSONからItemインスタンスを作成
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      count: json['count'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// ItemインスタンスをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 新しいItemインスタンスを作成
  factory Item.create({
    required String name,
    required int initialCount,
  }) {
    final now = DateTime.now();
    final uuid = Uuid();
    return Item(
      id: uuid.v4(),
      name: name,
      count: initialCount,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          count == other.count;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ count.hashCode;

  @override
  String toString() {
    return 'Item(id: $id, name: $name, count: $count, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
