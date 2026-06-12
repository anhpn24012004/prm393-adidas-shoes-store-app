import 'package:flutter/material.dart';

import '../../models/product_detail_model.dart';
import '../../services/product_service.dart';

class AdminProductImageFormScreen extends StatefulWidget {
  final int productId;
  final ProductImageModel? image;

  const AdminProductImageFormScreen({
    super.key,
    required this.productId,
    this.image,
  });

  @override
  State<AdminProductImageFormScreen> createState() =>
      _AdminProductImageFormScreenState();
}

class _AdminProductImageFormScreenState
    extends State<AdminProductImageFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();

  final TextEditingController _imageUrlController = TextEditingController();

  bool _isMain = false;
  bool _isSubmitting = false;

  bool get isEditMode => widget.image != null;

  @override
  void initState() {
    super.initState();

    final image = widget.image;

    if (image != null) {
      _imageUrlController.text = image.imageUrl;
      _isMain = image.isMain;
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imageUrl = _imageUrlController.text.trim();

      if (isEditMode) {
        await _productService.updateProductImage(
          imageId: widget.image!.imageId,
          imageUrl: imageUrl,
          isMain: _isMain,
        );
      } else {
        await _productService.createProductImage(
          productId: widget.productId,
          imageUrl: imageUrl,
          isMain: _isMain,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Image updated successfully'
                : 'Image created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildPreview() {
    final imageUrl = _imageUrlController.text.trim();

    if (imageUrl.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 64)),
      );
    }

    return Image.network(
      imageUrl,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 220,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 64)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit Product Image' : 'Create Product Image';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPreview(),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'Image URL is required';
                      }

                      if (!text.startsWith('http://') &&
                          !text.startsWith('https://')) {
                        return 'Image URL must start with http:// or https://';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Set as main image'),
                    subtitle: const Text(
                      'If enabled, old main image will be changed to sub image.',
                    ),
                    value: _isMain,
                    onChanged: (value) {
                      setState(() {
                        _isMain = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : Text(isEditMode ? 'Update Image' : 'Create Image'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
