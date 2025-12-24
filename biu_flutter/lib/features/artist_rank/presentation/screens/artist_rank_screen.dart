import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../data/models/musician.dart';
import '../providers/artist_rank_notifier.dart';
import '../providers/artist_rank_state.dart';
import '../widgets/musician_card.dart';

/// Screen displaying artist/musician rankings.
class ArtistRankScreen extends ConsumerStatefulWidget {
  const ArtistRankScreen({super.key});

  @override
  ConsumerState<ArtistRankScreen> createState() => _ArtistRankScreenState();
}

class _ArtistRankScreenState extends ConsumerState<ArtistRankScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(artistRankProvider);
      if (state.musicians.isEmpty && !state.isLoading) {
        ref.read(artistRankProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(artistRankProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Music Artists'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, ArtistRankState state) {
    if (state.isLoading && state.musicians.isEmpty) {
      return const LoadingState(message: 'Loading artists...');
    }

    if (state.hasError && state.musicians.isEmpty) {
      return EmptyState(
        icon: const Icon(
          Icons.error_outline,
          size: 48,
          color: AppColors.error,
        ),
        title: 'Failed to Load',
        message: state.errorMessage,
        action: ElevatedButton(
          onPressed: () => ref.read(artistRankProvider.notifier).load(),
          child: const Text('Retry'),
        ),
      );
    }

    if (state.isEmpty) {
      return const EmptyState(
        icon: Icon(
          Icons.music_note,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: 'No Artists',
        message: 'No artists found',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(artistRankProvider.notifier).refresh(),
      child: _buildGrid(context, state.musicians),
    );
  }

  Widget _buildGrid(BuildContext context, List<Musician> musicians) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: musicians.length,
      itemBuilder: (context, index) {
        final musician = musicians[index];
        return MusicianCard(
          musician: musician,
          onTap: () => _onMusicianTap(musician),
        );
      },
    );
  }

  void _onMusicianTap(Musician musician) {
    // Navigate to user profile
    // TODO: Navigate to user profile screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${musician.username}\'s profile...'),
        duration: const Duration(seconds: 1),
      ),
    );
    // For now, we can try to navigate if the route exists
    // context.push('/user/${musician.uid}');
  }
}
