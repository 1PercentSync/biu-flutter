import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../datasources/auth_remote_datasource.dart';

/// Service for refreshing Bilibili cookies
class CookieRefreshService {
  final AuthRemoteDatasource _datasource;

  CookieRefreshService(this._datasource);

  /// RSA public key for correspond path encryption (from Bilibili)
  /// This is a fixed public key used by Bilibili for cookie refresh
  static const _rsaPublicKeyN =
      'y4HdjgJHBlbaBN04VERG4qNBIFHP6a3GozCl75AihQloSWCXC5HDNgyinEnhaQ_4-gaMud_GF50elYXLlCToR9se9Z8z433U3KjM-3Yx7ptKkmQNAMggQwAVKgq3zYAoidNEWuxpkY_mAitTSRLnsJW-NCTa0bqBFF6Wm1MxgfE';
  static const _rsaPublicKeyE = 'AQAB';

  /// Check if cookie refresh is needed and perform refresh if necessary
  /// Returns (success, newRefreshToken) tuple
  Future<(bool, String?)> refreshCookieIfNeeded(String? currentRefreshToken) async {
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      return (false, null);
    }

    try {
      // Check if refresh is needed
      final cookieInfo = await _datasource.getCookieInfo();

      if (!cookieInfo.isSuccess || cookieInfo.data == null) {
        return (false, null);
      }

      if (!cookieInfo.data!.refresh) {
        // No refresh needed
        return (true, currentRefreshToken);
      }

      // Refresh is needed
      final timestamp = cookieInfo.data!.timestamp;

      // Generate correspond path
      final correspondPath = await _generateCorrespondPath(timestamp);

      // Get refresh_csrf from correspond path page
      final html = await _datasource.getCorrespondPathHtml(correspondPath);
      final refreshCsrf = _parseRefreshCsrf(html);

      if (refreshCsrf == null || refreshCsrf.isEmpty) {
        return (false, null);
      }

      // Refresh cookies
      final refreshResponse = await _datasource.refreshCookie(
        refreshCsrf: refreshCsrf,
        refreshToken: currentRefreshToken,
      );

      if (!refreshResponse.isSuccess || refreshResponse.data == null) {
        return (false, null);
      }

      // Confirm refresh (invalidates old refresh_token)
      final confirmResponse = await _datasource.confirmRefresh(
        refreshToken: currentRefreshToken,
      );

      if (!confirmResponse.isSuccess) {
        return (false, null);
      }

      // Return new refresh token
      return (true, refreshResponse.data!.refreshToken);
    } catch (e) {
      return (false, null);
    }
  }

  /// Generate correspond path using RSA-OAEP encryption
  Future<String> _generateCorrespondPath(int timestamp) async {
    final message = 'refresh_$timestamp';
    final messageBytes = utf8.encode(message);

    // Parse RSA public key
    final publicKey = _parseRsaPublicKey();

    // Encrypt using RSA-OAEP with SHA-256
    final encryptor = OAEPEncoding.withSHA256(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final encrypted = encryptor.process(Uint8List.fromList(messageBytes));

    // Convert to hex string
    return encrypted.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Parse RSA public key from JWK format
  RSAPublicKey _parseRsaPublicKey() {
    // Decode base64url encoded n and e
    final nBytes = _base64UrlDecode(_rsaPublicKeyN);
    final eBytes = _base64UrlDecode(_rsaPublicKeyE);

    // Convert to BigInt
    final n = _bytesToBigInt(nBytes);
    final e = _bytesToBigInt(eBytes);

    return RSAPublicKey(n, e);
  }

  /// Decode base64url string to bytes
  Uint8List _base64UrlDecode(String input) {
    // Convert base64url to base64
    var output = input.replaceAll('-', '+').replaceAll('_', '/');

    // Add padding if needed
    switch (output.length % 4) {
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
    }

    return base64.decode(output);
  }

  /// Convert bytes to BigInt (big-endian)
  BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  /// Parse refresh_csrf from HTML response
  String? _parseRefreshCsrf(String html) {
    // Look for <div id="1-name">...</div>
    final regex = RegExp(r'<div[^>]*id="1-name"[^>]*>([^<]*)</div>', caseSensitive: false);
    final match = regex.firstMatch(html);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim();
    }

    return null;
  }
}
