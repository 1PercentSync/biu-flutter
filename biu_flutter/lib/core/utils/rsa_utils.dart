import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

/// RSA encryption utilities for Bilibili password login
class RsaUtils {
  RsaUtils._();

  /// Encrypt password using RSA public key
  ///
  /// [publicKeyPem] - PEM formatted RSA public key
  /// [hash] - Salt hash from server
  /// [password] - Plain text password
  ///
  /// Returns base64 encoded encrypted password, or null if encryption fails
  static String? encryptPassword({
    required String publicKeyPem,
    required String hash,
    required String password,
  }) {
    try {
      // Parse PEM public key
      final publicKey = _parsePublicKeyFromPem(publicKeyPem);
      if (publicKey == null) return null;

      // Combine hash and password
      final plainText = hash + password;
      final plainBytes = utf8.encode(plainText);

      // Create cipher with PKCS1 padding (standard for bilibili)
      final cipher = PKCS1Encoding(RSAEngine())
        ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

      // Encrypt
      final encrypted = cipher.process(Uint8List.fromList(plainBytes));

      // Return base64 encoded
      return base64.encode(encrypted);
    } catch (e) {
      return null;
    }
  }

  /// Parse RSA public key from PEM format
  static RSAPublicKey? _parsePublicKeyFromPem(String pem) {
    try {
      // Remove PEM headers and whitespace
      final pemContent = pem
          .replaceAll('-----BEGIN PUBLIC KEY-----', '')
          .replaceAll('-----END PUBLIC KEY-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      // Decode base64
      final bytes = base64.decode(pemContent);

      // Parse ASN.1 structure
      final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
      final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

      // The public key is in the second element (bit string)
      final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;

      // Parse the actual public key
      final publicKeyAsn = ASN1Parser(publicKeyBitString.valueBytes!);
      final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;

      final modulus = publicKeySeq.elements![0] as ASN1Integer;
      final exponent = publicKeySeq.elements![1] as ASN1Integer;

      return RSAPublicKey(modulus.integer!, exponent.integer!);
    } catch (e) {
      return null;
    }
  }
}
