import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for key-value storage
abstract class StorageService {
  /// Get a string value
  Future<String?> getString(String key);

  /// Set a string value
  Future<bool> setString(String key, String value);

  /// Get a boolean value
  Future<bool?> getBool(String key);

  /// Set a boolean value
  Future<bool> setBool(String key, {required bool value});

  /// Get an integer value
  Future<int?> getInt(String key);

  /// Set an integer value
  Future<bool> setInt(String key, int value);

  /// Get a double value
  Future<double?> getDouble(String key);

  /// Set a double value
  Future<bool> setDouble(String key, double value);

  /// Get a list of strings
  Future<List<String>?> getStringList(String key);

  /// Set a list of strings
  Future<bool> setStringList(String key, List<String> value);

  /// Get a JSON object
  Future<Map<String, dynamic>?> getJson(String key);

  /// Set a JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value);

  /// Remove a value
  Future<bool> remove(String key);

  /// Check if a key exists
  Future<bool> containsKey(String key);

  /// Clear all values
  Future<bool> clear();
}

/// Implementation of StorageService using SharedPreferences
class SharedPreferencesStorage implements StorageService {
  SharedPreferencesStorage._(this._prefs);

  final SharedPreferences _prefs;

  /// Create a new instance
  static Future<SharedPreferencesStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStorage._(prefs);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setBool(String key, {required bool value}) async {
    return _prefs.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonStr = json.encode(value);
      return _prefs.setString(key, jsonStr);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }
}
