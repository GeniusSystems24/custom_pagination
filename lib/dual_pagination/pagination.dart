import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../core/core.dart';
import '../data/data.dart';

part 'bloc/pagination_cubit.dart';
part 'bloc/pagination_listeners.dart';
part 'bloc/pagination_state.dart';
part 'controller/controller.dart';
part '../core/widget/bottom_loader.dart';
part '../core/widget/empty_display.dart';
part '../core/widget/error_display.dart';
part '../core/widget/initial_loader.dart';
part 'widgets/paginate_grouped_view.dart';

/// Widget for displaying paginated data organized into groups.
///
/// [DualPagination] is ideal for scenarios where items need to be grouped:
/// - Chat messages grouped by date
/// - Products grouped by category
/// - Posts grouped by author
/// - Events grouped by month
///
/// ## Basic Example
///
/// ```dart
/// DualPagination<String, Message>(
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
///   groupHeaderBuilder: (context, dateKey, messages) {
///     return Container(
///       padding: EdgeInsets.all(16),
///       color: Colors.grey[200],
///       child: Text(dateKey, style: TextStyle(fontWeight: FontWeight.bold)),
///     );
///   },
///   itemBuilder: (context, message, index) {
///     return ListTile(
///       title: Text(message.content),
///       subtitle: Text(message.author),
///     );
///   },
/// )
/// ```
///
/// ## With Cubit
///
/// ```dart
/// final cubit = DualPaginationCubit<String, Message>(
///   request: PaginationRequest(page: 1, pageSize: 50),
///   dataProvider: fetchMessages,
///   groupKeyGenerator: groupByDate,
/// );
///
/// DualPagination<String, Message>.cubit(
///   cubit: cubit,
///   groupHeaderBuilder: buildDateHeader,
///   itemBuilder: buildMessageTile,
/// )
/// ```
class DualPagination<Key, T> extends StatefulWidget {
  /// Creates a DualPagination widget with automatic cubit creation.
  DualPagination({
    super.key,
    required PaginationRequest request,
    required DualPaginationDataProvider<T> dataProvider,
    DualPaginationStreamProvider<T>? streamProvider,
    required KeyGenerator<Key, T> groupKeyGenerator,
    List<T> Function(List<T> list)? sort,
    Stream<List<T>> Function()? localStreamBuilder,
    required this.groupHeaderBuilder,
    required this.itemBuilder,
    this.heightOfInitialLoadingAndEmptyWidget,
    this.onError,
    this.onReachedEnd,
    this.onLoaded,
    this.emptyWidget = const EmptyDisplay(),
    this.loadingWidget = const InitialLoader(),
    this.bottomLoader = const BottomLoader(),
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(0),
    this.physics,
    this.scrollController,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.header,
    this.footer,
    this.cacheExtent,
    this.separator,
    InsertAllCallback<T>? insertionCallback,
    VoidCallback? onClear,
    Logger? logger,
    int maxPagesInMemory = 5,
    DualPaginationRefreshedChangeListener? refreshListener,
    List<DualPaginationFilterChangeListener<T>>? filterListeners,
  })  : internalCubit = true,
        cubit = DualPaginationCubit<Key, T>(
          request: request,
          dataProvider: dataProvider,
          streamProvider: streamProvider,
          groupKeyGenerator: groupKeyGenerator,
          sort: sort,
          localStreamBuilder: localStreamBuilder,
          insertionCallback: insertionCallback,
          onClear: onClear,
          logger: logger,
          maxPagesInMemory: maxPagesInMemory,
        ),
        listeners = refreshListener != null || filterListeners?.isNotEmpty == true
            ? [if (refreshListener != null) refreshListener, ...?filterListeners]
            : null;

  /// Creates a DualPagination widget with an existing cubit.
  DualPagination.cubit({
    super.key,
    required this.cubit,
    required this.groupHeaderBuilder,
    required this.itemBuilder,
    this.heightOfInitialLoadingAndEmptyWidget,
    this.onError,
    this.onReachedEnd,
    this.onLoaded,
    this.emptyWidget = const EmptyDisplay(),
    this.loadingWidget = const InitialLoader(),
    this.bottomLoader = const BottomLoader(),
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(0),
    this.physics,
    this.scrollController,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.header,
    this.footer,
    this.cacheExtent,
    this.separator,
    DualPaginationRefreshedChangeListener? refreshListener,
    List<DualPaginationFilterChangeListener<T>>? filterListeners,
  })  : internalCubit = false,
        listeners = refreshListener != null || filterListeners?.isNotEmpty == true
            ? [if (refreshListener != null) refreshListener, ...?filterListeners]
            : null;

  /// The cubit managing the pagination state.
  final DualPaginationCubit<Key, T> cubit;

