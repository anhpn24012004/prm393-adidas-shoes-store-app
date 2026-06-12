import 'package:flutter/material.dart';

import '../../models/product_detail_model.dart';
import '../../services/product_service.dart';

class AdminVariantFormScreen extends StatefulWidget {
  final int productId;
  final ProductVariantModel? variant;

  const AdminVariantFormScreen({
    super.key,
    required this.productId,
    this.variant,
  });

  @override
  State<AdminVariantFormScreen> createState() => _AdminVariantFormScreenState();
}

class _AdminVariantFormScreenState extends State<AdminVariantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();

  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();

  bool _isActive = true;
  bool _isSubmitting = false;

  bool get isEditMode => widget.variant != null;

  @override
  void initState() {
    super.initState();

    final variant = widget.variant;

    if (variant != null) {
      _sizeController.text = variant.size;
      _colorController.text = variant.color;
      _priceController.text = variant.price.toStringAsFixed(0);
      _stockController.text = variant.stockQuantity.toString();
      _skuController.text = variant.sku ?? '';
      _isActive = variant.isActive;
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final size = _sizeController.text.trim();
      final color = _colorController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stockQuantity = int.parse(_stockController.text.trim());
      final sku = _skuController.text.trim();

      if (isEditMode) {
        await _productService.updateVariant(
          variantId: widget.variant!.variantId,
          size: size,
          color: color,
          price: price,
          stockQuantity: stockQuantity,
          sku: sku.isEmpty ? null : sku,
          isActive: _isActive,
        );
      } else {
        await _productService.createVariant(
          productId: widget.productId,
          size: size,
          color: color,
          price: price,
          stockQuantity: stockQuantity,
          sku: sku.isEmpty ? null : sku,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Variant updated successfully'
                : 'Variant created successfully',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (requiredField && text.isEmpty) {
          return '$label is required';
        }

        if (label == 'Price') {
          final price = double.tryParse(text);
          if (price == null || price < 0) {
            return 'Price must be a valid number';
          }
        }

        if (label == 'Stock Quantity') {
          final stock = int.tryParse(text);
          if (stock == null || stock < 0) {
            return 'Stock quantity must be a valid number';
          }
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit Variant' : 'Create Variant';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _sizeController,
                    label: 'Size',
                    requiredField: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _colorController,
                    label: 'Color',
                    requiredField: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    requiredField: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stockController,
                    label: 'Stock Quantity',
                    requiredField: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _skuController, label: 'SKU'),
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
                              isEditMode ? 'Update Variant' : 'Create Variant',
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
