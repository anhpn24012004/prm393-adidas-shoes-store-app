import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _bulkStockController = TextEditingController();

  late Future<List<CategoryModel>> _categoriesFuture;

  int? _selectedCategoryId;
  String _selectedGender = 'Unisex';
  bool _isActive = false;
  bool _isSubmitting = false;
  bool _isLoadingVariants = false;
  final List<_PendingImage> _pendingImages = [];
  final List<_PendingVariant> _pendingVariants = [];
  final Map<String, _PendingVariant> _variantCache = {};
  final List<_ClassificationGroupDraft> _classificationGroups = [];
  bool _bulkStockHadNegativeInput = false;
  int _draftId = 0;

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
      _loadEditClassifications(product.productId);
    } else {
      _brandController.text = 'Adidas';
      _classificationGroups.add(_createEmptyGroup());
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
    _bulkStockController.dispose();
    for (final group in _classificationGroups) {
      group.dispose();
    }
    for (final variant in _pendingVariants) {
      variant.dispose();
    }
    for (final variant in _variantCache.values) {
      variant.dispose();
    }
    super.dispose();
  }

  String _normalizeGender(String? value) {
    const genders = ['Unisex', 'Men', 'Women', 'Kids'];
    if (value == null || value.trim().isEmpty) return 'Unisex';
    return genders.contains(value) ? value : 'Unisex';
  }

  int _nextDraftId() => ++_draftId;

  _ClassificationGroupDraft _createEmptyGroup({String name = ''}) {
    return _ClassificationGroupDraft(
      id: _nextDraftId(),
      name: name,
      options: [_ClassificationOptionDraft(id: _nextDraftId())],
    );
  }

  Future<void> _loadEditClassifications(int productId) async {
    setState(() => _isLoadingVariants = true);
    try {
      final data = await _productService.getProductClassifications(productId);
      if (!mounted) return;
      setState(() {
        for (final group in _classificationGroups) {
          group.dispose();
        }
        for (final variant in _pendingVariants) {
          variant.dispose();
        }
        for (final variant in _variantCache.values) {
          variant.dispose();
        }
        _classificationGroups.clear();
        _pendingVariants.clear();
        _variantCache.clear();

        for (final sourceGroup in data.classificationGroups) {
          final group = _ClassificationGroupDraft(
            id: _nextDraftId(),
            name: sourceGroup.name,
            options: sourceGroup.options
                .map(
                  (option) => _ClassificationOptionDraft(
                    id: _nextDraftId(),
                    name: option.name,
                    description: option.description ?? '',
                    image: option.imageUrl == null
                        ? null
                        : _PendingColorImage(imageUrl: option.imageUrl),
                  ),
                )
                .toList(),
          );
          group.options.add(_ClassificationOptionDraft(id: _nextDraftId()));
          _classificationGroups.add(group);
        }
        if (_classificationGroups.isEmpty) {
          _classificationGroups.add(_createEmptyGroup(name: 'Size'));
        }

        for (final sourceVariant in data.variants) {
          final values = sourceVariant.optionValues;
          if (values.length != _classificationGroups.length) continue;
          final optionIds = <int>[];
          var valid = true;
          for (var groupIndex = 0; groupIndex < values.length; groupIndex++) {
            _ClassificationOptionDraft? matchedOption;
            for (final candidate
                in _classificationGroups[groupIndex].filledOptions) {
              if (candidate.name.trim().toLowerCase() ==
                  values[groupIndex].trim().toLowerCase()) {
                matchedOption = candidate;
                break;
              }
            }
            if (matchedOption == null) {
              valid = false;
              break;
            }
            optionIds.add(matchedOption.id);
          }
          if (!valid) continue;
          _pendingVariants.add(
            _PendingVariant(
              variantId: sourceVariant.variantId,
              combinationKey: _combinationKey(optionIds),
              optionIds: optionIds,
              optionValues: values,
              price: sourceVariant.price,
              stockQuantity: sourceVariant.stockQuantity,
              sku: sourceVariant.sku,
              isActive: sourceVariant.isActive,
            ),
          );
        }
        _regenerateVariants(notify: false);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product variants: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingVariants = false);
    }
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
    if (!_validateClassifications()) return;

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

      await _saveEditVariants(widget.product!.productId);

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
    if (!_validateClassifications()) return;

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

    try {
      imageCount += await _persistClassificationImages(productId);
      await _syncClassifications(productId);
      activeVariantCount = _pendingVariants
          .where((variant) => variant.isActive)
          .length;
      totalStock = _pendingVariants
          .where((variant) => variant.isActive)
          .fold(0, (sum, variant) => sum + variant.stockQuantity);
    } catch (_) {
      hasFailure = true;
    }

    return _SaveRelatedResult(
      hasFailure: hasFailure,
      imageCount: imageCount,
      activeVariantCount: activeVariantCount,
      totalStock: totalStock,
    );
  }

  Future<int> _persistClassificationImages(int productId) async {
    if (_classificationGroups.isEmpty ||
        !_isColorGroup(_classificationGroups.first.name)) {
      return 0;
    }

    var uploadedCount = 0;
    for (final option in _classificationGroups.first.filledOptions) {
      final image = option.image;
      if (image?.bytes == null || image?.fileName == null) continue;
      final uploaded = await _productService.uploadProductImage(
        productId: productId,
        bytes: image!.bytes!,
        fileName: image.fileName!,
        isMain: false,
      );
      option.image = _PendingColorImage(imageUrl: uploaded.imageUrl);
      uploadedCount++;
    }
    return uploadedCount;
  }

  Future<void> _saveEditVariants(int productId) async {
    await _persistClassificationImages(productId);
    await _syncClassifications(productId);
  }

  Future<void> _syncClassifications(int productId) async {
    await _productService.syncProductClassifications(
      productId: productId,
      classificationGroups: _classificationGroups
          .asMap()
          .entries
          .map(
            (entry) => {
              'name': entry.value.name.trim(),
              'sortOrder': entry.key,
              'options': entry.value.filledOptions
                  .asMap()
                  .entries
                  .map(
                    (optionEntry) => {
                      'name': optionEntry.value.name.trim(),
                      'description': optionEntry.value.description.trim(),
                      'imageUrl': optionEntry.value.image?.imageUrl,
                      'sortOrder': optionEntry.key,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      variants: _pendingVariants
          .map(
            (variant) => {
              'variantId': variant.variantId,
              'optionValues': variant.optionValues,
              'price': variant.price,
              'stockQuantity': variant.stockQuantity,
              'sku': variant.sku,
              'isActive': variant.isActive,
              'imageUrl': _variantImageUrl(variant),
            },
          )
          .toList(),
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

  bool _isColorGroup(String name) {
    final normalized = name.trim().toLowerCase();
    return normalized.contains('color') ||
        normalized.contains('màu') ||
        normalized.contains('mau');
  }

  String _combinationKey(Iterable<int> optionIds) => optionIds.join('|');

  void _addClassificationGroup() {
    if (_classificationGroups.length >= 2) return;
    setState(() {
      _classificationGroups.add(_createEmptyGroup());
      _regenerateVariants(notify: false);
    });
  }

  void _removeClassificationGroup(int groupIndex) {
    if (_classificationGroups.length == 1) return;
    setState(() {
      _classificationGroups.removeAt(groupIndex).dispose();
      _regenerateVariants(notify: false);
    });
  }

  void _onGroupNameChanged() => setState(() {});

  void _onOptionChanged(int groupIndex, int optionIndex) {
    setState(() {
      final group = _classificationGroups[groupIndex];
      if (optionIndex == group.options.length - 1 &&
          group.options[optionIndex].name.trim().isNotEmpty) {
        group.options.add(_ClassificationOptionDraft(id: _nextDraftId()));
      }
      _regenerateVariants(notify: false);
    });
  }

  void _removeClassificationOption(int groupIndex, int optionIndex) {
    setState(() {
      final group = _classificationGroups[groupIndex];
      group.options.removeAt(optionIndex).dispose();
      if (group.options.isEmpty || group.options.last.name.trim().isNotEmpty) {
        group.options.add(_ClassificationOptionDraft(id: _nextDraftId()));
      }
      _regenerateVariants(notify: false);
    });
  }

  void _reorderClassificationOption(
    int groupIndex,
    int sourceOptionId,
    int targetOptionId,
  ) {
    setState(() {
      final options = _classificationGroups[groupIndex].options;
      final sourceIndex = options.indexWhere(
        (item) => item.id == sourceOptionId,
      );
      final targetIndex = options.indexWhere(
        (item) => item.id == targetOptionId,
      );
      if (sourceIndex < 0 || targetIndex < 0 || sourceIndex == targetIndex) {
        return;
      }
      final option = options.removeAt(sourceIndex);
      options.insert(targetIndex, option);
      if (options.last.name.trim().isNotEmpty) {
        options.add(_ClassificationOptionDraft(id: _nextDraftId()));
      }
      _regenerateVariants(notify: false);
    });
  }

  Future<void> _chooseColorImage(_ClassificationOptionDraft option) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      option.image = _PendingColorImage(bytes: bytes, fileName: image.name);
    });
  }

  void _removeColorImage(_ClassificationOptionDraft option) {
    setState(() => option.image = null);
  }

  void _regenerateVariants({bool notify = true}) {
    final oldVariants = List<_PendingVariant>.from(_pendingVariants);
    final oldByKey = {
      ..._variantCache,
      for (final variant in oldVariants) variant.combinationKey: variant,
    };
    _variantCache.clear();
    final optionGroups = _classificationGroups
        .map((group) => group.filledOptions)
        .toList();
    final generated = <_PendingVariant>[];

    if (optionGroups.isNotEmpty &&
        optionGroups.every((options) => options.isNotEmpty)) {
      void buildCombination(
        int groupIndex,
        List<_ClassificationOptionDraft> selected,
      ) {
        if (groupIndex == optionGroups.length) {
          final optionIds = selected.map((option) => option.id).toList();
          final key = _combinationKey(optionIds);
          final values = selected.map((option) => option.name.trim()).toList();
          final existing = oldByKey.remove(key);
          if (existing != null) {
            existing
              ..optionIds = optionIds
              ..optionValues = values;
            generated.add(existing);
          } else {
            _PendingVariant? source;
            for (final candidate in oldVariants) {
              final sharedLength = candidate.optionIds.length < optionIds.length
                  ? candidate.optionIds.length
                  : optionIds.length;
              var samePrefix = sharedLength > 0;
              for (var index = 0; index < sharedLength; index++) {
                if (candidate.optionIds[index] != optionIds[index]) {
                  samePrefix = false;
                  break;
                }
              }
              if (samePrefix) {
                source = candidate;
                break;
              }
            }
            generated.add(
              _PendingVariant(
                combinationKey: key,
                optionIds: optionIds,
                optionValues: values,
                price:
                    source?.price ??
                    double.tryParse(_basePriceController.text.trim()) ??
                    0,
                stockQuantity: source?.stockQuantity ?? 0,
                isActive: source?.isActive ?? true,
              ),
            );
          }
          return;
        }

        for (final option in optionGroups[groupIndex]) {
          buildCombination(groupIndex + 1, [...selected, option]);
        }
      }

      buildCombination(0, []);
    }

    _variantCache.addAll(oldByKey);
    _pendingVariants
      ..clear()
      ..addAll(generated);
    if (notify && mounted) setState(() {});
  }

  String? _variantImageUrl(_PendingVariant variant) {
    if (_classificationGroups.isEmpty ||
        !_isColorGroup(_classificationGroups.first.name) ||
        variant.optionIds.isEmpty) {
      return null;
    }
    final colorOptionId = variant.optionIds.first;
    for (final option in _classificationGroups.first.filledOptions) {
      if (option.id == colorOptionId) return option.image?.imageUrl;
    }
    return null;
  }

  bool _validateClassifications() {
    String? message;
    if (_classificationGroups.isEmpty || _classificationGroups.length > 2) {
      message = 'Product must have one or two classification groups.';
    }

    final groupNames = <String>{};
    for (final group in _classificationGroups) {
      if (message != null) break;
      if (group.name.trim().isEmpty) {
        message = 'Classification name is required.';
        break;
      }
      if (!groupNames.add(group.name.trim().toLowerCase())) {
        message = 'Classification names cannot be duplicated.';
        break;
      }
      if (group.filledOptions.isEmpty) {
        message = 'Each classification must have at least one option.';
        break;
      }
      final names = <String>{};
      for (final option in group.filledOptions) {
        final name = option.name.trim().toLowerCase();
        if (!names.add(name)) {
          message = 'Option names cannot be duplicated in the same group.';
          break;
        }
      }
    }

    if (message == null && _pendingVariants.isEmpty) {
      message = 'No variants were generated.';
    }
    if (message == null) {
      for (final variant in _pendingVariants) {
        if (variant.price < 0 || variant.stockQuantity < 0) {
          message = 'Variant price and stock must be 0 or greater.';
          break;
        }
      }
    }

    if (message == null) return true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    return false;
  }

  void _applyBulkStock() {
    if (_pendingVariants.isEmpty) return;

    final text = _bulkStockController.text.trim();
    if (_bulkStockHadNegativeInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tồn kho không được nhỏ hơn 0.')),
      );
      return;
    }
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lượng tồn kho.')),
      );
      return;
    }

    final stock = int.tryParse(text);
    if (stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tồn kho phải là số nguyên không âm.')),
      );
      return;
    }
    if (stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tồn kho không được nhỏ hơn 0.')),
      );
      return;
    }

    setState(() {
      for (final variant in _pendingVariants) {
        variant.stockController.text = stock.toString();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã áp dụng tồn kho cho tất cả phân loại.')),
    );
  }

  Widget _buildBulkStockControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final stockField = TextField(
          controller: _bulkStockController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.contains('-')) {
                _bulkStockHadNegativeInput = true;
                return oldValue;
              }
              _bulkStockHadNegativeInput = false;
              return RegExp(r'^\d*$').hasMatch(newValue.text)
                  ? newValue
                  : oldValue;
            }),
          ],
          decoration: const InputDecoration(
            labelText: 'Nhập tồn kho chung',
            hintText: 'Ví dụ: 100',
            prefixIcon: Icon(Icons.inventory_2_outlined),
            isDense: true,
          ),
          onSubmitted: (_) => _applyBulkStock(),
        );
        final applyButton = ElevatedButton.icon(
          onPressed: _isSubmitting || _pendingVariants.isEmpty
              ? null
              : _applyBulkStock,
          icon: const Icon(Icons.done_all),
          label: const Text('Áp dụng cho tất cả'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [stockField, const SizedBox(height: 10), applyButton],
          );
        }

        return Row(
          children: [
            SizedBox(width: 280, child: stockField),
            const SizedBox(width: 12),
            applyButton,
          ],
        );
      },
    );
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
          const _SectionTitle('Phân loại hàng'),
          const Text(
            'Tạo tối đa 2 nhóm phân loại. Danh sách variant sẽ được sinh tự động theo các tùy chọn.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          ..._classificationGroups.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildClassificationGroup(entry.key),
            ),
          ),
          if (_classificationGroups.length < 2)
            SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: const Color(0xFFEE4D2D),
                  radius: 10,
                ),
                child: TextButton.icon(
                  onPressed: _isSubmitting ? null : _addClassificationGroup,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm nhóm phân loại 2'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEE4D2D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          if (_isLoadingVariants) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
          ],
          if (_pendingVariants.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Danh sách phân loại hàng'),
            const SizedBox(height: 12),
            _buildBulkStockControls(),
            const SizedBox(height: 12),
            _buildVariantTable(),
          ],
        ],
      ),
    );
  }

  Widget _buildClassificationGroup(int groupIndex) {
    final group = _classificationGroups[groupIndex];
    final showColorImage = groupIndex == 0 && _isColorGroup(group.name);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Phân loại ${groupIndex + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (_classificationGroups.length > 1)
                IconButton(
                  tooltip: 'Xóa nhóm phân loại',
                  onPressed: _isSubmitting
                      ? null
                      : () => _removeClassificationGroup(groupIndex),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: group.nameController,
            onChanged: (_) => _onGroupNameChanged(),
            decoration: const InputDecoration(
              labelText: 'Tên phân loại',
              hintText: 'Ví dụ: Màu Sắc, Size',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tùy chọn', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 680;
              final itemWidth = twoColumns
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: group.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final option = entry.value;
                  final isBlank =
                      option.name.trim().isEmpty &&
                      optionIndex == group.options.length - 1;
                  return SizedBox(
                    width: itemWidth,
                    child: DragTarget<_OptionDragData>(
                      onWillAcceptWithDetails: (details) =>
                          details.data.groupIndex == groupIndex &&
                          details.data.optionId != option.id,
                      onAcceptWithDetails: (details) =>
                          _reorderClassificationOption(
                            groupIndex,
                            details.data.optionId,
                            option.id,
                          ),
                      builder: (context, candidates, _) => Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: candidates.isEmpty
                              ? Colors.white
                              : const Color(0xFFFFEEE9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE1E1E1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                LongPressDraggable<_OptionDragData>(
                                  data: _OptionDragData(
                                    groupIndex: groupIndex,
                                    optionId: option.id,
                                  ),
                                  feedback: const Material(
                                    color: Colors.transparent,
                                    child: Icon(Icons.drag_indicator),
                                  ),
                                  child: Icon(
                                    Icons.drag_indicator,
                                    color: isBlank
                                        ? Colors.black26
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: option.nameController,
                                    onChanged: (_) => _onOptionChanged(
                                      groupIndex,
                                      optionIndex,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Nhập',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: option.descriptionController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: 'Thêm mô tả',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                if (!isBlank)
                                  IconButton(
                                    tooltip: 'Xóa tùy chọn',
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _removeClassificationOption(
                                            groupIndex,
                                            optionIndex,
                                          ),
                                    icon: const Icon(Icons.close, size: 20),
                                  ),
                              ],
                            ),
                            if (showColorImage && !isBlank) ...[
                              const SizedBox(height: 10),
                              _buildColorImageAssignment(option),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorImageAssignment(_ClassificationOptionDraft option) {
    final image = option.image;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: image?.bytes != null
              ? Image.memory(image!.bytes!, fit: BoxFit.cover)
              : image?.imageUrl != null
              ? Image.network(
                  AppConfig.resolveImageUrl(image!.imageUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                )
              : const Icon(Icons.image_outlined),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : () => _chooseColorImage(option),
          icon: const Icon(Icons.upload_outlined, size: 18),
          label: Text(image == null ? 'Chọn ảnh màu' : 'Đổi ảnh'),
        ),
        if (image != null)
          IconButton(
            tooltip: 'Xóa ảnh màu',
            onPressed: _isSubmitting ? null : () => _removeColorImage(option),
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }

  Widget _buildVariantTable() {
    final showImage =
        _classificationGroups.isNotEmpty &&
        _isColorGroup(_classificationGroups.first.name);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
          columns: [
            const DataColumn(label: Text('Phân loại')),
            const DataColumn(label: Text('Giá')),
            const DataColumn(label: Text('Số lượng tồn kho')),
            const DataColumn(label: Text('SKU')),
            const DataColumn(label: Text('Trạng thái')),
            if (showImage) const DataColumn(label: Text('Ảnh')),
          ],
          rows: _pendingVariants.map((variant) {
            final colorImage = _variantColorImage(variant);
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      variant.optionValues.join(' / '),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: variant.priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: variant.stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: variant.skuController,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ),
                DataCell(
                  Switch(
                    value: variant.isActive,
                    onChanged: _isSubmitting
                        ? null
                        : (value) => setState(() => variant.isActive = value),
                  ),
                ),
                if (showImage)
                  DataCell(
                    Container(
                      width: 46,
                      height: 46,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: colorImage?.bytes != null
                          ? Image.memory(colorImage!.bytes!, fit: BoxFit.cover)
                          : colorImage?.imageUrl != null
                          ? Image.network(
                              AppConfig.resolveImageUrl(colorImage!.imageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image, size: 20),
                            )
                          : const Icon(Icons.image_outlined, size: 20),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  _PendingColorImage? _variantColorImage(_PendingVariant variant) {
    if (_classificationGroups.isEmpty || variant.optionIds.isEmpty) return null;
    final optionId = variant.optionIds.first;
    for (final option in _classificationGroups.first.filledOptions) {
      if (option.id == optionId) return option.image;
    }
    return null;
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _goToImages,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Manage Images'),
                    ),
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
                        const SizedBox(height: 10),
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
                ] else ...[
                  const SizedBox(height: 16),
                  _buildCreateVariantsSection(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting || _isLoadingVariants
                              ? null
                              : _submitEdit,
                          child: _isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text('Save product and variants'),
                        ),
                      ),
                    ],
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
  final int? variantId;
  String combinationKey;
  List<int> optionIds;
  List<String> optionValues;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController skuController;
  bool isActive;

  _PendingVariant({
    this.variantId,
    required this.combinationKey,
    required this.optionIds,
    required this.optionValues,
    required double price,
    required int stockQuantity,
    String? sku,
    required this.isActive,
  }) : priceController = TextEditingController(text: _numberText(price)),
       stockController = TextEditingController(text: stockQuantity.toString()),
       skuController = TextEditingController(text: sku ?? '');

  double get price => double.tryParse(priceController.text.trim()) ?? -1;
  int get stockQuantity => int.tryParse(stockController.text.trim()) ?? -1;
  String? get sku {
    final value = skuController.text.trim();
    return value.isEmpty ? null : value;
  }

  void dispose() {
    priceController.dispose();
    stockController.dispose();
    skuController.dispose();
  }

  static String _numberText(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

class _ClassificationGroupDraft {
  final int id;
  final TextEditingController nameController;
  final List<_ClassificationOptionDraft> options;

  _ClassificationGroupDraft({
    required this.id,
    String name = '',
    required this.options,
  }) : nameController = TextEditingController(text: name);

  String get name => nameController.text;
  List<_ClassificationOptionDraft> get filledOptions =>
      options.where((option) => option.name.trim().isNotEmpty).toList();

  void dispose() {
    nameController.dispose();
    for (final option in options) {
      option.dispose();
    }
  }
}

class _ClassificationOptionDraft {
  final int id;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  _PendingColorImage? image;

  _ClassificationOptionDraft({
    required this.id,
    String name = '',
    String description = '',
    this.image,
  }) : nameController = TextEditingController(text: name),
       descriptionController = TextEditingController(text: description);

  String get name => nameController.text;
  String get description => descriptionController.text;

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}

class _OptionDragData {
  final int groupIndex;
  final int optionId;

  const _OptionDragData({required this.groupIndex, required this.optionId});
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _PendingColorImage {
  final Uint8List? bytes;
  final String? fileName;
  final String? imageUrl;

  const _PendingColorImage({this.bytes, this.fileName, this.imageUrl});
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
