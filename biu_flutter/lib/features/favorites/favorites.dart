/// Favorites feature exports
library;

// Domain
export 'domain/entities/favorites_folder.dart';
export 'domain/entities/fav_media.dart';
export 'domain/repositories/favorites_repository.dart';

// Data
export 'data/repositories/favorites_repository_impl.dart';

// Presentation
export 'presentation/providers/favorites_state.dart';
export 'presentation/providers/favorites_notifier.dart';
export 'presentation/screens/favorites_screen.dart';
export 'presentation/screens/folder_detail_screen.dart';
export 'presentation/widgets/folder_edit_dialog.dart';
export 'presentation/widgets/folder_select_sheet.dart';
