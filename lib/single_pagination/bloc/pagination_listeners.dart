part of '../pagination.dart';

class SinglePaginationChangeListener extends ChangeNotifier
    implements IPaginationChangeListener {}

class SinglePaginationRefreshedChangeListener
    extends SinglePaginationChangeListener
    implements IPaginationRefreshedChangeListener {
  SinglePaginationRefreshedChangeListener();

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

class SinglePaginationFilterChangeListener<T>
    extends SinglePaginationChangeListener
    implements IPaginationFilterChangeListener<T> {
  SinglePaginationFilterChangeListener();

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

class SinglePaginationOrderChangeListener<T>
    extends SinglePaginationChangeListener
    implements IPaginationOrderChangeListener<T> {
  SinglePaginationOrderChangeListener();

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
