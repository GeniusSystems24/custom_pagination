import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../data/data.dart';

// Export error handling utilities
export 'error_handling.dart';

// Core interfaces for pagination system
part 'bloc/pagination_cubit.dart';
part 'bloc/pagination_listeners.dart';
part 'bloc/pagination_state.dart';
part 'controller/controller.dart';

typedef WhereChecker<T> = bool Function(T item);
typedef CompareBy<T> = int Function(T a, T b);
typedef OnInsertionCallback<T> = void Function(List<T> items);

/// Unified pagination data provider that can be either Future-based or Stream-based.
///
/// Use [PaginationProvider.future] for standard REST API pagination.
/// Use [PaginationProvider.stream] for real-time updates.
///
/// Example with Future:
/// ```dart
/// final provider = PaginationProvider<Product>.future(
///   (request) => apiService.fetchProducts(request),
/// );
/// ```
///
/// Example with Stream:
/// ```dart
/// final provider = PaginationProvider<Product>.stream(
///   (request) => apiService.productsStream(request),
/// );
/// ```
sealed class PaginationProvider<T> {
  const PaginationProvider();

  /// Creates a Future-based pagination provider for standard REST APIs.
  const factory PaginationProvider.future(
    Future<List<T>> Function(PaginationRequest request) dataProvider,
  ) = FuturePaginationProvider<T>;

  /// Creates a Stream-based pagination provider for real-time updates.
  const factory PaginationProvider.stream(
    Stream<List<T>> Function(PaginationRequest request) streamProvider,
  ) = StreamPaginationProvider<T>;
}

/// Future-based pagination provider for standard REST APIs.
final class FuturePaginationProvider<T> extends PaginationProvider<T> {
  const FuturePaginationProvider(this.dataProvider);

  /// Function that fetches a page of data from your API.
  final Future<List<T>> Function(PaginationRequest request) dataProvider;
}

/// Stream-based pagination provider for real-time updates.
final class StreamPaginationProvider<T> extends PaginationProvider<T> {
  const StreamPaginationProvider(this.streamProvider);

  /// Function that provides a stream of data updates.
  final Stream<List<T>> Function(PaginationRequest request) streamProvider;
}

/// Legacy typedef for backward compatibility (will be deprecated).
typedef PaginationDataProvider<T> = Future<List<T>> Function(PaginationRequest request);

/// Legacy typedef for backward compatibility (will be deprecated).
typedef PaginationStreamProvider<T> = Stream<List<T>> Function(PaginationRequest request);

/// Signature for a function that scrolls the pagination list to a specific item ID.
typedef PaginationScrollToItem =
    Future<bool> Function(
      String itemId, {
      Duration duration,
      Curve curve,
      double alignment,
      double offset,
    });

/// Signature for a function that scrolls the pagination list to a specific index.
typedef PaginationScrollToIndex =
    Future<bool> Function(
      int index, {
      Duration duration,
      Curve curve,
      double alignment,
      double offset,
    });

/// Signature for a function that builds a list from fetched items.
typedef ListBuilder<T> = List<T> Function(List<T> list);

/// Signature for a callback function that is called when items are inserted.
typedef InsertAllCallback<T> =
    void Function(List<T> currentItems, Iterable<T> newItems);

/// Base mixin for pagination controllers with scroll capabilities.
mixin PaginationScrollToItemMixin {
  PaginationScrollToItem? _scrollToItem;
  PaginationScrollToIndex? _scrollToIndex;

  /// Attaches the scroll methods that will be used for scrolling operations.
  void attachScrollMethods({
    required PaginationScrollToItem scrollToItem,
    required PaginationScrollToIndex scrollToIndex,
  }) {
    _scrollToItem = scrollToItem;
    _scrollToIndex = scrollToIndex;
  }

  /// Detaches the scroll methods when the widget is disposed.
  void detachScrollMethods() {
    _scrollToItem = null;
    _scrollToIndex = null;
  }

  /// Scrolls to a specific item by Path.
  Future<bool> scrollToItem(
    String itemPath, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linearToEaseOut,
    double alignment = 0,
    double offset = 0,
  }) {
    if (_scrollToItem == null) {
      return Future.value(false);
    }

    return (_scrollToItem as PaginationScrollToItem)(
      itemPath,
      duration: duration,
      curve: curve,
      alignment: alignment,
      offset: offset,
    );
  }

  /// Scrolls to a specific index in the item list.
  Future<bool> scrollToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linearToEaseOut,
    double alignment = 0,
    double offset = 0,
  }) {
    if (_scrollToIndex == null) {
      return Future.value(false);
    }

    return (_scrollToIndex as PaginationScrollToIndex)(
      index,
      duration: duration,
      curve: curve,
      alignment: alignment,
      offset: offset,
    );
  }

  /// Disposes scroll resources.
  void disposeScrollMethods() {
    detachScrollMethods();
  }
}
