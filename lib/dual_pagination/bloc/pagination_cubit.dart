part of '../pagination.dart';

/// Type definition for data provider function.
typedef DualPaginationDataProvider<T> =
    Future<List<T>> Function(PaginationRequest request);

/// Type definition for stream provider function.
typedef DualPaginationStreamProvider<T> =
    Stream<List<T>> Function(PaginationRequest request);

/// Cubit for managing grouped pagination state.
///
/// [DualPaginationCubit] handles fetching, grouping, filtering, and managing
/// paginated data that needs to be organized into groups.
///
/// The Key type parameter represents the type of the grouping key.
/// The T type parameter represents the item type.
///
/// Example:
/// ```dart
/// // Messages grouped by date
/// final cubit = DualPaginationCubit<String, Message>(
///   request: PaginationRequest(page: 1, pageSize: 50),
///   dataProvider: fetchMessages,
///   groupKeyGenerator: (messages) {
///     final grouped = <String, List<Message>>{};
///     for (var message in messages) {
///       final date = DateFormat('yyyy-MM-dd').format(message.timestamp);
///       grouped.putIfAbsent(date, () => []).add(message);
///     }
///     return grouped.entries.toList();
///   },
/// );
/// ```
class DualPaginationCubit<Key, T>
    extends IDualPaginationCubit<T, Key, DualPaginationState<T>> {
  DualPaginationCubit({
    required PaginationRequest request,
    required DualPaginationDataProvider<T> dataProvider,
    DualPaginationStreamProvider<T>? streamProvider,
    required KeyGenerator<Key, T> groupKeyGenerator,
    List<T> Function(List<T> list)? sort,
    Stream<List<T>> Function()? localStreamBuilder,
    InsertAllCallback<T>? insertionCallback,
    VoidCallback? onClear,
    int maxPagesInMemory = 5,
    Logger? logger,
    RetryConfig? retryConfig,
  })  : _dataProvider = dataProvider,
        _streamProvider = streamProvider,
        _groupKeyGenerator = groupKeyGenerator,
        _sort = sort,
        _localStreamBuilder = localStreamBuilder,
        _insertionCallback = insertionCallback,
        _onClear = onClear,
        _maxPagesInMemory = maxPagesInMemory,
        _logger = logger ?? Logger(),
        _retryHandler = retryConfig != null ? RetryHandler(retryConfig) : null,
        initialRequest = request,
        _currentRequest = request,
        super(DualPaginationInitial<T>());

  final DualPaginationDataProvider<T> _dataProvider;
  final DualPaginationStreamProvider<T>? _streamProvider;
  final KeyGenerator<Key, T> _groupKeyGenerator;
  final List<T> Function(List<T> list)? _sort;
  final Stream<List<T>> Function()? _localStreamBuilder;
  final InsertAllCallback<T>? _insertionCallback;
  final VoidCallback? _onClear;
  final int _maxPagesInMemory;
  final Logger _logger;
  final RetryHandler? _retryHandler;

  @override
  final PaginationRequest initialRequest;

  PaginationRequest _currentRequest;
  PaginationMeta? _currentMeta;
  final List<List<T>> _pages = <List<T>>[];
  StreamSubscription<List<T>>? _streamSubscription;
  StreamSubscription<List<T>>? _localStreamSubscription;
  int _fetchToken = 0;

  bool _didFetch = false;
  bool get didFetch => _didFetch;

  bool get _hasReachedEnd => _currentMeta != null && !_currentMeta!.hasNext;

  @override
  KeyGenerator<Key, T>? get groupKeyGenerator => _groupKeyGenerator;

  @override
  List<T> Function(List<T> list)? get sort => _sort;

  @override
  Stream<List<T>> Function()? get localStreamBuilder => _localStreamBuilder;

  @override
  InsertAllCallback<T>? get insertionCallback => _insertionCallback;

  @override
  void filterPaginatedList(WhereChecker<T>? searchTerm) {
    final currentState = state;
    if (currentState is! DualPaginationLoaded<Key, T>) return;

    if (searchTerm == null) {
      // Reset to all items
      final groups = _groupItems(currentState.allItems);
      emit(
        currentState.copyWith(
          groups: groups,
          lastUpdate: DateTime.now(),
        ),
      );
      return;
    }

    // Filter items
    final filtered = currentState.allItems.where(searchTerm).toList();
    final groups = _groupItems(filtered);

    _logger.d(
      'Applied pagination filter ${currentState.allItems.length} -> ${filtered.length}',
    );

    emit(
      currentState.copyWith(
        groups: groups,
        lastUpdate: DateTime.now(),
      ),
    );
  }

  @override
  void refreshPaginatedList({PaginationRequest? requestOverride, int? limit}) {
    cancelOngoingRequest();
    _streamSubscription?.cancel();
    _localStreamSubscription?.cancel();
    _onClear?.call();
    _didFetch = false;
    _pages.clear();
    _currentMeta = null;

    final request = _buildRequest(
      reset: true,
      override: requestOverride,
      limit: limit,
    );
    _fetch(request: request, reset: true);
  }

  @override
  void fetchPaginatedList({PaginationRequest? requestOverride, int? limit}) {
    if (state is DualPaginationInitial<T>) {
      refreshPaginatedList(requestOverride: requestOverride, limit: limit);
      return;
    }

    if (_hasReachedEnd) return;

    final request = _buildRequest(
      reset: false,
      override: requestOverride,
      limit: limit,
    );
    _fetch(request: request, reset: false);
  }

  Future<void> _fetch({
    required PaginationRequest request,
    required bool reset,
  }) async {
    final token = ++_fetchToken;

    try {
      // Use retry handler if available
      final pageItems = _retryHandler != null
          ? await _retryHandler!.execute(
              () => _dataProvider(request),
              onRetry: (attempt, error) {
                _logger.w('Retry attempt $attempt after error: $error');
              },
            )
          : await _dataProvider(request);

      if (token != _fetchToken) return;

      _didFetch = true;
      _currentRequest = request;

      if (reset) {
        _pages
          ..clear()
          ..add(pageItems);
      } else {
        _pages.add(pageItems);
      }

      _trimCachedPages();

      var aggregated = _pages.expand((page) => page).toList();

      // Apply sorting if provided
      if (_sort != null) {
        aggregated = _sort!(aggregated);
      }

      // Group items
      final groups = _groupItems(aggregated);

      final hasNext = _computeHasNext(pageItems, request.pageSize);
      final meta = PaginationMeta(
        page: request.page,
        pageSize: request.pageSize,
        hasNext: hasNext,
        hasPrevious: request.page > 1,
      );
      _currentMeta = meta;

      _insertionCallback?.call(aggregated, pageItems);

      emit(
        DualPaginationLoaded<Key, T>(
          groups: groups,
          allItems: aggregated,
          meta: meta,
          hasReachedEnd: !hasNext,
        ),
      );

      // Attach streams
      if (reset) {
        final streamProvider = _streamProvider;
        if (streamProvider != null) {
          _attachStream(streamProvider(request), request);
        }

        final localBuilder = _localStreamBuilder;
        if (localBuilder != null) {
          _attachLocalStream(localBuilder());
        }
      }
    } on Exception catch (error, stackTrace) {
      _logger.e(
        'Pagination request failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(DualPaginationError<T>(error: error));
    } catch (error, stackTrace) {
      final exception = Exception(error.toString());
      _logger.e(
        'Pagination request failed',
        error: exception,
        stackTrace: stackTrace,
      );
      emit(DualPaginationError<T>(error: exception));
    }
  }

  List<MapEntry<Key, List<T>>> _groupItems(List<T> items) {
    return _groupKeyGenerator(items);
  }

  PaginationRequest _buildRequest({
    required bool reset,
    PaginationRequest? override,
    int? limit,
  }) {
    final base = override ?? (reset ? initialRequest : _currentRequest);
    final pageSize = limit ?? base.pageSize ?? initialRequest.pageSize;
    final nextPage = reset ? 1 : base.page + 1;

    return base.copyWith(page: nextPage, pageSize: pageSize);
  }

  bool _computeHasNext(List<T> items, int? pageSize) {
    if (pageSize == null) {
      return items.isNotEmpty;
    }
    return items.length >= pageSize;
  }

  void _attachStream(Stream<List<T>> stream, PaginationRequest request) {
    _streamSubscription?.cancel();
    _streamSubscription = stream.listen(
      (items) {
        var aggregated = items;

        if (_sort != null) {
          aggregated = _sort!(aggregated);
        }

        final groups = _groupItems(aggregated);
        _insertionCallback?.call(aggregated, items);

        final meta = PaginationMeta(
          page: request.page,
          pageSize: request.pageSize,
          hasNext: _computeHasNext(items, request.pageSize),
          hasPrevious: request.page > 1,
        );
        _currentMeta = meta;

        emit(
          DualPaginationLoaded<Key, T>(
            groups: groups,
            allItems: aggregated,
            meta: meta,
            hasReachedEnd: !meta.hasNext,
          ),
        );
      },
      onError: (error, stack) {
        final exception =
            error is Exception ? error : Exception(error.toString());
        _logger.e(
          'Pagination stream failed',
          error: exception,
          stackTrace: stack,
        );
        emit(DualPaginationError<T>(error: exception));
      },
    );
  }

  void _attachLocalStream(Stream<List<T>> stream) {
    _localStreamSubscription?.cancel();
    _localStreamSubscription = stream.listen(
      (items) {
        final currentState = state;
        if (currentState is! DualPaginationLoaded<Key, T>) return;

        var aggregated = items;

        if (_sort != null) {
          aggregated = _sort!(aggregated);
        }

        final groups = _groupItems(aggregated);
        _insertionCallback?.call(aggregated, items);

        emit(
          currentState.copyWith(
            groups: groups,
            allItems: aggregated,
            lastUpdate: DateTime.now(),
          ),
        );
      },
      onError: (error, stack) {
        _logger.e(
          'Local stream failed',
          error: error,
          stackTrace: stack,
        );
      },
    );
  }

  void _trimCachedPages() {
    if (_maxPagesInMemory <= 0) return;
    while (_pages.length > _maxPagesInMemory) {
      _pages.removeAt(0);
    }
  }

  @override
  void insertEmitState({required List<T> newItems}) {
    final currentState = state;
    if (currentState is! DualPaginationLoaded<Key, T>) return;

    final updated = List<T>.from(currentState.allItems)..addAll(newItems);

    var aggregated = updated;
    if (_sort != null) {
      aggregated = _sort!(aggregated);
    }

    final groups = _groupItems(aggregated);
    _insertionCallback?.call(aggregated, newItems);

    emit(
      currentState.copyWith(
        groups: groups,
        allItems: aggregated,
        lastUpdate: DateTime.now(),
      ),
    );
  }

  @override
  void cancelOngoingRequest() {
    _fetchToken++;
  }

  @override
  void dispose() {
    cancelOngoingRequest();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _localStreamSubscription?.cancel();
    _localStreamSubscription = null;
  }
}