  /// Whether the cubit is managed internally and should be disposed.
  final bool internalCubit;

  /// Builder for group headers.
  final Widget Function(BuildContext context, Key groupKey, List<T> items)
      groupHeaderBuilder;

  /// Builder for individual items.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Height for initial loading and empty widget containers.
  final double? heightOfInitialLoadingAndEmptyWidget;

  /// Custom error widget builder.
  final Widget Function(Exception exception)? onError;

  /// Callback when pagination reaches the end.
  final void Function(DualPaginationLoaded<Key, T> loader)? onReachedEnd;

  /// Callback when data is loaded.
  final void Function(DualPaginationLoaded<Key, T> loader)? onLoaded;

  /// Widget displayed when there are no items.
  final Widget emptyWidget;

  /// Widget displayed while initially loading data.
  final Widget loadingWidget;

  /// Widget displayed while loading more items.
  final Widget bottomLoader;

  /// Whether the scroll view should shrink-wrap.
  final bool shrinkWrap;

  /// Whether to display items in reverse order.
  final bool reverse;

  /// The scroll direction.
  final Axis scrollDirection;

  /// Padding around the scroll view.
  final EdgeInsetsGeometry padding;

  /// The scroll physics.
  final ScrollPhysics? physics;

  /// Optional scroll controller.
  final ScrollController? scrollController;

  /// Keyboard dismiss behavior.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Optional header widget.
  final Widget? header;

  /// Optional footer widget.
  final Widget? footer;

  /// Cache extent for pre-rendering.
  final double? cacheExtent;

  /// Optional separator between items.
  final Widget? separator;

  /// Change listeners for refresh and filter.
  final List<DualPaginationChangeListener>? listeners;

  @override
  State<DualPagination<Key, T>> createState() =>
      _DualPaginationState<Key, T>();
}

class _DualPaginationState<Key, T> extends State<DualPagination<Key, T>> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DualPaginationCubit<Key, T>, DualPaginationState<T>>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (!widget.cubit.didFetch) widget.cubit.fetchPaginatedList();

        if (state is DualPaginationInitial<T>) {
          return _buildWithScrollView(context, widget.loadingWidget);
        } else if (state is DualPaginationError<T>) {
          return _buildWithScrollView(
            context,
            (widget.onError != null)
                ? widget.onError!(state.error)
                : ErrorDisplay(exception: state.error),
          );
        } else {
          final loadedState = state as DualPaginationLoaded<Key, T>;

          if (widget.onLoaded != null) {
            widget.onLoaded!(loadedState);
          }
          if (loadedState.hasReachedEnd && widget.onReachedEnd != null) {
            widget.onReachedEnd!(loadedState);
          }

          if (loadedState.groups.isEmpty) {
            return _buildWithScrollView(context, widget.emptyWidget);
          }

          final view = PaginateGroupedView<Key, T>(
            loadedState: loadedState,
            groupHeaderBuilder: widget.groupHeaderBuilder,
            itemBuilder: widget.itemBuilder,
            shrinkWrap: widget.shrinkWrap,
            reverse: widget.reverse,
            scrollDirection: widget.scrollDirection,
            padding: widget.padding,
            physics: widget.physics,
            scrollController: widget.scrollController,
            keyboardDismissBehavior: widget.keyboardDismissBehavior,
            header: widget.header,
            footer: widget.footer,
            bottomLoader: widget.bottomLoader,
            fetchPaginatedList: widget.cubit.fetchPaginatedList,
            cacheExtent: widget.cacheExtent,
            separator: widget.separator,
          );

          if (widget.listeners != null && widget.listeners!.isNotEmpty) {
            return MultiProvider(
              providers: widget.listeners!
                  .map((listener) => ChangeNotifierProvider(create: (_) => listener))
                  .toList(),
              child: view,
            );
          }

          return view;
        }
      },
    );
  }

  Widget _buildWithScrollView(BuildContext context, Widget child) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        height: widget.heightOfInitialLoadingAndEmptyWidget ??
            MediaQuery.of(context).size.height,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.internalCubit) widget.cubit.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.listeners != null) {
      for (var listener in widget.listeners!) {
        if (listener is DualPaginationRefreshedChangeListener) {
          listener.addListener(() {
            if (listener.refreshed) {
              widget.cubit.refreshPaginatedList();
            }
          });
        } else if (listener is DualPaginationFilterChangeListener<T>) {
          listener.addListener(() {
            if (listener.searchTerm != null) {
              widget.cubit.filterPaginatedList(listener.searchTerm);
            }
          });
        }
      }
    }

    if (!widget.cubit.didFetch) widget.cubit.fetchPaginatedList();
    super.initState();
  }
}
