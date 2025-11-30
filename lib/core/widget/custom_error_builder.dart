part of '../../pagination.dart';

/// A customizable error widget builder for pagination errors.
///
/// Provides pre-built error UI styles that can be used with error builders
/// in pagination widgets.
///
/// ## Example Usage
///
/// ```dart
/// SmartPaginatedListView<Product>(
///   request: PaginationRequest(page: 1, pageSize: 20),
///   provider: PaginationProvider.future(fetchProducts),
///   childBuilder: (context, product, index) => ProductCard(product: product),
///   firstPageErrorBuilder: (context, error, retry) {
///     return CustomErrorBuilder.material(
///       context: context,
///       error: error,
///       onRetry: retry,
///       title: 'Failed to load products',
///       message: 'Please check your internet connection',
///     );
///   },
///   loadMoreErrorBuilder: (context, error, retry) {
///     return CustomErrorBuilder.compact(
///       context: context,
///       error: error,
///       onRetry: retry,
///     );
///   },
/// )
/// ```
class CustomErrorBuilder {
  /// Creates a Material Design style error widget with full details
  ///
  /// Best suited for first page errors where you have full screen space
  static Widget material({
    required BuildContext context,
    required Exception error,
    required VoidCallback onRetry,
    String? title,
    String? message,
    IconData? icon,
    Color? iconColor,
    String? retryButtonText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: iconColor ?? Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? 'Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a compact error widget for inline errors (like load more errors)
  ///
  /// Best suited for bottom loading errors where space is limited
  static Widget compact({
    required BuildContext context,
    required Exception error,
    required VoidCallback onRetry,
    String? message,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: textColor ?? Colors.red[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Failed to load more items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor ?? Colors.red[700],
                  ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(
                color: textColor ?? Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a minimal error widget with just a message and retry icon button
  ///
  /// Best suited for very limited space scenarios
  static Widget minimal({
    required BuildContext context,
    required Exception error,
    required VoidCallback onRetry,
    String? message,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message ?? 'Error occurred',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            iconSize: 20,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Creates a custom error widget with complete control
  ///
  /// Use this when you need a specific layout or design
  static Widget custom({
    required BuildContext context,
    required Exception error,
    required VoidCallback onRetry,
    required Widget Function(
      BuildContext context,
      Exception error,
      VoidCallback onRetry,
    ) builder,
  }) {
    return builder(context, error, onRetry);
  }

  /// Creates a card-style error widget with shadow and rounded corners
  ///
  /// Good for grid views or when you want a distinct error card
  static Widget card({
    required BuildContext context,
    required Exception error,
    required VoidCallback onRetry,
    String? title,
    String? message,
    double? elevation,
  }) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: elevation ?? 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                title ?? 'Error Loading Data',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message ?? 'An error occurred while loading the data.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a snackbar-style error widget that appears at the bottom
  ///
  /// Best for non-intrusive error messages that don't block content
  static Widget snackbar({
    required BuildContext context,
    required Exception error,
    required VoidCallback onRetry,
    String? message,
    Color? backgroundColor,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message ?? 'Failed to load',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
