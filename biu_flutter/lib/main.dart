import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage_service.dart';
import 'shared/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage
  await SecureStorageService.instance.initialize();

  // Initialize Dio client for network requests
  await DioClient.instance.initialize();

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
      theme: AppTheme.buildDarkTheme(),
      routerConfig: router,
    );
  }
}
