import '../../data/models/hot_song.dart';

/// State for music rank screen.
class MusicRankState {
  const MusicRankState({
    this.songs = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<HotSong> songs;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get isEmpty => songs.isEmpty && !isLoading;

  MusicRankState copyWith({
    List<HotSong>? songs,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MusicRankState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
