import '../../data/models/musician.dart';

/// State for artist rank screen
class ArtistRankState {
  const ArtistRankState({
    this.musicians = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  /// List of musicians
  final List<Musician> musicians;

  /// Whether initial loading is in progress
  final bool isLoading;

  /// Whether refresh is in progress
  final bool isRefreshing;

  /// Error message if any
  final String? errorMessage;

  /// Whether there's an error
  bool get hasError => errorMessage != null;

  /// Whether data is empty
  bool get isEmpty => musicians.isEmpty && !isLoading;

  ArtistRankState copyWith({
    List<Musician>? musicians,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ArtistRankState(
      musicians: musicians ?? this.musicians,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
