import 'package:flutter/material.dart';

import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'admin_product_image_form_screen.dart';

class AdminProductImageListScreen extends StatefulWidget {
  final ProductModel product;

  const AdminProductImageListScreen({super.key, required this.product});

  @override
  State<AdminProductImageListScreen> createState() =>
      _AdminProductImageListScreenState();
}

class _AdminProductImageListScreenState
    extends State<AdminProductImageListScreen> {
  final ProductService _productService = ProductService();

  late Future<List<ProductImageModel>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    _imagesFuture = _productService.getImagesByProduct(
      widget.product.productId,
    );
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminProductImageFormScreen(productId: widget.product.productId),
      ),
    );

    if (result == true) {
      setState(() {
        _loadImages();
      });
    }
  }

  Future<void> _goToEdit(ProductImageModel image) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductImageFormScreen(
          productId: widget.product.productId,
          image: image,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _loadImages();
      });
    }
  }

  Future<void> _deleteImage(ProductImageModel image) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete image'),
          content: const Text('Are you sure you want to delete this image?'),
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
      await _productService.deleteProductImage(image.imageId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );

      setState(() {
        _loadImages();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildPreview(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image),
      );
    }

    return Image.network(
      imageUrl,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 90,
          height: 90,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  Widget _buildImageItem(ProductImageModel image) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildPreview(image.imageUrl),
        ),
        title: Text(
          image.imageUrl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          image.isMain ? 'Main image' : 'Sub image',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: image.isMain ? Colors.green : Colors.grey.shade700,
          ),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit image',
              icon: const Icon(Icons.edit),
              onPressed: () => _goToEdit(image),
            ),
            IconButton(
              tooltip: 'Delete image',
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteImage(image),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<ProductImageModel>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final images = snapshot.data ?? [];

        if (images.isEmpty) {
          return const Center(child: Text('No images found'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadImages();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildImageItem(images[index]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Images - ${widget.product.productName}')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
