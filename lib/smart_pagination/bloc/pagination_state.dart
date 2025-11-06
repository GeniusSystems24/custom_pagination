part of '../../pagination.dart';

@immutable
abstract class SmartPaginationState<T> implements IPaginationInitialState<T> {
  @override
  bool get hasReachedEnd => false;

  @override
  DateTime get lastUpdate => DateTime.now();

  @override
  PaginationMeta? get meta => null;
}

class SmartPaginationInitial<T> extends SmartPaginationState<T> {}

class SmartPaginationError<T> extends SmartPaginationState<T>
    implements IPaginationErrorState<T> {
  final Exception _error;
  SmartPaginationError({required Exception error}) : _error = error;

  @override
  Exception get error => _error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SmartPaginationError<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

class SmartPaginationLoaded<T> extends SmartPaginationState<T>
    implements IPaginationLoadedState<T> {
  SmartPaginationLoaded({
    required this.items,
    required this.allItems,
    required this.meta,
    required this.hasReachedEnd,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  final List<T> items;
  @override
  final List<T> allItems;
  @override
  final PaginationMeta meta;
  @override
  final bool hasReachedEnd;
  @override
  final DateTime lastUpdate;

  SmartPaginationLoaded<T> copyWith({
    List<T>? items,
    List<T>? allItems,
    bool? hasReachedEnd,
    PaginationMeta? meta,
    DateTime? lastUpdate,
  }) {
    final updatedAllItems = allItems ?? this.allItems;
    final updatedItems = items ?? this.items;

    return SmartPaginationLoaded<T>(
      items: updatedItems,
      allItems: updatedAllItems,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      meta: meta ?? this.meta,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SmartPaginationLoaded<T> &&
        other.hasReachedEnd == hasReachedEnd &&
        listEquals(other.items, items) &&
        listEquals(other.allItems, allItems) &&
        other.meta == meta;
  }

  @override
  int get hashCode => Object.hash(
    hasReachedEnd,
    Object.hashAll(items),
    Object.hashAll(allItems),
    meta,
  );
}
