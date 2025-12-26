import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/presentation/providers/settings_notifier.dart';
import '../../theme/app_theme.dart';
import 'glass_styles.dart';

/// iOS-style bottom navigation bar with transparent background.
///
/// This widget is designed to be used on top of a [GlassBackdrop] in a Stack,
/// providing the frosted glass navigation effect seen in iOS system apps.
///
/// The navigation bar:
/// - Has transparent background (glass backdrop is separate)
/// - Uses 28pt icons and 10pt labels
/// - Uses primary color for selected items
/// - Uses 35% white for unselected items
/// - Includes bottom safe area padding
class GlassBottomNav extends ConsumerWidget {
  const GlassBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  /// Currently selected navigation index.
  final int selectedIndex;

  /// Callback when a navigation item is tapped.
  final ValueChanged<int> onDestinationSelected;

  // iOS-style filled icons (Apple Music style) - same icon for both states,
  // distinguished by color only (matching prototype)
  static const List<_NavItemData> _items = [
    _NavItemData(icon: CupertinoIcons.house_fill, label: '首页'),
    _NavItemData(icon: CupertinoIcons.search, label: '搜索'),
    _NavItemData(icon: CupertinoIcons.heart_fill, label: '收藏'),
    _NavItemData(icon: CupertinoIcons.clock_fill, label: '历史'),
    _NavItemData(icon: CupertinoIcons.person_fill, label: '我的'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(primaryColorProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: AppTheme.bottomNavHeight + bottomPadding,
      child: Column(
        children: [
          // Navigation items row
          SizedBox(
            height: AppTheme.bottomNavHeight,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: _NavItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    primaryColor: primaryColor,
                    onTap: () => onDestinationSelected(index),
                  ),
                );
              }),
            ),
          ),
          // Bottom safe area spacer
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? primaryColor : GlassStyles.inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Minimum touch target: 44pt (iOS HIG)
        height: AppTheme.bottomNavHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppTheme.bottomNavIconSize,
              color: color,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.bottomNavLabelSize,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
