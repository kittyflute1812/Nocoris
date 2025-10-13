import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _itemsKey = 'items';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// SharedPreferencesのインスタンスを初期化して新しいStorageServiceを作成
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// 文字列をJSONとして保存
  Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    return await _prefs.setString(key, jsonEncode(json));
  }

  /// JSONを文字列として読み込み
  Map<String, dynamic>? loadJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// 複数のJSONデータをリストとして保存
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> jsonList) async {
    return await _prefs.setString(key, jsonEncode(jsonList));
  }

  /// JSONデータのリストを読み込み
  List<Map<String, dynamic>>? loadJsonList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return List<Map<String, dynamic>>.from(
      jsonDecode(jsonString) as List,
    );
  }

  /// アイテムリストを保存
  Future<bool> saveItems(List<Map<String, dynamic>> items) async {
    return await saveJsonList(_itemsKey, items);
  }

  /// アイテムリストを読み込み
  List<Map<String, dynamic>>? loadItems() {
    return loadJsonList(_itemsKey);
  }
}