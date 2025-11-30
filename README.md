# Custom Pagination 📄

[![Pub Version](https://img.shields.io/badge/pub-v0.0.5-blue)](https://pub.dev/packages/custom_pagination)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-3.9.0+-02569B?logo=flutter)](https://flutter.dev)

A comprehensive Flutter pagination library with BLoC pattern support, advanced error handling, and beautiful error states. Provides flexible pagination for REST APIs with multiple view types, retry mechanisms, and real-time stream support.

## ✨ Features

### 🎨 Layout Support
- **ListView** - Vertical/horizontal scrollable lists
- **GridView** - Multi-column grids with customizable delegates
- **PageView** - Swipeable pages with pagination
- **StaggeredGridView** - Pinterest-style masonry layouts
- **ReorderableListView** - Drag-and-drop reordering
- **Custom View Builder** - Complete control with custom layouts
- **Column/Row** - Non-scrollable layouts

### 🏗️ State Management
- **BLoC Pattern** - Clean state management using flutter_bloc
- **Type-Safe States** - Generic type support throughout
- **State Separation** - Different builders for first page vs load more states
- **Smart State Transitions** - Optimized state updates

### 🔄 Pagination Strategies
- **Offset Pagination** - Traditional page-based pagination
- **Cursor Pagination** - Efficient cursor-based pagination
- **Lazy Loading** - Automatic loading as user scrolls
- **Smart Preloading** - Load items before reaching the end (configurable threshold)
- **Memory Management** - Configurable page caching (`maxPagesInMemory`)

### 📡 Data Sources
- **Future Provider** - Standard REST API calls
- **Stream Provider** - Real-time updates
- **Multiple Streams** - Switch between different data streams
- **Merged Streams** - Combine multiple streams into one
- **Custom Providers** - Bring your own async data source

### 🛡️ Advanced Error Handling
- **6 Error Widget Styles** - Material, Compact, Card, Minimal, Snackbar, Custom
- **Error State Separation** - Different UI for first page vs load more errors
- **Custom Error Builders** - `firstPageErrorBuilder`, `loadMoreErrorBuilder`
- **Retry Functionality** - Built-in retry with callbacks
- **Error Recovery Strategies** - Cached data, partial data, fallback sources
- **Graceful Degradation** - Offline mode, placeholders, limited features
- **Custom Exceptions** - NetworkException, TimeoutException, ServerException

### 🔁 Retry Mechanism
- **Automatic Retry** - Exponential backoff for failed requests
- **Configurable Attempts** - Set max retry attempts
- **Custom Delays** - Define retry delays per attempt
- **Timeout Support** - Request timeout configuration
- **Conditional Retry** - Custom logic to determine if retry should occur
- **Manual Retry** - User-triggered retry buttons
- **Auto Retry** - Automatic retry with countdown
- **Limited Retry** - Maximum retry attempts with exhaustion handling

### 🎯 UI Customization
- **Loading States** - `loadingWidget`, `firstPageLoadingBuilder`, `loadMoreLoadingBuilder`
- **Empty States** - `emptyWidget`, `firstPageEmptyBuilder`
- **Error States** - `onError`, `firstPageErrorBuilder`, `loadMoreErrorBuilder`
- **End of List** - `loadMoreNoMoreItemsBuilder`
- **Bottom Loader** - Customizable loading indicator at bottom
- **Header/Footer** - Add widgets above/below the list
- **Separators** - Custom separators between items

### 🔍 Filtering & Search
- **Built-in Filter Listeners** - Type-safe filter callbacks
- **Search Support** - Real-time search with pagination
- **In-Memory Filtering** - Client-side filtering with `WhereChecker<T>`
- **Server-Side Filtering** - Pass filters in `PaginationRequest`
- **Order/Sort Support** - Custom sorting with `CompareBy<T>`

### 📍 Scroll Control
- **Programmatic Scrolling** - Scroll to specific items or indices
- **Scroll to Message** - Advanced scroll-to-item capabilities
- **Scroll Controller** - Custom scroll controller support
- **Scroll Physics** - Customizable scroll behavior
- **Cache Extent** - Control viewport caching

### ⚡ Performance
- **Efficient Rendering** - Optimized for large lists
- **Smart Preloading** - Configurable `invisibleItemsThreshold` (default: 3 items)
- **Memory Optimization** - Page-based caching
- **Lazy Building** - Items built only when visible
- **Scroll Notifications** - Efficient scroll detection

### 🎨 Error Illustrations
- **ErrorImages Helper** - Easy image integration with fallback icons
- **12 Pre-configured Images** - General, Network, 404, 500, Timeout, Auth, Offline, Empty, Retry, Recovery, Loading, Custom
- **Automatic Fallback** - Icons display if images fail to load
- **Free Resources Guide** - Curated list of free illustration sources (unDraw, Storyset, DrawKit)
- **Download Script** - Helper script for image acquisition

### 🛠️ Convenience Features
- **Pull-to-Refresh** - Easy refresh functionality
- **beforeBuild Hook** - Transform state before rendering
- **Callbacks** - `onReachedEnd`, `onLoaded`, `onInsertionCallback`, `onClear`
- **List Builder** - Transform items before emission
- **Custom Logger** - Integrated logging support
- **Reorderable Items** - Built-in drag-and-drop support

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  custom_pagination: ^0.0.5
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Simple ListView Pagination

```dart
SmartPaginatedListView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(
    (request) => apiService.fetchProducts(request),
  ),
  childBuilder: (context, product, index) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('\$${product.price}'),
    );
  },
)
```

### GridView Pagination

```dart
SmartPaginatedGridView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(
    (request) => apiService.fetchProducts(request),
  ),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
  ),
  childBuilder: (context, product, index) {
    return ProductCard(product: product);
  },
)
```

### With Error Handling

```dart
SmartPaginatedListView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  childBuilder: (context, product, index) => ProductCard(product),

  // Custom error widget for first page
  firstPageErrorBuilder: (context, error, retry) {
    return CustomErrorBuilder.material(
      context: context,
      error: error,
      onRetry: retry,
      title: 'Failed to Load Products',
      message: 'Please check your internet connection',
    );
  },

  // Compact error for load more
  loadMoreErrorBuilder: (context, error, retry) {
    return CustomErrorBuilder.compact(
      context: context,
      error: error,
      onRetry: retry,
    );
  },
)
```

## 🛡️ Error Handling

### CustomErrorBuilder Styles

The library includes 6 pre-built error widget styles:

#### 1. Material Design
```dart
CustomErrorBuilder.material(
  context: context,
  error: error,
  onRetry: retry,
  title: 'Failed to Load',
  message: 'Please check your connection',
  icon: Icons.cloud_off,
  iconColor: Colors.blue,
)
```

#### 2. Compact (Inline)
```dart
CustomErrorBuilder.compact(
  context: context,
  error: error,
  onRetry: retry,
  message: 'Failed to load more items',
  backgroundColor: Colors.red[50],
)
```

#### 3. Card Style
```dart
CustomErrorBuilder.card(
  context: context,
  error: error,
  onRetry: retry,
  title: 'Products Unavailable',
  elevation: 4,
)
```

#### 4. Minimal
```dart
CustomErrorBuilder.minimal(
  context: context,
  error: error,
  onRetry: retry,
  message: 'Error occurred',
)
```

#### 5. Snackbar
```dart
CustomErrorBuilder.snackbar(
  context: context,
  error: error,
  onRetry: retry,
  message: 'Failed to load',
)
```

#### 6. Custom
```dart
CustomErrorBuilder.custom(
  context: context,
  error: error,
  onRetry: retry,
  builder: (context, error, retry) {
    return YourCustomErrorWidget();
  },
)
```

### Error State Separation

Different error handling for first page vs load more:

```dart
SmartPaginatedListView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  childBuilder: (context, product, index) => ProductCard(product),

  // First page error - full screen
  firstPageErrorBuilder: (context, error, retry) {
    return CustomErrorBuilder.material(
      context: context,
      error: error,
      onRetry: retry,
    );
  },

  // Load more error - compact inline
  loadMoreErrorBuilder: (context, error, retry) {
    return CustomErrorBuilder.compact(
      context: context,
      error: error,
      onRetry: retry,
    );
  },
)
```

### Error Recovery Strategies

#### 1. Cached Data Fallback
Show offline cached data when fresh data fails:
```dart
// Automatically handled by showing cached data
// when network request fails
```

#### 2. Partial Data Display
Show whatever loaded before error occurred

#### 3. Alternative Source
Switch to backup server on primary failure

#### 4. User-Initiated Recovery
Require user action (login, permissions) to resolve

See [docs/ERROR_HANDLING.md](docs/ERROR_HANDLING.md) for comprehensive guide.

### Custom Error Types

```dart
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

class ServerException implements Exception {
  final int statusCode;
  final String message;
  ServerException(this.statusCode, this.message);
}
```

## 🎨 Error Illustrations

### Setup Error Images

1. **Download illustrations** from free sources:
   - [unDraw](https://undraw.co) (Highly recommended)
   - [Storyset](https://storyset.com)
   - [DrawKit](https://drawkit.com)

2. **Save to assets directory**:
   ```
   example/assets/images/errors/
   ```

3. **Use ErrorImages helper**:
   ```dart
   ErrorImages.network(
     width: 200,
     height: 200,
     fallbackColor: Colors.orange,
   )
   ```

See [docs/ERROR_IMAGES_SETUP.md](docs/ERROR_IMAGES_SETUP.md) for detailed setup guide.

### Available Error Images

```dart
ErrorImages.general()       // General error
ErrorImages.network()       // Network error
ErrorImages.notFound()      // 404 error
ErrorImages.serverError()   // 500 error
ErrorImages.timeout()       // Timeout error
ErrorImages.auth()          // Authentication error
ErrorImages.offline()       // Offline mode
ErrorImages.empty()         // Empty state
ErrorImages.retry()         // Retry icon
ErrorImages.recovery()      // Recovery icon
ErrorImages.loadingError()  // Load more error
ErrorImages.custom()        // Custom error
```

## 📡 Stream Support

### Single Stream

```dart
SmartPagination<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.stream(
    (request) => apiService.productsStream(request),
  ),
  itemBuilder: (context, items, index) {
    return ProductCard(items[index]);
  },
)
```

### Multiple Streams

Switch between different streams:

```dart
SmartPagination<Product>(
  key: ValueKey(selectedStream), // Force rebuild on stream change
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.stream(
    (request) => getStreamProvider(request),
  ),
  itemBuilder: (context, items, index) {
    return ProductCard(items[index]);
  },
)
```

### Merged Streams

Combine multiple streams into one:

```dart
SmartPagination<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.mergeStreams(
    (request) => [
      apiService.regularProductsStream(request),
      apiService.featuredProductsStream(request),
      apiService.saleProductsStream(request),
    ],
  ),
  itemBuilder: (context, items, index) {
    return ProductCard(items[index]);
  },
)
```

## 🔁 Retry Mechanism

### Automatic Retry with Exponential Backoff

```dart
SmartPaginatedListView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  retryConfig: RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 10),
    timeoutDuration: Duration(seconds: 30),
    shouldRetry: (error) {
      return error is NetworkException;
    },
  ),
  childBuilder: (context, product, index) {
    return ProductCard(product: product);
  },
)
```

### Manual Retry

```dart
firstPageErrorBuilder: (context, error, retry) {
  return Column(
    children: [
      Text('Error: $error'),
      ElevatedButton(
        onPressed: retry,
        child: Text('Try Again'),
      ),
    ],
  );
}
```

### Auto Retry with Countdown

```dart
// See example app for full implementation
// example/lib/screens/errors/retry_patterns_example.dart
```

### Retry Patterns Available

1. **Manual Retry** - User explicitly clicks retry button
2. **Auto Retry** - Automatic retry with countdown
3. **Exponential Backoff** - Increasing delays (1s → 2s → 4s → 8s)
4. **Limited Attempts** - Maximum retry attempts with reset option

## 🎯 State Separation

Different builders for different states:

```dart
SmartPaginatedListView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  childBuilder: (context, product, index) => ProductCard(product),

  // First page states
  firstPageLoadingBuilder: (context) {
    return Center(child: CircularProgressIndicator());
  },

  firstPageErrorBuilder: (context, error, retry) {
    return ErrorWidget(error: error, onRetry: retry);
  },

  firstPageEmptyBuilder: (context) {
    return Center(child: Text('No items found'));
  },

  // Load more states
  loadMoreLoadingBuilder: (context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: CircularProgressIndicator(),
    );
  },

  loadMoreErrorBuilder: (context, error, retry) {
    return CompactErrorWidget(error: error, onRetry: retry);
  },

  loadMoreNoMoreItemsBuilder: (context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text('No more items'),
    );
  },
)
```

## ⚡ Smart Preloading

Load items before user reaches the end:

```dart
SmartPaginatedListView<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  childBuilder: (context, product, index) => ProductCard(product),

  // Load when user is 3 items away from the end
  invisibleItemsThreshold: 3, // Default value
)
```

## 📋 Data Provider

### Future Provider (REST APIs)

```dart
final provider = PaginationProvider.future(
  (request) => apiService.fetchProducts(request),
);
```

### Stream Provider (Real-time)

```dart
final streamProvider = PaginationProvider.stream(
  (request) => apiService.productsStream(request),
);
```

### Merged Streams

```dart
final mergedProvider = PaginationProvider.mergeStreams(
  (request) => [
    apiService.stream1(request),
    apiService.stream2(request),
    apiService.stream3(request),
  ],
);
```

### PaginationRequest

```dart
const PaginationRequest(
  page: 1,
  pageSize: 20,
  filters: {'status': 'active', 'category': 'electronics'},
);
```

## 🎨 View Types

### ListView

```dart
SmartPagination.listView(
  cubit: cubit,
  itemBuilder: (context, items, index) {
    return ListTile(title: Text(items[index].name));
  },
)
```

### GridView

```dart
SmartPagination.gridView(
  cubit: cubit,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemBuilder: (context, items, index) {
    return ProductCard(items[index]);
  },
)
```

### PageView

```dart
SmartPagination.pageView(
  cubit: cubit,
  itemBuilder: (context, items, index) {
    return FullScreenProductView(items[index]);
  },
)
```

### StaggeredGridView

```dart
SmartPagination.staggeredGridView(
  cubit: cubit,
  crossAxisCount: 2,
  itemBuilder: (context, items, index) {
    return StaggeredGridTile.fit(
      crossAxisCellCount: 1,
      child: ProductCard(items[index]),
    );
  },
)
```

### ReorderableListView

```dart
SmartPagination(
  cubit: cubit,
  itemBuilderType: PaginateBuilderType.reorderableListView,
  itemBuilder: (context, items, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
  onReorder: (oldIndex, newIndex) {
    // Handle reordering
  },
)
```

### Custom View Builder

Complete control over the view:

```dart
SmartPagination(
  cubit: cubit,
  itemBuilderType: PaginateBuilderType.custom,
  customViewBuilder: (context, items, hasReachedEnd, fetchMore) {
    return YourCustomLayout(
      items: items,
      onLoadMore: fetchMore,
      isLastPage: hasReachedEnd,
    );
  },
)
```

## 📍 Scroll Control

```dart
final controller = SmartPaginationController<Product>();

// Scroll to specific item
controller.scrollToItem(
  targetItem,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// Scroll to index
controller.scrollToIndex(
  10,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// Use with SmartPagination
SmartPagination.cubit(
  cubit: cubit..controller = controller,
  itemBuilder: (context, items, index) {
    return ListTile(title: Text(items[index].name));
  },
)
```

## 🔍 Filtering & Search

### In-Memory Filtering

```dart
final filterListener = SmartPaginationFilterChangeListener<Product>();

SmartPagination(
  cubit: cubit,
  filterListeners: [filterListener],
  itemBuilder: (context, items, index) {
    return ProductCard(items[index]);
  },
)

// Trigger filter
filterListener.searchTerm = (product) =>
  product.name.toLowerCase().contains(searchQuery.toLowerCase());
```

### Server-Side Filtering

```dart
PaginationRequest(
  page: 1,
  pageSize: 20,
  filters: {
    'category': 'electronics',
    'minPrice': 100,
    'maxPrice': 1000,
  },
)
```

## 🔧 Advanced Features

### Before Build Hook

Transform state before rendering:

```dart
SmartPagination<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  itemBuilder: (context, items, index) => ProductCard(items[index]),
  beforeBuild: (state) {
    // Sort items before rendering
    final sorted = state.items..sort((a, b) => a.price.compareTo(b.price));
    return state.copyWith(items: sorted);
  },
)
```

### List Builder

Transform items before emission:

```dart
SmartPaginationCubit<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  listBuilder: (items) {
    // Remove duplicates
    return items.toSet().toList();
  },
)
```

### Callbacks

```dart
SmartPaginationCubit<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  onInsertionCallback: (items) {
    print('Inserted ${items.length} items');
  },
  onClear: () {
    print('List cleared');
  },
)
```

### Pull to Refresh

```dart
final refreshListener = SmartPaginationRefreshedChangeListener();

SmartPagination(
  cubit: cubit,
  refreshListener: refreshListener,
  itemBuilder: (context, items, index) {
    return ProductCard(items[index]);
  },
)

// Trigger refresh
RefreshIndicator(
  onRefresh: () async {
    refreshListener.refreshed = true;
    await Future.delayed(Duration(seconds: 1));
  },
  child: yourPaginationWidget,
)
```

### Memory Management

```dart
SmartPaginationCubit<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  maxPagesInMemory: 5, // Keep only 5 pages in memory
)
```

### Custom Logger

```dart
SmartPaginationCubit<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  provider: PaginationProvider.future(fetchProducts),
  logger: Logger(
    printer: PrettyPrinter(),
    level: Level.debug,
  ),
)
```

## 🎨 Example App

The library includes a comprehensive example app with **27+ demonstration screens**:

```bash
cd example
flutter pub get
flutter run
```

### Single Pagination Examples

1. **Basic ListView** - Simple paginated product list
2. **GridView** - Product grid with pagination
3. **Retry Mechanism** - Auto-retry with exponential backoff
4. **Filter & Search** - Real-time filtering and search
5. **Pull to Refresh** - Swipe down to refresh

### Stream Examples

6. **Single Stream** - Real-time updates from single data stream
7. **Multi Stream** - Multiple streams with different update rates
8. **Merged Streams** - Combine multiple streams into one

### Advanced Examples

9. **Cursor Pagination** - Cursor-based pagination
10. **Horizontal Scroll** - Horizontal scrolling list
11. **PageView** - Swipeable pages with pagination
12. **Staggered Grid** - Pinterest-style masonry layout
13. **Custom States** - Custom loading, empty, and error states
14. **Scroll Control** - Programmatic scrolling to items
15. **beforeBuild Hook** - Transform state before rendering
16. **hasReachedEnd** - Detect when pagination reaches the end
17. **Custom View Builder** - Complete control with custom layouts
18. **Reorderable List** - Drag and drop to reorder items
19. **State Separation** - Different UI for first page vs load more
20. **Smart Preloading** - Load items before reaching the end
21. **Custom Error Handling** - Multiple error widget styles

### Error Handling Examples

22. **Basic Error Handling** - Simple error display with retry
23. **Network Errors** - Different network error types (timeout, 404, 500, etc.)
24. **Retry Patterns** - Manual, auto, exponential backoff, limited retries
25. **Custom Error Widgets** - All 6 pre-built error widget styles
26. **Error Recovery** - Cached data, partial data, fallback strategies
27. **Graceful Degradation** - Offline mode, placeholders, limited features
28. **Load More Errors** - Handle errors while loading additional pages

## 📚 API Reference

### SmartPaginatedListView

```dart
SmartPaginatedListView<T>({
  required PaginationRequest request,
  required PaginationProvider<T> provider,
  required Widget Function(BuildContext, T, int) childBuilder,

  // Optional builders
  Widget Function(BuildContext, int)? separatorBuilder,
  Widget Function(BuildContext)? emptyBuilder,
  Widget Function(BuildContext, Exception, VoidCallback)? errorBuilder,
  Widget Function(BuildContext)? initialLoadingBuilder,
  Widget Function(BuildContext)? bottomLoadingBuilder,

  // State separation builders
  Widget Function(BuildContext)? firstPageLoadingBuilder,
  Widget Function(BuildContext, Exception, VoidCallback)? firstPageErrorBuilder,
  Widget Function(BuildContext)? firstPageEmptyBuilder,
  Widget Function(BuildContext)? loadMoreLoadingBuilder,
  Widget Function(BuildContext, Exception, VoidCallback)? loadMoreErrorBuilder,
  Widget Function(BuildContext)? loadMoreNoMoreItemsBuilder,

  // Configuration
  RetryConfig? retryConfig,
  bool shrinkWrap = false,
  bool reverse = false,
  EdgeInsetsGeometry? padding,
  ScrollPhysics? physics,
  ScrollController? scrollController,
  VoidCallback? onReachedEnd,
  int invisibleItemsThreshold = 3,
})
```

### SmartPaginatedGridView

```dart
SmartPaginatedGridView<T>({
  required PaginationRequest request,
  required PaginationProvider<T> provider,
  required SliverGridDelegate gridDelegate,
  required Widget Function(BuildContext, T, int) childBuilder,

  // Same optional parameters as ListView
  // ...
})
```

### SmartPagination

```dart
SmartPagination<T>({
  required PaginationRequest request,
  required PaginationProvider<T> provider,
  required Widget Function(BuildContext, List<T>, int) itemBuilder,
  PaginateBuilderType itemBuilderType = PaginateBuilderType.listView,

  // All customization options
  // ...
})
```

### CustomErrorBuilder

```dart
// Material design error
CustomErrorBuilder.material({
  required BuildContext context,
  required Exception error,
  required VoidCallback onRetry,
  String? title,
  String? message,
  IconData? icon,
  Color? iconColor,
  String? retryButtonText,
})

// Compact inline error
CustomErrorBuilder.compact({
  required BuildContext context,
  required Exception error,
  required VoidCallback onRetry,
  String? message,
  Color? backgroundColor,
  Color? textColor,
})

// Card style error
CustomErrorBuilder.card({
  required BuildContext context,
  required Exception error,
  required VoidCallback onRetry,
  String? title,
  String? message,
  double? elevation,
})

// Minimal error
CustomErrorBuilder.minimal({
  required BuildContext context,
  required Exception error,
  required VoidCallback onRetry,
  String? message,
})

// Snackbar style error
CustomErrorBuilder.snackbar({
  required BuildContext context,
  required Exception error,
  required VoidCallback onRetry,
  String? message,
  Color? backgroundColor,
})

// Custom error
CustomErrorBuilder.custom({
  required BuildContext context,
  required Exception error,
  required VoidCallback onRetry,
  required Widget Function(BuildContext, Exception, VoidCallback) builder,
})
```

### ErrorImages

```dart
ErrorImages.general({double width, double height, Color? fallbackColor})
ErrorImages.network({double width, double height, Color? fallbackColor})
ErrorImages.notFound({double width, double height, Color? fallbackColor})
ErrorImages.serverError({double width, double height, Color? fallbackColor})
ErrorImages.timeout({double width, double height, Color? fallbackColor})
ErrorImages.auth({double width, double height, Color? fallbackColor})
ErrorImages.offline({double width, double height, Color? fallbackColor})
ErrorImages.empty({double width, double height, Color? fallbackColor})
ErrorImages.retry({double width, double height, Color? fallbackColor})
ErrorImages.recovery({double width, double height, Color? fallbackColor})
ErrorImages.loadingError({double width, double height, Color? fallbackColor})
ErrorImages.custom({double width, double height, Color? fallbackColor})
```

### RetryConfig

```dart
RetryConfig({
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
  Duration maxDelay = const Duration(seconds: 10),
  Duration? timeoutDuration,
  List<Duration>? retryDelays,
  bool Function(Exception)? shouldRetry,
})
```

### PaginationProvider

```dart
// Future-based
PaginationProvider.future(
  Future<List<T>> Function(PaginationRequest) provider
)

// Stream-based
PaginationProvider.stream(
  Stream<List<T>> Function(PaginationRequest) provider
)

// Merged streams
PaginationProvider.mergeStreams(
  List<Stream<List<T>>> Function(PaginationRequest) providers
)
```

## 🏗️ Architecture

```
lib/
├── core/                    # Core interfaces and mixins
│   ├── bloc/               # IPaginationCubit, IPaginationState, IPaginationListeners
│   ├── controller/         # IPaginationController interfaces
│   └── widget/             # Shared widgets
│       ├── error_display.dart
│       ├── custom_error_builder.dart
│       ├── initial_loader.dart
│       ├── bottom_loader.dart
│       └── empty_display.dart
├── data/                   # Data models
│   └── models/
│       ├── pagination_request.dart
│       └── pagination_meta.dart
└── smart_pagination/      # Implementation
    ├── bloc/               # Cubit, State, Listeners
    ├── controller/         # Controller with scroll capabilities
    └── widgets/            # UI widgets
        ├── paginate_api_view.dart
        ├── smart_paginated_list_view.dart
        └── smart_paginated_grid_view.dart
```

## 📖 Documentation

- **Error Handling Guide**: [docs/ERROR_HANDLING.md](docs/ERROR_HANDLING.md)
- **Error Images Setup**: [docs/ERROR_IMAGES_SETUP.md](docs/ERROR_IMAGES_SETUP.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
- **License**: [LICENSE](LICENSE)

## 🎯 Best Practices

1. **Reuse Cubits** - Create cubits once and reuse with `SmartPagination.cubit()`
2. **Memory Management** - Set `maxPagesInMemory` based on item size
3. **Error Handling** - Always provide custom error builders for better UX
4. **Testing** - Mock data providers for predictable tests
5. **Performance** - Use `listBuilder` for transformations rather than `beforeBuild`
6. **Smart Preloading** - Adjust `invisibleItemsThreshold` based on your needs
7. **Error Images** - Use fallback icons to ensure content always displays
8. **State Separation** - Use different builders for first page vs load more states

## 🧪 Testing

### Cubit Tests

```dart
blocTest<SmartPaginationCubit<Product>, SmartPaginationState<Product>>(
  'emits loaded state when data fetched successfully',
  build: () => SmartPaginationCubit<Product>(
    request: PaginationRequest(page: 1, pageSize: 20),
    provider: PaginationProvider.future(
      (request) async => [Product(id: '1', name: 'Test')],
    ),
  ),
  act: (cubit) => cubit.fetchPaginatedList(),
  expect: () => [
    isA<SmartPaginationLoaded<Product>>(),
  ],
);
```

### Widget Tests

```dart
testWidgets('displays loading indicator initially', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SmartPaginatedListView<Product>(
        request: PaginationRequest(page: 1, pageSize: 20),
        provider: PaginationProvider.future(fetchProducts),
        childBuilder: (context, product, index) {
          return ListTile(title: Text(product.name));
        },
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## 🗺️ Roadmap

- [x] Single Pagination implementation
- [x] Retry mechanism with exponential backoff
- [x] Comprehensive unit tests (60+ tests)
- [x] Convenience widgets (SmartPaginatedListView, GridView)
- [x] Example app with 27+ demos
- [x] Advanced error handling
- [x] Custom error builders (6 styles)
- [x] Error state separation
- [x] Error illustrations infrastructure
- [x] Smart preloading
- [x] Reorderable list support
- [x] Custom view builder
- [x] Stream support
- [ ] Widget and integration tests
- [ ] Performance benchmarks
- [ ] Video tutorials
- [ ] CI/CD setup
- [ ] pub.dev publication

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- All tests pass
- Code is properly formatted (`flutter format .`)
- Documentation is updated
- Examples are provided for new features

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management
- Uses [scrollview_observer](https://pub.dev/packages/scrollview_observer) for scroll control
- [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) for staggered layouts
- Inspired by Flutter pagination best practices

## 📧 Support

- 📫 [Open an issue](https://github.com/GeniusSystems24/custom_pagination/issues)
- 💬 [Start a discussion](https://github.com/GeniusSystems24/custom_pagination/discussions)
- ⭐ Star the repo if you find it useful!

## 🌟 Features at a Glance

| Feature | Supported | Description |
|---------|-----------|-------------|
| ListView | ✅ | Vertical/horizontal scrollable lists |
| GridView | ✅ | Multi-column grids |
| PageView | ✅ | Swipeable pages |
| StaggeredGridView | ✅ | Pinterest-style layouts |
| ReorderableListView | ✅ | Drag-and-drop reordering |
| Custom View Builder | ✅ | Complete layout control |
| Future Provider | ✅ | REST API support |
| Stream Provider | ✅ | Real-time updates |
| Merged Streams | ✅ | Multiple stream sources |
| Error Handling | ✅ | 6 pre-built error styles |
| Retry Mechanism | ✅ | Automatic & manual retry |
| State Separation | ✅ | First page vs load more |
| Smart Preloading | ✅ | Configurable threshold |
| Filter & Search | ✅ | Client & server-side |
| Scroll Control | ✅ | Programmatic scrolling |
| Pull to Refresh | ✅ | Swipe down to refresh |
| Memory Management | ✅ | Page-based caching |
| Error Illustrations | ✅ | Image helper with fallback |
| Custom Logger | ✅ | Integrated logging |
| BLoC Pattern | ✅ | Clean state management |

---

**Transport agnostic**: bring your own async function and enjoy consistent pagination UI.

Made with ❤️ by [Genius Systems 24](https://github.com/GeniusSystems24)
