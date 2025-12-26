import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/models/dynamic_item.dart';
import 'dynamic_card.dart';

/// User dynamic feed list widget.
/// Source: biu/src/pages/user-profile/dynamic-list/index.tsx
class DynamicList extends ConsumerStatefulWidget {
  const DynamicList({
    required this.mid,
    super.key,
  });

  /// Target user ID
  final int mid;

  @override
  ConsumerState<DynamicList> createState() => _DynamicListState();
}

class _DynamicListState extends ConsumerState<DynamicList> {
  final List<DynamicItem> _items = [];
  String? _offset;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchData({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _items.clear();
        _offset = null;
        _hasMore = true;
        _error = null;
      }
    });

    try {
      final datasource = UserProfileRemoteDataSource();
      final response = await datasource.getDynamicFeed(
        hostMid: widget.mid,
        offset: refresh ? null : _offset,
      );

      if (!response.isSuccess) {
        setState(() {
          _error = response.message;
          _isLoading = false;
          _isInitialized = true;
        });
        return;
      }

      final data = response.data;
      if (data == null) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
        return;
      }

      // Filter to only show video dynamics (matching source behavior)
      // Source: biu/src/pages/user-profile/dynamic-list/index.tsx:43
      final videos = data.items
          .where((item) => item.type == DynamicType.av)
          .toList();

      setState(() {
        if (refresh) {
          _items.clear();
        }
        _items.addAll(videos);
        _offset = data.offset;
        _hasMore = data.hasMore;
        _isLoading = false;
        _isInitialized = true;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _fetchData();
  }

  Future<void> _refresh() async {
    await _fetchData(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Initial loading state
    if (!_isInitialized && _isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load dynamics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_isInitialized && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.list_bullet,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No dynamics yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    // Content list
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _items.length + 1, // +1 for loading/end indicator
        itemBuilder: (context, index) {
          // Loading/end indicator at the end
          if (index == _items.length) {
            return _buildFooter();
          }

          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DynamicCard(item: item),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasMore && _items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more dynamics',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
