import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../storage/storage_service.dart';
import '../dio_client.dart';

/// WBI signature generation for Bilibili API requests.
///
/// Implements the WBI (Web Bilibili Interface) signature algorithm required
/// for authenticated API calls.
///
/// External Reference: https://socialsisteryi.github.io/bilibili-API-collect/docs/misc/sign/wbi.html
/// Source: biu/src/service/request/wbi-sign.ts#encodeParamsWbi
class WbiSign {
  WbiSign._();

  static final WbiSign _instance = WbiSign._();
  static WbiSign get instance => _instance;

  /// Mixin key encoding table
  static const List<int> _mixinKeyEncTab = [
    46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49,
    33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40,
    61, 26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11,
    36, 20, 34, 44, 52,
  ];

  /// Characters to filter from parameter values
  static final RegExp _chrFilter = RegExp("[!'()*]");

  /// Cached WBI keys
  String? _imgKey;
  String? _subKey;
  int _cacheExpiry = 0;

  /// Storage service for persisting WBI keys
  StorageService? _storage;

  /// Storage keys
  static const String _storageKeyImgKey = 'wbi_img_key';
  static const String _storageKeySubKey = 'wbi_sub_key';
  static const String _storageKeyExpiry = 'wbi_cache_expiry';

  /// Initialize WBI sign with storage
  Future<void> initialize(StorageService storage) async {
    _storage = storage;
    await _loadCachedKeys();
  }

  /// Load cached keys from storage
  Future<void> _loadCachedKeys() async {
    if (_storage == null) return;

    _imgKey = await _storage!.getString(_storageKeyImgKey);
    _subKey = await _storage!.getString(_storageKeySubKey);
    final expiryStr = await _storage!.getString(_storageKeyExpiry);
    _cacheExpiry = expiryStr != null ? int.tryParse(expiryStr) ?? 0 : 0;
  }

  /// Save keys to storage
  Future<void> _saveKeys() async {
    if (_storage == null) return;

    if (_imgKey != null) {
      await _storage!.setString(_storageKeyImgKey, _imgKey!);
    }
    if (_subKey != null) {
      await _storage!.setString(_storageKeySubKey, _subKey!);
    }
    await _storage!.setString(_storageKeyExpiry, _cacheExpiry.toString());
  }

  /// Get mixin key by encoding imgKey + subKey
  String _getMixinKey(String orig) {
    return _mixinKeyEncTab
        .map((n) => n < orig.length ? orig[n] : '')
        .join()
        .substring(0, 32);
  }

  /// Extract key from URL
  /// URL format: https://i0.hdslb.com/bfs/wbi/xxx.png
  String _extractKeyFromUrl(String url) {
    final lastSlash = url.lastIndexOf('/');
    final lastDot = url.lastIndexOf('.');
    if (lastSlash == -1 || lastDot == -1 || lastDot <= lastSlash) {
      return '';
    }
    return url.substring(lastSlash + 1, lastDot);
  }

  /// Fetch WBI keys from API
  Future<void> _fetchWbiKeys() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Check if cache is still valid (cache for 12 hours)
    if (_imgKey != null && _subKey != null && _cacheExpiry > now) {
      return;
    }

    try {
      final dio = DioClient.instance.dio;
      final response = await dio.get<Map<String, dynamic>>(
        '/x/web-interface/nav',
        options: Options(extra: {'skipWbi': true}),
      );

      final data = response.data;
      if (data != null) {
        final dataMap = data['data'] as Map<String, dynamic>?;
        final wbiImg = dataMap?['wbi_img'] as Map<String, dynamic>?;
        if (wbiImg != null) {
          final imgUrl = wbiImg['img_url'] as String?;
          final subUrl = wbiImg['sub_url'] as String?;

          if (imgUrl != null && subUrl != null) {
            _imgKey = _extractKeyFromUrl(imgUrl);
            _subKey = _extractKeyFromUrl(subUrl);
            // Cache for 12 hours
            _cacheExpiry = now + 12 * 60 * 60;
            await _saveKeys();
          }
        }
      }
    } catch (e) {
      // Silently fail, will retry on next request
    }
  }

  /// Update WBI keys from nav response data
  void updateFromNavData(Map<String, dynamic>? wbiImg) {
    if (wbiImg == null) return;

    final imgUrl = wbiImg['img_url'] as String?;
    final subUrl = wbiImg['sub_url'] as String?;

    if (imgUrl != null && subUrl != null) {
      _imgKey = _extractKeyFromUrl(imgUrl);
      _subKey = _extractKeyFromUrl(subUrl);
      _cacheExpiry = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 12 * 60 * 60;
      _saveKeys();
    }
  }

  /// Encode parameters with WBI signature
  Future<Map<String, String>> encodeParams(Map<String, String> params) async {
    // Ensure we have valid keys
    await _fetchWbiKeys();

    if (_imgKey == null || _subKey == null || _imgKey!.isEmpty || _subKey!.isEmpty) {
      // Return params as-is if we don't have keys
      return params;
    }

    final mixinKey = _getMixinKey(_imgKey! + _subKey!);
    final currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Add wts (timestamp)
    final newParams = Map<String, String>.from(params);
    newParams['wts'] = currTime.toString();

    // Sort parameters and build query string
    final sortedKeys = newParams.keys.toList()..sort();
    final queryParts = <String>[];

    for (final key in sortedKeys) {
      final value = newParams[key];
      if (value != null) {
        // Filter special characters from value
        final filteredValue = value.replaceAll(_chrFilter, '');
        queryParts.add(
          '${Uri.encodeComponent(key)}=${Uri.encodeComponent(filteredValue)}',
        );
      }
    }

    final query = queryParts.join('&');

    // Generate MD5 hash
    final wbiSign = md5.convert(utf8.encode(query + mixinKey)).toString();

    // Return params with w_rid
    return {
      ...newParams,
      'w_rid': wbiSign,
    };
  }

  /// Clear cached keys
  Future<void> clearCache() async {
    _imgKey = null;
    _subKey = null;
    _cacheExpiry = 0;

    if (_storage != null) {
      await _storage!.remove(_storageKeyImgKey);
      await _storage!.remove(_storageKeySubKey);
      await _storage!.remove(_storageKeyExpiry);
    }
  }
}
