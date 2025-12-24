import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/url_utils.dart';
import '../theme/app_colors.dart';

/// A cached network image widget with loading and error states.
///
/// Supports both audio and video placeholder icons for error states.
/// Uses CachedNetworkImage for efficient caching.
///
/// Source: biu/src/components/image/index.tsx#Image
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fileType = FileType.audio,
    this.placeholder,
    this.errorWidget,
  });

  /// The URL of the image to display
  final String? imageUrl;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// How to inscribe the image into the space allocated
  final BoxFit fit;

  /// Border radius for the image
  final BorderRadius? borderRadius;

  /// Type of file (affects error placeholder icon)
  final FileType fileType;

  /// Custom placeholder widget
  final Widget? placeholder;

  /// Custom error widget
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    // Handle empty or null URL
    final rawUrl = imageUrl;
    if (rawUrl == null || rawUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // Ensure URL has proper protocol
    // Source: biu/src/common/utils/url.ts#formatUrlProtocal
    final url = UrlUtils.formatProtocol(rawUrl);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorWidget(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Build loading placeholder
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  /// Build error placeholder
  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadius,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Center(
        child: Icon(
          fileType == FileType.audio ? Icons.music_note : Icons.movie,
          size: 24,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// Type of file for placeholder icon
enum FileType {
  audio,
  video,
}
