import '../../data/models/recommended_song.dart';

/// State for music recommend screen with pagination support.
/// Source: biu/src/pages/music-recommend/index.tsx (state management)
class MusicRecommendState {
  const MusicRecommendState({
    this.songs = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<RecommendedSong> songs;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  /// Check if the list is empty
  bool get isEmpty => songs.isEmpty;

  /// Create a copy with updated fields
  MusicRecommendState copyWith({
    List<RecommendedSong>? songs,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    int? currentPage,
    bool? hasMore,
  }) {
    return MusicRecommendState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
