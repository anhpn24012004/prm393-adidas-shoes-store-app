import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();

  late Future<List<CategoryModel>> _categoriesFuture;

  int? _selectedCategoryId;
  bool _isActive = true;
  bool _isSubmitting = false;

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
      _genderController.text = product.gender ?? '';
      _materialController.text = product.material ?? '';
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
    _genderController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select category')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final productName = _productNameController.text.trim();
      final description = _descriptionController.text.trim();
      final basePrice = double.parse(_basePriceController.text.trim());
      final brand = _brandController.text.trim();
      final gender = _genderController.text.trim();
      final material = _materialController.text.trim();

      if (isEditMode) {
        await _productService.updateProduct(
          productId: widget.product!.productId,
          productName: productName,
          description: description,
          basePrice: basePrice,
          categoryId: _selectedCategoryId!,
          brand: brand,
          gender: gender,
          material: material,
          isActive: _isActive,
        );
      } else {
        await _productService.createProduct(
          productName: productName,
          description: description,
          basePrice: basePrice,
          categoryId: _selectedCategoryId!,
          brand: brand,
          gender: gender,
          material: material,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Product updated successfully'
                : 'Product created successfully',
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

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text('Failed to load categories: ${snapshot.error}');
        }

        final categories = snapshot.data ?? [];

        return DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.categoryId,
              child: Text(category.categoryName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select category';
            }
            return null;
          },
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }

        if (label == 'Base Price') {
          final price = double.tryParse(value ?? '');
          if (price == null || price < 0) {
            return 'Base price must be a valid number';
          }
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit Product' : 'Create Product';

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
                  _buildTextField(
                    controller: _productNameController,
                    label: 'Product Name',
                    requiredField: true,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _basePriceController,
                    label: 'Base Price',
                    requiredField: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),

                  _buildTextField(controller: _brandController, label: 'Brand'),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _genderController,
                    label: 'Gender',
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _materialController,
                    label: 'Material',
                  ),
                  const SizedBox(height: 16),

                  if (isEditMode)
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
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
                          : Text(
                              isEditMode ? 'Update Product' : 'Create Product',
                            ),
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
