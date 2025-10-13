
import 'package:uuid/uuid.dart';

/// アイテムを表すモデルクラス
class Item {
  final String id;
  
  final String name;
  
  int count;
  
  final DateTime createdAt;
  
  DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
  });

  void decrement() {
    if (count > 0) {
      count--;
      updatedAt = DateTime.now();
    }
  }

  void increment() {
    count++;
    updatedAt = DateTime.now();
  }

  void setCount(int newCount) {
    if (newCount >= 0) {
      count = newCount;
      updatedAt = DateTime.now();
    }
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Item.create({required String name, required int initialCount}) {
    final now = DateTime.now();
    const uuid = Uuid();
    return Item(
      id: uuid.v4(),  // UUID v4を使用して一意のIDを生成
      name: name,
      count: initialCount,
      createdAt: now,
      updatedAt: now,
    );
  }
}
