# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-10-31

### Added

#### Core Features
- Initial release of Custom Pagination library
- `SinglePagination` widget with multiple layout support:
  - ListView with separators
  - GridView with configurable delegates
  - PageView for swipeable content
  - StaggeredGridView for masonry layouts
  - Column layout (non-scrollable)
  - Row layout (non-scrollable horizontal)

#### State Management
- `SinglePaginationCubit` implementing BLoC pattern
- Three state types: `Initial`, `Loaded`, `Error`
- `PaginationMeta` for pagination metadata tracking
- `PaginationRequest` for pagination configuration

#### Advanced Features
- Cursor-based and offset-based pagination support
- Stream provider for real-time updates
- Memory management with configurable `maxPagesInMemory`
- Filter listeners (`SinglePaginationFilterChangeListener`)
- Refresh listeners (`SinglePaginationRefreshedChangeListener`)
- Order listeners (`SinglePaginationOrderChangeListener`)
- Custom list builder for item transformation
- `beforeBuild` hook for pre-render transformations

#### Controller
- `SinglePaginationController` with scroll capabilities
- Programmatic scrolling to index: `scrollToIndex()`
- Programmatic scrolling to item: `scrollToItem()`
- Controller factory: `SinglePaginationController.of()`
- Public/private controller modes

#### UI Components
- `BottomLoader` - loading indicator for pagination
- `InitialLoader` - initial loading state widget
- `EmptyDisplay` - empty state widget
- `ErrorDisplay` - error state widget
- `EmptySeparator` - zero-size separator widget

#### Developer Experience
- Type-safe generic support for any data model
- Custom error handling with `onError` callback
- Callbacks: `onLoaded`, `onReachedEnd`, `onInsertionCallback`, `onClear`
- Custom logger integration
- Comprehensive documentation in code
- Multiple named constructors for different use cases

### Fixed
- Fixed spelling error in `ErrorDisplay`: "occured" → "occurred"
- Fixed entry point (`lib/pagination.dart`) - removed unrelated Calculator class

### Documentation
- Comprehensive README.md with:
  - Feature overview
  - Installation instructions
  - Quick start guide
  - 10+ usage examples
  - Architecture documentation
  - API reference
  - Best practices
  - Contributing guidelines
- Added library-level documentation in `lib/pagination.dart`
- Updated `pubspec.yaml` with proper package description
- Added CHANGELOG.md for version tracking

### Dependencies
- `flutter_bloc: ^9.1.1` - State management
- `flutter_staggered_grid_view: ^0.7.0` - Staggered layouts
- `logger: ^2.6.2` - Logging support
- `provider: ^6.1.5+1` - Listener management
- `scrollview_observer: ^1.26.2` - Scroll observation

### Known Limitations
- Limited test coverage (tests to be added in future releases)

## [0.0.2] - 2025-10-31

### Added

#### Dual Pagination (Grouped Pagination)
- **🎯 Complete DualPagination Implementation**: Full support for grouped pagination
  - `DualPaginationCubit<Key, T>` for managing grouped state
  - `DualPaginationState` with `DualPaginationLoaded` containing grouped items
  - `DualPaginationController` for advanced control
  - `DualPagination` widget with multiple constructors
  - `PaginateGroupedView` for rendering grouped items
- **🔑 Flexible Grouping**: Custom `KeyGenerator` function for grouping logic
  - Group messages by date
  - Group products by category
  - Group posts by author
  - Any custom grouping strategy
- **📊 Group Headers**: Customizable group header builder
- **🔄 Real-time Updates**: Stream support for grouped data
- **📋 Listeners**: Full listener support (refresh, filter, order)
- **💾 Memory Management**: Configurable page caching for grouped data

#### Retry Mechanism & Error Handling
- **🔄 Retry Configuration**: `RetryConfig` class for configurable retry behavior
  - Exponential backoff strategy
  - Configurable max attempts (default: 3)
  - Initial delay (default: 1 second)
  - Max delay (default: 10 seconds)
  - Custom retry conditions via `shouldRetry` callback
- **⏱️ Timeout Handling**: Built-in timeout support
  - Configurable timeout duration (default: 30 seconds)
  - Automatic timeout detection and retry
- **🚨 Enhanced Exceptions**: Custom exception types for better error handling
  - `PaginationTimeoutException` - For timeout errors
  - `PaginationNetworkException` - For network errors
  - `PaginationParseException` - For parsing errors
  - `PaginationRetryExhaustedException` - When all retries fail
- **🔧 RetryHandler Utility**: Automatic retry execution with logging
  - Integrated with both `SinglePaginationCubit` and `DualPaginationCubit`
  - Optional retry callbacks for monitoring
  - Smart error detection and classification

#### Integration
- Both `SinglePaginationCubit` and `DualPaginationCubit` support retry configuration
- Seamless integration with existing code (backward compatible)
- Optional retry - works without configuration

### Enhanced
- Improved error logging with retry attempt information
- Better error messages with original error context
- Exponential backoff prevents API rate limiting issues

### Example Usage

#### DualPagination Example
```dart
// Group messages by date
final cubit = DualPaginationCubit<String, Message>(
  request: PaginationRequest(page: 1, pageSize: 50),
  dataProvider: fetchMessages,
  groupKeyGenerator: (messages) {
    final grouped = <String, List<Message>>{};
    for (var message in messages) {
      final date = DateFormat('yyyy-MM-dd').format(message.timestamp);
      grouped.putIfAbsent(date, () => []).add(message);
    }
    return grouped.entries.toList();
  },
);

DualPagination<String, Message>(
  request: request,
  dataProvider: fetchMessages,
  groupKeyGenerator: groupByDate,
  groupHeaderBuilder: (context, dateKey, messages) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Text(dateKey),
    );
  },
  itemBuilder: (context, message, index) {
    return ListTile(title: Text(message.content));
  },
)
```

#### Retry Configuration Example
```dart
final cubit = SinglePaginationCubit<Product>(
  request: PaginationRequest(page: 1, pageSize: 20),
  dataProvider: fetchProducts,
  retryConfig: RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 10),
    timeoutDuration: Duration(seconds: 30),
    shouldRetry: (error) {
      // Only retry on network errors
      return error is PaginationNetworkException;
    },
  ),
);
```

### Dependencies
No new dependencies added. Phase 2 features use existing dependencies efficiently.

## [Unreleased]

### Planned Features
- ✅ ~~Dual pagination implementation with grouping support~~ (Completed in 0.0.2)
- ✅ ~~Network retry mechanism with exponential backoff~~ (Completed in 0.0.2)
- Comprehensive unit and integration tests
- Pull-to-refresh indicator integration (built-in widget support)
- Performance benchmarks and optimizations
- Example app with various use cases
- Video tutorials and documentation
- CI/CD pipeline setup
- Publication to pub.dev

---

For more information about this release, visit the [GitHub repository](https://github.com/GeniusSystems24/custom_pagination).
