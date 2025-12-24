import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Home screen displaying featured content and recommendations.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: const Text('Biu'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  // TODO: Navigate to history
                },
              ),
            ],
          ),
          // Content
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Placeholder content for now
    return const EmptyState(
      icon: Icon(
        Icons.home_outlined,
        size: 48,
        color: AppColors.textTertiary,
      ),
      title: 'Welcome to Biu',
      message: 'Your favorite music player\n\nStart by searching for content',
    );
  }
}
