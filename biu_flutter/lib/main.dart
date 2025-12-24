import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/storage/storage_service.dart';
import 'features/player/services/audio_service_init.dart';
import 'shared/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage
  await SecureStorageService.instance.initialize();

  // Initialize Dio client for network requests
  await DioClient.instance.initialize();

  // Initialize storage service
  final storageService = await SharedPreferencesStorage.create();

  // Create provider container for pre-runApp initialization
  // Override the storage service provider with the initialized instance
  final container = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storageService),
    ],
  );

  // Initialize audio service (must be done before runApp for background audio)
  await initializeAudioService(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BiuApp(),
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
