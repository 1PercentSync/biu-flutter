import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_notifier.dart';

/// QR code login state
enum QrLoginStatus {
  /// Initial state, loading QR code
  loading,

  /// QR code ready for scanning
  ready,

  /// QR code scanned, waiting for confirmation
  scanned,

  /// Login successful
  success,

  /// QR code expired
  expired,

  /// Error occurred
  error,
}

/// QR login state
class QrLoginState {

  const QrLoginState({
    this.status = QrLoginStatus.loading,
    this.qrCodeUrl,
    this.qrCodeKey,
    this.errorMessage,
  });
  final QrLoginStatus status;
  final String? qrCodeUrl;
  final String? qrCodeKey;
  final String? errorMessage;

  static const QrLoginState initial = QrLoginState();

  QrLoginState copyWith({
    QrLoginStatus? status,
    String? qrCodeUrl,
    String? qrCodeKey,
    String? errorMessage,
    bool clearUrl = false,
    bool clearKey = false,
    bool clearError = false,
  }) {
    return QrLoginState(
      status: status ?? this.status,
      qrCodeUrl: clearUrl ? null : (qrCodeUrl ?? this.qrCodeUrl),
      qrCodeKey: clearKey ? null : (qrCodeKey ?? this.qrCodeKey),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider for QR login state
final qrLoginNotifierProvider =
    StateNotifierProvider.autoDispose<QrLoginNotifier, QrLoginState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  return QrLoginNotifier(repository, authNotifier);
});

/// QR login state notifier
class QrLoginNotifier extends StateNotifier<QrLoginState> {

  QrLoginNotifier(this._repository, this._authNotifier)
      : super(QrLoginState.initial) {
    // Generate QR code on initialization
    generateQrCode();
  }
  final AuthRepository _repository;
  final AuthNotifier _authNotifier;
  Timer? _pollTimer;

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  /// Generate new QR code
  Future<void> generateQrCode() async {
    state = state.copyWith(
      status: QrLoginStatus.loading,
      clearError: true,
    );

    try {
      final (url, key) = await _repository.generateQrCode();
      state = state.copyWith(
        status: QrLoginStatus.ready,
        qrCodeUrl: url,
        qrCodeKey: key,
      );
      // Start polling for login status
      _startPolling();
    } catch (e) {
      state = state.copyWith(
        status: QrLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh QR code (after expiration)
  Future<void> refreshQrCode() async {
    _stopPolling();
    await generateQrCode();
  }

  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollStatus();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollStatus() async {
    final key = state.qrCodeKey;
    if (key == null || key.isEmpty) return;

    try {
      final (code, refreshToken, message) =
          await _repository.pollQrCodeStatus(key);

      switch (code) {
        case 0:
          // Login successful
          _stopPolling();
          state = state.copyWith(status: QrLoginStatus.success);
          // Notify auth notifier of successful login
          await _authNotifier.onLoginSuccess(refreshToken);
          break;
        case 86038:
          // QR code expired
          _stopPolling();
          state = state.copyWith(
            status: QrLoginStatus.expired,
            errorMessage: message,
          );
          break;
        case 86090:
          // QR code scanned, waiting for confirmation
          if (state.status != QrLoginStatus.scanned) {
            state = state.copyWith(status: QrLoginStatus.scanned);
          }
          break;
        case 86101:
          // Not scanned yet, continue polling
          break;
        default:
          // Unknown status
          break;
      }
    } catch (e) {
      // Ignore polling errors, continue polling
    }
  }
}
