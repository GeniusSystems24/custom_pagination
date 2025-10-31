part of '../core.dart';

/// Base interface for pagination cubits that provides common functionality
/// for both SinglePagination and DualPagination cubits.
abstract class IPaginationCubit<T, StateType extends IPaginationState<T>>
    extends Cubit<StateType> {
  IPaginationCubit(super.initialState);

  /// Initial request configuration used when the pagination starts.
  PaginationRequest get initialRequest;

  /// Filters the paginated list based on the provided search term.
  void filterPaginatedList(WhereChecker<T>? searchTerm);

  /// Refreshes the paginated list, starting from the beginning.
  void refreshPaginatedList({PaginationRequest? requestOverride, int? limit});

  /// Fetches the next page of the paginated list.
  void fetchPaginatedList({PaginationRequest? requestOverride, int? limit});

  /// Cancels any inflight work.
  void cancelOngoingRequest();

  /// Disposes the cubit and its resources.
  void dispose() {
    cancelOngoingRequest();
  }
}

/// Base interface for pagination cubits with list building capabilities.
abstract class IPaginationListCubit<T, StateType extends IPaginationState<T>>
    extends IPaginationCubit<T, StateType> {
  IPaginationListCubit(super.initialState);

  /// Whether the cubit has fetched data at least once.
  bool get didFetch;

  /// Optional hook to transform or sort items before emitting.
  ListBuilder<T>? get listBuilder;

  /// Inserts an item at the specified index.
  void insertEmit(T item, {int index = 0});

  /// Adds or updates an item in the list.
  void addOrUpdateEmit(T item, {int index = 0});
}

/// Base interface for dual pagination cubits with grouping capabilities.
abstract class IDualPaginationCubit<
  T,
  Key,
  StateType extends IPaginationState<T>
>
    extends IPaginationCubit<T, StateType> {
  IDualPaginationCubit(super.initialState);

  /// The function to generate keys for grouping items.
  KeyGenerator<Key, T>? get groupKeyGenerator;

  /// The function to sort items.
  List<T> Function(List<T> list)? get sort;

  /// The function to build local streams.
  Stream<List<T>> Function()? get localStreamBuilder;

  /// The callback to be called when items are inserted.
  InsertAllCallback<T>? get insertionCallback;

  /// Inserts multiple items and emits the updated state.
  void insertEmitState({required List<T> newItems});
}
