import 'gaia_vgate_handler.dart';

/// Global holder for Gaia VGate handler.
///
/// This holder allows the core network layer to access the handler
/// without depending on the auth feature layer. The handler is set
/// during app initialization from the auth feature.
///
/// Usage:
/// ```dart
/// // In main.dart or app initialization
/// GaiaVgateHandlerHolder.handler = GaiaVgateHandlerImpl();
///
/// // In interceptor
/// final handler = GaiaVgateHandlerHolder.handler;
/// if (handler != null) {
///   // Use handler for verification
/// }
/// ```
class GaiaVgateHandlerHolder {
  GaiaVgateHandlerHolder._();

  /// The current handler (may be null if not initialized).
  /// Set this during app initialization, before any network requests.
  static GaiaVgateHandler? handler;
}
