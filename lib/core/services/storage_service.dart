import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// ローカルストレージへのデータ永続化を担当するサービス
/// 
/// SharedPreferencesを使用してJSONデータの保存・読み込みを行います。
class StorageService {
  final Logger _logger = Logger();
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// SharedPreferencesのインスタンスを初期化して新しいStorageServiceを作成
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// 文字列をJSONとして保存
  Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    try {
      return await _prefs.setString(key, jsonEncode(json));
    } catch (e) {
      _logger.e('Failed to save json: $e');
      return false;
    }
  }

  /// JSONを文字列として読み込み
  Map<String, dynamic>? loadJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      _logger.e('Failed to decode json: $e');
    }
    return null;
  }

  /// 複数のJSONデータをリストとして保存
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> jsonList) async {
    try {
      return await _prefs.setString(key, jsonEncode(jsonList));
    } catch (e) {
      _logger.e('Failed to save json list: $e');
      return false;
    }
  }

  /// JSONデータのリストを読み込み
  List<Map<String, dynamic>>? loadJsonList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    } catch (e) {
      _logger.e('Failed to decode json list: $e');
    }
    return null;
  }

  /// アイテムリストを保存
  Future<bool> saveItems(List<Map<String, dynamic>> items) async {
    return await saveJsonList(AppConstants.itemsStorageKey, items);
  }

  /// アイテムリストを読み込み
  List<Map<String, dynamic>>? loadItems() {
    return loadJsonList(AppConstants.itemsStorageKey);
  }
}

