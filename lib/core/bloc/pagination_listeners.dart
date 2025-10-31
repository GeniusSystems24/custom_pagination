part of '../core.dart';

/// Base interface for pagination change listeners that provides common functionality
/// for both SinglePagination and DualPagination listeners.
abstract class IPaginationChangeListener {
  /// Notifies listeners that a change has occurred.
  void notifyListeners();

  /// Adds a listener to be called when the notifier changes.
  void addListener(VoidCallback listener);

  /// Removes a previously registered listener.
  void removeListener(VoidCallback listener);

  /// Removes all listeners.
  void dispose();
}

/// Base interface for pagination refresh listeners.
abstract class IPaginationRefreshedChangeListener
    extends IPaginationChangeListener {
  /// Whether the pagination has been refreshed.
  bool get refreshed;

  /// Sets the refreshed state and notifies listeners if true.
  set refreshed(bool value);
}

/// Base interface for pagination filter listeners.
abstract class IPaginationFilterChangeListener<T>
    extends IPaginationChangeListener {
  /// The current search term for filtering.
  WhereChecker<T>? get searchTerm;

  /// Sets the search term and notifies listeners if changed.
  set searchTerm(WhereChecker<T>? value);
}

/// Base interface for pagination order listeners.
abstract class IPaginationOrderChangeListener<T>
    extends IPaginationChangeListener {
  /// The current order comparison function.
  CompareBy<T>? get orderCompare;

  /// Sets the order comparison function and notifies listeners if changed.
  set orderCompare(CompareBy<T>? value);
}
