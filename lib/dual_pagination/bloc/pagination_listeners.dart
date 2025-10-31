part of '../pagination.dart';

/// Base class for DualPagination change listeners.
class DualPaginationChangeListener extends ChangeNotifier
    implements IPaginationChangeListener {}

/// Listener for triggering refresh operations.
///
/// Set [refreshed] to true to trigger a refresh of the pagination.
///
/// Example:
/// ```dart
/// final refreshListener = DualPaginationRefreshedChangeListener();
///
/// // Trigger refresh
/// refreshListener.refreshed = true;
///
/// // Listen to changes
/// refreshListener.addListener(() {
///   if (refreshListener.refreshed) {
///     print('Refresh triggered');
///   }
/// });
/// ```
class DualPaginationRefreshedChangeListener
    extends DualPaginationChangeListener
    implements IPaginationRefreshedChangeListener {
  DualPaginationRefreshedChangeListener();

  bool _refreshed = false;

  @override
  set refreshed(bool value) {
    _refreshed = value;
    if (value) {
      notifyListeners();
    }
  }

  @override
  bool get refreshed => _refreshed;
}

/// Listener for filtering items in the pagination.
///
/// Provide a [WhereChecker] function to filter items based on criteria.
///
/// Example:
/// ```dart
/// final filterListener = DualPaginationFilterChangeListener<Message>();
///
/// // Set filter
/// filterListener.searchTerm = (message) =>
///   message.content.toLowerCase().contains('hello');
///
/// // Clear filter
/// filterListener.searchTerm = null;
/// ```
class DualPaginationFilterChangeListener<T>
    extends DualPaginationChangeListener
    implements IPaginationFilterChangeListener<T> {
  DualPaginationFilterChangeListener();

  WhereChecker<T>? _filterChecker;

  @override
  set searchTerm(WhereChecker<T>? value) {
    if (value == _filterChecker) return;
    _filterChecker = value;
    notifyListeners();
  }

  @override
  WhereChecker<T>? get searchTerm => _filterChecker;
}

/// Listener for sorting items within groups.
///
/// Provide a [CompareBy] function to sort items.
///
/// Example:
/// ```dart
/// final orderListener = DualPaginationOrderChangeListener<Message>();
///
/// // Sort by timestamp descending
/// orderListener.orderCompare = (a, b) =>
///   b.timestamp.compareTo(a.timestamp);
///
/// // Sort by content alphabetically
/// orderListener.orderCompare = (a, b) =>
///   a.content.compareTo(b.content);
/// ```
class DualPaginationOrderChangeListener<T>
    extends DualPaginationChangeListener
    implements IPaginationOrderChangeListener<T> {
  DualPaginationOrderChangeListener();

  CompareBy<T>? _orderBy;

  @override
  set orderCompare(CompareBy<T>? value) {
    if (value == _orderBy) return;
    _orderBy = value;
    notifyListeners();
  }

  @override
  CompareBy<T>? get orderCompare => _orderBy;
}
