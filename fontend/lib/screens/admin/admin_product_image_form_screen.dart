import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_config.dart';
import '../../models/product_detail_model.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
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

  Future<void> _chooseImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _selectedImageBytes = bytes;
      _selectedFileName = image.name;
    });
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedFileName = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final imageUrl = _imageUrlController.text.trim();
      if (isEditMode) {
        await _productService.updateProductImage(
          imageId: widget.image!.imageId,
          imageUrl: imageUrl,
          isMain: _isMain,
        );
      } else if (_selectedImageBytes != null && _selectedFileName != null) {
        await _productService.uploadProductImage(
          productId: widget.productId,
          bytes: _selectedImageBytes!,
          fileName: _selectedFileName!,
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
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildPreview() {
    final selectedBytes = _selectedImageBytes;
    if (selectedBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          selectedBytes,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) {
      return Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(child: Icon(Icons.image_outlined, size: 58)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        AppConfig.resolveImageUrl(imageUrl),
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: 260,
          width: double.infinity,
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 58),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit image' : 'Add image';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose an image file to upload, or paste an image URL/static path manually.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 18),
                    _buildPreview(),
                    const SizedBox(height: 18),
                    if (!isEditMode) ...[
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _chooseImage,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(
                              _selectedImageBytes == null
                                  ? 'Choose image'
                                  : 'Choose another image',
                            ),
                          ),
                          if (_selectedImageBytes != null)
                            OutlinedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : _clearSelectedImage,
                              icon: const Icon(Icons.close),
                              label: const Text('Use image URL instead'),
                            ),
                        ],
                      ),
                      if (_selectedFileName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedFileName!,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                    ],
                    TextFormField(
                      controller: _imageUrlController,
                      enabled: _selectedImageBytes == null || isEditMode,
                      decoration: InputDecoration(
                        labelText: isEditMode
                            ? 'Image URL'
                            : 'Image URL or static path',
                        helperText: isEditMode
                            ? null
                            : 'Optional when an image file is selected.',
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (!isEditMode && _selectedImageBytes != null) {
                          return null;
                        }
                        if (text.isEmpty) return 'Image URL is required';
                        if (!text.startsWith('http://') &&
                            !text.startsWith('https://') &&
                            !text.startsWith('/')) {
                          return 'Image URL must start with http://, https://, or /';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Main image',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Shown as the primary product image in lists and detail pages.',
                      ),
                      value: _isMain,
                      onChanged: (value) => setState(() => _isMain = value),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const CircularProgressIndicator()
                                : Text(isEditMode ? 'Save image' : 'Add image'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
