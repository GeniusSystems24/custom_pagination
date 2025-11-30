part of '../pagination.dart';

class SmartPaginationChangeListener extends ChangeNotifier
    implements IPaginationChangeListener {}

class SmartPaginationRefreshedChangeListener
    extends SmartPaginationChangeListener
    implements IPaginationRefreshedChangeListener {
  SmartPaginationRefreshedChangeListener();

  bool _refreshed = false;

  @override
  set refreshed(bool value) {
    _refreshed = value;
    if (value) {
      notifyListeners();
    }
  }

  @override
  bool get refreshed {
    return _refreshed;
  }
}

class SmartPaginationFilterChangeListener<T>
    extends SmartPaginationChangeListener
    implements IPaginationFilterChangeListener<T> {
  SmartPaginationFilterChangeListener();

  WhereChecker<T>? _filterChecker;

  @override
  set searchTerm(WhereChecker<T>? value) {
    if (value == _filterChecker) return;
    _filterChecker = value;
    notifyListeners();
  }

  @override
  WhereChecker<T>? get searchTerm {
    return _filterChecker;
  }
}

class SmartPaginationOrderChangeListener<T>
    extends SmartPaginationChangeListener
    implements IPaginationOrderChangeListener<T> {
  SmartPaginationOrderChangeListener();

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
