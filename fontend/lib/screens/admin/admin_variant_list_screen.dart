import 'package:flutter/material.dart';

import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'admin_variant_form_screen.dart';

class AdminVariantListScreen extends StatefulWidget {
  final ProductModel product;

  const AdminVariantListScreen({
    super.key,
    required this.product,
  });

  @override
  State<AdminVariantListScreen> createState() => _AdminVariantListScreenState();
}

class _AdminVariantListScreenState extends State<AdminVariantListScreen> {
  final ProductService _productService = ProductService();

  late Future<List<ProductVariantModel>> _variantsFuture;

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  void _loadVariants() {
    _variantsFuture =
        _productService.getVariantsByProduct(widget.product.productId);
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminVariantFormScreen(
          productId: widget.product.productId,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _loadVariants();
      });
    }
  }

  Future<void> _goToEdit(ProductVariantModel variant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminVariantFormScreen(
          productId: widget.product.productId,
          variant: variant,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _loadVariants();
      });
    }
  }

  Future<void> _deleteVariant(ProductVariantModel variant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete variant'),
          content: Text(
            'Delete variant ${variant.size} - ${variant.color}?',
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
      await _productService.deleteVariant(variant.variantId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variant deleted successfully'),
        ),
      );

      setState(() {
        _loadVariants();
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

  Widget _buildVariantItem(ProductVariantModel variant) {
    return Card(
      child: ListTile(
        title: Text(
          '${variant.size} - ${variant.color}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Price: ${formatPrice(variant.price)}\n'
              'Stock: ${variant.stockQuantity}\n'
              'SKU: ${variant.sku ?? 'N/A'}\n'
              'Status: ${variant.isActive ? 'Active' : 'Inactive'}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit variant',
              icon: const Icon(Icons.edit),
              onPressed: () => _goToEdit(variant),
            ),
            IconButton(
              tooltip: 'Delete variant',
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteVariant(variant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<ProductVariantModel>>(
      future: _variantsFuture,
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

        final variants = snapshot.data ?? [];

        if (variants.isEmpty) {
          return const Center(
            child: Text('No variants found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadVariants();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: variants.length,
            itemBuilder: (context, index) {
              return _buildVariantItem(variants[index]);
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
        title: Text('Variants - ${widget.product.productName}'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}