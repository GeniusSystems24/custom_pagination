part of '../pagination.dart';

/// Widget for displaying grouped paginated data.
///
/// [PaginateGroupedView] renders items organized into groups, with support
/// for custom group headers and item builders.
///
/// Example:
/// ```dart
/// PaginateGroupedView<String, Message>(
///   loadedState: state,
///   groupHeaderBuilder: (context, groupKey, items) {
///     return Container(
///       padding: EdgeInsets.all(16),
///       color: Colors.grey[200],
///       child: Text(
///         groupKey, // Date string
///         style: TextStyle(fontWeight: FontWeight.bold),
///       ),
///     );
///   },
///   itemBuilder: (context, item, index) {
///     return ListTile(
///       title: Text(item.content),
///       subtitle: Text(item.author),
///     );
///   },
///   fetchPaginatedList: cubit.fetchPaginatedList,
/// )
/// ```
class PaginateGroupedView<Key, T> extends StatelessWidget {
  const PaginateGroupedView({
    super.key,
    required this.loadedState,
    required this.groupHeaderBuilder,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(0),
    this.physics,
    this.scrollController,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.header,
    this.footer,
    this.bottomLoader,
    this.fetchPaginatedList,
    this.cacheExtent,
    this.separator,
  });

  /// The loaded state containing grouped items.
  final DualPaginationLoaded<Key, T> loadedState;

  /// Builder for group headers.
  ///
  /// Called once for each group with the group key and items.
  final Widget Function(BuildContext context, Key groupKey, List<T> items)
      groupHeaderBuilder;

  /// Builder for individual items within groups.
  ///
  /// Called for each item with the item and its index within the group.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Whether the scroll view should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Whether to display items in reverse order.
  final bool reverse;

  /// The scroll direction (vertical or horizontal).
  final Axis scrollDirection;

  /// Padding around the scroll view.
  final EdgeInsetsGeometry padding;

  /// The scroll physics to use.
  final ScrollPhysics? physics;

  /// Optional scroll controller.
  final ScrollController? scrollController;

  /// How the keyboard dismissal should behave.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Optional header widget displayed at the top.
  final Widget? header;

  /// Optional footer widget displayed at the bottom.
  final Widget? footer;

  /// Widget displayed while loading more items.
  final Widget? bottomLoader;

  /// Callback to fetch the next page.
  final VoidCallback? fetchPaginatedList;

  /// Cache extent for pre-rendering off-screen items.
  final double? cacheExtent;

  /// Optional separator between items.
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      reverse: reverse,
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      physics: physics,
      keyboardDismissBehavior: keyboardDismissBehavior,
      cacheExtent: cacheExtent,
      slivers: [
        if (header != null) header!,
        SliverPadding(
          padding: padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Calculate which group and item this index corresponds to
                int currentIndex = 0;
                for (var i = 0; i < loadedState.groups.length; i++) {
                  final group = loadedState.groups[i];
                  final groupKey = group.key;
                  final items = group.value;

                  // +1 for group header
                  final groupSize =
                      1 + items.length + (separator != null ? items.length : 0);

                  if (index < currentIndex + groupSize) {
                    final localIndex = index - currentIndex;

                    if (localIndex == 0) {
                      // Group header
                      return groupHeaderBuilder(context, groupKey, items);
                    } else {
                      // Item or separator
                      if (separator != null) {
                        final itemIndex = localIndex ~/ 2;
                        if (localIndex.isOdd) {
                          // Separator
                          return separator;
                        } else {
                          // Item
                          return itemBuilder(context, items[itemIndex - 1], itemIndex - 1);
                        }
                      } else {
                        // Item without separator
                        final itemIndex = localIndex - 1;
                        return itemBuilder(context, items[itemIndex], itemIndex);
                      }
                    }
                  }
                  currentIndex += groupSize;
                }

                // Bottom loader
                if (!loadedState.hasReachedEnd) {
                  fetchPaginatedList?.call();
                  return bottomLoader ?? const SizedBox.shrink();
                }

                return const SizedBox.shrink();
              },
              childCount: _calculateTotalCount(),
            ),
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }

  int _calculateTotalCount() {
    int count = 0;

    for (var group in loadedState.groups) {
      // +1 for group header
      count += 1;
      // Add items count
      count += group.value.length;
      // Add separators if present
      if (separator != null) {
        count += group.value.length;
      }
    }

    // +1 for bottom loader if not at end
    if (!loadedState.hasReachedEnd) {
      count += 1;
    }

    return count;
  }
}
