/// Route path constants
class AppRoutes {
  AppRoutes._();

  /// Home page
  static const String home = '/';

  /// Search page
  static const String search = '/search';

  /// Favorites page
  static const String favorites = '/favorites';

  /// Profile page
  static const String profile = '/profile';

  /// Settings page
  static const String settings = '/settings';

  /// Login page
  static const String login = '/login';

  /// Video detail page
  static const String videoDetail = '/video/:bvid';

  /// Audio detail page
  static const String audioDetail = '/audio/:sid';

  /// User space page
  static const String userSpace = '/user/:mid';

  /// Favorites folder detail page
  static const String favoritesFolder = '/favorites/:folderId';

  /// Build video detail path
  static String videoDetailPath(String bvid) => '/video/$bvid';

  /// Build audio detail path
  static String audioDetailPath(int sid) => '/audio/$sid';

  /// Build user space path
  static String userSpacePath(int mid) => '/user/$mid';

  /// Build favorites folder path
  static String favoritesFolderPath(int folderId) => '/favorites/$folderId';
}

/// Routes that require authentication
const List<String> protectedRoutes = [
  AppRoutes.favorites,
  AppRoutes.profile,
];

/// Check if a route requires authentication
bool isProtectedRoute(String path) {
  return protectedRoutes.any((route) => path.startsWith(route));
}
