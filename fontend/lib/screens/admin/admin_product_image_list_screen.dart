import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import 'admin_product_image_form_screen.dart';

class AdminProductImageListScreen extends StatefulWidget {
  final ProductModel product;
  final bool fromCreateFlow;

  const AdminProductImageListScreen({
    super.key,
    required this.product,
    this.fromCreateFlow = false,
  });

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
    if (result == true) setState(_loadImages);
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
    if (result == true) setState(_loadImages);
  }

  void _goToVariants() {
    Navigator.pushReplacementNamed(
      context,
      '/admin/products/variants',
      arguments: ProductRouteArgs(
        product: widget.product,
        fromCreateFlow: widget.fromCreateFlow,
      ),
    );
  }

  Future<void> _setAsMain(ProductImageModel image) async {
    try {
      await _productService.updateProductImage(
        imageId: image.imageId,
        imageUrl: image.imageUrl,
        isMain: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Main image updated')));
      setState(_loadImages);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _deleteImage(ProductImageModel image) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (confirm != true) return;

    try {
      await _productService.deleteProductImage(image.imageId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image deleted')));
      setState(_loadImages);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Widget _buildBody() {
    return FutureBuilder<List<ProductImageModel>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final images = snapshot.data ?? [];
        if (images.isEmpty) {
          return _EmptyState(onAdd: _goToCreate);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(_loadImages),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 800 ? 3 : 1,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: MediaQuery.sizeOf(context).width >= 800
                  ? 0.9
                  : 1.12,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return _ImageCard(
                image: image,
                onSetMain: image.isMain ? null : () => _setAsMain(image),
                onEdit: () => _goToEdit(image),
                onDelete: () => _deleteImage(image),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.fromCreateFlow
        ? 'Step 2: Add Images'
        : 'Images - ${widget.product.productName}';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _PageHeader(
                  title: title,
                  subtitle: widget.fromCreateFlow
                      ? 'Add at least one image, then continue to variants.'
                      : 'Upload and manage product images.',
                ),
              ),
              Expanded(child: _buildBody()),
              if (widget.fromCreateFlow)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _goToVariants,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next: Add Variants'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add image',
        onPressed: _goToCreate,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add image'),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final ProductImageModel image;
  final VoidCallback? onSetMain;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ImageCard({
    required this.image,
    required this.onSetMain,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  AppConfig.resolveImageUrl(image.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _ImageBadge(
                    label: image.isMain ? 'Main image' : 'Sub image',
                    main: image.isMain,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.imageUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onSetMain,
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Set main'),
                    ),
                    IconButton.outlined(
                      tooltip: 'Edit image',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton.outlined(
                      tooltip: 'Delete image',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final String label;
  final bool main;

  const _ImageBadge({required this.label, required this.main});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: main ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: main ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            const Text(
              'No images yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add at least one image before publishing this product.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add first image'),
            ),
          ],
        ),
      ),
    );
  }
}
