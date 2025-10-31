part of '../pagination.dart';

/// Controller for managing DualPagination state and operations.
///
/// [DualPaginationController] provides a convenient way to manage a
/// [DualPaginationCubit] along with listeners and configuration.
///
/// Example:
/// ```dart
/// final controller = DualPaginationController<String, Message>.of(
///   request: PaginationRequest(page: 1, pageSize: 50),
///   dataProvider: fetchMessages,
///   groupKeyGenerator: (messages) {
///     // Group by date
///     final grouped = <String, List<Message>>{};
///     for (var message in messages) {
///       final date = DateFormat('yyyy-MM-dd').format(message.timestamp);
///       grouped.putIfAbsent(date, () => []).add(message);
///     }
///     return grouped.entries.toList();
///   },
/// );
///
/// // Use in widget
/// DualPagination<String, Message>.cubit(
///   cubit: controller.cubit,
///   // ... other parameters
/// );
///
/// // Dispose when done
/// controller.dispose();
/// ```
class DualPaginationController<Key, T> implements IPaginationController<T> {
  DualPaginationController({
    required DualPaginationCubit<Key, T> cubit,
    this.isPublic = false,
    this.estimatedItemHeight = 60.0,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
    this.maxRetries = 10,
    this.refreshListeners,
    this.filterListeners,
    this.orderListeners,
  }) : _cubit = cubit;

  /// Factory constructor to create a controller with a new cubit.
  ///
  /// This is a convenience method that creates both the cubit and controller
  /// in one step.
  factory DualPaginationController.of({
    required PaginationRequest request,
    required DualPaginationDataProvider<T> dataProvider,
    DualPaginationStreamProvider<T>? streamProvider,
    required KeyGenerator<Key, T> groupKeyGenerator,
    List<T> Function(List<T> list)? sort,
    Stream<List<T>> Function()? localStreamBuilder,
    InsertAllCallback<T>? insertionCallback,
    VoidCallback? onClear,
    bool isPublic = false,
    double estimatedItemHeight = 60,
    Duration animationDuration = const Duration(milliseconds: 500),
    Curve animationCurve = Curves.easeInOut,
    int maxRetries = 10,
    int maxPagesInMemory = 5,
    Logger? logger,
    List<IPaginationRefreshedChangeListener>? refreshListeners,
    List<IPaginationFilterChangeListener<T>>? filterListeners,
    List<IPaginationOrderChangeListener<T>>? orderListeners,
  }) {
    final cubit = DualPaginationCubit<Key, T>(
      request: request,
      dataProvider: dataProvider,
      streamProvider: streamProvider,
      groupKeyGenerator: groupKeyGenerator,
      sort: sort,
      localStreamBuilder: localStreamBuilder,
      insertionCallback: insertionCallback,
      onClear: onClear,
      maxPagesInMemory: maxPagesInMemory,
      logger: logger,
    );

    return DualPaginationController<Key, T>(
      cubit: cubit,
      isPublic: isPublic,
      estimatedItemHeight: estimatedItemHeight,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      maxRetries: maxRetries,
      refreshListeners: refreshListeners,
      filterListeners: filterListeners,
      orderListeners: orderListeners,
    );
  }

  final DualPaginationCubit<Key, T> _cubit;

  /// The cubit managing the pagination state.
  @override
  DualPaginationCubit<Key, T> get cubit => _cubit;

  /// Observer controller for scroll observation (optional).
  @override
  SliverObserverController? observerController;

  /// Estimated height of each item for scroll calculations.
  @override
  final double estimatedItemHeight;

  /// Animation duration for scroll operations.
  @override
  final Duration animationDuration;

  /// Animation curve for scroll operations.
  @override
  final Curve animationCurve;

  /// Maximum number of retries for failed operations.
  @override
  final int maxRetries;

  /// Listeners for filter changes.
  @override
  final List<IPaginationFilterChangeListener<T>>? filterListeners;

  /// Listeners for order/sort changes.
  @override
  final List<IPaginationOrderChangeListener<T>>? orderListeners;

  /// Listeners for refresh triggers.
  @override
  final List<IPaginationRefreshedChangeListener>? refreshListeners;

  /// Whether this controller should persist when widgets dispose.
  ///
  /// If true, the controller will not dispose the cubit automatically.
  @override
  final bool isPublic;

  /// Disposes the controller and its resources.
  ///
  /// If [isPublic] is false, this will also dispose the cubit.
  @override
  void dispose() {
    if (!isPublic) {
      _cubit.dispose();
    }
  }
}
