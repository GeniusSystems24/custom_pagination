import 'package:flutter/material.dart';
import 'package:custom_pagination/pagination.dart';
import '../../models/product.dart';
import '../../services/mock_api_service.dart';

/// Example of programmatic scrolling to items or indices
class ScrollControlScreen extends StatefulWidget {
  const ScrollControlScreen({super.key});

  @override
  State<ScrollControlScreen> createState() => _ScrollControlScreenState();
}

class _ScrollControlScreenState extends State<ScrollControlScreen> {
  late SmartPaginationController<Product> _controller;
  final TextEditingController _indexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Create a cubit and wrap it in a controller
    final cubit = SmartPaginationCubit<Product>(
      request: const PaginationRequest(page: 1, pageSize: 100),
      provider: PaginationProvider.future(
        (request) => MockApiService.fetchProducts(request),
      ),
    );

    _controller = SmartPaginationController(
      cubit: cubit,
      estimatedItemHeight: 80,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _indexController.dispose();
    super.dispose();
  }

  Future<void> _scrollToIndex(int index) async {
    final success = await _controller.scrollToIndex(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.5, // Center in viewport
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Scrolled to item #${index + 1}'
                : 'Could not scroll to item #${index + 1}',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Control'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.keyboard_arrow_down, color: Colors.indigo),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Programmatically scroll to any item or index. '
                    'Perfect for search results, notifications, or deep links.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _scrollToIndex(0),
                        icon: const Icon(Icons.vertical_align_top, size: 18),
                        label: const Text('Top'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _scrollToIndex(24),
                        icon: const Icon(Icons.vertical_align_center, size: 18),
                        label: const Text('Middle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _scrollToIndex(49),
                        icon: const Icon(Icons.vertical_align_bottom, size: 18),
                        label: const Text('Bottom'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jump to Index',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _indexController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter index (0-99)',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _indexController.clear(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final index = int.tryParse(_indexController.text);
                        if (index != null && index >= 0) {
                          _scrollToIndex(index);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid index'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Go'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Product List
          Expanded(
            child: SmartPagination<Product>.listView(
              cubit: _controller.cubit,
              itemBuilder: (context, items, index) {
                return _buildProductCard(items[index], index);
              },
              separator: const Divider(height: 1),
              emptyWidget: const Center(
                child: Text('No products'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on item #${index + 1}: ${product.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Index Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _scrollToIndex(index),
                        icon: const Icon(Icons.gps_fixed, size: 14),
                        label: const Text(
                          'Scroll Here',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
