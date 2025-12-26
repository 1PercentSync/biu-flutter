import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../domain/entities/search_history_item.dart';
import '../providers/search_history_notifier.dart';

/// Widget displaying search history with chips
class SearchHistoryWidget extends ConsumerWidget {
  const SearchHistoryWidget({
    required this.onSelect, super.key,
  });

  final void Function(String query) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(searchHistoryProvider);

    if (!historyState.isLoaded) {
      return const SizedBox.shrink();
    }

    if (historyState.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref),
        const SizedBox(height: 12),
        _buildHistoryChips(context, ref, historyState.items),
      ],
    );
  }

  /// Source: biu/src/layout/navbar/search/index.tsx:114-124
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '搜索历史',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        GestureDetector(
          onTap: () {
            _showClearConfirmDialog(context, ref);
          },
          child: const Text(
            '清除',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChips(
    BuildContext context,
    WidgetRef ref,
    List<SearchHistoryItem> items,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return _HistoryChip(
          item: item,
          onTap: () => onSelect(item.value),
          onDelete: () {
            ref.read(searchHistoryProvider.notifier).delete(item);
          },
        );
      }).toList(),
    );
  }

  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除搜索历史'),
        content: const Text('确定要清除所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(searchHistoryProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}

/// Individual history chip with delete button
class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final SearchHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
