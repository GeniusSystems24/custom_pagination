part of '../pagination.dart';

/// Base class for all DualPagination states.
///
/// DualPagination supports grouping items by keys for scenarios like:
/// - Chat messages grouped by date
/// - Products grouped by category
/// - Posts grouped by author
@immutable
abstract class DualPaginationState<T> implements IPaginationInitialState<T> {
  @override
  bool get hasReachedEnd => false;

  @override
  DateTime get lastUpdate => DateTime.now();

  @override
  PaginationMeta? get meta => null;
}

/// Initial state before any data is fetched.
class DualPaginationInitial<T> extends DualPaginationState<T> {}

/// Error state when data fetching fails.
///
/// Contains the exception that occurred during fetching.
class DualPaginationError<T> extends DualPaginationState<T>
    implements IPaginationErrorState<T> {
  final Exception _error;

  DualPaginationError({required Exception error}) : _error = error;

  @override
  Exception get error => _error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DualPaginationError<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

/// Loaded state containing grouped items.
///
/// Items are organized into groups based on the key generator function.
/// Each group contains a key and a list of items belonging to that group.
///
/// Example:
/// ```dart
/// // Messages grouped by date
/// final state = DualPaginationLoaded<Message>(
///   groups: [
///     MapEntry('2024-01-01', [message1, message2]),
///     MapEntry('2024-01-02', [message3, message4]),
///   ],
///   allItems: [message1, message2, message3, message4],
///   meta: meta,
///   hasReachedEnd: false,
/// );
/// ```
class DualPaginationLoaded<Key, T> extends DualPaginationState<T>
    implements IPaginationLoadedState<T> {
  DualPaginationLoaded({
    required this.groups,
    required this.allItems,
    required this.meta,
    required this.hasReachedEnd,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  /// The grouped items as key-value pairs.
  /// Each entry contains a group key and the list of items in that group.
  final List<MapEntry<Key, List<T>>> groups;

  /// All items in a flat list (ungrouped).
  @override
  final List<T> allItems;

  /// Metadata about the pagination state.
  @override
  final PaginationMeta meta;

  /// Whether all available data has been fetched.
  @override
  final bool hasReachedEnd;

  /// Timestamp of the last update to this state.
  @override
  final DateTime lastUpdate;

  /// Creates a copy of this state with updated values.
  DualPaginationLoaded<Key, T> copyWith({
    List<MapEntry<Key, List<T>>>? groups,
    List<T>? allItems,
    bool? hasReachedEnd,
    PaginationMeta? meta,
    DateTime? lastUpdate,
  }) {
    return DualPaginationLoaded<Key, T>(
      groups: groups ?? this.groups,
      allItems: allItems ?? this.allItems,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      meta: meta ?? this.meta,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DualPaginationLoaded<Key, T> &&
        other.hasReachedEnd == hasReachedEnd &&
        listEquals(other.groups, groups) &&
        listEquals(other.allItems, allItems) &&
        other.meta == meta;
  }

  @override
  int get hashCode => Object.hash(
        hasReachedEnd,
        Object.hashAll(groups),
        Object.hashAll(allItems),
        meta,
      );
}
