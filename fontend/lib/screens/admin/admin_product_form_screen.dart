import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  final bool createMode;

  const AdminProductFormScreen({
    super.key,
    this.product,
    this.createMode = false,
  });

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _manualImageUrlController =
      TextEditingController();
  final TextEditingController _variantSizeController = TextEditingController();
  final TextEditingController _variantColorController = TextEditingController();
  final TextEditingController _variantPriceController = TextEditingController();
  final TextEditingController _variantStockController = TextEditingController();
  final TextEditingController _variantSkuController = TextEditingController();

  late Future<List<CategoryModel>> _categoriesFuture;

  int? _selectedCategoryId;
  String _selectedGender = 'Unisex';
  bool _isActive = false;
  bool _isSubmitting = false;
  bool _newVariantActive = true;
  final List<_PendingImage> _pendingImages = [];
  final List<_PendingVariant> _pendingVariants = [];

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
    final product = widget.product;

    if (product != null) {
      _productNameController.text = product.productName;
      _descriptionController.text = product.description ?? '';
      _basePriceController.text = product.basePrice.toStringAsFixed(0);
      _brandController.text = product.brand ?? 'Adidas';
      _materialController.text = product.material ?? '';
      _selectedGender = _normalizeGender(product.gender);
      _selectedCategoryId = product.categoryId;
      _isActive = product.isActive;
    } else {
      _brandController.text = 'Adidas';
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _brandController.dispose();
    _materialController.dispose();
    _manualImageUrlController.dispose();
    _variantSizeController.dispose();
    _variantColorController.dispose();
    _variantPriceController.dispose();
    _variantStockController.dispose();
    _variantSkuController.dispose();
    super.dispose();
  }

  String _normalizeGender(String? value) {
    const genders = ['Unisex', 'Men', 'Women', 'Kids'];
    if (value == null || value.trim().isEmpty) return 'Unisex';
    return genders.contains(value) ? value : 'Unisex';
  }

  ProductModel _createdDraft(
    int productId, {
    int? imageCount,
    int? activeVariantCount,
    int? totalStock,
  }) {
    return ProductModel(
      productId: productId,
      productName: _productNameController.text.trim(),
      description: _descriptionController.text.trim(),
      basePrice: double.parse(_basePriceController.text.trim()),
      categoryId: _selectedCategoryId!,
      categoryName: null,
      brand: _brandController.text.trim(),
      gender: _selectedGender,
      material: _materialController.text.trim(),
      mainImageUrl: null,
      averageRating: 0,
      reviewCount: 0,
      isActive: false,
      imageCount: imageCount ?? _pendingImages.length,
      activeVariantCount:
          activeVariantCount ??
          _pendingVariants.where((variant) => variant.isActive).length,
      totalStock:
          totalStock ??
          _pendingVariants
              .where((variant) => variant.isActive)
              .fold(0, (sum, variant) => sum + variant.stockQuantity),
    );
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('selectCategory'))));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final productName = _productNameController.text.trim();
      final description = _descriptionController.text.trim();
      final basePrice = double.parse(_basePriceController.text.trim());
      final brand = _brandController.text.trim();
      final material = _materialController.text.trim();

      await _productService.updateProduct(
        productId: widget.product!.productId,
        productName: productName,
        description: description,
        basePrice: basePrice,
        categoryId: _selectedCategoryId!,
        brand: brand,
        gender: _selectedGender,
        material: material,
        isActive: _isActive,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product updated')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitCreate({required bool publish}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('selectCategory'))));
      return;
    }

    setState(() => _isSubmitting = true);

    int? productId;
    try {
      productId = await _productService.createProduct(
        productName: _productNameController.text.trim(),
        description: _descriptionController.text.trim(),
        basePrice: double.parse(_basePriceController.text.trim()),
        categoryId: _selectedCategoryId!,
        brand: _brandController.text.trim(),
        gender: _selectedGender,
        material: _materialController.text.trim(),
      );

      final saveResult = await _saveImagesAndVariants(productId);
      if (!mounted) return;

      final draftProduct = _createdDraft(
        productId,
        imageCount: saveResult.imageCount,
        activeVariantCount: saveResult.activeVariantCount,
        totalStock: saveResult.totalStock,
      );
      if (saveResult.hasFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product draft was created, but some images or variants failed to save.',
            ),
          ),
        );
        _goToCreatedProductEdit(draftProduct);
        return;
      }

      if (publish) {
        try {
          await _productService.publishProduct(productId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product published successfully')),
          );
          _goToProductList();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Product kept as draft. $e')));
          _goToCreatedProductEdit(draftProduct);
        }
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product draft saved')));
      _goToProductList();
    } catch (e) {
      if (!mounted) return;
      final message = productId == null
          ? 'Error: $e'
          : 'Product draft was created, but some images or variants failed to save.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      if (productId != null) {
        _goToCreatedProductEdit(_createdDraft(productId));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<_SaveRelatedResult> _saveImagesAndVariants(int productId) async {
    var hasFailure = false;
    var imageCount = 0;
    var activeVariantCount = 0;
    var totalStock = 0;

    for (var index = 0; index < _pendingImages.length; index++) {
      final image = _pendingImages[index];
      try {
        final isMain = image.isMain || index == 0;
        if (image.bytes != null && image.fileName != null) {
          await _productService.uploadProductImage(
            productId: productId,
            bytes: image.bytes!,
            fileName: image.fileName!,
            isMain: isMain,
          );
        } else if (image.imageUrl != null &&
            image.imageUrl!.trim().isNotEmpty) {
          await _productService.createProductImage(
            productId: productId,
            imageUrl: image.imageUrl!.trim(),
            isMain: isMain,
          );
        }
        imageCount++;
      } catch (_) {
        hasFailure = true;
      }
    }

    for (final variant in _pendingVariants) {
      try {
        await _productService.createVariant(
          productId: productId,
          size: variant.size,
          color: variant.color,
          price: variant.price,
          stockQuantity: variant.stockQuantity,
          sku: variant.sku,
          isActive: variant.isActive,
        );
        if (variant.isActive) {
          activeVariantCount++;
          totalStock += variant.stockQuantity;
        }
      } catch (_) {
        hasFailure = true;
      }
    }

    return _SaveRelatedResult(
      hasFailure: hasFailure,
      imageCount: imageCount,
      activeVariantCount: activeVariantCount,
      totalStock: totalStock,
    );
  }

  void _goToProductList() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/admin/products',
      (route) => false,
    );
  }

  void _goToCreatedProductEdit(ProductModel product) {
    Navigator.pushReplacementNamed(
      context,
      '/admin/products/edit',
      arguments: ProductRouteArgs(product: product),
    );
  }

  Future<void> _goToImages() async {
    final product = widget.product;
    if (product == null) return;
    await Navigator.pushNamed(
      context,
      '/admin/products/images',
      arguments: ProductRouteArgs(product: product),
    );
  }

  Future<void> _goToVariants() async {
    final product = widget.product;
    if (product == null) return;
    await Navigator.pushNamed(
      context,
      '/admin/products/variants',
      arguments: ProductRouteArgs(product: product),
    );
  }

  void _setActiveStatus(bool value) {
    final product = widget.product;
    if (!value || product == null) {
      setState(() => _isActive = value);
      return;
    }

    final missingImage = product.imageCount == 0;
    final missingVariant = product.activeVariantCount == 0;
    final outOfStock = product.totalStock <= 0;
    if (missingImage || missingVariant || outOfStock) {
      final missing = [
        if (missingImage) 'at least one image',
        if (missingVariant) 'at least one active variant',
        if (outOfStock) 'stock greater than 0',
      ].join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot publish yet: missing $missing.')),
      );
      return;
    }

    setState(() => _isActive = value);
  }

  Future<void> _chooseImages() async {
    final images = await _imagePicker.pickMultiImage();
    if (images.isEmpty) return;

    final pending = <_PendingImage>[];
    for (final image in images) {
      pending.add(
        _PendingImage(
          bytes: await image.readAsBytes(),
          fileName: image.name,
          isMain: _pendingImages.isEmpty && pending.isEmpty,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _pendingImages.addAll(pending));
  }

  void _addManualImageUrl() {
    final imageUrl = _manualImageUrlController.text.trim();
    if (imageUrl.isEmpty) return;
    if (!imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://') &&
        !imageUrl.startsWith('/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image URL must start with http://, https://, or /'),
        ),
      );
      return;
    }

    setState(() {
      _pendingImages.add(
        _PendingImage(imageUrl: imageUrl, isMain: _pendingImages.isEmpty),
      );
      _manualImageUrlController.clear();
    });
  }

  void _removePendingImage(int index) {
    setState(() {
      final wasMain = _pendingImages[index].isMain;
      _pendingImages.removeAt(index);
      if (wasMain && _pendingImages.isNotEmpty) {
        _pendingImages[0] = _pendingImages[0].copyWith(isMain: true);
      }
    });
  }

  void _setPendingMainImage(int index) {
    setState(() {
      for (var i = 0; i < _pendingImages.length; i++) {
        _pendingImages[i] = _pendingImages[i].copyWith(isMain: i == index);
      }
    });
  }

  void _addPendingVariant() {
    final size = _variantSizeController.text.trim();
    final color = _variantColorController.text.trim();
    final price = double.tryParse(_variantPriceController.text.trim());
    final stock = int.tryParse(_variantStockController.text.trim());
    final sku = _variantSkuController.text.trim();

    if (size.isEmpty || color.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variant size, color and price are required.'),
        ),
      );
      return;
    }

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Variant stock must be 0 or greater.')),
      );
      return;
    }

    final duplicate = _pendingVariants.any(
      (variant) =>
          variant.size.toLowerCase() == size.toLowerCase() &&
          variant.color.toLowerCase() == color.toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Variant size and color already added.')),
      );
      return;
    }

    setState(() {
      _pendingVariants.add(
        _PendingVariant(
          size: size,
          color: color,
          price: price,
          stockQuantity: stock,
          sku: sku.isEmpty ? null : sku,
          isActive: _newVariantActive,
        ),
      );
      _variantSizeController.clear();
      _variantColorController.clear();
      _variantPriceController.clear();
      _variantStockController.clear();
      _variantSkuController.clear();
      _newVariantActive = true;
    });
  }

  void _removePendingVariant(int index) {
    setState(() => _pendingVariants.removeAt(index));
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Failed to load categories: ${snapshot.error}');
        }

        final categories = snapshot.data ?? [];
        return DropdownButtonFormField<int>(
          initialValue: _selectedCategoryId,
          decoration: const InputDecoration(labelText: 'Category'),
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.categoryId,
              child: Text(category.categoryName),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategoryId = value),
          validator: (value) => value == null ? 'Category is required' : null,
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (requiredField && text.isEmpty) return '$label is required';
        if (label == 'Base price') {
          final price = double.tryParse(text);
          if (price == null || price <= 0) {
            return 'Base price must be greater than 0';
          }
        }
        return null;
      },
    );
  }

  Widget _buildCreateImagesSection() {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Images'),
          const Text(
            'Optional for draft. Required before publishing.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _chooseImages,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Choose images'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualImageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL or static path',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _addManualImageUrl,
                icon: const Icon(Icons.add_link),
                label: const Text('Add URL'),
              ),
            ],
          ),
          if (_pendingImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 3 : 2;
                return GridView.builder(
                  itemCount: _pendingImages.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .9,
                  ),
                  itemBuilder: (context, index) {
                    final image = _pendingImages[index];
                    return _PendingImageCard(
                      image: image,
                      onSetMain: () => _setPendingMainImage(index),
                      onRemove: () => _removePendingImage(index),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateVariantsSection() {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Variants'),
          const Text(
            'Optional for draft. Publishing requires at least one active variant with stock.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final fields = [
                TextField(
                  controller: _variantSizeController,
                  decoration: const InputDecoration(labelText: 'Size'),
                ),
                TextField(
                  controller: _variantColorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                TextField(
                  controller: _variantPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: _variantStockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                ),
              ];

              if (!wide) {
                return Column(
                  children: [
                    for (final field in fields) ...[
                      field,
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 10),
                      Expanded(child: fields[1]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: fields[2]),
                      const SizedBox(width: 10),
                      Expanded(child: fields[3]),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _variantSkuController,
            decoration: const InputDecoration(labelText: 'SKU'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active variant'),
            value: _newVariantActive,
            onChanged: (value) => setState(() => _newVariantActive = value),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _addPendingVariant,
              icon: const Icon(Icons.add),
              label: const Text('Add variant'),
            ),
          ),
          if (_pendingVariants.isNotEmpty) ...[
            const SizedBox(height: 14),
            ..._pendingVariants.asMap().entries.map((entry) {
              final index = entry.key;
              final variant = entry.value;
              return _PendingVariantTile(
                variant: variant,
                onRemove: () => _removePendingVariant(index),
              );
            }),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final missingImage = product != null && product.imageCount == 0;
    final missingVariant = product != null && product.activeVariantCount == 0;
    final outOfStock = product != null && product.totalStock <= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit product' : 'Create product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AdminPageHeader(
                  title: isEditMode ? 'Edit product' : 'Create product',
                  subtitle: isEditMode
                      ? 'Update product information and manage publishing readiness.'
                      : 'Create a draft product, then add images and variants before publishing.',
                ),
                const SizedBox(height: 16),
                if (!isEditMode) ...[
                  const _ProductFlowStepper(activeStep: 1),
                  const SizedBox(height: 16),
                ],
                if (isEditMode && product != null) ...[
                  _StatusCard(
                    isActive: _isActive,
                    missingImage: missingImage,
                    missingVariant: missingVariant,
                    outOfStock: outOfStock,
                    onChanged: _setActiveStatus,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _goToImages,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Manage Images'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _goToVariants,
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Manage Variants'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                _FormCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Basic information'),
                        if (!isEditMode) ...[
                          const _DraftNote(),
                          const SizedBox(height: 18),
                        ],
                        _buildTextField(
                          controller: _productNameController,
                          label: 'Product name',
                          requiredField: true,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('Pricing & category'),
                        _buildTextField(
                          controller: _basePriceController,
                          label: 'Base price',
                          requiredField: true,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _buildCategoryDropdown(),
                        const SizedBox(height: 22),
                        const _SectionTitle('Product attributes'),
                        _buildTextField(
                          controller: _brandController,
                          label: 'Brand',
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                          items: const ['Unisex', 'Men', 'Women', 'Kids']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _materialController,
                          label: 'Material',
                        ),
                        const SizedBox(height: 26),
                        if (isEditMode)
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
                                  onPressed: _isSubmitting ? null : _submitEdit,
                                  child: _isSubmitting
                                      ? const CircularProgressIndicator()
                                      : const Text('Save changes'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isEditMode) ...[
                  const SizedBox(height: 16),
                  _buildCreateImagesSection(),
                  const SizedBox(height: 16),
                  _buildCreateVariantsSection(),
                  const SizedBox(height: 16),
                  _CreateActionsCard(
                    isSubmitting: _isSubmitting,
                    onSaveDraft: () => _submitCreate(publish: false),
                    onSavePublish: () => _submitCreate(publish: true),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AdminPageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _CreateActionsCard extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSaveDraft;
  final VoidCallback onSavePublish;

  const _CreateActionsCard({
    required this.isSubmitting,
    required this.onSaveDraft,
    required this.onSavePublish,
  });

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSubmitting ? null : onSaveDraft,
              child: const Text('Save as draft'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSavePublish,
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Save and publish'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingImage {
  final Uint8List? bytes;
  final String? fileName;
  final String? imageUrl;
  final bool isMain;

  const _PendingImage({
    this.bytes,
    this.fileName,
    this.imageUrl,
    required this.isMain,
  });

  _PendingImage copyWith({bool? isMain}) {
    return _PendingImage(
      bytes: bytes,
      fileName: fileName,
      imageUrl: imageUrl,
      isMain: isMain ?? this.isMain,
    );
  }
}

class _PendingVariant {
  final String size;
  final String color;
  final double price;
  final int stockQuantity;
  final String? sku;
  final bool isActive;

  const _PendingVariant({
    required this.size,
    required this.color,
    required this.price,
    required this.stockQuantity,
    this.sku,
    required this.isActive,
  });
}

class _SaveRelatedResult {
  final bool hasFailure;
  final int imageCount;
  final int activeVariantCount;
  final int totalStock;

  const _SaveRelatedResult({
    required this.hasFailure,
    required this.imageCount,
    required this.activeVariantCount,
    required this.totalStock,
  });
}

class _PendingImageCard extends StatelessWidget {
  final _PendingImage image;
  final VoidCallback onSetMain;
  final VoidCallback onRemove;

  const _PendingImageCard({
    required this.image,
    required this.onSetMain,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = image.bytes;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bytes != null)
                  Image.memory(bytes, fit: BoxFit.cover)
                else
                  Image.network(
                    AppConfig.resolveImageUrl(image.imageUrl ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                if (image.isMain)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Main',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: image.isMain ? null : onSetMain,
                    child: const Text('Set main'),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.outlined(
                  tooltip: 'Remove image',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingVariantTile extends StatelessWidget {
  final _PendingVariant variant;
  final VoidCallback onRemove;

  const _PendingVariantTile({required this.variant, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text('Size ${variant.size}')),
                Chip(label: Text(variant.color)),
                Chip(label: Text('Stock ${variant.stockQuantity}')),
                Chip(label: Text(variant.isActive ? 'Active' : 'Inactive')),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove variant',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _ProductFlowStepper extends StatelessWidget {
  final int activeStep;

  const _ProductFlowStepper({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (1, 'Basic Info'),
      (2, 'Images'),
      (3, 'Variants'),
      (4, 'Publish'),
    ];

    return _FormCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: steps.map((step) {
          final active = step.$1 == activeStep;
          final completed = step.$1 < activeStep;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: active ? Colors.black : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: active ? Colors.black : AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completed ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: active ? Colors.white : AppColors.muted,
                ),
                const SizedBox(width: 8),
                Text(
                  'Step ${step.$1}: ${step.$2}',
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DraftNote extends StatelessWidget {
  const _DraftNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE0A3)),
      ),
      child: const Text(
        'This product will be saved as Draft. It will not be visible to customers until images and variants are added and the product is published.',
        style: TextStyle(
          color: Color(0xFF4A3600),
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isActive;
  final bool missingImage;
  final bool missingVariant;
  final bool outOfStock;
  final ValueChanged<bool> onChanged;

  const _StatusCard({
    required this.isActive,
    required this.missingImage,
    required this.missingVariant,
    required this.outOfStock,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isActive ? 'Active product' : 'Draft product',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch(value: isActive, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HealthBadge(
                label: isActive ? 'Active' : 'Draft',
                attention: !isActive,
              ),
              if (missingImage)
                const _HealthBadge(label: 'Missing image', attention: true),
              if (missingVariant)
                const _HealthBadge(label: 'Missing variant', attention: true),
              if (outOfStock)
                const _HealthBadge(label: 'Out of stock', attention: true),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to publish?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          _ChecklistItem(label: 'Basic information completed', done: true),
          _ChecklistItem(label: 'At least one image', done: !missingImage),
          _ChecklistItem(
            label: 'At least one active variant',
            done: !missingVariant,
          ),
          _ChecklistItem(label: 'Stock available', done: !outOfStock),
          if (missingImage || missingVariant || outOfStock) ...[
            const SizedBox(height: 8),
            const Text(
              'Publishing will be rejected until every checklist item is complete.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool done;

  const _ChecklistItem({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? const Color(0xFF1F7A4D) : AppColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: done ? AppColors.black : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final String label;
  final bool attention;

  const _HealthBadge({required this.label, required this.attention});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: attention ? const Color(0xFFFFF2D8) : AppColors.surface,
      labelStyle: TextStyle(
        color: attention ? const Color(0xFF805C00) : AppColors.black,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
