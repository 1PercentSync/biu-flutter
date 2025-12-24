import 'package:flutter/material.dart';

import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../data/models/musician.dart';

/// Card widget for displaying a musician
class MusicianCard extends StatelessWidget {
  const MusicianCard({
    required this.musician,
    required this.onTap,
    super.key,
  });

  final Musician musician;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.contentBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with title overlay
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppCachedImage(
                    imageUrl: musician.cover,
                    fileType: FileType.video,
                  ),
                  // Title overlay at top left
                  if (musician.title.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          musician.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // User info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // User avatar
                  ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: AppCachedImage(
                        imageUrl: musician.userProfile,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // User name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          musician.username,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          musician.desc.isNotEmpty
                              ? musician.desc
                              : musician.selfIntro,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List tile variant of musician display
class MusicianListTile extends StatelessWidget {
  const MusicianListTile({
    required this.musician,
    required this.onTap,
    super.key,
  });

  final Musician musician;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipOval(
        child: SizedBox(
          width: 48,
          height: 48,
          child: AppCachedImage(
            imageUrl: musician.userProfile,
          ),
        ),
      ),
      title: Text(
        musician.username,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            '${NumberUtils.formatCompact(musician.fansCount)} fans',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${musician.archiveCount} videos',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
