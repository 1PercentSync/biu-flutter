import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data like tokens and cookies
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService _instance = SecureStorageService._();
  late final FlutterSecureStorage _storage;

  /// Get the singleton instance
  static SecureStorageService get instance => _instance;

  /// Initialize the secure storage
  Future<void> initialize() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  /// Get a string value
  Future<String?> getString(String key) async {
    return _storage.read(key: key);
  }

  /// Set a string value
  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Get a JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonStr = await _storage.read(key: key);
    if (jsonStr == null) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Set a JSON object
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonStr = json.encode(value);
    await _storage.write(key: key, value: jsonStr);
  }

  /// Remove a value
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  /// Clear all values
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Get all keys
  Future<Map<String, String>> getAll() async {
    return _storage.readAll();
  }
}
