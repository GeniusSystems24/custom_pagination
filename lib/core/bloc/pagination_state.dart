part of '../../pagination.dart';

/// Base interface for pagination states that provides common functionality
/// for both SmartPagination and DualPagination states.
abstract class IPaginationState<T> {
  PaginationMeta? get meta;
}

/// Base interface for pagination states that provides common functionality
/// for both SmartPagination and DualPagination states.
abstract class IPaginationInitialState<T> extends IPaginationState<T> {
  /// Whether the pagination has reached the end of available data.
  bool get hasReachedEnd;

  /// The timestamp of the last update to the pagination state.
  DateTime get lastUpdate;

  @override
  PaginationMeta? get meta => null;
}

/// Base interface for loaded pagination states.
abstract class IPaginationLoadedState<T> extends IPaginationState<T> {
  /// The list of items in the current pagination state.
  List<T> get allItems;

  /// Whether the pagination has reached the end of available data.
  bool get hasReachedEnd;

  /// The timestamp of the last update to the pagination state.
  DateTime get lastUpdate;

  @override
  PaginationMeta get meta;
}

/// Base interface for error pagination states.
abstract class IPaginationErrorState<T> extends IPaginationState<T> {
  /// The error that occurred during pagination.
  Exception get error;

  @override
  PaginationMeta? get meta => null;
}
