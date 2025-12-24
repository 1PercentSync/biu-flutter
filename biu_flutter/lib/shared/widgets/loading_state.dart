import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A widget to display a loading indicator.
///
/// Flutter-only: Provides full-screen loading state for async operations.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.size = 36,
  });

  /// Optional loading message
  final String? message;

  /// Size of the loading indicator
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact loading indicator for inline use.
///
/// Flutter-only: Smaller variant for inline loading states.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

/// A shimmer loading placeholder for list items.
///
/// Flutter-only: Provides skeleton loading animation for list items.
class ShimmerLoadingItem extends StatefulWidget {
  const ShimmerLoadingItem({
    super.key,
    this.height = 72,
  });

  final double height;

  @override
  State<ShimmerLoadingItem> createState() => _ShimmerLoadingItemState();
}

class _ShimmerLoadingItemState extends State<ShimmerLoadingItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value, 0),
                    colors: const [
                      AppColors.contentBackground,
                      Color(0xFF3A3A3A),
                      AppColors.contentBackground,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Text placeholders
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: const [
                            AppColors.contentBackground,
                            Color(0xFF3A3A3A),
                            AppColors.contentBackground,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: const [
                            AppColors.contentBackground,
                            Color(0xFF3A3A3A),
                            AppColors.contentBackground,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A list of shimmer loading placeholders.
///
/// Flutter-only: Provides skeleton loading list for better UX.
class ShimmerLoadingList extends StatelessWidget {
  const ShimmerLoadingList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => ShimmerLoadingItem(height: itemHeight),
    );
  }
}

/// A shimmer loading placeholder for video/image cards.
///
/// Source: biu/src/components/image-card/skeleton.tsx#CardSkeleton
class VideoCardSkeleton extends StatefulWidget {
  const VideoCardSkeleton({
    super.key,
    this.coverHeight = 188,
  });

  /// Height of the cover image placeholder
  final double coverHeight;

  @override
  State<VideoCardSkeleton> createState() => _VideoCardSkeletonState();
}

class _VideoCardSkeletonState extends State<VideoCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover placeholder
              Container(
                height: widget.coverHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value, 0),
                    colors: const [
                      AppColors.shimmerBase,
                      Color(0xFF3A3A3A),
                      AppColors.shimmerBase,
                    ],
                  ),
                ),
              ),
              // Title placeholder
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: const [
                            AppColors.shimmerBase,
                            Color(0xFF3A3A3A),
                            AppColors.shimmerBase,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: const [
                            AppColors.shimmerBase,
                            Color(0xFF3A3A3A),
                            AppColors.shimmerBase,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A grid of shimmer loading placeholders for video cards.
///
/// Source: biu/src/components/grid-list/index.tsx (loading state)
class VideoCardSkeletonGrid extends StatelessWidget {
  const VideoCardSkeletonGrid({
    super.key,
    this.itemCount = 12,
    this.coverHeight = 188,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio,
  });

  final int itemCount;
  final double coverHeight;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// Aspect ratio for each item.
  /// If null, calculates based on cover height + padding.
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    // Calculate aspect ratio: width / height
    // Card height = coverHeight + padding (12) + title (16) + spacing (8)
    //               + subtitle (12) + padding (12) = coverHeight + 60
    final aspectRatio = childAspectRatio ??
        (MediaQuery.of(context).size.width / crossAxisCount - crossAxisSpacing) /
            (coverHeight + 60);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => VideoCardSkeleton(
        coverHeight: coverHeight,
      ),
    );
  }
}
