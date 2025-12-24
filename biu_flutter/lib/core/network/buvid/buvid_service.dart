import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../constants/api.dart';
import '../../storage/storage_service.dart';

/// Response from buvid API
class BuvidResponse {
  const BuvidResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.b3,
    required this.b4,
  });

  factory BuvidResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BuvidResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      ttl: json['ttl'] as int? ?? 1,
      b3: data['b_3'] as String? ?? '',
      b4: data['b_4'] as String? ?? '',
    );
  }

  final int code;
  final String message;
  final int ttl;
  final String b3; // buvid3
  final String b4; // buvid4
}

/// BUVID service for generating and managing BUVID cookies
///
/// BUVID is a unique identifier used by Bilibili for tracking and
/// anti-spam purposes. It needs to be included in cookies for API requests.
///
/// Reference: https://socialsisteryi.github.io/bilibili-API-collect/docs/misc/buvid3_4.html
class BuvidService {
  BuvidService._();

  static final BuvidService _instance = BuvidService._();
  static BuvidService get instance => _instance;

  /// Storage keys
  static const String _storageKeyBuvid3 = 'buvid3';
  static const String _storageKeyBuvid4 = 'buvid4';

  /// Storage service
  StorageService? _storage;

  /// Cached values
  String? _buvid3;
  String? _buvid4;

  /// Dio instance for fetching BUVID (without auth interceptors)
  Dio? _dio;

  /// Get cached buvid3
  String? get buvid3 => _buvid3;

  /// Get cached buvid4
  String? get buvid4 => _buvid4;

  /// Initialize the service
  Future<void> initialize(StorageService storage) async {
    _storage = storage;
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
        headers: {
          'User-Agent': ApiConstants.webUserAgent,
        },
      ),
    );

    await _loadCachedBuvid();
  }

  /// Load cached BUVID from storage
  Future<void> _loadCachedBuvid() async {
    if (_storage == null) return;

    _buvid3 = await _storage!.getString(_storageKeyBuvid3);
    _buvid4 = await _storage!.getString(_storageKeyBuvid4);
  }

  /// Save BUVID to storage
  Future<void> _saveBuvid() async {
    if (_storage == null) return;

    if (_buvid3 != null) {
      await _storage!.setString(_storageKeyBuvid3, _buvid3!);
    }
    if (_buvid4 != null) {
      await _storage!.setString(_storageKeyBuvid4, _buvid4!);
    }
  }

  /// Fetch BUVID from API
  Future<void> fetchBuvid() async {
    if (_dio == null) return;

    try {
      final response = await _dio!.get<Map<String, dynamic>>('/x/frontend/finger/spi');
      final data = response.data;

      if (data != null) {
        final buvidResponse = BuvidResponse.fromJson(data);

        if (buvidResponse.code == 0) {
          _buvid3 = buvidResponse.b3;
          _buvid4 = buvidResponse.b4;
          await _saveBuvid();
        }
      }
    } catch (e) {
      // Silently fail, will generate locally if needed
    }
  }

  /// Generate BUVID3 locally (fallback)
  ///
  /// Format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXinfoc
  /// Where X is a hex digit derived from device info or random data
  String generateBuvid3Local() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = '${timestamp}flutter_app';
    final hash = md5.convert(utf8.encode(random)).toString().toUpperCase();

    return '${hash.substring(0, 8)}-${hash.substring(8, 12)}-'
        '${hash.substring(12, 16)}-${hash.substring(16, 20)}-'
        '${hash.substring(20, 32)}infoc';
  }

  /// Ensure BUVID is available
  Future<void> ensureBuvid() async {
    if (_buvid3 != null && _buvid3!.isNotEmpty) {
      return;
    }

    // Try to fetch from API first
    await fetchBuvid();

    // If still not available, generate locally
    if (_buvid3 == null || _buvid3!.isEmpty) {
      _buvid3 = generateBuvid3Local();
      await _saveBuvid();
    }
  }

  /// Clear cached BUVID
  Future<void> clear() async {
    _buvid3 = null;
    _buvid4 = null;

    if (_storage != null) {
      await _storage!.remove(_storageKeyBuvid3);
      await _storage!.remove(_storageKeyBuvid4);
    }
  }
}
