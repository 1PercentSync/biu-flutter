import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage
  await SecureStorageService.instance.initialize();

  runApp(
    const ProviderScope(
      child: BiuApp(),
    ),
  );
}

/// Main application widget
class BiuApp extends ConsumerWidget {
  const BiuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      routerConfig: router,
    );
  }

  /// Build the dark theme matching the source application
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.defaultPrimaryColor,
        secondary: AppConstants.defaultPrimaryColor,
        surface: AppConstants.defaultBackgroundColor,
      ),
      scaffoldBackgroundColor: AppConstants.defaultBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.defaultBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.defaultContentBackgroundColor,
        indicatorColor: AppConstants.defaultPrimaryColor.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.defaultContentBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.defaultContentBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.defaultPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
      ),
    );
  }
}
