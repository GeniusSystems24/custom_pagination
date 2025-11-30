part of '../../pagination.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.exception,
    this.onRetry,
    this.customBuilder,
  });

  final Exception exception;
  final VoidCallback? onRetry;

  /// Custom builder for complete control over error UI
  /// If provided, this takes precedence over the default error display
  final Widget Function(BuildContext context, Exception exception, VoidCallback? onRetry)? customBuilder;

  @override
  Widget build(BuildContext context) {
    // Use custom builder if provided
    if (customBuilder != null) {
      return customBuilder!(context, exception, onRetry);
    }

    // Default error display with retry button
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error occurred',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              exception.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
