import 'package:flutter/material.dart';

/// Application-wide constants and default settings
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'Biu';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Default border radius
  static const double defaultBorderRadius = 8;

  /// Default font family
  static const String defaultFontFamily = 'system-ui';

  /// Default background color (dark theme)
  static const Color defaultBackgroundColor = Color(0xFF18181B);

  /// Default content background color (dark theme)
  static const Color defaultContentBackgroundColor = Color(0xFF1F1F1F);

  /// Default primary color
  static const Color defaultPrimaryColor = Color(0xFF17C964);

  /// Display modes for content lists
  static const List<String> displayModes = ['card', 'list'];
}

/// Storage keys for persistent data
class StorageKeys {
  StorageKeys._();

  /// Key for storing user login info
  static const String userLoginInfo = 'user_login_info';

  /// Key for storing app settings
  static const String appSettings = 'app_settings';

  /// Key for storing playlist
  static const String playlist = 'playlist';

  /// Key for storing play progress
  static const String playProgress = 'play_progress';

  /// Key for storing cookies
  static const String cookies = 'cookies';

  /// Key for storing BUVID
  static const String buvid = 'buvid';

  /// Key for storing bili_ticket
  static const String biliTicket = 'bili_ticket';

  /// Key for storing WBI keys
  static const String wbiKeys = 'wbi_keys';
}
