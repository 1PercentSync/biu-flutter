import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../constants/api.dart';
import '../../storage/storage_service.dart';

/// Response from bili_ticket API
class BiliTicketResponse {
  const BiliTicketResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.ticket,
    required this.createdAt,
    required this.ticketTtl,
  });

  factory BiliTicketResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BiliTicketResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      ttl: json['ttl'] as int? ?? 1,
      ticket: data['ticket'] as String? ?? '',
      createdAt: data['created_at'] as int? ?? 0,
      ticketTtl: data['ttl'] as int? ?? 0,
    );
  }

  final int code;
  final String message;
  final int ttl;
  final String ticket;
  final int createdAt;
  final int ticketTtl;
}

/// Bili Ticket service for managing bili_ticket
///
/// bili_ticket is a JWT token used by Bilibili for anti-spam protection.
/// It needs to be refreshed periodically (TTL is typically 259200 seconds / 3 days).
///
/// Reference: https://socialsisteryi.github.io/bilibili-API-collect/docs/misc/sign/bili_ticket.html
class BiliTicketService {
  BiliTicketService._();

  static final BiliTicketService _instance = BiliTicketService._();
  static BiliTicketService get instance => _instance;

  /// HMAC key for generating hexsign
  static const String _hmacKey = 'XgwSnGZ1p';

  /// Storage keys
  static const String _storageKeyTicket = 'bili_ticket';
  static const String _storageKeyExpiry = 'bili_ticket_expiry';

  /// Storage service
  StorageService? _storage;

  /// Cached values
  String? _ticket;
  int _expiryTime = 0;

  /// Dio instance for fetching ticket
  Dio? _dio;

  /// Get cached ticket
  String? get ticket => _ticket;

  /// Check if ticket is valid
  bool get isTicketValid {
    if (_ticket == null || _ticket!.isEmpty) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Consider expired if less than 1 hour remaining
    return _expiryTime > now + 3600;
  }

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

    await _loadCachedTicket();
  }

  /// Load cached ticket from storage
  Future<void> _loadCachedTicket() async {
    if (_storage == null) return;

    _ticket = await _storage!.getString(_storageKeyTicket);
    final expiryStr = await _storage!.getString(_storageKeyExpiry);
    _expiryTime = expiryStr != null ? int.tryParse(expiryStr) ?? 0 : 0;
  }

  /// Save ticket to storage
  Future<void> _saveTicket() async {
    if (_storage == null) return;

    if (_ticket != null) {
      await _storage!.setString(_storageKeyTicket, _ticket!);
    }
    await _storage!.setString(_storageKeyExpiry, _expiryTime.toString());
  }

  /// Generate HMAC-SHA256 hexsign
  String _generateHexSign(int timestamp) {
    final message = 'ts$timestamp';
    final hmac = Hmac(sha256, utf8.encode(_hmacKey));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  /// Fetch bili_ticket from API
  Future<void> fetchTicket({String? csrf}) async {
    if (_dio == null) return;

    try {
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final hexsign = _generateHexSign(ts);

      final response = await _dio!.post<Map<String, dynamic>>(
        '/bapis/bilibili.api.ticket.v1.Ticket/GenWebTicket',
        queryParameters: {
          'key_id': 'ec02',
          'hexsign': hexsign,
          'context[ts]': ts.toString(),
          'csrf': csrf ?? '',
        },
      );

      final data = response.data;

      if (data != null) {
        final ticketResponse = BiliTicketResponse.fromJson(data);

        if (ticketResponse.code == 0 && ticketResponse.ticket.isNotEmpty) {
          _ticket = ticketResponse.ticket;
          _expiryTime = ticketResponse.createdAt + ticketResponse.ticketTtl;
          await _saveTicket();
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Ensure ticket is available and valid
  Future<void> ensureTicket({String? csrf}) async {
    if (isTicketValid) return;
    await fetchTicket(csrf: csrf);
  }

  /// Refresh ticket if needed
  Future<void> refreshIfNeeded({String? csrf}) async {
    if (!isTicketValid) {
      await fetchTicket(csrf: csrf);
    }
  }

  /// Clear cached ticket
  Future<void> clear() async {
    _ticket = null;
    _expiryTime = 0;

    if (_storage != null) {
      await _storage!.remove(_storageKeyTicket);
      await _storage!.remove(_storageKeyExpiry);
    }
  }
}
