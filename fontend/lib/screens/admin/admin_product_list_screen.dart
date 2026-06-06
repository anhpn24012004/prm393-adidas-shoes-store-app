import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'admin_product_form_screen.dart';
import 'admin_variant_list_screen.dart';
import 'admin_product_image_list_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final ProductService _productService = ProductService();

  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = _productService.getProducts();
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product'),
          content: Text(
            'Are you sure you want to delete "${product.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _productService.deleteProduct(product.productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );

      setState(() {
        _loadProducts();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminProductFormScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        _loadProducts();
      });
    }
  }

  Future<void> _goToEdit(ProductModel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(product: product),
      ),
    );

    if (result == true) {
      setState(() {
        _loadProducts();
      });
    }
  }

  Future<void> _goToVariants(ProductModel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminVariantListScreen(product: product),
      ),
    );

    setState(() {
      _loadProducts();
    });
  }

  Future<void> _goToImages(ProductModel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductImageListScreen(product: product),
      ),
    );

    setState(() {
      _loadProducts();
    });
  }

  void _goToCategories() {
    Navigator.pushNamed(context, '/admin/categories');
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image),
      );
    }

    return Image.network(
      imageUrl,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(product.mainImageUrl),
        ),
        title: Text(
          product.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${formatPrice(product.basePrice)}\n'
              '${product.categoryName ?? 'No category'}\n'
              'Status: ${product.isActive ? 'Active' : 'Inactive'}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Manage images',
              icon: const Icon(Icons.image),
              onPressed: () => _goToImages(product),
            ),
            IconButton(
              tooltip: 'Manage variants',
              icon: const Icon(Icons.inventory_2),
              onPressed: () => _goToVariants(product),
            ),
            IconButton(
              tooltip: 'Edit product',
              icon: const Icon(Icons.edit),
              onPressed: () => _goToEdit(product),
            ),
            IconButton(
              tooltip: 'Delete product',
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteProduct(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Text('No products found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadProducts();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductItem(products[index]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Product Management'),
        actions: [
          IconButton(
            tooltip: 'Manage Categories',
            icon: const Icon(Icons.category),
            onPressed: _goToCategories,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}