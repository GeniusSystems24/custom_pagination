part of '../../pagination.dart';

/// Base interface for pagination controllers that provides common functionality
/// for both SmartPagination and DualPagination controllers.
abstract class IPaginationController<T> {
  /// The cubit exposing the REST-backed pagination state.
  IPaginationCubit<T, IPaginationState<T>> get cubit;

  /// The refresh listeners to the cubit.
  List<IPaginationRefreshedChangeListener>? get refreshListeners;

  /// The filter listeners to the cubit.
  List<IPaginationFilterChangeListener<T>>? get filterListeners;

  /// The order listeners to the cubit.
  List<IPaginationOrderChangeListener<T>>? get orderListeners;

  /// SliverObserverController for scroll observation and management.
  SliverObserverController? get observerController;

  /// The estimated item height to animate to the specific item.
  double get estimatedItemHeight;

  /// The duration of the animation.
  Duration get animationDuration;

  /// The curve of the animation.
  Curve get animationCurve;

  /// The maximum number of retries to animate to the specific item.
  int get maxRetries;

  /// If `isPublic = true`, the controller will be live until the app is closed.
  bool get isPublic;

  /// Disposes the controller and its resources.
  void dispose();
}

/// Base interface for pagination controllers with scroll capabilities.
abstract class IPaginationScrollController<T> extends IPaginationController<T> {
  /// Attaches the scroll methods that will be used for scrolling operations.
  void attachScrollMethods({
    required PaginationScrollToItem scrollToItem,
    required PaginationScrollToIndex scrollToIndex,
  });

  /// Detaches the scroll methods when the widget is disposed.
  void detachScrollMethods();

  /// Scrolls to a specific item by Path.
  Future<bool> scrollToItem(
    String itemPath, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linearToEaseOut,
    double alignment = 0,
    double offset = 0,
  });

  /// Scrolls to a specific index in the item list.
  Future<bool> scrollToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linearToEaseOut,
    double alignment = 0,
    double offset = 0,
  });

  /// Disposes scroll resources.
  void disposeScrollMethods();
}
