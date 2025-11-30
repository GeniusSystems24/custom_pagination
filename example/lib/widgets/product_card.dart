import 'package:flutter/material.dart';
import '../models/product.dart';
import 'highlighted_text.dart';

/// A reusable product card widget with optional search query highlighting
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.searchQuery = '',
    this.onTap,
  });

  final Product product;
  final String searchQuery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
      ),
      title: HighlightedText.single(
        text: product.name,
        searchQuery: searchQuery,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            product.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.category,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      trailing: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}
