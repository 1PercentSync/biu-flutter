import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/media_action_menu.dart';
import '../../../../shared/widgets/media_item.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../data/models/history_item.dart';

/// Widget for displaying a history item using MediaItem.
///
/// Fixed to list mode as history page only shows list layout.
/// Source: biu/src/pages/history/index.tsx
class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    required this.item,
    super.key,
    this.onTap,
    this.isActive = false,
  });

  final HistoryItem item;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return MediaItem(
      displayMode: DisplayMode.list, // History page only uses list mode
      title: item.title,
      coverUrl: item.cover,
      ownerName: item.authorName,
      isActive: isActive,
      actionWidget: item.isPlayable ? _buildActionMenu() : null,
      onTap: onTap,
      onOwnerTap: item.authorMid != null
          ? () => context.push('/user/${item.authorMid}')
          : null,
    );
  }

  Widget _buildActionMenu() {
    return MediaActionMenu(
      title: item.title,
      bvid: item.history.bvid ?? '',
      aid: item.history.oid.toString(),
      cover: item.cover,
      ownerName: item.authorName,
    );
  }
}
