import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';

/// アイテムのデータモデル
/// 
/// 不変性を保つため、状態変更は新しいインスタンスを返すメソッドで行います。
class Item {
  final String id;
  final String name;
  final int count;
  final String? icon; // 絵文字アイコン（オプショナル）
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
  }) : assert(count >= 0, 'Count must be non-negative') {
    _validateName(name);
  }

  /// 内部用コンストラクタ（バリデーションをスキップ）
  /// デシリアライゼーション時の後方互換性のために使用
  Item._internal({
    required this.id,
    required this.name,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
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
  /// 
  /// [icon]パラメータについて：
  /// - パラメータが提供されない場合：既存のアイコンを維持
  /// - パラメータにnullが渡された場合：アイコンを削除（nullに設定）
  /// - パラメータに値が渡された場合：新しいアイコンに更新
  /// 
  /// 注意：nameが変更される場合は新しい値に対してバリデーションが実行されます
  Item copyWith({
    String? id,
    String? name,
    int? count,
    Object? icon = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // 名前が変更される場合は新しい値をバリデーション
    if (name != null) {
      _validateName(name);
    }
    
    return Item._internal(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      icon: icon == _sentinel ? this.icon : icon as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// copyWithメソッドで「値が提供されなかった」ことを示すセンチネル値
  static const Object _sentinel = Object();

  /// JSONからItemインスタンスを作成
  /// 
  /// 後方互換性のため、不正な名前を持つ既存データを自動的にサニタイズします：
  /// - 空文字列 → "無名のアイテム"
  /// - 空白のみ → "無名のアイテム"  
  /// - 長すぎる名前 → 最大長に切り詰め
  factory Item.fromJson(Map<String, dynamic> json) {
    final String rawName = json['name'] as String;
    final String sanitizedName = _sanitizeName(rawName);
    
    return Item._internal(
      id: json['id'] as String,
      name: sanitizedName,
      count: json['count'] as int,
      icon: json['icon'] as String?,
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
      if (icon != null) 'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 新しいItemインスタンスを作成
  factory Item.create({
    required String name,
    required int initialCount,
    String? icon,
  }) {
    // 名前の検証
    if (name.trim().isEmpty) {
      throw ArgumentError('Item name cannot be empty or only whitespace');
    }
    
    // 数量の検証
    if (initialCount < 0) {
      throw ArgumentError('Initial count must be non-negative');
    }
    
    final now = DateTime.now();
    const uuid = Uuid();
    return Item(
      id: uuid.v4(),
      name: name,
      count: initialCount,
      icon: icon,
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
          count == other.count &&
          icon == other.icon;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ count.hashCode ^ (icon?.hashCode ?? 0);

  @override
  String toString() {
    return 'Item(id: $id, name: $name, count: $count, icon: $icon, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// 名前のバリデーションを行う
  static void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Item name cannot be empty or only whitespace');
    }
    if (name.length > AppConstants.maxNameLength) {
      throw ArgumentError('Item name cannot exceed ${AppConstants.maxNameLength} characters');
    }
  }

  /// 既存データの名前をサニタイズする（後方互換性のため）
  static String _sanitizeName(String name) {
    // 空文字列または空白のみの場合はデフォルト名を使用
    if (name.trim().isEmpty) {
      return '無名のアイテム';
    }
    
    // 長すぎる場合は切り詰める
    if (name.length > AppConstants.maxNameLength) {
      return name.substring(0, AppConstants.maxNameLength);
    }
    
    return name;
  }
}
