/// Route path constants
class AppRoutes {
  AppRoutes._();

  /// Home page
  static const String home = '/';

  /// Search page
  static const String search = '/search';

  /// Favorites page
  static const String favorites = '/favorites';

  /// History page
  static const String history = '/history';

  /// Watch Later page
  static const String later = '/later';

  /// Profile page
  static const String profile = '/profile';

  /// Settings page
  static const String settings = '/settings';

  /// About page
  static const String about = '/about';

  /// Login page
  static const String login = '/login';

  /// Artist Rank page
  static const String artistRank = '/artists';

  /// Music Recommend page
  static const String musicRecommend = '/music-recommend';

  /// Follow List page
  static const String followList = '/follow';

  /// User space page
  static const String userSpace = '/user/:mid';

  /// Favorites folder detail page
  static const String favoritesFolder = '/favorites/:folderId';

  /// Build user space path
  static String userSpacePath(int mid) => '/user/$mid';

  /// Build favorites folder path
  static String favoritesFolderPath(int folderId) => '/favorites/$folderId';
}

/// Routes that require authentication
const List<String> protectedRoutes = [
  AppRoutes.favorites,
  AppRoutes.history,
  AppRoutes.later,
  AppRoutes.followList,
  AppRoutes.profile,
];

/// Check if a route requires authentication
bool isProtectedRoute(String path) {
  return protectedRoutes.any((route) => path.startsWith(route));
}
